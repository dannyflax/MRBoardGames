/*===============================================================================
 Copyright (c) 2016 PTC Inc. All Rights Reserved.
 
 Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of PTC Inc., registered in the United States and other
 countries.
 ===============================================================================*/

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <sys/time.h>

#import <Vuforia/Vuforia.h>
#import <Vuforia/State.h>
#import <Vuforia/Tool.h>
#import <Vuforia/Renderer.h>
#import <Vuforia/TrackableResult.h>
#import <Vuforia/VideoBackgroundConfig.h>

#import "ImageTargetsEAGLView.h"
#import "Texture.h"
#import "SampleApplicationUtils.h"
#import "SampleApplicationShaderUtils.h"
#import "Teapot.h"
#import "Quad.h"
#import "ChessObject.h"
#import "CollisionChecker.h"
#import "ChessPiecesFactory.h"


//******************************************************************************
// *** OpenGL ES thread safety ***
//
// OpenGL ES on iOS is not thread safe.  We ensure thread safety by following
// this procedure:
// 1) Create the OpenGL ES context on the main thread.
// 2) Start the Vuforia camera, which causes Vuforia to locate our EAGLView and start
//    the render thread.
// 3) Vuforia calls our renderFrameVuforia method periodically on the render thread.
//    The first time this happens, the defaultFramebuffer does not exist, so it
//    is created with a call to createFramebuffer.  createFramebuffer is called
//    on the main thread in order to safely allocate the OpenGL ES storage,
//    which is shared with the drawable layer.  The render (background) thread
//    is blocked during the call to createFramebuffer, thus ensuring no
//    concurrent use of the OpenGL ES context.
//
//******************************************************************************


namespace {
  // --- Data private to this unit ---
  
  // Teapot texture filenames
  const char* textureFilenames[] = {
    "TextureTeapotBrass.png",
    "TextureTeapotBlue.png",
    "TextureTeapotRed.png",
    "building_texture.jpeg"
  };
}

static const float kBoardSize = 200;
static const float kBoardPadding = 50.0;

static float kRedColor[3] =   {1.0, 0.0, 0.0};
static float kGreenColor[3] = {0.0, 1.0, 0.0};
static float kBlueColor[3] = {0.0, 1.0, 1.0};
static float kWhiteColor[3] = {1.0, 1.0, 1.0};
static float kBlackColor[3] = {.3, 0.3, 0.3};

@interface ImageTargetsEAGLView (PrivateMethods)

- (void)initShaders;
- (void)createFramebuffer;
- (void)deleteFramebuffer;
- (void)setFramebuffer;
- (BOOL)presentFramebuffer;

@end

@implementation ImageTargetsEAGLView
{
  ChessObject *_collidingObject;
  ChessObject *_grabbedObject;
  bool _grabMode;
  Point3D *_grabObjPos;
  Point3D *_grabCursorPos;
  NSDictionary<NSString *, id> *_pieceMeshMap;
  SessionObject *_sessionObject;
  NSString *_gameID;
  NSString *_playerID;
  bool _networkless;
  UILabel *_gameIDLabel;
}

@synthesize vapp = vapp;

// You must implement this method, which ensures the view's underlying layer is
// of type CAEAGLLayer
+ (Class)layerClass
{
  return [CAEAGLLayer class];
}


//------------------------------------------------------------------------------
#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame gamePieces:(NSMutableArray <ChessObject*> *)chessObjects appSession:(SampleApplicationSession *)app
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _chessPieces = chessObjects;
        [self configureView:app];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame appSession:(SampleApplicationSession *)app
{
  self = [super initWithFrame:frame];
  
  if (self) {
      _gameIDLabel = [UILabel new];
      CGRect frm = _gameIDLabel.frame;
      frm.origin = CGPointMake(5.0, 5.0);
      _gameIDLabel.frame = frm;
      [_gameIDLabel setTextColor:[UIColor colorWithWhite:1.0 alpha:0.7]];
      [self addSubview:_gameIDLabel];
      [self configureView:app];
  }
  
  return self;
}

- (void)startGameWithID:(NSString *)gameID playerID:(NSString *)playerID networkless:(bool)networkless sessionObject:(SessionObject *)sessionObject gameState:(NSArray *)gameState
{
  _sessionObject = sessionObject;
  sessionObject.gameDelegate = self;
  if (networkless) {
    _chessPieces = [NSMutableArray arrayWithArray:[ChessPiecesFactory createNewChessGame]];
  } else {
    _chessPieces = [NSMutableArray arrayWithArray:gameState];
  }
  _gameID = gameID;
  _playerID = playerID;
  _networkless = networkless;
  [_gameIDLabel setText:_gameID];
  [_gameIDLabel sizeToFit];
}

- (void)gameStateUpdated:(NSArray *)objectList playerID:(NSString *)playerID success:(BOOL)success
{
  if ([playerID isEqualToString:playerID] && success) {
    return;
  }
  
  for (ChessObject *baseObj in objectList) {
    for (ChessObject *baseObj2 in _chessPieces) {
      if ([baseObj2.name isEqualToString:baseObj.name] && baseObj2 != _grabbedObject) {
        baseObj2.location = baseObj.location;
      }
    }
  }
}

- (void)configureView:(SampleApplicationSession *)app {
    NSString *filePathName = [[NSBundle mainBundle] pathForResource:@"monkey" ofType:@"obj"];
    monkeySource = loadFile([filePathName cStringUsingEncoding:NSASCIIStringEncoding]);
    
    filePathName = [[NSBundle mainBundle] pathForResource:@"queen-t" ofType:@"obj"];
    queenSource = loadFile([filePathName cStringUsingEncoding:NSASCIIStringEncoding]);
    
    filePathName = [[NSBundle mainBundle] pathForResource:@"king-t" ofType:@"obj"];
    kingSource = loadFile([filePathName cStringUsingEncoding:NSASCIIStringEncoding]);
    
    filePathName = [[NSBundle mainBundle] pathForResource:@"rook-t" ofType:@"obj"];
    rookSource = loadFile([filePathName cStringUsingEncoding:NSASCIIStringEncoding]);
    
    filePathName = [[NSBundle mainBundle] pathForResource:@"bishop-t" ofType:@"obj"];
    bishopSource = loadFile([filePathName cStringUsingEncoding:NSASCIIStringEncoding]);
    
    filePathName = [[NSBundle mainBundle] pathForResource:@"knight-t" ofType:@"obj"];
    knightSource = loadFile([filePathName cStringUsingEncoding:NSASCIIStringEncoding]);
    
    filePathName = [[NSBundle mainBundle] pathForResource:@"pawn-t" ofType:@"obj"];
    pawnSource = loadFile([filePathName cStringUsingEncoding:NSASCIIStringEncoding]);
    
    _pieceMeshMap = @{
                      kQueenName : [NSValue valueWithPointer:queenSource],
                      kKingName : [NSValue valueWithPointer:kingSource],
                      kRookName : [NSValue valueWithPointer:rookSource],
                      kBishopName : [NSValue valueWithPointer:bishopSource],
                      kKnightName : [NSValue valueWithPointer:knightSource],
                      kPawnName : [NSValue valueWithPointer:pawnSource]
                      };
    
    CGRect scaledBounds = self.bounds;
    scaledBounds.size.width = scaledBounds.size.width / [UIScreen mainScreen].nativeScale;
    scaledBounds.size.height = scaledBounds.size.height / [UIScreen mainScreen].nativeScale;
    
    occlusionView = [[UIImageView alloc] initWithFrame:scaledBounds];
    [occlusionView setBackgroundColor:[UIColor clearColor]];
    [occlusionView setAlpha:0.7];
    
    [self addSubview:occlusionView];
    
    inputHandler = [ARInputHandler new];
    
    inputHandler.delegate = self;
    
    currentViewTexture = -1;
    
    projectedView = [[ARTouchableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200, 200)];
    
    stylusHeld = NO;
    
    vapp = app;
    
    points = [NSMutableArray new];
    
    // Enable retina mode if available on this device
    if (YES == [vapp isRetinaDisplay]) {
        [self setContentScaleFactor:[UIScreen mainScreen].nativeScale];
    }
    
    // Load the augmentation textures
    for (int i = 0; i < kNumAugmentationTextures; ++i) {
        augmentationTexture[i] = [[Texture alloc] initWithImageFile:[NSString stringWithCString:textureFilenames[i] encoding:NSASCIIStringEncoding]];
    }
    
    // Create the OpenGL ES context
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // The EAGLContext must be set for each thread that wishes to use it.
    // Set it the first time this method is called (on the main thread)
    if (context != [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:context];
    }
    
    // Generate the OpenGL ES texture and upload the texture data for use
    // when rendering the augmentation
    for (int i = 0; i < kNumAugmentationTextures; ++i) {
        GLuint textureID;
        glGenTextures(1, &textureID);
        [augmentationTexture[i] setTextureID:textureID];
        glBindTexture(GL_TEXTURE_2D, textureID);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [augmentationTexture[i] width], [augmentationTexture[i] height], 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)[augmentationTexture[i] pngData]);
    }
    
    Texture *chessboardTexture = [[Texture alloc] initWithImageFile:[NSString stringWithCString:"chessboard.jpg" encoding:NSASCIIStringEncoding]];
    
    GLuint textureID;
    glGenTextures(1, &textureID);
    chessboardTextureID = textureID;
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [chessboardTexture width], [chessboardTexture height], 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)[chessboardTexture pngData]);
    
    
    offTargetTrackingEnabled = NO;
    sampleAppRenderer = [[SampleAppRenderer alloc]initWithSampleAppRendererControl:self deviceMode:Vuforia::Device::MODE_AR stereo:false];
    
    [self loadBuildingsModel];
    [self initShaders];
    
    // we initialize the rendering method of the SampleAppRenderer
    [sampleAppRenderer initRendering];
}

- (demoModel *)getMeshForGameObject:(ChessObject *)gameObject
{
  NSValue *ptr = [_pieceMeshMap objectForKey:gameObject.meshName];
  return (demoModel *)[ptr pointerValue];
}


- (GLuint)makeViewOpenGLTexture:(UIView *)view
{
  if (currentViewTexture != -1) {
    glDeleteTextures(1, &currentViewTexture);
  }
  
  
  int width = view.bounds.size.width;
  int height = view.bounds.size.height;
  
  
  GLubyte *pixelBuffer = (GLubyte *)malloc(
                                           4 *
                                           width *
                                           height);
  
  // create a suitable CoreGraphics context
  CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef textureContext =
  CGBitmapContextCreate(pixelBuffer,
                        width, height,
                        8, 4*width,
                        colourSpace,
                        kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  CGColorSpaceRelease(colourSpace);
  
  // draw the view to the buffer
  [view.layer renderInContext:textureContext];
  
  
  
  GLuint textureID;
  //  glGenTextures(<#GLsizei n#>, <#GLuint *textures#>)
  
  glGenTextures(1, &textureID);
  glBindTexture(GL_TEXTURE_2D, textureID);
  
  // these must be defined for non mipmapped nPOT textures (double check)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  
  // upload to OpenGL
  glTexImage2D(GL_TEXTURE_2D, 0,
               GL_RGBA,
               width, height, 0,
               GL_RGBA, GL_UNSIGNED_BYTE, pixelBuffer);
  
  // clean up
  CGContextRelease(textureContext);
  free(pixelBuffer);
  
  currentViewTexture = textureID;
  
  return textureID;
}


- (void)dealloc
{
  [self deleteFramebuffer];
  
  // Tear down context
  if ([EAGLContext currentContext] == context) {
    [EAGLContext setCurrentContext:nil];
  }
  
  for (int i = 0; i < kNumAugmentationTextures; ++i) {
    augmentationTexture[i] = nil;
  }
}


- (void)finishOpenGLESCommands
{
  // Called in response to applicationWillResignActive.  The render loop has
  // been stopped, so we now make sure all OpenGL ES commands complete before
  // we (potentially) go into the background
  if (context) {
    [EAGLContext setCurrentContext:context];
    glFinish();
  }
}


- (void)freeOpenGLESResources
{
  // Called in response to applicationDidEnterBackground.  Free easily
  // recreated OpenGL ES resources
  [self deleteFramebuffer];
  glFinish();
}

- (void) setOffTargetTrackingMode:(BOOL) enabled {
  offTargetTrackingEnabled = enabled;
}

- (void) loadBuildingsModel {
  buildingModel = [[SampleApplication3DModel alloc] initWithTxtResourceName:@"buildings"];
  [buildingModel read];
}


//------------------------------------------------------------------------------
#pragma mark - UIGLViewProtocol methods

// Draw the current frame using OpenGL
//
// This method is called by Vuforia when it wishes to render the current frame to
// the screen.
//
// *** Vuforia will call this method periodically on a background thread ***
- (void)renderFrameVuforia
{
  if (! vapp.cameraIsStarted) {
    return;
  }
  
  [sampleAppRenderer renderFrameVuforia];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  
}

- (CGRect)getCurrentARViewFrame
{
  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  CGRect viewFrame = screenBounds;
  
  // If this device has a retina display, scale the view bounds
  // for the AR (OpenGL) view
  if (YES == vapp.isRetinaDisplay) {
    viewFrame.size.width *= [UIScreen mainScreen].nativeScale;
    viewFrame.size.height *= [UIScreen mainScreen].nativeScale;
  }
  return viewFrame;
}

- (void) renderFrameWithState:(const Vuforia::State&) state projectMatrix:(Vuforia::Matrix44F&) projectionMatrix {
  [self setFramebuffer];
  
  // Clear colour and depth buffers
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  // Render video background and retrieve tracking state
  [sampleAppRenderer renderVideoBackgroundWithScreenSize:[self getCurrentARViewFrame].size];
  
  glEnable(GL_DEPTH_TEST);
  // We must detect if background reflection is active and adjust the culling direction.
  // If the reflection is active, this means the pose matrix has been reflected as well,
  // therefore standard counter clockwise face culling will result in "inside out" models.
  if (offTargetTrackingEnabled) {
    glDisable(GL_CULL_FACE);
  } else {
    glEnable(GL_CULL_FACE);
  }
  glCullFace(GL_BACK);
  if(Vuforia::Renderer::getInstance().getVideoBackgroundConfig().mReflection == Vuforia::VIDEO_BACKGROUND_REFLECTION_ON)
    glFrontFace(GL_CW);  //Front camera
  else
    glFrontFace(GL_CCW);   //Back camera
  
  [inputHandler computeInputFromState:state projectMatrix:projectionMatrix];
  
  _collidingObject = nil;
  
  if ([inputHandler backgroundInSight]) {
    const float boardVertices[3*4]{
      -kBoardSize / 2.0f, -kBoardSize / 2.0f, 0.0,
       kBoardSize / 2.0f, -kBoardSize / 2.0f, 0.0,
       kBoardSize / 2.0f,  kBoardSize / 2.0f, 0.0,
      -kBoardSize / 2.0f,  kBoardSize / 2.0f, 0.0
    };
    
    float objModelView[16];
    float objModelViewProjection[16];
    
    Vuforia::Matrix44F bgModelView = [inputHandler backgroundModelView];
    
    for (int i = 0; i < 16; i++) {
      objModelView[i] = bgModelView.data[i];
    }
    
    float scale = 1.0;
    
    SampleApplicationUtils::translatePoseMatrix(0.0, -(kBoardSize/2 + kBoardPadding), 0.0, objModelView);
    
    SampleApplicationUtils::multiplyMatrix(&projectionMatrix.data[0], objModelView, objModelViewProjection);
    
    [self drawModelWithMvp:objModelViewProjection vertexCoords:(GLvoid *)boardVertices elements:(GLvoid *)quadIndices numElements:kNumQuadIndices normalCoords:(GLvoid *)quadNormals texCoords:(GLvoid *)quadTexCoords hasTexture:YES modelScale:scale textureID:chessboardTextureID color:nil flipped:NO];
    
    for (int i = 0; i < _chessPieces.count; i++) {
      [self drawPiece:[_chessPieces objectAtIndex:i] projectionMatrix:projectionMatrix];
    }
  }
  
  
  if ([inputHandler cursorInSight]) {
    currentPos = [inputHandler currentPos];
    currentPos = [[Point3D alloc] initWithX:-(currentPos.y + kBoardPadding + kBoardSize/2.0f)
                                          Y:currentPos.x
                                          Z:currentPos.z];
    
    
    Vuforia::Matrix44F cursorModelView = [inputHandler cursorModelView];
    
    int vpWidth = static_cast<int>(vapp.viewport.sizeX/[UIScreen mainScreen].nativeScale);
    
    int viewPort[4] = { vapp.viewport.posX, vapp.viewport.posY, static_cast<int>(vapp.viewport.sizeX/[UIScreen mainScreen].nativeScale), static_cast<int>(vapp.viewport.sizeY/[UIScreen mainScreen].nativeScale) };
    
    float point1[3], point2[3], point3[3], point4[3];
    
    float halfWidth = 247.0 / 6.0;
    float halfHeight = 173.0 / 6.0;
    
    SampleApplicationUtils::glhProjectf(-halfWidth, -halfHeight, 0.0f, cursorModelView.data, projectionMatrix.data, viewPort, point1);
    
    SampleApplicationUtils::glhProjectf(halfWidth, -halfHeight, 0.0f, cursorModelView.data, projectionMatrix.data, viewPort, point2);
    
    SampleApplicationUtils::glhProjectf(halfWidth, halfHeight, 0.0f, cursorModelView.data, projectionMatrix.data, viewPort, point3);
    
    SampleApplicationUtils::glhProjectf(-halfWidth, halfHeight, 0.0f, cursorModelView.data, projectionMatrix.data, viewPort, point4);
    
    NSArray *path = [[NSArray alloc] initWithObjects:
                     [NSValue valueWithCGPoint:CGPointMake(vpWidth - point1[0], point1[1])],
                     [NSValue valueWithCGPoint:CGPointMake(vpWidth - point2[0], point2[1])],
                     [NSValue valueWithCGPoint:CGPointMake(vpWidth - point3[0], point3[1])],
                     [NSValue valueWithCGPoint:CGPointMake(vpWidth - point4[0], point4[1])],
                     nil];
    
    [sampleAppRenderer setImageViewToBackground:occlusionView withCroppingPath:path];
    
    float cursorOffset[3] = {-247.0/6.0, 173.0/6.0, 0.0};
    
    float objModelViewProjection[16];
    
    SampleApplicationUtils::translatePoseMatrix(cursorOffset[0],cursorOffset[1],cursorOffset[2],&cursorModelView.data[0]);
    
    SampleApplicationUtils::multiplyMatrix(&projectionMatrix.data[0], &cursorModelView.data[0], objModelViewProjection);
    
    float *monkeyColor = [inputHandler grabbingMode] ? kGreenColor : kRedColor;
    
    if ([inputHandler backgroundInSight]) {
      if (_grabMode && _grabbedObject) {
        Point3D *difference = [[Point3D alloc] initWithX:(currentPos.x - _grabCursorPos.x)
                                                      Y:currentPos.y - _grabCursorPos.y
                                                      Z:currentPos.z - _grabCursorPos.z];
        
        Point3D *newLocation = [[Point3D alloc] initWithX:_grabObjPos.x + difference.x
                                                        Y:_grabObjPos.y + difference.y
                                                        Z:MAX(0, _grabObjPos.z + difference.z)];
        
        [_grabbedObject setLocation:newLocation];
        
        if (!_networkless)
        {
          [_sessionObject sendGameUpdate:_gameID playerID:_playerID unserializedGameStat:_chessPieces holding:_grabbedObject.name];
        }
      } else if (!_grabMode) {
        
        for (int i = 0; i < _chessPieces.count; i++) {
          ChessObject *piece = [_chessPieces objectAtIndex:i];
          bool collides = [CollisionChecker checkCollisionBetweenRectWithCenter:piece.location
                                                                  andDimensions:piece.dimensions
                                                                       andPoint:currentPos];
          if (collides) {
            monkeyColor = kBlueColor;
            _collidingObject = piece;
          }
        }
        
        
      }
    }
    
    
    
    [self drawModelWithMvp:objModelViewProjection modelSource:monkeySource modelScale:4.0 textureID:-1 color:monkeyColor flipped:NO];
    
  } else {
    if(occlusionView.image)
      [occlusionView setImage:nil];
  }
  
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_CULL_FACE);
  
  [self presentFramebuffer];
}

- (void)drawPiece:(ChessObject *)piece projectionMatrix:(Vuforia::Matrix44F)projectionMatrix
{
  float objModelView[16];
  float objModelViewProjection[16];
  
  Vuforia::Matrix44F bgModelView = [inputHandler backgroundModelView];
  
  for (int i = 0; i < 16; i++) {
    objModelView[i] = bgModelView.data[i];
  }
 
  SampleApplicationUtils::rotatePoseMatrix(90, 1.0, 0.0, 0.0, objModelView);
  
  SampleApplicationUtils::translatePoseMatrix(piece.location.y,
                                              piece.location.z,
                                              kBoardPadding + kBoardSize/2.0f + piece.location.x,
                                              objModelView);
  
  SampleApplicationUtils::multiplyMatrix(&projectionMatrix.data[0], objModelView, objModelViewProjection);
  
  float *queenColor = piece.isWhite ? kWhiteColor : kBlackColor;
  
  demoModel *modelSource = [self getMeshForGameObject:piece];
  
  [self drawModelWithMvp:objModelViewProjection modelSource:modelSource modelScale:10.0 textureID:-1 color:queenColor flipped:!piece.isWhite];
}

- (void)drawModelWithMvp:(GLvoid *)mvp modelSource:(demoModel *)source modelScale:(float)modelScale textureID:(GLuint)textureID color:(float *)color flipped:(bool)flipped
{
  [self drawModelWithMvp:mvp vertexCoords:source->positions elements:source->elements numElements:source->numElements normalCoords:source->normals texCoords:source->texcoords hasTexture:(source->texcoordArraySize > 0) modelScale:modelScale textureID:textureID color:color flipped:flipped];
}

- (void)drawModelWithMvp:(GLvoid *)mvp vertexCoords:(GLvoid *)vertexCoords elements:(GLvoid *)elements numElements:(int)numElements normalCoords:(GLvoid *)normalCoords texCoords:(GLvoid *)texCoords hasTexture:(bool)hasTexCoords modelScale:(float)modelScale textureID:(GLuint)textureID color:(float *)color flipped:(bool)flipped
{
  glUseProgram(shaderProgramID);
  
  glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)vertexCoords);
  glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)normalCoords);
  
  if (hasTexCoords) {
    glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)texCoords);
    glEnableVertexAttribArray(textureCoordHandle);
  }
  
  glEnableVertexAttribArray(vertexHandle);
  glEnableVertexAttribArray(normalHandle);
  if (hasTexCoords) {
    glEnableVertexAttribArray(textureCoordHandle);
  }
  
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, [augmentationTexture[0] textureID]);
  
  glUniform1i(textureUsedHandle, hasTexCoords);
  
  if (hasTexCoords) {
    glBindTexture(GL_TEXTURE_2D, textureID);
    glUniform1i(texSampler2DHandle, 0 /*GL_TEXTURE0*/);
  } else {
    glUniform3f(colorHandle, color[0], color[1], color[2]);
  }
  
  glUniform1i(flippedHandle, flipped);
  
  glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (const GLfloat*)mvp);
  glUniform1f(modelScaleHandle, modelScale);
  glUniform1f(texAlphaHandle, 1.0);
  
  glDrawElements(GL_TRIANGLES, numElements, GL_UNSIGNED_SHORT, (const GLvoid*)elements);
  
  glDisableVertexAttribArray(vertexHandle);
  glDisableVertexAttribArray(normalHandle);
  
  if (hasTexCoords) {
    glDisableVertexAttribArray(textureCoordHandle);
  }
  
  glUseProgram(0);
}

//------------------------------------------------------------------------------
#pragma mark - OpenGL ES management

- (void)initShaders
{
  shaderProgramID = [SampleApplicationShaderUtils createProgramWithVertexShaderFileName:@"Simple.vertsh"
                                                                 fragmentShaderFileName:@"Simple.fragsh"];
  
  if (0 < shaderProgramID) {
    vertexHandle = glGetAttribLocation(shaderProgramID, "vertexPosition");
    normalHandle = glGetAttribLocation(shaderProgramID, "vertexNormal");
    textureCoordHandle = glGetAttribLocation(shaderProgramID, "vertexTexCoord");
    mvpMatrixHandle = glGetUniformLocation(shaderProgramID, "modelViewProjectionMatrix");
    texSampler2DHandle  = glGetUniformLocation(shaderProgramID,"texSampler2D");
    modelScaleHandle  = glGetUniformLocation(shaderProgramID,"modelScale");
    texAlphaHandle  = glGetUniformLocation(shaderProgramID,"texAlpha");
    colorHandle  = glGetUniformLocation(shaderProgramID,"color");
    textureUsedHandle  = glGetUniformLocation(shaderProgramID,"textureUsed");
    flippedHandle  = glGetUniformLocation(shaderProgramID,"flipped");
  }
  else {
    NSLog(@"Could not initialise augmentation shader");
  }
}


- (void)createFramebuffer
{
  if (context) {
    // Create default framebuffer object
    glGenFramebuffers(1, &defaultFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    
    // Create colour renderbuffer and allocate backing store
    glGenRenderbuffers(1, &colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    
    // Allocate the renderbuffer's storage (shared with the drawable object)
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    GLint framebufferWidth;
    GLint framebufferHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
    
    // Create the depth render buffer and allocate storage
    glGenRenderbuffers(1, &depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, framebufferWidth, framebufferHeight);
    
    // Attach colour and depth render buffers to the frame buffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
    
    // Leave the colour render buffer bound so future rendering operations will act on it
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
  }
}


- (void)deleteFramebuffer
{
  if (context) {
    [EAGLContext setCurrentContext:context];
    
    if (defaultFramebuffer) {
      glDeleteFramebuffers(1, &defaultFramebuffer);
      defaultFramebuffer = 0;
    }
    
    if (colorRenderbuffer) {
      glDeleteRenderbuffers(1, &colorRenderbuffer);
      colorRenderbuffer = 0;
    }
    
    if (depthRenderbuffer) {
      glDeleteRenderbuffers(1, &depthRenderbuffer);
      depthRenderbuffer = 0;
    }
  }
}


- (void)setFramebuffer
{
  // The EAGLContext must be set for each thread that wishes to use it.  Set
  // it the first time this method is called (on the render thread)
  if (context != [EAGLContext currentContext]) {
    [EAGLContext setCurrentContext:context];
  }
  
  if (!defaultFramebuffer) {
    // Perform on the main thread to ensure safe memory allocation for the
    // shared buffer.  Block until the operation is complete to prevent
    // simultaneous access to the OpenGL context
    [self performSelectorOnMainThread:@selector(createFramebuffer) withObject:self waitUntilDone:YES];
  }
  
  glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
}


- (BOOL)presentFramebuffer
{
  // setFramebuffer must have been called before presentFramebuffer, therefore
  // we know the context is valid and has been set for this (render) thread
  
  // Bind the colour render buffer and present it
  glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
  
  return [context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark ARInputHandlerDelegate

- (bool)grabModeWillBegin
{
  if (_collidingObject) {
    _grabbedObject = _collidingObject;
    _grabObjPos = _grabbedObject.location;
    _grabCursorPos = currentPos;
    _grabMode = YES;
    return YES;
  } else {
    return NO;
  }
}

- (void)grabModeEnded
{
  _grabbedObject = nil;
  _grabMode = NO;
  
  if (!_networkless) {
    [_sessionObject sendGameUpdate:_gameID playerID:_playerID unserializedGameStat:_chessPieces holding:nil];
  }
}

@end
