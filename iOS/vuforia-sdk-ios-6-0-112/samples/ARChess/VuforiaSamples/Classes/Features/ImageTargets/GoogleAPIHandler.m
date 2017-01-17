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

//static NSString *const kCalendarClientID = @"28772676077-idrfqvms8s1l3hr48q4r09t71na1g484.apps.googleusercontent.com";

static NSString *const kScriptID = @"1IHhhVuAxljWt3RNW6CriVnAHFKZ1N0eAwwxryTEQ8-FhD6oKa7tYiSne";

static NSString *const kRedirectURI = @"com.googleusercontent.apps.1096669041108-c790vq2jk2jj6ao0i2rckkdria7cedic:/oauthredirect";

//static NSString *const kRedirectURI = @"com.googleusercontent.apps.28772676077-idrfqvms8s1l3hr48q4r09t71na1g484:/oauthredirect";

static NSString *const kExampleAuthorizerKey = @"Google Calendar API";

@interface GoogleAPIHandler() <OIDAuthStateChangeDelegate,
OIDAuthStateErrorDelegate>
@end

@implementation GoogleAPIHandler

- (void)viewDidLoad {
  [super viewDidLoad];
  
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
  
  _logTextView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
  _logTextView.layer.borderWidth = 1.0f;
  _logTextView.alwaysBounceVertical = YES;
  _logTextView.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
  _logTextView.text = @"";
  
  [self loadState];
  [self updateUI];
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

/*! @brief Refreshes UI, typically called after the auth state changed.
 */
- (void)updateUI {
  _userinfoButton.enabled = _authorization.canAuthorize;
  _clearAuthStateButton.enabled = _authorization.canAuthorize;
  // dynamically changes authorize button text depending on authorized state
  if (!_authorization.canAuthorize) {
    [_authAutoButton setTitle:@"Authorize" forState:UIControlStateNormal];
    [_authAutoButton setTitle:@"Authorize" forState:UIControlStateHighlighted];
  } else {
    [_authAutoButton setTitle:@"Re-authorize" forState:UIControlStateNormal];
    [_authAutoButton setTitle:@"Re-authorize" forState:UIControlStateHighlighted];
  }
}

- (void)stateChanged {
  [self saveState];
  [self updateUI];
}

- (void)didChangeState:(OIDAuthState *)state {
  [self stateChanged];
}

- (void)authState:(OIDAuthState *)state didEncounterAuthorizationError:(NSError *)error {
  [self logMessage:@"Received authorization error: %@", error];
}

- (IBAction)authWithAutoCodeExchange:(nullable id)sender {
  NSURL *issuer = [NSURL URLWithString:kIssuer];
  NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];
  
  [self logMessage:@"Fetching configuration for issuer: %@", issuer];
  
  // discovers endpoints
  [OIDAuthorizationService discoverServiceConfigurationForIssuer:issuer
                                                      completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
                                                        
                                                        if (!configuration) {
                                                          [self logMessage:@"Error retrieving discovery document: %@", [error localizedDescription]];
                                                          [self setGtmAuthorization:nil];
                                                          return;
                                                        }
                                                        
                                                        [self logMessage:@"Got configuration: %@", configuration];
                                                        
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
                                                        [self logMessage:@"Initiating authorization request with scope: %@", request.scope];
                                                        
                                                        appDelegate.currentAuthorizationFlow =
                                                        [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                                                                       presentingViewController:self
                                                                                                       callback:^(OIDAuthState *_Nullable authState,
                                                                                                                  NSError *_Nullable error) {
                                                                                                         if (authState) {
                                                                                                           GTMAppAuthFetcherAuthorization *authorization =
                                                                                                           [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];
                                                                                                           
                                                                                                           [self setGtmAuthorization:authorization];
                                                                                                           [self logMessage:@"Got authorization tokens. Access token: %@",
                                                                                                            authState.lastTokenResponse.accessToken];
                                                                                                         } else {
                                                                                                           [self setGtmAuthorization:nil];
                                                                                                           [self logMessage:@"Authorization error: %@", [error localizedDescription]];
                                                                                                         }
                                                                                                       }];
                                                      }];
}

- (IBAction)clearAuthState:(nullable id)sender {
  [self setGtmAuthorization:nil];
}

- (IBAction)clearLog:(nullable id)sender {
  _logTextView.text = @"";
}


// Construct a query and get a list of upcoming events from the user calendar. Display the
// start dates and event summaries in the UITextView.
- (void)fetchEventsForRoomNumber:(int)roomNumber {
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://script.googleapis.com/v1/scripts/%@:run",
                                     kScriptID]];
  // Create an execution request object.
  GTLObject *request = [[GTLObject alloc] init];
  [request setJSONValue:@"getRoomInfo" forKey:@"function"];
  
  [request setJSONValue:@[@(roomNumber)] forKey:@"parameters"];
  
  // Make the API request.
  [self.coreService fetchObjectByInsertingObject:request
                                          forURL:url
                                        delegate:self
                               didFinishSelector:@selector(displayFoldersWithServiceTicket:finishedWithObject:error:)];
}




- (void)displayFoldersWithServiceTicket:(GTLServiceTicket *)ticket
                     finishedWithObject:(GTLObject *)object
                                  error:(NSError *)error {
  if (error == nil) {
    NSMutableString *output = [[NSMutableString alloc] init];
    if ([object.JSON objectForKey:@"error"] != nil) {
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
      
    } else {
      
      NSMutableArray *result = [[[object.JSON objectForKey:@"response"] objectForKey:@"result"] objectAtIndex:0];
      
      if (result && [result count] == 3) {
        NSString *calendarID = [result objectAtIndex:1];
        //        NSString *professorName = [result objectAtIndex:2];
        
        [self computeFreeBusyWithCalendarID:calendarID];
      }
    }
    [self logMessage:@"%@",output];
  } else {
    // The API encountered a problem before the script started executing.
    [self logMessage:@"%@",[error localizedDescription]];
  }
}


- (void)computeFreeBusyWithCalendarID:(NSString *)calendarID
{
  _professorCalendarID = calendarID;
  
  GTLQueryCalendar *query = [GTLQueryCalendar queryForFreebusyQuery];
  
  query.timeMin = [GTLDateTime dateTimeWithDate:[NSDate date]
                                       timeZone:[NSTimeZone localTimeZone]];
  
  query.timeMax = [GTLDateTime dateTimeWithDate:[NSDate dateWithTimeIntervalSinceNow:60*60*24]
                                       timeZone:[NSTimeZone localTimeZone]];
  
  query.singleEvents = YES;
  query.orderBy = kGTLCalendarOrderByStartTime;
  
  GTLCalendarFreeBusyRequestItem *first = [GTLCalendarFreeBusyRequestItem new];
  GTLCalendarFreeBusyRequestItem *second = [GTLCalendarFreeBusyRequestItem new];
  
  first.identifier = @"primary";
  second.identifier = calendarID;
  
  
  query.items = [NSArray arrayWithObjects:first,second, nil];
  
  [self.service executeQuery:query
                    delegate:self
           didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
  
  [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error){
    [self displayResultWithTicket:ticket finishedWithObject:object error:error];
  }];
}


- (void)displayResultWithTicket:(GTLServiceTicket *)ticket
             finishedWithObject:(GTLCalendarFreeBusyResponse *)result
                          error:(NSError *)error {
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
    
    NSLog(@"%@", busyEvents);
    
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    [gregorian setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDateComponents *weekdayComponents =
    [gregorian components:(NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:today];
    [weekdayComponents setHour:9];
    [weekdayComponents setMinute:30];
    
    NSDate *date = [gregorian dateFromComponents:weekdayComponents];
    
    NSLog(@"%@", date);
    
  } else {
    [self logMessage:@"%@",error.localizedDescription];
  }
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


- (IBAction)userinfo:(nullable id)sender {
  [self fetchEventsForRoomNumber:657];
}

/*! @brief Logs a message to stdout and the textfield.
 @param format The format string and arguments.
 */
- (void)logMessage:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) {
  // gets message as string
  va_list argp;
  va_start(argp, format);
  NSString *log = [[NSString alloc] initWithFormat:format arguments:argp];
  va_end(argp);
  
  // outputs to stdout
  NSLog(@"%@", log);
  
  // appends to output log
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.dateFormat = @"hh:mm:ss";
  NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
  _logTextView.text = [NSString stringWithFormat:@"%@%@%@: %@",
                       _logTextView.text,
                       ([_logTextView.text length] > 0) ? @"\n" : @"",
                       dateString,
                       log];
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
