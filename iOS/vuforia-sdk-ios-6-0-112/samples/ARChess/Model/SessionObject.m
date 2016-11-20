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
{
  NSMutableArray *_lastGameState;
}

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
          [self.joinDelegate successfullyCreatedGame:[objects objectForKey:@"playerID"] withGameID:[objects objectForKey:@"gameID"] gameState:[NSArray arrayWithArray:_lastGameState]];
        }
    }];
    
    [socket on:@"gameJoined" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSDictionary *objects = data[0];
        if ([objects objectForKey:@"playerID"]) {
          NSMutableArray *gameObjs = [NSMutableArray new];
          NSArray *state = [objects objectForKey:@"state"];
          
          for (NSData *json in state) {
            [gameObjs addObject:[[ChessObject alloc] initWithJSON:json]];
          }
          
          [self.joinDelegate successfullyJoinedGame:[objects objectForKey:@"playerID"] gameState:[NSArray arrayWithArray:gameObjs]];
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
        [gameObjs addObject:[[ChessObject alloc] initWithJSON:json]];
      }
  
      [self.gameDelegate gameStateUpdated:gameObjs];
    }];
  
    [socket on:@"gameStateUpdated" callback:^(NSArray* data, SocketAckEmitter* ack) {
      NSDictionary *objects = data[0];
      
      NSMutableArray *gameObjs = [NSMutableArray new];
      NSArray *state = [objects objectForKey:@"state"];
      
      for (NSData *json in state) {
        [gameObjs addObject:[[ChessObject alloc] initWithJSON:json]];
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

- (void)endGame:(NSString *)gameID playerID:(NSString *)playerID{
  [socket emit:@"leaveGame" with:@[@{@"gameID":gameID, @"playerID":playerID}]];
}

- (void)refreshGames {
    [socket emit:@"listGames" with:@[]];
}

- (void)pollForGameUpdate:(NSString *)gameID playerID:(NSString *)playerID
{
  [socket emit:@"getGameState" with:@[@{@"playerID":playerID, @"gameID":gameID}]];
}

- (void)sendGameUpdate:(NSString *)gameID playerID:(NSString *)playerID unserializedGameStat:(NSArray *)unserializedGS holding:(NSString *)holding
{
  NSArray<ChessObject *> *initialData = unserializedGS;
  
  NSMutableArray *processedData = [NSMutableArray new];
  
  for (ChessObject *baseObj in initialData) {
    [processedData addObject:[baseObj getJsonRepresentation]];
  }
  
  if (holding) {
      [socket emit:@"updateGameState" with:@[@{@"playerID":playerID, @"gameID":gameID, @"state":processedData, @"holding":holding}]];
  } else {
      [socket emit:@"updateGameState" with:@[@{@"playerID":playerID, @"gameID":gameID, @"state":processedData}]];
  }
  
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
    NSArray<ChessObject *> *initialData = [ChessPiecesFactory createNewChessGame];
  
    NSMutableArray *processedData = [NSMutableArray new];
  
    for (ChessObject *baseObj in initialData) {
      [processedData addObject:[baseObj getJsonRepresentation]];
    }
  
    [socket emit:@"createGame" with:@[@{@"state":processedData}]];
  
    _lastGameState = processedData;
}

@end
