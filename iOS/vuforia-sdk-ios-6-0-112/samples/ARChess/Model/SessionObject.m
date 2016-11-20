//
//  SessionObject.m
//  MRBoardGames
//
//  Created by Benjamin Stammen on 11/19/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import "SessionObject.h"

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
        // called when player creates a game.
        // IF GAMEJOINED IS CALLED THEN THIS IS NOT.
    }];
    
    [socket on:@"gameJoined" callback:^(NSArray* data, SocketAckEmitter* ack) {
        // called when player joins a game.
        // IF GAMECREATED IS CALLED THEN THIS IS NOT.
    }];

    [socket on:@"gameList" callback:^(NSArray* data, SocketAckEmitter* ack) {
        [self processGameList:data];
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
    [self.delegate sessionFoundGames:gameList];
}

- (void)joinGame:(GameInfo *)gameInfo {
    [socket emit:@"joinGame" with:@[gameInfo.gameTitle]];
}

- (void)createGame {
    [socket emit:@"createGame" with:@[]];
}

@end
