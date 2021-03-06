//
//  ChessObject.h
//  MRBoardGames
//
//  Created by Danny Flax on 11/20/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseObject.h"

@interface ChessObject : BaseObject

- (id)initWithProperties:(NSString *)name
                HolderId:(NSNumber *)playerNumber
                Location:(Point3D *)location
              Dimensions:(Point3D *)dimensions
                   Scale:(float)scale
             AndMeshName:(NSString *)meshName
                   White:(BOOL)white;

@property BOOL isWhite;

@end
