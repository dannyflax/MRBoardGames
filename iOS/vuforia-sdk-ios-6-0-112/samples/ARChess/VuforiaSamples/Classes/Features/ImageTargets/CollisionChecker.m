//
//  CollisionChecker.m
//  MRBoardGames
//
//  Created by Danny Flax on 11/19/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import "CollisionChecker.h"

@implementation CollisionChecker

+(bool)checkCollisionBetweenRectWithCenter:(Point3D *)center andDimensions:(Point3D *)dimensions andPoint:(Point3D *)point
{
  Point3D *maxValues = [[Point3D alloc] initWithX: center.x + dimensions.x/2.0f
                                                Y: center.y + dimensions.y/2.0f
                                                Z: center.z + dimensions.z];
  
  Point3D *minValues = [[Point3D alloc] initWithX: center.x - dimensions.x/2.0f
                                                Y: center.y - dimensions.y/2.0f
                                                Z: center.z];
  
  if (point.x < maxValues.x && point.x > minValues.x) {
    if (point.y < maxValues.y && point.y > minValues.y) {
      if (point.z < maxValues.z && point.z > minValues.z) {
        return true;
      }
    }
  }
  
  return false;
}

@end
