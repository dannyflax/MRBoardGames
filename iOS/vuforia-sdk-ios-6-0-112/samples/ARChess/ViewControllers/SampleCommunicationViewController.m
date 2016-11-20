//
//  SampleCommunicationViewController.m
//  MRBoardGames
//
//  Created by Benjamin Stammen on 11/19/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import "SampleCommunicationViewController.h"
#import "GameListTableViewCell.h"

@import SocketIO;

// This class holds information about games available to us.
@implementation GameInfo

@end

@interface SampleCommunicationViewController ()  {
    NSMutableArray *gameList;
}

@end

@implementation SampleCommunicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameTableView.delegate = self;
    self.gameTableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self setViewActive:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [self connectToServer];
}

- (void)setViewActive:(BOOL)active {
    self.gameTableView.hidden = !active;
    self.activityIndicator.hidden = active;
    self.gameButton.enabled = active;
    if (active) {
        [self.activityIndicator stopAnimating];
    } else {
        [self.activityIndicator startAnimating];
    }
}

// Called when view has appeared
- (void)connectToServer {
    NSURL* url = [[NSURL alloc] initWithString:@"http://ec2-52-15-161-144.us-east-2.compute.amazonaws.com:3901"];
    SocketIOClient* socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @YES, @"forcePolling": @YES}];
    
    [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        [socket emit:@"listGames" with:@[]];
    }];

    [socket on:@"gameList" callback:^(NSArray *data, SocketAckEmitter *ack) {
        // populate the table view with games!
        //NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        gameList = [[NSMutableArray alloc] init];
        NSDictionary *gameObjects = data[0];
        for (NSString *key in [gameObjects allKeys]) {
            int numPlayers = [[gameObjects objectForKey:key] intValue];
            GameInfo *gameInfo = [[GameInfo alloc] init];
            gameInfo.gameTitle = key;
            gameInfo.playersInGame = numPlayers;
            [gameList addObject:gameInfo];
        }
        [self.gameTableView reloadData];
        [self setViewActive:YES];
    }];
    
    [socket on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        // would be good to handle this gracefully...
    }];
    
    [socket connect];
}

- (IBAction)newGamePressed:(id)sender {
    // launch into a new view that will connect to the game.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma MARK - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (gameList) {
        return [gameList count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GameListTableViewCell *cell = (GameListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"GameListTableViewCell"];
    // remove an item from the dictionary for the cell.
    GameInfo *gameInfo = [gameList objectAtIndex:indexPath.row];
    cell.gameName.text = gameInfo.gameTitle;
    cell.playersLabel.text = [NSString stringWithFormat:@"[%i]", gameInfo.playersInGame];
    return cell;
}

@end
