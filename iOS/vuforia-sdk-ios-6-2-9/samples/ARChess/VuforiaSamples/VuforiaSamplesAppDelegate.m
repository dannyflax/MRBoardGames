/*===============================================================================
Copyright (c) 2015 PTC Inc. All Rights Reserved.

 Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of PTC Inc., registered in the United States and other
 countries.
 ===============================================================================*/

#import "VuforiaSamplesAppDelegate.h"

#import "AppAuth.h"

@interface VuforiaSamplesAppDelegate ()

@end

@implementation VuforiaSamplesAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if (self.glResourceHandler) {
        // Delete OpenGL resources (e.g. framebuffer) of the SampleApp AR View
        [self.glResourceHandler freeOpenGLESResources];
        [self.glResourceHandler finishOpenGLESCommands];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*! @brief Handles inbound URLs. Checks if the URL matches the redirect URI for a pending
 AppAuth authorization request.
 */
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *, id> *)options {
  // Sends the URL to the current authorization flow (if any) which will process it if it relates to
  // an authorization response.
  if ([_currentAuthorizationFlow resumeAuthorizationFlowWithURL:url]) {
    _currentAuthorizationFlow = nil;
    return YES;
  }
  
  // Your additional URL handling (if any) goes here.
  
  return NO;
}

/*! @brief Forwards inbound URLs for iOS 8.x and below to @c application:openURL:options:.
 @discussion When you drop support for versions of iOS earlier than 9.0, you can delete this
 method. NB. this implementation doesn't forward the sourceApplication or annotations. If you
 need these, then you may want @c application:openURL:options to call this method instead.
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  return [self application:application
                   openURL:url
                   options:@{}];
}

@end
