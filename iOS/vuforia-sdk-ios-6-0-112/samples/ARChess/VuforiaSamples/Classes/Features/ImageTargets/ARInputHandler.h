//
//  ARInputHandler.h
//  ARChess
//
//  Created by Danny Flax on 11/17/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import <Vuforia/Vuforia.h>
#import <Vuforia/State.h>
#import <Vuforia/Tool.h>
#import <Vuforia/Renderer.h>
#import <Vuforia/TrackableResult.h>
#import <Vuforia/VideoBackgroundConfig.h>
#import <Vuforia/UIGLViewProtocol.h>

#import "Point3D.h"

@interface ARInputHandler : NSObject

- (void)computeInputFromState:(const Vuforia::State&)state projectMatrix:(Vuforia::Matrix44F&) projectionMatrix;

- (bool)backgroundInSight;
- (bool)cursorInSight;
- (bool)grabbingMode;

- (Point3D *)currentPos;

- (Vuforia::Matrix44F)backgroundModelView;
- (Vuforia::Matrix44F)cursorModelView;

@end
