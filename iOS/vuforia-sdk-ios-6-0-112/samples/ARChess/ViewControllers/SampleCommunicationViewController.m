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

@interface SampleCommunicationViewController ()  {
    NSMutableArray *gamesToList;
}

@end

@implementation SampleCommunicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameTableView.delegate = self;
    self.gameTableView.dataSource = self;
    self.gameButton.layer.cornerRadius = 10.0;
}

- (void)viewWillAppear:(BOOL)animated {
    [self setViewActive:NO];
    self.sessionObject = [[SessionObject alloc] init];
    self.sessionObject.delegate = self;
    [self.sessionObject connectToServer];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [self.sessionObject disconnect];
    }
    [super viewWillDisappear:animated];
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

- (void)sessionFoundGames:(NSMutableArray *)gameList {
    gamesToList = gameList;
    [self.gameTableView reloadData];
    [self setViewActive:YES];
}

- (IBAction)newGamePressed:(id)sender {
    [self.sessionObject createGame];
}

- (IBAction)refreshPressed:(id)sender {
    [self setViewActive:NO];
    [self.sessionObject refreshGames];
}

- (IBAction)networklessPressed:(id)sender {
    [self.sessionObject disconnect];
    [self performSegueWithIdentifier:@"startNetworklessViewer" sender:self];
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
    if (gamesToList) {
        return [gamesToList count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GameListTableViewCell *cell = (GameListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"GameListTableViewCell"];
    // remove an item from the dictionary for the cell.
    GameInfo *gameInfo = [gamesToList objectAtIndex:indexPath.row];
    [cell configureCellForGameInfo:gameInfo];
    cell.delegate = self;
    return cell;
}

#pragma MARK - GameListTableViewCellDelegate

- (void)addUserToGame:(GameInfo *)game {
    [self.sessionObject joinGame:game];
}

@end
