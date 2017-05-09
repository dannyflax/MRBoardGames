//
//  ARTouchableView.m
//  ARChess
//
//  Created by Danny Flax on 11/6/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import "ARTouchableView.h"
#import <AVKit/AVKit.h>

@implementation ARTouchableView
{
}

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32RGBA
                                                )};
        _avOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
        
        self.backgroundColor = [UIColor purpleColor];
        NSString *filepath = [[NSBundle mainBundle] pathForResource:@"IMG_3782" ofType:@"MOV"];
        NSURL *fileURL = [NSURL fileURLWithPath:filepath];
        _avPlayer = [AVPlayer playerWithURL:fileURL];
        _avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [_avPlayer.currentItem addOutput:_avOutput];
        
        AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
        videoLayer.frame = self.bounds;
        videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.layer addSublayer:videoLayer];
        [_avPlayer play];
    }
    return self;
}

#pragma mark ARTouchReceiver

bool toggle = false;

-(void)tapBegan:(CGPoint)tap
{
    
}

-(void)tapMoved:(CGPoint)tap
{
    
}

-(void)tapEnded:(CGPoint)tap
{
    
}

@end

