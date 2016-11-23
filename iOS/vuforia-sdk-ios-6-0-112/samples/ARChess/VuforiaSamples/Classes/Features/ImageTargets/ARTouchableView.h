//
//  ARTouchableView.h
//  ARChess
//
//  Created by Danny Flax on 11/6/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ARTouchReceiver <NSObject>
-(void)tapBegan:(CGPoint)tap;

-(void)tapMoved:(CGPoint)tap;

-(void)tapEnded:(CGPoint)tap;
@end

@interface ARTouchableView : UIView<ARTouchReceiver>
{
  bool holdingSquare;
  CGPoint grabPoint;
  CGPoint baseViewPoint;
  UIView *subView;
}

@end
