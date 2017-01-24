/*! @file AppAuthExampleViewController.m
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

#import "GoogleAPIHandler.h"

#import <AppAuth/AppAuth.h>
#import <GTMAppAuth/GTMAppAuth.h>
#import <QuartzCore/QuartzCore.h>

#import "GTMSessionFetcher.h"
#import "GTMSessionFetcherService.h"

#import "VuforiaSamplesAppDelegate.h"

/*! @brief The OIDC issuer from which the configuration will be discovered.
 */
static NSString *const kIssuer = @"https://accounts.google.com";

static NSString *const kCalendarClientID = @"1096669041108-c790vq2jk2jj6ao0i2rckkdria7cedic.apps.googleusercontent.com";

static NSString *const kScriptID = @"1IHhhVuAxljWt3RNW6CriVnAHFKZ1N0eAwwxryTEQ8-FhD6oKa7tYiSne";

static NSString *const kRedirectURI = @"com.googleusercontent.apps.1096669041108-c790vq2jk2jj6ao0i2rckkdria7cedic:/oauthredirect";

static NSString *const kExampleAuthorizerKey = @"Google Calendar API";

@interface GoogleAPIHandler() <OIDAuthStateChangeDelegate,
OIDAuthStateErrorDelegate>
@end

@implementation GoogleAPIHandler

+ (GoogleAPIHandler *)sharedAPIHandler
{
  static GoogleAPIHandler *apiHandler = nil;
  if (apiHandler == nil) {
    apiHandler = [GoogleAPIHandler new];
  }
  return apiHandler;
}

- (id)init
{
  if (self = [super init]) {
    [self setup];
  }
  return self;
}

- (void)setup {
  
#if !defined(NS_BLOCK_ASSERTIONS)
  
  NSAssert(![kCalendarClientID isEqualToString:@"YOUR_CLIENT.apps.googleusercontent.com"],
           @"Update kCalendarClientID with your own client ID. "
           "Instructions: https://github.com/openid/AppAuth-iOS/blob/master/Example/README.md");
  
  NSAssert(![kRedirectURI isEqualToString:@"com.googleusercontent.apps.YOUR_CLIENT:/oauthredirect"],
           @"Update kRedirectURI with your own redirect URI. "
           "Instructions: https://github.com/openid/AppAuth-iOS/blob/master/Example/README.md");
  
  // verifies that the custom URI scheme has been updated in the Info.plist
  NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
  NSAssert(urlTypes.count > 0, @"No custom URI scheme has been configured for the project.");
  NSArray *urlSchemes = ((NSDictionary *)urlTypes.firstObject)[@"CFBundleURLSchemes"];
  NSAssert(urlSchemes.count > 0, @"No custom URI scheme has been configured for the project.");
  NSString *urlScheme = urlSchemes.firstObject;
  
  NSAssert(![urlScheme isEqualToString:@"com.googleusercontent.apps.YOUR_CLIENT"],
           @"Configure the URI scheme in Info.plist (URL Types -> Item 0 -> URL Schemes -> Item 0) "
           "with the scheme of your redirect URI. Full instructions: "
           "https://github.com/openid/AppAuth-iOS/blob/master/Example/README.md");
  
#endif // !defined(NS_BLOCK_ASSERTIONS)
  
  [self loadState];
}

/*! @brief Saves the @c GTMAppAuthFetcherAuthorization to @c NSUSerDefaults.
 */
- (void)saveState {
  if (_authorization.canAuthorize) {
    [GTMAppAuthFetcherAuthorization saveAuthorization:_authorization
                                    toKeychainForName:kExampleAuthorizerKey];
  } else {
    [GTMAppAuthFetcherAuthorization removeAuthorizationFromKeychainForName:kExampleAuthorizerKey];
  }
}

/*! @brief Loads the @c GTMAppAuthFetcherAuthorization from @c NSUSerDefaults.
 */
- (void)loadState {
  GTMAppAuthFetcherAuthorization* authorization =
  [GTMAppAuthFetcherAuthorization authorizationFromKeychainForName:kExampleAuthorizerKey];
  [self setGtmAuthorization:authorization];
}

- (void)setGtmAuthorization:(GTMAppAuthFetcherAuthorization*)authorization {
  if ([_authorization isEqual:authorization]) {
    return;
  }
  _authorization = authorization;
  
  self.service = [[GTLServiceCalendar alloc] init];
  self.service.authorizer = _authorization;
  
  self.coreService = [[GTLService alloc] init];
  self.coreService.authorizer = _authorization;
  
  [self stateChanged];
}

- (void)stateChanged {
  [self saveState];
}

- (void)didChangeState:(OIDAuthState *)state {
  [self stateChanged];
}

- (void)authState:(OIDAuthState *)state didEncounterAuthorizationError:(NSError *)error {
  NSLog(@"Received authorization error: %@", error);
}

- (void)authWithAutoCodeExchange:(UIViewController *)presentingViewController
{
  NSURL *issuer = [NSURL URLWithString:kIssuer];
  NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];
  
  NSLog(@"Fetching configuration for issuer: %@", issuer);
  
  // discovers endpoints
  [OIDAuthorizationService discoverServiceConfigurationForIssuer:issuer
                                                      completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
                                                        
                                                        if (!configuration) {
                                                          NSLog(@"Error retrieving discovery document: %@", [error localizedDescription]);
                                                          [self setGtmAuthorization:nil];
                                                          return;
                                                        }
                                                        
                                                        NSLog(@"Got configuration: %@", configuration);
                                                        
                                                        // builds authentication request
                                                        OIDAuthorizationRequest *request =
                                                        [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                                                                      clientId:kCalendarClientID
                                                                                                        scopes:@[kGTLAuthScopeCalendar, @"https://www.google.com/calendar/feeds",
                                                                                                                 @"https://www.googleapis.com/auth/forms",
                                                                                                                 @"https://www.googleapis.com/auth/spreadsheets"]
                                                                                                   redirectURL:redirectURI
                                                                                                  responseType:OIDResponseTypeCode
                                                                                          additionalParameters:nil];
                                                        // performs authentication request
                                                        VuforiaSamplesAppDelegate *appDelegate = (VuforiaSamplesAppDelegate *)[UIApplication sharedApplication].delegate;
                                                        NSLog(@"Initiating authorization request with scope: %@", request.scope);
                                                        
                                                        appDelegate.currentAuthorizationFlow =
                                                        [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                                                                       presentingViewController:presentingViewController
                                                                                                       callback:^(OIDAuthState *_Nullable authState,
                                                                                                                  NSError *_Nullable error) {
                                                                                                         if (authState) {
                                                                                                           GTMAppAuthFetcherAuthorization *authorization =
                                                                                                           [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];
                                                                                                           
                                                                                                           [self setGtmAuthorization:authorization];
                                                                                                           NSLog(@"Got authorization tokens. Access token: %@",
                                                                                                            authState.lastTokenResponse.accessToken);
                                                                                                         } else {
                                                                                                           [self setGtmAuthorization:nil];
                                                                                                           NSLog(@"Authorization error: %@", [error localizedDescription]);
                                                                                                         }
                                                                                                       }];
                                                      }];
}

- (void)clearAuthState {
  [self setGtmAuthorization:nil];
}

// Construct a query and get a list of upcoming events from the user calendar. Display the
// start dates and event summaries in the UITextView.
- (void)fetchEventsForRoomNumber:(int)roomNumber onSuccess:(CalendarLookupSuccessBlock)successBlock onFailure:(CalendarLookupFailureBlock)failureBlock
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://script.googleapis.com/v1/scripts/%@:run",
                                     kScriptID]];
  // Create an execution request object.
  GTLObject *request = [[GTLObject alloc] init];
  [request setJSONValue:@"getRoomInfo" forKey:@"function"];
  
  [request setJSONValue:@[@(roomNumber)] forKey:@"parameters"];
  
  // Make the API request.
  [self.coreService fetchObjectByInsertingObject:request
                                          forURL:url
                               completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
                                 [self displayFoldersWithServiceTicket:ticket finishedWithObject:object error:error onSuccess:successBlock onFailure:failureBlock];
  }];
  
}




- (void)displayFoldersWithServiceTicket:(GTLServiceTicket *)ticket
                     finishedWithObject:(GTLObject *)object
                                  error:(NSError *)error
                              onSuccess:(CalendarLookupSuccessBlock)successBlock
                              onFailure:(CalendarLookupFailureBlock)failureBlock
{
  if (error == nil) {
    if ([object.JSON objectForKey:@"error"] != nil) {
      NSMutableString *output = [[NSMutableString alloc] init];
      
      // The API executed, but the script returned an error.
      
      // Extract the first (and only) set of error details and cast as a
      // NSDictionary. The values of this dictionary are the script's
      // 'errorMessage' and 'errorType', and an array of stack trace
      // elements (which also need to be cast as NSDictionaries).
      NSDictionary *err =
      [[object.JSON objectForKey:@"error"] objectForKey:@"details"][0];
      [output appendFormat:@"Script error message: %@\n",
       [err objectForKey:@"errorMessage"]];
      
      if ([err objectForKey:@"scriptStackTraceElements"]) {
        // There may not be a stacktrace if the script didn't start
        // executing.
        [output appendString:@"Script error stacktrace:\n"];
        for (NSDictionary *trace in [err objectForKey:@"scriptStackTraceElements"]) {
          [output appendFormat:@"\t%@: %@\n",
           [trace objectForKey:@"function"],
           [trace objectForKey:@"lineNumber"]];
        }
      }
      
      failureBlock(output);
      
    } else {
      //Success!
      
      NSMutableArray *result = [[[object.JSON objectForKey:@"response"] objectForKey:@"result"] objectAtIndex:0];
      
      if (result && [result count] == 4) {
        NSString *calendarID = [result objectAtIndex:1];
        NSString *professorName = [result objectAtIndex:2];
        NSString *professorEmail = [result objectAtIndex:3];
        [self computeFreeBusyWithCalendarID:calendarID onSuccess:successBlock onFailure:failureBlock professorName:professorName professorEmail:professorEmail];
      }
    }
  } else {
    // The API encountered a problem before the script started executing.
    failureBlock([error localizedDescription]);
  }
}


- (void)computeFreeBusyWithCalendarID:(NSString *)calendarID
                            onSuccess:(CalendarLookupSuccessBlock)successBlock
                            onFailure:(CalendarLookupFailureBlock)failureBlock
                        professorName:(NSString *)professorName
                       professorEmail:(NSString *)professorEmail
{
  _professorCalendarID = calendarID;
  
  GTLQueryCalendar *query = [GTLQueryCalendar queryForFreebusyQuery];
  
  NSDate *today = [NSDate date];
  NSCalendar *gregorian = [[NSCalendar alloc]
                           initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  
  [gregorian setTimeZone:[NSTimeZone localTimeZone]];
  
  NSDateComponents *weekdayComponents =
  [gregorian components:(NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitYear) fromDate:today];
  [weekdayComponents setHour:0];
  [weekdayComponents setMinute:0];
  [weekdayComponents setSecond:0];
  
  NSDate *start = [gregorian dateFromComponents:weekdayComponents];
  
  query.timeMin = [GTLDateTime dateTimeWithDate:start
                                       timeZone:[NSTimeZone localTimeZone]];
  
  query.timeMax = [GTLDateTime dateTimeWithDate:[start dateByAddingTimeInterval:60*60*24]
                                       timeZone:[NSTimeZone localTimeZone]];
  
  query.singleEvents = YES;
  query.orderBy = kGTLCalendarOrderByStartTime;
  
  GTLCalendarFreeBusyRequestItem *first = [GTLCalendarFreeBusyRequestItem new];
  GTLCalendarFreeBusyRequestItem *second = [GTLCalendarFreeBusyRequestItem new];
  
  first.identifier = @"primary";
  second.identifier = calendarID;
  
  
  query.items = [NSArray arrayWithObjects:first,second, nil];
  
  query.singleEvents = NO;
  
  [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error){
    [self displayResultWithTicket:ticket finishedWithObject:object error:error onSuccess:successBlock onFailure:failureBlock professorName:professorName professorEmail:professorEmail calendarID:calendarID];
  }];
}


- (void)displayResultWithTicket:(GTLServiceTicket *)ticket
             finishedWithObject:(GTLCalendarFreeBusyResponse *)result
                          error:(NSError *)error
                      onSuccess:(CalendarLookupSuccessBlock)successBlock
                      onFailure:(CalendarLookupFailureBlock)failureBlock
                  professorName:(NSString *)professorName
                 professorEmail:(NSString *)professorEmail
                     calendarID:(NSString *)calendarID
{
  if (error == nil) {
    GTLCalendarFreeBusyResponseCalendars *calendars = result.calendars;
    
    NSDictionary *primaryBusy = [calendars.JSON objectForKey:@"primary"];
    NSDictionary *professorBusy = [calendars.JSON objectForKey:_professorCalendarID];
    
    NSMutableArray<CalendarEventDataModel *> *busyEvents = [NSMutableArray new];
    
    if (primaryBusy) {
      [busyEvents addObjectsFromArray:[self getEventsFromCalendar:primaryBusy]];
    }
    
    if (professorBusy) {
      [busyEvents addObjectsFromArray:[self getEventsFromCalendar:professorBusy]];
    }
    
    successBlock(busyEvents, professorName, professorEmail, calendarID);
  } else {
    failureBlock([error localizedDescription]);
  }
}

- (void)scheduleCalendarEventWithStudentEmail:(NSString *)studentEmail startTime:(NSDate *)startTime endTime:(NSDate *)endTime professorEmail:(NSString *)professorEmail onCompletion:(void(^)())completion
{
  GTLCalendarEvent *event = [GTLCalendarEvent new];
  
  event.summary = @"Meeting with student";
  
  GTLCalendarEventAttendee *attendee1 = [GTLCalendarEventAttendee new];
  attendee1.email = studentEmail;
  
  GTLCalendarEventAttendee *attendee2 = [GTLCalendarEventAttendee new];
  attendee2.email = professorEmail;
  
  event.attendees = [[NSArray alloc] initWithObjects:attendee1, attendee2, nil];
  
  GTLCalendarEventDateTime *start = [GTLCalendarEventDateTime new];
  GTLCalendarEventDateTime *end = [GTLCalendarEventDateTime new];
  
  start.dateTime = [GTLDateTime dateTimeWithDate:startTime
                                       timeZone:[NSTimeZone localTimeZone]];
  end.dateTime = [GTLDateTime dateTimeWithDate:endTime
                                       timeZone:[NSTimeZone localTimeZone]];
  
  event.start = start;
  event.end = end;
  
  GTLQueryCalendar *query = [GTLQueryCalendar queryForEventsInsertWithObject:event calendarId:@"primary"];
  
  [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error){
    if (!error) {
      UIAlertView *aView = [[UIAlertView alloc] initWithTitle:@"Successfully scheduled event" message:@"Successfully scheduled event with professor" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
      [aView show];
    }
    completion();
  }];

}


- (NSArray<CalendarEventDataModel *> *)getEventsFromCalendar:(NSDictionary *)calendar
{
  NSMutableArray<CalendarEventDataModel *> *events = [NSMutableArray new];
  
  for (NSDictionary *event in [calendar objectForKey:@"busy"]) {
    NSString *startString = [event objectForKey:@"start"];
    NSString *endString = [event objectForKey:@"end"];
    
    NSDate *startDate = [[GTLDateTime dateTimeWithRFC3339String:startString] date];
    NSDate *endDate = [[GTLDateTime dateTimeWithRFC3339String:endString] date];
    
    [events addObject:[[CalendarEventDataModel alloc] initWithStartDate:startDate endDate:endDate]];
  }
  
  return events;
}

@end

@implementation CalendarEventDataModel

-(id)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
  if (self = [super init]) {
    _startDate = startDate;
    _endDate = endDate;
  }
  
  return self;
}

@end
