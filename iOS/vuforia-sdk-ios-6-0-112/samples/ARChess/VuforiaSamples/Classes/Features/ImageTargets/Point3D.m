//
//  Point3D.m
//  ARChess
//
//  Created by Danny Flax on 11/18/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import "Point3D.h"

@implementation Point3D

-(id)initWithX:(float)x Y:(float)y Z:(float)z {
    self = [super init];
    self.x = x;
    self.y = y;
    self.z = z;
    return self;
}

-(NSString *)description
{
  return [NSString stringWithFormat:@"[X: %.2f, Y: %.2f, Z: %.2f]", self.x, self.y, self.z];
}

@end
