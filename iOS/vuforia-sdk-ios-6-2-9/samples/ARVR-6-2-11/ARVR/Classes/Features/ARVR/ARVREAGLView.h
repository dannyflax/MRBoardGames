/*===============================================================================
 Copyright (c) 2016 PTC Inc. All Rights Reserved.
 
 Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of PTC Inc., registered in the United States and other
 countries.
 ===============================================================================*/

#import <UIKit/UIKit.h>

#import <Vuforia/UIGLViewProtocol.h>
#import <Vuforia/RenderingPrimitives.h>

#import "Texture.h"
#import "SampleApplicationSession.h"
#import "SampleApplication3DModel.h"
#import "SampleGLResourceHandler.h"
#import "ModelV3d.h"


#define kNumAugmentationTextures 4


// EAGLView is a subclass of UIView and conforms to the informal protocol
// UIGLViewProtocol
@interface ARVREAGLView : UIView <UIGLViewProtocol, SampleGLResourceHandler> {
@private
    // OpenGL ES context
    EAGLContext *context;
    bool mIsStereo;
    bool mIsVR;
    bool isARObjectVisible;
    
    Vuforia::Matrix44F interactionViewMatrix;
    Vuforia::Matrix34F deviceViewMatrix;

    
    // The OpenGL ES names for the framebuffer and renderbuffers used to render
    // to this view
    GLuint defaultFramebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;

    // Shader handles
    GLuint shaderProgramID;
    GLint vertexHandle;
    GLint normalHandle;
    GLint textureCoordHandle;
    GLint mvpMatrixHandle;
    GLint texSampler2DHandle;
    GLint modelScaleHandle;
    GLint texAlphaHandle;
    GLint colorHandle;
    GLboolean textureUsedHandle;
    GLboolean flippedHandle;
    
    // Video background shader
    GLuint vbShaderProgramID;
    GLint vbVertexHandle;
    GLint vbTexCoordHandle;
    GLint vbTexSampler2DHandle;
    GLint vbMaskSampler2DCoordHandle;
    GLint vbProjectionMatrixHandle;
    GLint vbTexAlphaHandle;
    
    // For distortion rendering when docked in a viewer
    unsigned int distoShaderProgramID;
    GLint distoVertexHandle;
    GLint distoTexCoordHandle;
    GLint distoTexSampler2DHandle;
    
    GLuint viewerDistortionTextureID;
    GLuint viewerDepthTextureID;
    GLuint viewerDistortionFboID;
    
    GLuint vbMaskTextureID;
    
    // Texture used when rendering augmentation
    Texture* augmentationTexture[kNumAugmentationTextures];
    
    Modelv3d * mMountainModelVR;
    Modelv3d * mMountainModelAR;
}

@property (nonatomic, weak) SampleApplicationSession * vapp;
@property (nonatomic, readwrite) Vuforia::Vec2I viewerDistortionTextureSize;

// The current set of rendering primitives
@property (nonatomic, readwrite) Vuforia::RenderingPrimitives *currentRenderingPrimitives;


- (id)initWithFrame:(CGRect)frame appSession:(SampleApplicationSession *) app isStereo:(bool) isStereo isVR:(bool) isVR;
- (void)updateRenderingPrimitives;

- (void)finishOpenGLESCommands;
- (void)freeOpenGLESResources;
- (void)loadModels;
- (void)unloadModels;
@end
