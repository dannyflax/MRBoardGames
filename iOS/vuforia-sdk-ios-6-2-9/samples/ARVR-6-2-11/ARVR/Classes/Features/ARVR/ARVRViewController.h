/*===============================================================================
Copyright (c) 2016 PTC Inc. All Rights Reserved.

Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/

#import <UIKit/UIKit.h>
#import "ARVREAGLView.h"
#import "SampleApplicationSession.h"
#import <Vuforia/DataSet.h>

typedef NS_ENUM(NSInteger, ARVRDisplayMode) {
    MobileAR,
    MobileVR,
    ViewerAR,
    ViewerVR
};

@interface ARVRViewController : UIViewController <SampleApplicationControl> {
    
    Vuforia::DataSet*  dataSetCurrent;
    Vuforia::DataSet*  dataSetTarmac;
    Vuforia::DataSet*  dataSetStonesAndChips;
    
    BOOL switchToTarmac;
    BOOL switchToStonesAndChips;
    
    // menu options
    BOOL extendedTrackingEnabled;
    BOOL continuousAutofocusEnabled;
    BOOL flashEnabled;
    BOOL frontCameraEnabled;
}

@property (nonatomic, strong) ARVREAGLView* eaglView;
@property (nonatomic, strong) UITapGestureRecognizer * tapGestureRecognizer;
@property (nonatomic, strong) SampleApplicationSession * vapp;

@property (nonatomic, readwrite) ARVRDisplayMode displayMode;

@end
