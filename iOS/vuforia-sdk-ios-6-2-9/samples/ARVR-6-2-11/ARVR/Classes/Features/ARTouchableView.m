//
//  ARTouchableView.m
//  ARChess
//
//  Created by Danny Flax on 11/6/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import "ARTouchableView.h"

@implementation ARTouchableView
{
  
}

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor purpleColor];
    }
    return self;
}

#pragma mark ARTouchReceiver

bool toggle = false;

-(void)tapBegan:(CGPoint)tap
{
    toggle = !toggle;
    self.backgroundColor = toggle ? [UIColor whiteColor] : [UIColor greenColor];
}

-(void)tapMoved:(CGPoint)tap
{
    
}

-(void)tapEnded:(CGPoint)tap
{
    
}

@end

