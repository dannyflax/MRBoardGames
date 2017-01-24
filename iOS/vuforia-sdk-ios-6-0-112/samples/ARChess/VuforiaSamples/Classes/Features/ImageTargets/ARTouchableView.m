//
//  ARTouchableView.m
//  ARChess
//
//  Created by Danny Flax on 11/6/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import "ARTouchableView.h"
#import "CalendarCellView.h"
#import "GoogleAPIHandler.h"

static NSString *kLoadingString = @"Loading professor schedule...";
static NSString *kSaveString = @"Schedule";
static const float kHeaderSize = 50.0f;
static const float kFooterSize = 50.0f;

@implementation ARTouchableView
{
  UILabel *_descriptionLabel;
  UIActivityIndicatorView *_loadingView;
  bool _loadedSchedule;
  NSArray<CalendarCellView *> *_calendarCells;
  NSArray<CalendarCellViewModel *> *_viewModels;
  UIView *_cellContainer;
  UIButton *_saveButton;
  NSString *_professorEmail;
  NSString *_calendarID;
}

-(id)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    [self setBackgroundColor:[UIColor whiteColor]];
    _descriptionLabel = [UILabel new];
    [_descriptionLabel setText:kLoadingString];
    _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    _cellContainer = [UIView new];
    
    [self addSubview:_loadingView];
    [self addSubview:_descriptionLabel];
    [self addSubview:_cellContainer];
    
    _loadedSchedule = false;
    
    _saveButton = [UIButton new];
    [_saveButton setTitle:kSaveString forState:UIControlStateNormal];
    [_saveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    
    [self addSubview:_saveButton];
    
  }
  return self;
}

int lengthInHours = 8;
int startTime = 9;

- (void)_setupInitialViewModels
{
  NSMutableArray *initialViewModels = [NSMutableArray new];
  
  for (int i = 0; i < lengthInHours*2; i++) {
    CalendarCellViewModel *viewModel = [CalendarCellViewModel new];
    
    int hour = (startTime + i/2) % 12;
    
    bool pm = ((startTime + i/2) / 12) == 1;
    
    int min = (i%2 == 0) ? 0 : 30;
    
    viewModel.eventTime = [NSString stringWithFormat:@"%02i:%02i", hour, min];
    viewModel.eventTitle = [NSString stringWithFormat:@"Event %i", i];
    viewModel.actualTime = [self _dateTodayWithHours:hour minutes:min isPm:pm];
    
    viewModel.available = YES;
    viewModel.editable = YES;
    
    [initialViewModels addObject:viewModel];
  }
  
  _viewModels = [NSArray arrayWithArray:initialViewModels];
  [self _updateViews];
}

- (NSDate *)_dateTodayWithHours:(int)hours minutes:(int)min isPm:(bool)isPm
{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    [gregorian setTimeZone:[NSTimeZone localTimeZone]];

    NSDateComponents *weekdayComponents =
    [gregorian components:(NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitYear) fromDate:today];
    [weekdayComponents setHour:isPm ? 12 + hours :  hours];
    [weekdayComponents setMinute:min];
    [weekdayComponents setSecond:0];

    return [gregorian dateFromComponents:weekdayComponents];
}

- (void)_updateViews
{
  for (CalendarCellView *cellView in _calendarCells) {
    [cellView removeFromSuperview];
  }
  
  bool enabledSave = false;
  NSMutableArray *newViews = [[NSMutableArray alloc] initWithCapacity:_viewModels.count];
  for (int i = 0; i < _viewModels.count; i++) {
    CalendarCellView *cellView = [CalendarCellView new];
    [newViews addObject:cellView];
    
    CalendarCellViewModel *vm = [_viewModels objectAtIndex:i];
    
    [cellView setViewModel:vm];
    [_cellContainer addSubview:cellView];
    
    if (vm.editable && !vm.available) {
      enabledSave = true;
    }
  }
  
  _saveButton.enabled = enabledSave;
  
  _calendarCells = [NSArray arrayWithArray:newViews];
  
  [self setNeedsLayout];
}

- (void)layoutSubviews
{
  CGRect cellFrame = self.frame;
  cellFrame.size.height = cellFrame.size.height - (kHeaderSize + kFooterSize);
  cellFrame.origin.y = kHeaderSize;
  _cellContainer.frame = cellFrame;
  
  if (!_loadedSchedule) {
    [_descriptionLabel sizeToFit];
    
    float loadingViewSize = 100.0f;
    
    float lvCenterX = (self.frame.size.width / 2.0) - (loadingViewSize / 2.0);
    float yPadding = 50.0f;
    
    _loadingView.frame = CGRectMake(lvCenterX,
                                    yPadding,
                                    loadingViewSize,
                                    loadingViewSize);
    
    [_loadingView startAnimating];
    
    float desCenterX = (self.frame.size.width / 2.0) - (_descriptionLabel.frame.size.width / 2.0);
    
    _descriptionLabel.frame = CGRectMake(desCenterX,
                                         _loadingView.frame.size.height + 15.0,
                                         _descriptionLabel.frame.size.width,
                                         _descriptionLabel.frame.size.height);
  
  } else {
     [_descriptionLabel sizeToFit];
    
    float desCenterX = (self.frame.size.width / 2.0) - (_descriptionLabel.frame.size.width / 2.0);
    float desCenterY = (kHeaderSize / 2.0) - (_descriptionLabel.frame.size.height / 2.0);
    
    _descriptionLabel.frame = CGRectMake(desCenterX,
                                         desCenterY,
                                         _descriptionLabel.frame.size.width,
                                         _descriptionLabel.frame.size.height);
    
    
    float viewHeight = _cellContainer.frame.size.height / _calendarCells.count;
    float viewWidth = _cellContainer.frame.size.width;
    
    int i = 0;
    for (CalendarCellView *cellView in _calendarCells) {
      cellView.frame = CGRectMake(0.0f, i*viewHeight, viewWidth, viewHeight);
      i++;
    }
    
    [_saveButton sizeToFit];
    
    float saveCenterX = (self.frame.size.width / 2.0) - (_saveButton.frame.size.width / 2.0);
    float saveCenterY = _cellContainer.frame.origin.y + _cellContainer.frame.size.height +(kFooterSize / 2.0) - (_saveButton.frame.size.height / 2.0);
    
    _saveButton.frame = CGRectMake(saveCenterX,
                                   saveCenterY,
                                   _saveButton.frame.size.width,
                                   _saveButton.frame.size.height);
  }
}

bool fetching = false;

-(void)professorNameDetermined:(NSString *)professorName
{
  if (![professorName isEqualToString:@""]) {
    
    if (!fetching) {
      
      fetching = true;
      GoogleAPIHandler *apiHandler = [GoogleAPIHandler sharedAPIHandler];
      
      [apiHandler fetchEventsForRoomNumber:[professorName intValue] onSuccess:^(NSArray<CalendarEventDataModel *> *events, NSString *actualProfessorName, NSString *professorEmail, NSString *calendarID){
        fetching = false;
        [self displayCalendar];
        [self updateViewsWithBusyTimes:events];
        [_loadingView setHidden:YES];
        [_descriptionLabel setText:actualProfessorName];
        _loadedSchedule = true;
        _professorEmail = professorEmail;
        _calendarID = calendarID;
        [self setNeedsLayout];
      } onFailure:^(NSString *error){
        fetching = false;
        NSLog(@"%@",error);
      }];
    }
  }
}

-(void)updateViewsWithBusyTimes:(NSArray<CalendarEventDataModel *> *)busyTimes
{
  for (CalendarCellViewModel * viewModel in _viewModels) {
    NSDate *vmStart = viewModel.actualTime;
    NSDate *vmEnd = [viewModel.actualTime dateByAddingTimeInterval:60*30];
    
    viewModel.available = true;
    
    for (CalendarEventDataModel *busyTime in busyTimes) {
      bool startInside = ([busyTime.startDate compare:vmStart] > 0 && [busyTime.startDate compare:vmEnd] < 0);
      bool endInside = ([busyTime.endDate compare:vmStart] > 0 && [busyTime.endDate compare:vmEnd] < 0);
      
      bool intersects = startInside || endInside;
      
      if (intersects) {
        viewModel.available = false;
        viewModel.editable = false;
        break;
      }
      
      bool startInside2 = ([vmStart compare:busyTime.startDate] > 0 && [vmStart compare:busyTime.endDate] < 0);
      bool endInside2 = ([vmEnd compare:busyTime.startDate] > 0 && [vmEnd compare:busyTime.endDate] < 0);
      
      bool intersects2 = startInside2 || endInside2;
      
      if (intersects2) {
        viewModel.available = false;
        viewModel.editable = false;
        break;
      }
      
    }
  }
  
  [self _updateViews];
}

-(void)displayCalendar
{
  [_saveButton setHidden:NO];
  [self _setupInitialViewModels];
}

-(void)failedToDetermineProfessorName
{
//  [self professorNameDetermined:@""];
  
  [_loadingView setHidden:YES];
  [_descriptionLabel setText:@"Unable to determine professor."];
  [self setNeedsLayout];
  _loadedSchedule = false;
}

-(void)tapBegan:(CGPoint)tap
{
  
  if (_viewModels.count > 0) {
    CGPoint tapInCells = [self convertPoint:tap toView:_cellContainer];
    
    int viewNumber = (tapInCells.y) / ((_cellContainer.frame.size.height) / _viewModels.count);
    
    if (viewNumber >= 0 && viewNumber < _viewModels.count) {
      CalendarCellViewModel *viewModel = [_viewModels objectAtIndex:viewNumber];
      if (viewModel.editable) {
        viewModel.available = !viewModel.available;
      }
      [self _updateViews];
    }
    
  }
  
  CGPoint tapInButton = [self convertPoint:tap toView:_saveButton];
  
  if(tapInButton.y > 0 && tapInButton.y < _saveButton.frame.size.height) {
    [self submit];
    
    
  }
  
}

-(void)submit
{
  
  int startVmNum = 0;
  
  int i = 0;
  for (CalendarCellViewModel *viewModel in _viewModels) {
    if (viewModel.editable && !viewModel.available) {
      startVmNum = i;
      break;
    }
    i++;
  }
  
  int endVmNum = startVmNum;
  
  for (int i = startVmNum + 1; i < [_viewModels count]; i++) {
    CalendarCellViewModel *viewModel = [_viewModels objectAtIndex:i];
    if (viewModel.editable && !viewModel.available) {
      endVmNum = i;
    } else {
      break;
    }
  }
  
  NSDate *start = [_viewModels objectAtIndex:startVmNum].actualTime;
  NSDate *end = [[_viewModels objectAtIndex:endVmNum].actualTime dateByAddingTimeInterval:60*30];
  
  [[GoogleAPIHandler sharedAPIHandler] scheduleCalendarEventWithStudentEmail:@"MyWork1229@gmail.com" startTime:start endTime:end professorEmail:_professorEmail onCompletion:^{
    [[GoogleAPIHandler sharedAPIHandler] computeFreeBusyWithCalendarID:_calendarID onSuccess:^(NSArray *events, NSString *profName, NSString *profEmail, NSString *calendarID){
      [self updateViewsWithBusyTimes:events];
    } onFailure:^(NSString *error){
    } professorName:@"" professorEmail:@""];
  }];
}

-(void)tapMoved:(CGPoint)tap
{
  
}

-(void)tapEnded:(CGPoint)tap
{
  
}

-(void)toLoading
{
  _viewModels = [NSArray new];
  [_saveButton setHidden:YES];
  [self _updateViews];
  [_descriptionLabel setText:kLoadingString];
  [_loadingView setHidden:NO];
}

-(bool)hasLoadedSchedule
{
  return _loadedSchedule;
}

@end
