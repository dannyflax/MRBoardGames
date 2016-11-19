//
//  BaseObject.h
//  MRBoardGames
//
//  Created by Benjamin Stammen on 11/19/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Point3D.h"

@interface BaseObject : NSObject

- (id)initWithProperties:(NSString *)name
                HolderId:(NSNumber *)playerNumber
                Location:(Point3D *)location
              Dimensions:(Point3D *)dimensions
                   Scale:(float)scale
             AndMeshName:(NSString *)meshName;

- (id)initWithJSON:(NSData*)jsonData;

@end
