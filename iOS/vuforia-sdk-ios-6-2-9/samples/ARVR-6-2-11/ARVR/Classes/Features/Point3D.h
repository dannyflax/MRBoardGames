//
//  Point3D.h
//  ARChess
//
//  Created by Danny Flax on 11/18/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Point3D : NSObject
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float z;

- (id)initWithX:(float)x Y:(float)y Z:(float)z;
+(Point3D *)zero;

@end
