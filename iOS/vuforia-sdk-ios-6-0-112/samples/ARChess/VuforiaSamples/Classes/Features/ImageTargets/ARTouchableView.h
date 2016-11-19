//
//  ARTouchableView.h
//  ARChess
//
//  Created by Danny Flax on 11/6/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARTouchableView : UIView
{
  bool holdingSquare;
  CGPoint grabPoint;
  CGPoint baseViewPoint;
  UIView *subView;
}
-(void)tapBegan:(CGPoint)tap;

-(void)tapMoved:(CGPoint)tap;

-(void)tapEnded:(CGPoint)tap;

@end
