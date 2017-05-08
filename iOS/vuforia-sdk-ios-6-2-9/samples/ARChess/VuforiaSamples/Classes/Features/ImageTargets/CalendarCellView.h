//
//  CalendarCellView.h
//  MRBoardGames
//
//  Created by Danny Flax on 12/6/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CalendarCellViewModel.h"

@interface CalendarCellView : UIView
- (void)setViewModel:(CalendarCellViewModel *)viewModel;
@property bool enabled;
@end
