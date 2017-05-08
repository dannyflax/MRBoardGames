//
//  DreamStoreHolder.m
//  MRBoardGames
//
//  Created by Danny Flax on 4/28/17.
//  Copyright © 2017 Qualcomm. All rights reserved.
//

#import "DreamStoreHolder.h"

@implementation DreamStoreHolder
static id<DreamStore> sharedDreamStore;

+ (id<DreamStore>)sharedDreamStore
{
  if(!sharedDreamStore)
  {
    sharedDreamStore = [DreamStoreAVM new];
  }
  return sharedDreamStore;
}
@end
