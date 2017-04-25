/*! @file AppAuthExampleViewController.h
 @brief GTMAppAuth SDK iOS Example
 @copyright
 Copyright 2016 Google Inc.
 @copydetails
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
#import <UIKit/UIKit.h>

#import "GTLCalendar.h"
#import "GTLService.h"

@class OIDAuthState;
@class GTMAppAuthFetcherAuthorization;
@class OIDServiceConfiguration;
@class CalendarEventDataModel;

NS_ASSUME_NONNULL_BEGIN

typedef void(^CalendarLookupSuccessBlock)(NSArray<CalendarEventDataModel *> *, NSString *professorNAme, NSString *professorEmail, NSString *calendarID);
typedef void(^CalendarLookupFailureBlock)(NSString *error);

/*! @brief The example application's view controller.
 */
@interface GoogleAPIHandler : NSObject

/*! @brief The authorization state.
 */
@property(nonatomic, nullable) GTMAppAuthFetcherAuthorization *authorization;

- (void)authWithAutoCodeExchange:(UIViewController *)presentingViewController;

- (void)fetchEventsForRoomNumber:(int)roomNumber onSuccess:(CalendarLookupSuccessBlock)successBlock onFailure:(CalendarLookupFailureBlock)failureBlock;

- (void)scheduleCalendarEventWithStudentEmail:(NSString *)studentEmail startTime:(NSDate *)startTime endTime:(NSDate *)endTime professorEmail:(NSString *)professorEmail onCompletion:(void(^)())completion;

- (void)clearAuthState;

+ (GoogleAPIHandler *)sharedAPIHandler;

@property (nonatomic, strong) GTLServiceCalendar *service;
@property (nonatomic, strong) GTLService *coreService;
@property (nonatomic) NSString *professorCalendarID;

@end

@interface CalendarDataModel : NSObject
@property (nonatomic) NSString *professorName;
@property (nonatomic) NSString *professorEmail;
@property (nonatomic) NSArray <CalendarEventDataModel *> *events;

+(CalendarDataModel *)fromJSONString:(NSString *)jsonString;
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

NS_ASSUME_NONNULL_END
