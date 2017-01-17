/*===============================================================================
 Copyright (c) 2016 PTC Inc. All Rights Reserved.
 
 Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of PTC Inc., registered in the United States and other
 countries.
 ===============================================================================*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Vuforia/Device.h>
#import <Vuforia/State.h>

@protocol SampleAppRendererControl
// This method has to be implemented by the Renderer class which handles the content rendering
// of the sample, this one is called from SampleAppRendering class for each view inside a loop
- (void) renderFrameWithState:(const Vuforia::State&) state projectMatrix:(Vuforia::Matrix44F&) projectionMatrix;

@end

@interface SampleAppRenderer : NSObject

- (id)initWithSampleAppRendererControl:(id<SampleAppRendererControl>)control deviceMode:(Vuforia::Device::MODE)deviceMode stereo:(bool)stereo;
- (void) initRendering;
- (void) setNearPlane:(CGFloat) near farPlane:(CGFloat) far;
- (void)renderFrameVuforia;
- (void) renderVideoBackground;
- (void)renderVideoBackgroundWithScreenSize:(CGSize)screenSize;
- (void)setImageViewToBackground:(UIImageView *)imageView withCroppingPath:(NSArray *)croppingPath;
- (UIImage *)grabCameraBufferForTextDetection;

@end
