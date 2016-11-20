//
//  GameListTableViewCell.h
//  MRBoardGames
//
//  Created by Benjamin Stammen on 11/19/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameInfo.h"

@protocol GameListLabelViewCellDelegate
@required
- (void)addUserToGame:(GameInfo*)game;
@end

@interface GameListTableViewCell : UITableViewCell

@property id<GameListLabelViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *gameNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerCountLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)configureCellForGameInfo:(GameInfo*)game;

@end
