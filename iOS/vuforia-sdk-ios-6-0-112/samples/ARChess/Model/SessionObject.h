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
- (void)gameStateUpdated:(NSArray *)objectList playerID:(NSString *)playerID success:(BOOL)success;

@end

@protocol SessionObjectJoinDelegate <NSObject>
- (void)sessionFoundGames:(NSMutableArray *)gameList;
- (void)successfullyCreatedGame:(NSString *)playerID withGameID:(NSString *)gameID gameState:(NSArray *)gameState;
- (void)successfullyJoinedGame:(NSString *)playerID gameState:(NSArray *)gameState;

@end

@interface SessionObject : NSObject

@property id<SessionObjectGameDelegate> gameDelegate;
@property id<SessionObjectJoinDelegate> joinDelegate;

- (void)connectToServer;
- (void)refreshGames;
- (void)joinGame:(GameInfo *)gameInfo;
- (void)createGame;
- (void)disconnect;
- (void)endGame:(NSString *)gameID playerID:(NSString *)playerID;
- (void)sendGameUpdate:(NSString *)gameID playerID:(NSString *)playerID unserializedGameStat:(NSArray *)unserializedGS holding:(NSString *)holding;
- (void)pollForGameUpdate:(NSString *)gameID playerID:(NSString *)playerID;

@end
