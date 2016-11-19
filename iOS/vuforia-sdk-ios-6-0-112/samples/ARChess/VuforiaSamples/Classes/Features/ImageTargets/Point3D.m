//
//  Point3D.m
//  ARChess
//
//  Created by Danny Flax on 11/18/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import "Point3D.h"

@implementation Point3D

-(NSString *)description
{
  return [NSString stringWithFormat:@"[X: %.2f, Y: %.2f, Z: %.2f]", self.x, self.y, self.z];
}

@end
