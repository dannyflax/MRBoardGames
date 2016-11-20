//
//  CollisionChecker.h
//  MRBoardGames
//
//  Created by Danny Flax on 11/19/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Point3D.h"

@interface CollisionChecker : NSObject

+(bool)checkCollisionBetweenRectWithCenter:(Point3D *)center andDimensions:(Point3D *)dimensions andPoint:(Point3D *)point;

@end
