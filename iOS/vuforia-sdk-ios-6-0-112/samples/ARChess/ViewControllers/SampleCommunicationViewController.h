//
//  SampleCommunicationViewController.h
//  MRBoardGames
//
//  Created by Benjamin Stammen on 11/19/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionObject.h"
#import "GameListTableViewCell.h"
//#import "ImageTargetsEAGLView.h"

@protocol GameView <NSObject>

- (void)startGameWithID:(NSString *)gameID playerID:(NSString *)playerID networkless:(bool)networkless sessionObject:(SessionObject *)sessionObject gameState:(NSArray *)gameState
;

@end

@interface SampleCommunicationViewController : UIViewController <NSStreamDelegate,UITableViewDelegate, UITableViewDataSource, SessionObjectJoinDelegate, GameListLabelViewCellDelegate>

@property SessionObject *sessionObject;

@property (weak, nonatomic) IBOutlet UITableView *gameTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *gameButton;

@end
