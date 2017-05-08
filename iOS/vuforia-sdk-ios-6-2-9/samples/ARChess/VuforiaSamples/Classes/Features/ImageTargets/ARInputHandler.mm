//
//  ARInputHandler.m
//  ARChess
//
//  Created by Danny Flax on 11/17/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import "ARInputHandler.h"

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import <Vuforia/ImageTarget.h>
#import <Vuforia/ImageTargetResult.h>

#import <Vuforia/VirtualButtonResult.h>

#import "Texture.h"
#import "Quad.h"
#import "SampleApplicationUtils.h"
#import "ARTouchableView.h"

static const int kCameraFocusFrames = 20;

@implementation ARInputHandler
{
  Point3D *_currentPos;
  bool _backgroundInSight;
  bool _cursorInSight;
  bool _grabbingMode;
  bool _waitingForZero;
  Vuforia::Matrix44F _cursorModelView;
  Vuforia::Matrix44F _bgModelView;
  int _cameraFocusCount;
}

const float kObjectScaleNormal = 3.0f;

- (id)init{
  if (self = [super init]) {
    _grabbingMode = NO;
    _waitingForZero = NO;
    _cameraFocusCount = 0;
  }
  return self;
}

- (void)computeInputFromState:(const Vuforia::State&)state projectMatrix:(Vuforia::Matrix44F&) projectionMatrix
{
  bool computedBackground = NO;
  
  float backgroundPoint[3];
  float bgyMap[2];
  float bgxMap[2];
  
  float obj1pos[3];
  float obj2pos[3];
  
  _backgroundInSight = NO;
  _cursorInSight = NO;
  
  int viewPort[4] = { 0, 0, 320, 480 };
  
  float backgroundRotation[9];
  float cursorRotation[9];
  
  
  for (int i = 0; i < state.getNumTrackableResults(); ++i) {
    // Get the trackable
    const Vuforia::TrackableResult* result = state.getTrackableResult(i);
    const Vuforia::Trackable& trackable = result->getTrackable();
    
    // Choose the texture based on the target name
    int targetIndex = 0; // "stones"
    if (!strcmp(trackable.getName(), "chips"))
      targetIndex = 1;
    else if (!strcmp(trackable.getName(), "tarmac"))
      targetIndex = 2;
    
    //const Vuforia::Trackable& trackable = result->getTrackable();
    Vuforia::Matrix44F modelViewMatrix = Vuforia::Tool::convertPose2GLMatrix(result->getPose());
    
    // OpenGL 2
    Vuforia::Matrix44F modelViewProjection;
    

    SampleApplicationUtils::translatePoseMatrix(0.0f, 0.0f, kObjectScaleNormal, &modelViewMatrix.data[0]);
    SampleApplicationUtils::scalePoseMatrix(kObjectScaleNormal, kObjectScaleNormal, kObjectScaleNormal, &modelViewMatrix.data[0]);
    
    SampleApplicationUtils::multiplyMatrix(&projectionMatrix.data[0], &modelViewMatrix.data[0], &modelViewProjection.data[0]);
    
    
    if (targetIndex == 1) {
      // Wood = Reference
      float point1[3], point2[3], point3[3];
      
      SampleApplicationUtils::glhProjectf(0.0f, 0.0f, 0.0f, modelViewMatrix.data, projectionMatrix.data, viewPort, point1);
      
      SampleApplicationUtils::glhProjectf(1.0f, 0.0f, 0.0f, modelViewMatrix.data, projectionMatrix.data, viewPort, point2);
      
      SampleApplicationUtils::glhProjectf(0.0f, 1.0f, 0.0f, modelViewMatrix.data, projectionMatrix.data, viewPort, point3);
      
      
      bgxMap[0] = point2[0] - point1[0];
      bgxMap[1] = point2[1] - point1[1];
      
      
      
      bgyMap[0] = point3[0] - point1[0];
      bgyMap[1] = point3[1] - point1[1];
      
      backgroundPoint[0] = point1[0];
      backgroundPoint[1] = point1[1];
      backgroundPoint[2] = point1[2];
      
      _bgModelView = modelViewMatrix;
      
      computedBackground = YES;
      
      Vuforia::Matrix34F pose = result->getPose();
      
      
      obj1pos[0] = pose.data[3];
      obj1pos[1] = pose.data[7];
      obj1pos[2] = pose.data[11];
      
      backgroundRotation[0] = pose.data[0];
      backgroundRotation[1] = pose.data[1];
      backgroundRotation[2] = pose.data[2];
      backgroundRotation[3] = pose.data[4];
      backgroundRotation[4] = pose.data[5];
      backgroundRotation[5] = pose.data[6];
      backgroundRotation[6] = pose.data[8];
      backgroundRotation[7] = pose.data[9];
      backgroundRotation[8] = pose.data[10];
      
      _backgroundInSight = YES;
      
    } else if(targetIndex == 0) {
      // Stones = Cursor
      
      Vuforia::Matrix34F pose = result->getPose();
      
      obj2pos[0] = pose.data[3];
      obj2pos[1] = pose.data[7];
      obj2pos[2] = pose.data[11];
      
      cursorRotation[0] = pose.data[0];
      cursorRotation[1] = pose.data[1];
      cursorRotation[2] = pose.data[2];
      cursorRotation[3] = pose.data[4];
      cursorRotation[4] = pose.data[5];
      cursorRotation[5] = pose.data[6];
      cursorRotation[6] = pose.data[8];
      cursorRotation[7] = pose.data[9];
      cursorRotation[8] = pose.data[10];
      
      _cursorModelView = modelViewMatrix;
      
      _cursorInSight = YES;
      
      const Vuforia::ImageTargetResult* imageTargetResult =
      static_cast<const Vuforia::ImageTargetResult*>(result);
      
      
      for (int i = 0; i < imageTargetResult->getNumVirtualButtons(); ++i)
      {
        const Vuforia::VirtualButtonResult* buttonResult = imageTargetResult->getVirtualButtonResult("grabButton");
        
        if (buttonResult) {
          if(buttonResult->isPressed() && !_waitingForZero) {
            _waitingForZero = YES;
            _grabbingMode = !_grabbingMode;
            if (_grabbingMode) {
              _grabbingMode = [_delegate grabModeWillBegin];
            } else {
              [_delegate grabModeEnded];
            }
          } else if(!buttonResult->isPressed()) {
            _waitingForZero = NO;
          }
        }
      }
      
    }
    
    SampleApplicationUtils::checkGlError("EAGLView renderFrameVuforia");
  }
  
  float ratio = 1.0f;
  
  if (_cursorInSight && _backgroundInSight) {
    //    float ratio = 524.0f / 1500.0f;
    
    obj2pos[0] = obj2pos[0]*ratio;
    obj2pos[1] = obj2pos[1]*ratio;
    obj2pos[2] = obj2pos[2]*ratio;
    
    float diff[3];
    
    //Vector from obj1 pointing to obj2
    diff[0] = obj2pos[0] - obj1pos[0];
    diff[1] = obj2pos[1] - obj1pos[1];
    diff[2] = obj2pos[2] - obj1pos[2];
    
    
    float invertedBackgroundRotation[9];
    float multipliedResult[3];
    
    float cursorOffset[3] = {-247.0/6.0, 173.0/6.0, 0.0};
    float rotatedCursorOffset[3];
    
    float w_scale = .333;
    
    //rotation is orthonormal
    SampleApplicationUtils::mtx3x3Transpose(invertedBackgroundRotation, backgroundRotation);
    
    SampleApplicationUtils::multiplyMatrix3x3(cursorRotation, invertedBackgroundRotation, cursorRotation);
    
    multipliedResult[0] = invertedBackgroundRotation[0] * diff[0] + invertedBackgroundRotation[1] * diff[1] + invertedBackgroundRotation[2] * diff[2];
    
    multipliedResult[1] = invertedBackgroundRotation[3] * diff[0] + invertedBackgroundRotation[4] * diff[1] + invertedBackgroundRotation[5] * diff[2];
    
    multipliedResult[2] = invertedBackgroundRotation[6] * diff[0] + invertedBackgroundRotation[7] * diff[1] + invertedBackgroundRotation[8] * diff[2];
    
    
    rotatedCursorOffset[0] = cursorRotation[0] * cursorOffset[0] + cursorRotation[1] * cursorOffset[1] + cursorRotation[2] * cursorOffset[2];
    
    rotatedCursorOffset[1] = cursorRotation[3] * cursorOffset[0] + cursorRotation[4] * cursorOffset[1] + cursorRotation[5] * cursorOffset[2];
    
    rotatedCursorOffset[2] = cursorRotation[6] * cursorOffset[0] + cursorRotation[7] * cursorOffset[1] + cursorRotation[8] * cursorOffset[2];
    
    multipliedResult[0]*=w_scale;
    multipliedResult[1]*=w_scale;
    multipliedResult[2]*=w_scale;
    
    multipliedResult[0]+=rotatedCursorOffset[0];
    multipliedResult[1]+=rotatedCursorOffset[1];
    multipliedResult[2]+=rotatedCursorOffset[2];
    
    _currentPos = [Point3D new];
    
    _currentPos.x = multipliedResult[0];
    _currentPos.y = multipliedResult[1];
    _currentPos.z = multipliedResult[2];
  }
  
  //Count frames for camera focus, cap it at the max
  if (_backgroundInSight) {
    _cameraFocusCount = MIN(_cameraFocusCount + 1, kCameraFocusFrames);
  } else {
    _cameraFocusCount = 0;
  }
}

- (bool)backgroundInFocus
{
  return _cameraFocusCount == kCameraFocusFrames;
}
  
- (bool)backgroundInSight
{
  return _backgroundInSight;
}
  
- (bool)cursorInSight
{
  return _cursorInSight;
}

- (bool)grabbingMode
{
  return _grabbingMode;
}

- (Point3D *)currentPos
{
  return _currentPos;
}

- (Vuforia::Matrix44F)backgroundModelView
{
  return _bgModelView;
}
- (Vuforia::Matrix44F)cursorModelView
{
  return _cursorModelView;
}


@end
