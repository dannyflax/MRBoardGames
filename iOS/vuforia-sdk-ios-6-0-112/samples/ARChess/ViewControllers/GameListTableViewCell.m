//
//  GameListTableViewCell.m
//  MRBoardGames
//
//  Created by Benjamin Stammen on 11/19/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import "GameListTableViewCell.h"

@interface GameListTableViewCell () {
    GameInfo *referencingGame;
}

@end

@implementation GameListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellForGameInfo:(GameInfo *)game {
    self.gameNameLabel.text = game.gameTitle;
    self.playerCountLabel.text = [NSString stringWithFormat:@"%i", game.playersInGame];
    referencingGame = game;
}

- (IBAction)buttonPressed:(id)sender {
    ((UIButton *)sender).hidden = YES;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    [self.delegate addUserToGame:referencingGame];
}
@end
