//
//  DreamStoreHolder.h
//  MRBoardGames
//
//  Created by Danny Flax on 4/28/17.
//  Copyright © 2017 Qualcomm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DreamStoreFrontend/DreamStoreFrontend.h>

@interface DreamStoreHolder : NSObject
+ (id<DreamStore>)sharedDreamStore;
@end
