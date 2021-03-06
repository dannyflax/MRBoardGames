/*===============================================================================
Copyright (c) 2016 PTC Inc. All Rights Reserved.

Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/

#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>

#import <Vuforia/UIGLViewProtocol.h>

#import "ARInputHandler.h"

#import "Texture.h"
#import "SampleApplicationSession.h"
#import "SampleApplication3DModel.h"
#import "SampleGLResourceHandler.h"
#import "SampleAppRenderer.h"
#import "ARTouchableView.h"
#import "ARInputHandler.h"
#import "Point3D.h"
#import "modelUtil.h"
#import "SampleCommunicationViewController.h"
#import "SessionObject.h"

#import "ChessObject.h"

#define kNumAugmentationTextures 4


// EAGLView is a subclass of UIView and conforms to the informal protocol
// UIGLViewProtocol
@interface ImageTargetsEAGLView : UIView <UIGLViewProtocol, SampleGLResourceHandler, SampleAppRendererControl, ARInputHandlerDelegate, GameView, SessionObjectGameDelegate> {
@private
    ARInputHandler *inputHandler;
  
    // OpenGL ES context
    EAGLContext *context;
    
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
  
  
    // Texture used when rendering augmentation
    Texture* augmentationTexture[kNumAugmentationTextures];
  
    GLuint chessboardTextureID;
  
    BOOL offTargetTrackingEnabled;
    SampleApplication3DModel * buildingModel;
    
    SampleAppRenderer * sampleAppRenderer;
  
    Point3D *currentPos;
    NSMutableArray<Point3D *> *points;
  
    bool stylusHeld;
  
    ARTouchableView *projectedView;
  
    GLuint currentViewTexture;
  
    UIImageView *occlusionView;
  
    demoModel *monkeySource;
  
    demoModel *queenSource;
    demoModel *kingSource;
    demoModel *rookSource;
    demoModel *bishopSource;
    demoModel *knightSource;
    demoModel *pawnSource;
}

@property NSMutableArray <ChessObject *> *chessPieces;

@property (nonatomic, weak) SampleApplicationSession * vapp;

- (id)initWithFrame:(CGRect)frame appSession:(SampleApplicationSession *) app;

- (void)finishOpenGLESCommands;
- (void)freeOpenGLESResources;

- (void) setOffTargetTrackingMode:(BOOL) enabled;
@end
