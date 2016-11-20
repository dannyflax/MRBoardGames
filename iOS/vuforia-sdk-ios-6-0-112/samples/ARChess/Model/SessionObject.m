//
//  SessionObject.m
//  MRBoardGames
//
//  Created by Benjamin Stammen on 11/19/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import "SessionObject.h"
#import "ChessPiecesFactory.h"

@import SocketIO;

@interface SessionObject () {
    SocketIOClient *socket;
}

@end

@implementation SessionObject

- (void)connectToServer {
    NSURL* url = [[NSURL alloc] initWithString:@"http://ec2-52-15-161-144.us-east-2.compute.amazonaws.com:3901"];
    socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @YES, @"forcePolling": @YES}];
    
    [self configureCallbacks];
    
    [socket connect];
}

- (void)disconnect {
    [socket disconnect];
}

- (void)configureCallbacks {
    [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        [self onServerConnection];
    }];
    
    [socket on:@"gameCreated" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSDictionary *objects = data[0];
        if ([objects objectForKey:@"playerID"]) {
          [self.joinDelegate successfullyCreatedGame:[objects objectForKey:@"playerID"] withGameID:[objects objectForKey:@"gameID"]];
        }
    }];
    
    [socket on:@"gameJoined" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSDictionary *objects = data[0];
        if ([objects objectForKey:@"playerID"]) {
          [self.joinDelegate successfullyJoinedGame:[objects objectForKey:@"playerID"]];
        }
    }];

    [socket on:@"gameList" callback:^(NSArray* data, SocketAckEmitter* ack) {
        [self processGameList:data];
    }];
  
    [socket on:@"gameState" callback:^(NSArray* data, SocketAckEmitter* ack) {
      NSDictionary *objects = data[0];
      
      NSMutableArray *gameObjs = [NSMutableArray new];
      NSArray *state = [objects objectForKey:@"state"];
      
      for (NSData *json in state) {
        [gameObjs addObject:[[BaseObject alloc] initWithJSON:json]];
      }
  
      [self.gameDelegate gameStateUpdated:gameObjs];
    }];
  
    [socket on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        [self onServerDisconnect];
    }];
}

- (void)onServerConnection {
    [self refreshGames];
}

- (void)onServerDisconnect {
    
}

- (void)refreshGames {
    [socket emit:@"listGames" with:@[]];
}

- (void)pollForGameUpdate:(NSString *)gameID playerID:(NSString *)playerID
{
  [socket emit:@"getGameState" with:@[@{@"playerID":playerID, @"gameID":gameID}]];
}

- (void)sendGameUpdate:(NSString *)gameID playerID:(NSString *)playerID unserializedGameStat:(NSArray *)unserializedGS
{
  NSArray<BaseObject *> *initialData = unserializedGS;
  
  NSMutableArray *processedData = [NSMutableArray new];
  
  for (BaseObject *baseObj in initialData) {
    [processedData addObject:[baseObj getJsonRepresentation]];
  }
  
  [socket emit:@"updateGameState" with:@[@{@"playerID":playerID, @"gameID":gameID, @"state":processedData}]];
}

- (void)processGameList:(NSArray *)data {
    NSMutableArray *gameList = [[NSMutableArray alloc] init];
    NSDictionary *gameObjects = data[0];
    for (NSString *key in [gameObjects allKeys]) {
        int numPlayers = [[gameObjects objectForKey:key] intValue];
        GameInfo *gameInfo = [[GameInfo alloc] init];
        gameInfo.gameTitle = key;
        gameInfo.playersInGame = numPlayers;
        [gameList addObject:gameInfo];
    }
    [self.joinDelegate sessionFoundGames:gameList];
}

- (void)joinGame:(GameInfo *)gameInfo {
  [socket emit:@"joinGame" with:@[@{@"gameID":gameInfo.gameTitle}]];
}

- (void)createGame {
    NSArray<BaseObject *> *initialData = [ChessPiecesFactory createNewChessGame];
  
    NSMutableArray *processedData = [NSMutableArray new];
  
    for (BaseObject *baseObj in initialData) {
      [processedData addObject:[baseObj getJsonRepresentation]];
    }
  
    [socket emit:@"createGame" with:@[@{@"state":processedData}]];
}

@end
