//
//  GameListTableViewCell.h
//  MRBoardGames
//
//  Created by Benjamin Stammen on 11/19/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *gameName;
@property (weak, nonatomic) IBOutlet UILabel *playersLabel;

@end
