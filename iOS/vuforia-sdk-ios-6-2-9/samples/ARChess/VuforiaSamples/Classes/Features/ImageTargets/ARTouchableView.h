//
//  ARTouchableView.h
//  ARChess
//
//  Created by Danny Flax on 11/6/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ARTouchViewOwner <NSObject>
-(void)resetView;
@end

@protocol ARTouchReceiver <NSObject>
-(void)tapBegan:(CGPoint)tap;

-(void)tapMoved:(CGPoint)tap;

-(void)tapEnded:(CGPoint)tap;
@end

@interface ARTouchableView : UIView<ARTouchReceiver>
{
  bool holdingSquare;
  CGPoint grabPoint;
  CGPoint baseViewPoint;
  UIView *subView;
}
@property id<ARTouchViewOwner> owner;

-(void)professorNameDetermined:(NSString *)professorName;
-(void)failedToDetermineProfessorName;
-(bool)hasLoadedSchedule;
-(void)toLoading;
-(void)frameWithFocus;
-(void)frameWithoutFocus;

@end

@class CalendarEventDataModel;

@interface CalendarDataModel : NSObject
@property (nonatomic) NSString *professorName;
@property (nonatomic) NSString *professorEmail;
@property (nonatomic) NSArray <CalendarEventDataModel *> *events;

+(CalendarDataModel *)fromJSONString:(NSString *)jsonString;
+(CalendarDataModel *)empty;
-(NSString *)toJSONString;
-(id)initWithEvents:(NSArray <CalendarEventDataModel *>*)events professorName:(NSString *)profName professorEmail:(NSString *)profEmail;
-(NSDictionary *)toDict;
+(CalendarDataModel *)fromDict:(NSDictionary *)dict;
@end

@interface CalendarEventDataModel : NSObject

-(id)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
-(NSDictionary *)toDict;
-(NSString *)toJSONString;
+(CalendarEventDataModel *)fromDict:(NSDictionary *)dict;
+(CalendarEventDataModel *)fromJSONString:(NSString *)jsonString;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;

@end
