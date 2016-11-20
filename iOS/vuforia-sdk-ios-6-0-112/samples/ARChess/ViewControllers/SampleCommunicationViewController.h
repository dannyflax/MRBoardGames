//
//  SampleCommunicationViewController.h
//  MRBoardGames
//
//  Created by Benjamin Stammen on 11/19/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameInfo : NSObject

@property NSString *gameTitle;
@property int playersInGame;

@end

@interface SampleCommunicationViewController : UIViewController <NSStreamDelegate,UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *gameTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *gameButton;

@end
