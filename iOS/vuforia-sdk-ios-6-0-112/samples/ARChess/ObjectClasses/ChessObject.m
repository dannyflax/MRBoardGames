//
//  ChessObject.m
//  MRBoardGames
//
//  Created by Danny Flax on 11/20/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import "ChessObject.h"

@implementation ChessObject

- (id)initWithProperties:(NSString *)name
                HolderId:(NSNumber *)playerNumber
                Location:(Point3D *)location
              Dimensions:(Point3D *)dimensions
                   Scale:(float)scale
             AndMeshName:(NSString *)meshName
                   White:(BOOL)white
{
  if (self = [super init]) {
    _isWhite = white;
  }
  return self;
}

- (id)initWithJSON:(NSData*)jsonData {
  
  self = [super init];
  if (self) {
    NSError *error = nil;
    NSDictionary *jsonObject=[NSJSONSerialization
                              JSONObjectWithData:jsonData
                              options:NSJSONReadingMutableLeaves
                              error:&error];
    
    if (error != nil) {
      NSLog(@"JSON did not parse correctly");
    } else {
      self.name = [jsonObject objectForKey:@"name"];
      self.holderId = [jsonObject objectForKey:@"holderId"];
      
      // reconstruct location from keys
      float posX = [[jsonObject objectForKey:@"xLocation"] floatValue];
      float posY = [[jsonObject objectForKey:@"yLocation"] floatValue];
      float posZ = [[jsonObject objectForKey:@"zLocation"] floatValue];
      self.location = [[Point3D alloc] initWithX:posX Y:posY Z:posZ];
      
      // reconstruct dimensions from keys
      float width = [[jsonObject objectForKey:@"width"] floatValue];
      float height = [[jsonObject objectForKey:@"height"] floatValue];
      float depth = [[jsonObject objectForKey:@"depth"] floatValue];
      self.dimensions = [[Point3D alloc] initWithX:width Y:height Z:depth];
      
      self.scale = [[jsonObject objectForKey:@"scale"] floatValue];
      
      self.meshName = [jsonObject objectForKey:@"meshName"];
      
      self.isWhite = [[jsonObject objectForKey:@"isWhite"] boolValue];
    }
  }
  
  return self;
}


- (NSData*)getJsonRepresentation {
  NSError *error = nil;
  NSData *json;
  NSDictionary *objectProperties = @{
                                     @"name" : self.name,
                                     @"holderId" : self.holderId,
                                     @"xLocation" : @(self.location.x),
                                     @"yLocation" : @(self.location.y),
                                     @"zLocation" : @(self.location.z),
                                     @"width" : @(self.dimensions.x),
                                     @"height" : @(self.dimensions.y),
                                     @"depth" : @(self.dimensions.z),
                                     @"scale" : @(self.scale),
                                     @"meshName" : self.meshName,
                                     @"isWhite" : @(self.isWhite)};
  
  if ([NSJSONSerialization isValidJSONObject:objectProperties]) {
    json = [NSJSONSerialization dataWithJSONObject:objectProperties options:NSJSONWritingPrettyPrinted error:&error];
    
  }
  
  // If an error occurred, print it out.
  if (error != nil) {
    NSLog(@"Error: %@", error);
  }
  
  return json;
}

@end
