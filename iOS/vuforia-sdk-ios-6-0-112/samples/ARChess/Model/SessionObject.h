//
//  SessionObject.h
//  MRBoardGames
//
//  Created by Benjamin Stammen on 11/19/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameInfo.h"

@protocol SessionObjectDelegate <NSObject>
@required
- (void)sessionFoundGames:(NSMutableArray *)gameList;
// ... other methods here
@end

@interface SessionObject : NSObject

@property id<SessionObjectDelegate> delegate;

- (void)connectToServer;
- (void)refreshGames;
- (void)joinGame:(GameInfo *)gameInfo;
- (void)createGame;
- (void)disconnect;

@end
