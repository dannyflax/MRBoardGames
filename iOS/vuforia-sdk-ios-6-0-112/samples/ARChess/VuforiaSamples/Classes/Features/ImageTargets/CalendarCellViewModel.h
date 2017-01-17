//
//  CalendarCellViewModel.h
//  MRBoardGames
//
//  Created by Danny Flax on 12/6/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarCellViewModel : NSObject
@property NSString *eventTitle;
@property NSString *eventTime;
@property bool available;
@property bool editable;
@end
