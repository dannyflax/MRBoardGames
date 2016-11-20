//
//  SessionObject.h
//  MRBoardGames
//
//  Created by Benjamin Stammen on 11/19/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameInfo.h"

@protocol SessionObjectGameDelegate <NSObject>
@required
- (void)gameStateUpdated:(NSArray *)objectList;

@end

@protocol SessionObjectJoinDelegate <NSObject>
- (void)sessionFoundGames:(NSMutableArray *)gameList;
- (void)successfullyCreatedGame:(NSString *)playerID withGameID:(NSString *)gameID;
- (void)successfullyJoinedGame:(NSString *)playerID;

@end

@interface SessionObject : NSObject

@property id<SessionObjectGameDelegate> gameDelegate;
@property id<SessionObjectJoinDelegate> joinDelegate;

- (void)connectToServer;
- (void)refreshGames;
- (void)joinGame:(GameInfo *)gameInfo;
- (void)createGame;
- (void)disconnect;
- (void)sendGameUpdate:(NSString *)gameID playerID:(NSString *)playerID unserializedGameStat:(NSArray *)unserializedGS;
- (void)pollForGameUpdate:(NSString *)gameID playerID:(NSString *)playerID;

@end
