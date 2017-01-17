/*===============================================================================
 Copyright (c) 2016 PTC Inc. All Rights Reserved.
 
 Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of PTC Inc., registered in the United States and other
 countries.
 ===============================================================================*/

#import "SampleAppRenderer.h"
#import <UIKit/UIKit.h>

#import <Vuforia/UIGLViewProtocol.h>
#import <Vuforia/Renderer.h>
#import <Vuforia/CameraDevice.h>
#import <Vuforia/Vuforia.h>
#import <Vuforia/TrackerManager.h>
#import <Vuforia/Tool.h>
#import <Vuforia/ObjectTracker.h>
#import <Vuforia/Vuforia.h>
#import <Vuforia/TrackerManager.h>
#import <Vuforia/State.h>
#import <Vuforia/Tool.h>
#import <Vuforia/ObjectTracker.h>
#import <Vuforia/RotationalDeviceTracker.h>
#import <Vuforia/StateUpdater.h>
#import <Vuforia/Renderer.h>
#import <Vuforia/GLRenderer.h>


#import "Texture.h"
#import "SampleApplicationUtils.h"
#import "SampleApplicationShaderUtils.h"


@interface SampleAppRenderer ()

@property (nonatomic, readwrite) Vuforia::Device::MODE deviceMode;
@property (nonatomic, readwrite) bool stereo;

// SampleApplicationControl delegate (receives callbacks in response to particular
// events, such as completion of Vuforia initialisation)
@property (nonatomic, assign) id control;

// Video background shader
@property (nonatomic, readwrite) GLuint vbShaderProgramID;
@property (nonatomic, readwrite) GLint vbVertexHandle;
@property (nonatomic, readwrite) GLint vbTexCoordHandle;
@property (nonatomic, readwrite) GLint vbTexSampler2DHandle;
@property (nonatomic, readwrite) GLint vbProjectionMatrixHandle;
@property (nonatomic, readwrite) CGFloat nearPlane;
@property (nonatomic, readwrite) CGFloat farPlane;
@property (nonatomic, readwrite) Vuforia::VIEW currentView;

@end


@implementation SampleAppRenderer
{
  UIImage *_cameraBuffer;
}


- (id)initWithSampleAppRendererControl:(id<SampleAppRendererControl>)control deviceMode:(Vuforia::Device::MODE)deviceMode stereo:(bool)stereo {
    self = [super init];
    if (self) {
        self.control = control;
        self.stereo = stereo;
        self.deviceMode = deviceMode;
        self.nearPlane = 50.0f;
        self.farPlane = 5000.0f;
        
        Vuforia::Device& device = Vuforia::Device::getInstance();
        if (!device.setMode(self.deviceMode)) {
            NSLog(@"ERROR: failed to set the device mode");
        };
        device.setViewerActive(self.stereo);
    }
    return self;
}

- (void) initRendering {
    // Video background rendering
    self.vbShaderProgramID = [SampleApplicationShaderUtils createProgramWithVertexShaderFileName:@"Background.vertsh"
                                                                     fragmentShaderFileName:@"Background.fragsh"];
    
    if (0 < self.vbShaderProgramID) {
        self.vbVertexHandle = glGetAttribLocation(self.vbShaderProgramID, "vertexPosition");
        self.vbTexCoordHandle = glGetAttribLocation(self.vbShaderProgramID, "vertexTexCoord");
        self.vbProjectionMatrixHandle = glGetUniformLocation(self.vbShaderProgramID, "projectionMatrix");
        self.vbTexSampler2DHandle = glGetUniformLocation(self.vbShaderProgramID, "texSampler2D");
    }
    else {
        NSLog(@"Could not initialise video background shader");
    }
    
}


- (void) setNearPlane:(CGFloat) near farPlane:(CGFloat) far {
    self.nearPlane = near;
    self.farPlane = far;
}


// Draw the current frame using OpenGL
//
// This method is called by Vuforia when it wishes to render the current frame to
// the screen.
//
// *** Vuforia will call this method periodically on a background thread ***
- (void)renderFrameVuforia
{
    Vuforia::Renderer& mRenderer = Vuforia::Renderer::getInstance();
    
    const Vuforia::State state = Vuforia::TrackerManager::getInstance().getStateUpdater().updateState();
    mRenderer.begin(state);
    
    const Vuforia::RenderingPrimitives renderingPrimitives = Vuforia::Device::getInstance().getRenderingPrimitives();
    Vuforia::ViewList& viewList = renderingPrimitives.getRenderingViews();
    
    // Clear colour and depth buffers
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    // Iterate over the ViewList
    for (int viewIdx = 0; viewIdx < viewList.getNumViews(); viewIdx++) {
        Vuforia::VIEW vw = viewList.getView(viewIdx);
        self.currentView = vw;
        
        // Set up the viewport
        Vuforia::Vec4I viewport;
        // We're writing directly to the screen, so the viewport is relative to the screen
        viewport = renderingPrimitives.getViewport(vw);
        
        // Set viewport for current view
        glViewport(viewport.data[0], viewport.data[1], viewport.data[2], viewport.data[3]);
        
        //set scissor
        glScissor(viewport.data[0], viewport.data[1], viewport.data[2], viewport.data[3]);
        
        Vuforia::Matrix34F projMatrix = renderingPrimitives.getProjectionMatrix(vw,
                                                                                Vuforia::COORDINATE_SYSTEM_CAMERA);
        
        Vuforia::Matrix44F rawProjectionMatrixGL = Vuforia::Tool::convertPerspectiveProjection2GLMatrix(
                                                                                                        projMatrix,
                                                                                                        self.nearPlane,
                                                                                                        self.farPlane);
        
        // Apply the appropriate eye adjustment to the raw projection matrix, and assign to the global variable
        Vuforia::Matrix44F eyeAdjustmentGL = Vuforia::Tool::convert2GLMatrix(renderingPrimitives.getEyeDisplayAdjustmentMatrix(vw));
        
        Vuforia::Matrix44F projectionMatrix;
        SampleApplicationUtils::multiplyMatrix(&rawProjectionMatrixGL.data[0], &eyeAdjustmentGL.data[0], &projectionMatrix.data[0]);
        
        if (self.currentView != Vuforia::VIEW_POSTPROCESS) {
            [self.control renderFrameWithState:state projectMatrix:projectionMatrix];
        }
        
        glDisable(GL_SCISSOR_TEST);
        
    }
    
    mRenderer.end();
    
}

- (void)renderVideoBackground {
  [self renderVideoBackgroundWithScreenSize:CGSizeZero];
}

- (void)renderVideoBackgroundWithScreenSize:(CGSize)screenSize {
  if (self.currentView == Vuforia::VIEW_POSTPROCESS) {
    return;
  }
  
  // Use texture unit 0 for the video background - this will hold the camera frame and we want to reuse for all views
  // So need to use a different texture unit for the augmentation
  int vbVideoTextureUnit = 0;
  
  // Bind the video bg texture and get the Texture ID from Vuforia
  Vuforia::GLTextureUnit tex;
  tex.mTextureUnit = vbVideoTextureUnit;
  
  if (! Vuforia::Renderer::getInstance().updateVideoBackgroundTexture(&tex))
  {
    NSLog(@"Unable to bind video background texture!!");
    return;
  }
  const Vuforia::RenderingPrimitives renderingPrimitives = Vuforia::Device::getInstance().getRenderingPrimitives();
  
  Vuforia::Matrix44F vbProjectionMatrix = Vuforia::Tool::convert2GLMatrix(
                                                                          renderingPrimitives.getVideoBackgroundProjectionMatrix(self.currentView, Vuforia::COORDINATE_SYSTEM_CAMERA));
  
  // Apply the scene scale on video see-through eyewear, to scale the video background and augmentation
  // so that the display lines up with the real world
  // This should not be applied on optical see-through devices, as there is no video background,
  // and the calibration ensures that the augmentation matches the real world
  if (Vuforia::Device::getInstance().isViewerActive())
  {
    float sceneScaleFactor = [self getSceneScaleFactor];
    SampleApplicationUtils::scalePoseMatrix(sceneScaleFactor, sceneScaleFactor, 1.0f, vbProjectionMatrix.data);
  }
  
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_CULL_FACE);
  glDisable(GL_SCISSOR_TEST);
  
  
  
  const Vuforia::Mesh& vbMesh = renderingPrimitives.getVideoBackgroundMesh(self.currentView);
  // Load the shader and upload the vertex/texcoord/index data
  glUseProgram(self.vbShaderProgramID);
  glVertexAttribPointer(self.vbVertexHandle, 3, GL_FLOAT, false, 0, vbMesh.getPositionCoordinates());
  glVertexAttribPointer(self.vbTexCoordHandle, 2, GL_FLOAT, false, 0, vbMesh.getUVCoordinates());
  
  glUniform1i(self.vbTexSampler2DHandle, vbVideoTextureUnit);
  
  // Render the video background with the custom shader
  // First, we enable the vertex arrays
  glEnableVertexAttribArray(self.vbVertexHandle);
  glEnableVertexAttribArray(self.vbTexCoordHandle);
  
  // Pass the projection matrix to OpenGL
  glUniformMatrix4fv(self.vbProjectionMatrixHandle, 1, GL_FALSE, vbProjectionMatrix.data);
  
  // Then, we issue the render call
  glDrawElements(GL_TRIANGLES, vbMesh.getNumTriangles() * 3, GL_UNSIGNED_SHORT,
                 vbMesh.getTriangles());
  
  // Finally, we disable the vertex arrays
  glDisableVertexAttribArray(self.vbVertexHandle);
  glDisableVertexAttribArray(self.vbTexCoordHandle);
  
  _cameraBuffer = [self grabFrameBuffer:screenSize];
  
  SampleApplicationUtils::checkGlError("Rendering of the video background failed");
}

- (UIImage *)grabFrameBuffer:(CGSize)screenSize
{
  int width = screenSize.width, height = screenSize.height;
  
  int myDataLength = width * height * sizeof(GLubyte) * 4;
  
  GLubyte* pixels = (GLubyte*) malloc(myDataLength);
  glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
  
  // make data provider with data.
  CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, pixels, myDataLength, NULL);
  // prep the ingredients
  int bitsPerComponent = 8;
  int bitsPerPixel = 32;
  int bytesPerRow = 4 * width;
  CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
  CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
  CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
  // make the cgimage
  CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
  
  UIGraphicsBeginImageContext(screenSize);
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextDrawImage(context, CGRectMake(0, 0, screenSize.width, screenSize.height), imageRef);
  
  CGImageRef imgRef = CGBitmapContextCreateImage(context);
  
  UIImage* img = [UIImage imageWithCGImage:imgRef scale:1.0f orientation:UIImageOrientationUp];
  
  CGImageRelease(imgRef);
  CGContextRelease(context);
  
  CGImageRelease( imageRef );
  CGDataProviderRelease(provider);
  CGColorSpaceRelease(colorSpaceRef);
  free(pixels);
  
  return img;
}

- (UIImage *)grabCameraBufferForTextDetection
{
  int vuforiaLogoHeight = 100;
  return [self cropImage:_cameraBuffer toRect:CGRectMake(0, 0,  _cameraBuffer.size.width,  _cameraBuffer.size.height - vuforiaLogoHeight)];
}

- (UIImage *)cropImage:(UIImage *)imageToCrop toRect:(CGRect)rect
{
  CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
  UIImage *cropped = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  
  return cropped;
}

- (void)setImageViewToBackground:(UIImageView *)imageView withCroppingPath:(NSArray *)croppingPath
{
  imageView.image = _cameraBuffer;
  
  UIBezierPath *aPath = [UIBezierPath bezierPath];
  
  bool first = true;
  for (NSValue *pValue in croppingPath) {
    CGPoint point = [pValue CGPointValue];
    if (first) {
      [aPath moveToPoint:point];
      first = false;
    } else {
      [aPath addLineToPoint:point];
    }
  }
  
  [aPath closePath];
  CAShapeLayer *shapeLayer = [CAShapeLayer layer];
  shapeLayer.path = aPath.CGPath;
  [imageView.layer setMask:shapeLayer];
}


-(float) getSceneScaleFactor
{
    static const float VIRTUAL_FOV_Y_DEGS = 85.0f;
    
    // Get the y-dimension of the physical camera field of view
    Vuforia::Vec2F fovVector = Vuforia::CameraDevice::getInstance().getCameraCalibration().getFieldOfViewRads();
    float cameraFovYRads = fovVector.data[1];
    
    // Get the y-dimension of the virtual camera field of view
    float virtualFovYRads = VIRTUAL_FOV_Y_DEGS * M_PI / 180;
    
    // The scene-scale factor represents the proportion of the viewport that is filled by
    // the video background when projected onto the same plane.
    // In order to calculate this, let 'd' be the distance between the cameras and the plane.
    // The height of the projected image 'h' on this plane can then be calculated:
    //   tan(fov/2) = h/2d
    // which rearranges to:
    //   2d = h/tan(fov/2)
    // Since 'd' is the same for both cameras, we can combine the equations for the two cameras:
    //   hPhysical/tan(fovPhysical/2) = hVirtual/tan(fovVirtual/2)
    // Which rearranges to:
    //   hPhysical/hVirtual = tan(fovPhysical/2)/tan(fovVirtual/2)
    // ... which is the scene-scale factor
    return tan(cameraFovYRads / 2) / tan(virtualFovYRads / 2);
}

@end
