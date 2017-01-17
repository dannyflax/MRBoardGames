//
//  CalendarCellView.m
//  MRBoardGames
//
//  Created by Danny Flax on 12/6/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import "CalendarCellView.h"

static const int kPaddingX = 30.0f;

@implementation CalendarCellView
{
  CalendarCellViewModel *_viewModel;
  UILabel *_eventTitleLabel;
  UILabel *_eventTimeLabel;
}

- (id)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    _eventTitleLabel = [UILabel new];
    _eventTimeLabel = [UILabel new];
    
    [self addSubview:_eventTitleLabel];
    [self addSubview:_eventTimeLabel];
    
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor blackColor].CGColor;
  }
  return self;
}

- (void)layoutSubviews
{
  [_eventTitleLabel sizeToFit];
  [_eventTimeLabel sizeToFit];
  
  CGRect labelFrame = _eventTimeLabel.frame;
  labelFrame.origin.x = kPaddingX;
  labelFrame.origin.y = self.frame.size.height/2.0 - labelFrame.size.height/2.0;
  _eventTimeLabel.frame = labelFrame;
  
  labelFrame = _eventTitleLabel.frame;
  labelFrame.origin.x = kPaddingX + 50 + kPaddingX;
  labelFrame.origin.y = self.frame.size.height/2.0 - labelFrame.size.height/2.0;
  _eventTitleLabel.frame = labelFrame;
}

- (void)setViewModel:(CalendarCellViewModel *)viewModel
{
  _viewModel = viewModel;
  
  _eventTitleLabel.text = _viewModel.eventTitle;
  _eventTimeLabel.text = _viewModel.eventTime;
  
  UIColor *bookedColor = _viewModel.editable ? [UIColor greenColor] : [UIColor redColor];
  self.backgroundColor = _viewModel.available ? [UIColor whiteColor] : bookedColor;
  self.enabled = _viewModel.editable;
  
  [self setNeedsLayout];
}
@end
