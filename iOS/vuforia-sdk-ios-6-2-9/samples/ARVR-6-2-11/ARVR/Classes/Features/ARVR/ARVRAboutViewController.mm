/*===============================================================================
 Copyright (c) 2016 PTC Inc. All Rights Reserved.
 
 Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of PTC Inc., registered in the United States and other
 countries.
 ===============================================================================*/

#import "ARVRAboutViewController.h"
#import "ARVRViewController.h"

@interface ARVRAboutViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *uiWebView;

@end

@implementation ARVRAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadWebView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissAppController:)
                                                 name:@"kDismissAppViewController"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // We ensure the navigation bar is shown
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self setUiWebView:nil];
}
- (IBAction)onMobileAR:(id)sender {
    [self performSegueWithIdentifier:@"PushMobileAR" sender:self];
}
- (IBAction)onMobileVR:(id)sender {
    [self performSegueWithIdentifier:@"PushMobileVR" sender:self];
}
- (IBAction)onViewerAR:(id)sender {
    [self performSegueWithIdentifier:@"PushViewerAR" sender:self];
}
- (IBAction)onViewerVR:(id)sender {
    [self performSegueWithIdentifier:@"PushViewerVR" sender:self];
}


//------------------------------------------------------------------------------
//#pragma mark - Autorotation
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)shouldAutorotate {
    return NO;
}

//------------------------------------------------------------------------------
#pragma mark - Private

- (void) dismissAppController:(id) sender
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)loadWebView
{
    self.uiWebView.delegate = self;
    
    //  Load html from a local file for the about screen
    NSString *aboutFilePath = [[NSBundle mainBundle] pathForResource:@"ARVR_about"
                                                              ofType:@"html"];
    
    NSString* htmlString = [NSString stringWithContentsOfFile:aboutFilePath
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    
    NSString *aPath = [[NSBundle mainBundle] bundlePath];
    NSURL *anURL = [NSURL fileURLWithPath:aPath];
    [self.uiWebView loadHTMLString:htmlString baseURL:anURL];
}


//------------------------------------------------------------------------------
#pragma mark - UIWebViewDelegate

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
    //  Opens the links within this UIWebView on a safari web browser
    
    BOOL retVal = NO;
    
    if ( inType == UIWebViewNavigationTypeLinkClicked )
    {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
    }
    else
    {
        retVal = YES;
    }
    
    return retVal;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *dest = [segue destinationViewController];
    if ([dest isKindOfClass:[ARVRViewController class]]) {
        ARVRViewController * vc = (ARVRViewController *) dest;
        
        // Make sure your segue name in storyboard is the same as this line
        if ([[segue identifier] isEqualToString:@"PushMobileAR"])
        {
            vc.displayMode = MobileAR;
        } else if ([[segue identifier] isEqualToString:@"PushMobileVR"])
        {
            vc.displayMode = MobileVR;
        } else if ([[segue identifier] isEqualToString:@"PushViewerAR"])
        {
            vc.displayMode = ViewerAR;
        } else if ([[segue identifier] isEqualToString:@"PushViewerVR"])
        {
            vc.displayMode = ViewerVR;
        }
    }
}



@end
