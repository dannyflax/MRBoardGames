//
//  ARTouchableView.h
//  ARChess
//
//  Created by Danny Flax on 11/6/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ARTouchViewOwner <NSObject>
-(void)resetView;
@end

@protocol ARTouchReceiver <NSObject>
-(void)tapBegan:(CGPoint)tap;

-(void)tapMoved:(CGPoint)tap;

-(void)tapEnded:(CGPoint)tap;
@end

@interface ARTouchableView : UIView<ARTouchReceiver>
{
}
@property id<ARTouchViewOwner> owner;
@property AVPlayer *avPlayer;
@property AVPlayerItemVideoOutput *avOutput;
@end
