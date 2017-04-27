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
#import <DreamStoreFrontend/DreamStoreFrontend.h>

static NSString *kLoadingString = @"Loading professor schedule...";
static NSString *kSaveString = @"Save Changes";
static const float kHeaderSize = 50.0f;
static const float kFooterSize = 50.0f;

@implementation ARTouchableView
{
  UILabel *_descriptionLabel;
  UIActivityIndicatorView *_loadingView;
  bool _loadedSchedule;
  NSArray<CalendarCellView *> *_calendarCells;
  NSArray<CalendarCellViewModel *> *_viewModels;
  CalendarDataModel *_calendar;
  UIView *_cellContainer;
  UIButton *_saveButton;
  NSString *_professorEmail;
  NSString *_calendarID;
  id<DreamStore> _dreamStore;
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
    
    CalendarDataModel *dm = [CalendarDataModel empty];
    NSString *serialized = [dm toJSONString];
    CalendarDataModel *unserialized = [CalendarDataModel fromJSONString:serialized];
    NSLog(@"%@", unserialized);
  }
  return self;
}

int lengthInHours = 8;
int startTime = 9;

- (void)_setupAndPopulateInitialViewModels
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
  
  [self updateViewsWithBusyTimes:_calendar.events];
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
  if (!fetching && ![professorName isEqualToString:@""]) {
      _dreamStore = [DreamStoreAVM new];
      _calendarID = professorName;
      NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(readLoop) userInfo:nil repeats:YES];
      [timer fire];
      fetching = true;
  }
}


bool readDB = false;

-(void)readLoop
{
  if (!readDB) {
    
      readDB = true;
    
      [_dreamStore select:_calendarID onSuccess:^(NSString *object){
        if (object == (id)[NSNull null]) {
          _calendar = [CalendarDataModel empty];
        } else {
          _calendar = [CalendarDataModel fromJSONString:object];
        }
        readDB = false;
        
        [self performSelectorOnMainThread:@selector(_updateViewsAfterServerRead) withObject:nil waitUntilDone:NO];
        
      } onFailure:^(NSString *error){
        readDB = false;
      }];
  }
}

-(void)_updateViewsAfterServerRead
{
  [_saveButton setHidden:NO];
  [self _setupAndPopulateInitialViewModels];
  [_descriptionLabel setText:_calendar.professorName];
  [_loadingView setHidden:YES];
  _loadedSchedule = true;
  [self setNeedsLayout];
}

-(void)updateViewsWithBusyTimes:(NSArray<CalendarEventDataModel *> *)busyTimes
{
  for (CalendarCellViewModel * viewModel in _viewModels) {
    viewModel.available = true;
    viewModel.editable = true;
    
    for (CalendarEventDataModel *busyTime in busyTimes) {
      if ([viewModel.actualTime isEqualToDate:busyTime.startDate]) {
        viewModel.available = false;
      }
    }
  }
  
  [self _updateViews];
}

-(void)failedToDetermineProfessorName
{
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
      NSMutableArray *mutatedEvents = [NSMutableArray arrayWithArray:_calendar.events];
      if (viewModel.available) {
        CalendarEventDataModel *newEvent = [[CalendarEventDataModel alloc] initWithStartDate:viewModel.actualTime endDate:[viewModel.actualTime dateByAddingTimeInterval:30*60]];
        [mutatedEvents addObject:newEvent];
      } else {
        for (CalendarEventDataModel *event in _calendar.events) {
          if ([event.startDate isEqualToDate:viewModel.actualTime]) {
            [mutatedEvents removeObject:event];
            break;
          }
        }
      }
      _calendar.events = mutatedEvents;
      
      [_dreamStore update:[_calendar toJSONString] toKey:_calendarID onSuccess:^(id obj){
      } onFailure:^(id failure){}];
      
      [self _setupAndPopulateInitialViewModels];
    }
    
  }
  
  CGPoint tapInButton = [self convertPoint:tap toView:_saveButton];
  
  if(tapInButton.y > 0 && tapInButton.y < _saveButton.frame.size.height) {
    [self submit];
  }
  
}

-(void)submit
{
  [_dreamStore commitWithOnSuccess:^(id obj){
    [self performSelectorOnMainThread:@selector(_displaySuccessAlert) withObject:nil waitUntilDone:NO];
  } onFailure:^(id failure){}];
}

-(void)_displaySuccessAlert
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Successfully modified calendar." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
  [alert show];
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
