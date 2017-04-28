// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "NumberRecognizer.h"

@interface NumberRecognizer ()

@end

@implementation NumberRecognizer

static int numberOfRequests = 0;
static bool cancelingRequests = false;

+ (UIImage *) resizeImage: (UIImage*) image toSize: (CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSString *) base64EncodeImage: (UIImage*)image {
    NSData *imagedata = UIImagePNGRepresentation(image);
    
    // Resize the image if it exceeds the 2MB API limit
//    if ([imagedata length] > 2097152) {
        CGSize oldSize = [image size];
        CGSize newSize = CGSizeMake(800, oldSize.height / oldSize.width * 800);
        image = [NumberRecognizer resizeImage: image toSize: newSize];
        imagedata = UIImagePNGRepresentation(image);
//    }
  
    NSString *base64String = [imagedata base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    return base64String;
}

+ (void) createRequest: (UIImage*)image onSuccess:(NumberRecognizerSuccessBlock)success onFailure:(NumberRecognizerErrorBlock)failure{
    // Create our request URL

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSString *imageData = [NumberRecognizer base64EncodeImage:image];
      
      
      NSString *urlString = @"https://vision.googleapis.com/v1/images:annotate?key=";
      NSString *API_KEY = @"AIzaSyC75pElYcTO6tZd5M4Go7dtm89YXi87Tbc";
      
      NSString *requestString = [NSString stringWithFormat:@"%@%@", urlString, API_KEY];
      
      NSURL *url = [NSURL URLWithString: requestString];
      NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
      [request setHTTPMethod: @"POST"];
      [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
      [request
       addValue:[[NSBundle mainBundle] bundleIdentifier]
       forHTTPHeaderField:@"X-Ios-Bundle-Identifier"];
      
      // Build our API request
      NSDictionary *paramsDictionary =
      @{@"requests":@[
            @{@"image":
                @{@"content":imageData},
              @"features":@[
                  @{@"type":@"TEXT_DETECTION",
                    @"maxResults":@10}]}]};
      
      NSError *error;
      NSData *requestData = [NSJSONSerialization dataWithJSONObject:paramsDictionary options:0 error:&error];
      [request setHTTPBody: requestData];
      
      numberOfRequests++;
      
      // Run the request on a background thread
      [NumberRecognizer runRequestOnBackgroundThread:request onSuccess:success onFailure:failure];
    });
  
  
}

+ (void)runRequestOnBackgroundThread: (NSMutableURLRequest*)request onSuccess:(NumberRecognizerSuccessBlock)success onFailure:(NumberRecognizerErrorBlock)failure{
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^ (NSData *data, NSURLResponse *response, NSError *error) {
      numberOfRequests--;
      if (cancelingRequests) {
        if (numberOfRequests == 0) {
          cancelingRequests = false;
        }
      } else {
        [NumberRecognizer analyzeResults:data onSuccess:success onFailure:failure];
      }
    }];
    [task resume];
}

+ (void)cancelAllCurrentRequests
{
  if (numberOfRequests > 0) {
    cancelingRequests = true;
  }
}

+ (void)analyzeResults: (NSData*)dataToParse onSuccess:(NumberRecognizerSuccessBlock)success onFailure:(NumberRecognizerErrorBlock)failure{
    
    // Update UI on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSError *e = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataToParse options:kNilOptions error:&e];
        
        NSArray *responses = [json objectForKey:@"responses"];
        NSDictionary *responseData = [responses objectAtIndex: 0];
        NSDictionary *errorObj = [json objectForKey:@"error"];
        
        // Check for errors
        if (errorObj) {
            NSString *errorString1 = @"Error code ";
            NSString *errorCode = [errorObj[@"code"] stringValue];
            NSString *errorString2 = @": ";
            NSString *errorMsg = errorObj[@"message"];
            NSString *fullError = [NSString stringWithFormat:@"%@ %@ %@ %@", errorString1, errorCode, errorString2, errorMsg];
            failure(fullError);
        } else {
            // Get label annotations
            NSDictionary *textAnnotations = [responseData objectForKey:@"textAnnotations"];
          
            NSMutableArray *texts = [NSMutableArray new];
          
            for(NSDictionary *annotation in textAnnotations)
            {
              [texts addObject:[annotation objectForKey:@"description"]];
            }
          
            success(texts);
        }
    });
    
}

@end
