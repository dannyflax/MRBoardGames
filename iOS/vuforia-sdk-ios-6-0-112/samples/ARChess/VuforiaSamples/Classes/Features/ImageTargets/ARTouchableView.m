//
//  ARTouchableView.m
//  ARChess
//
//  Created by Danny Flax on 11/6/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import "ARTouchableView.h"

@implementation ARTouchableView

-(id)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    [self setBackgroundColor:[UIColor whiteColor]];
    subView = [[UIView alloc] initWithFrame:CGRectMake(50.0, 30.0, 10.0, 10.0)];
    [subView setBackgroundColor:[UIColor blackColor]];
    [self addSubview:subView];
    holdingSquare = false;
  }
  return self;
}

-(void)tapBegan:(CGPoint)tap
{
  if (CGRectContainsPoint(subView.frame, tap)) {
    holdingSquare = true;
    grabPoint = tap;
    baseViewPoint = subView.frame.origin;
  }
}

-(void)tapMoved:(CGPoint)tap
{
  if (holdingSquare) {
    CGPoint difference = CGPointMake(tap.x - grabPoint.x, tap.y - grabPoint.y);
    CGRect sFrame = subView.frame;
    sFrame.origin = CGPointMake(baseViewPoint.x + difference.x, baseViewPoint.y + difference.y);
    subView.frame = sFrame;
  }
}

-(void)tapEnded:(CGPoint)tap
{
  holdingSquare = false;
}

@end
