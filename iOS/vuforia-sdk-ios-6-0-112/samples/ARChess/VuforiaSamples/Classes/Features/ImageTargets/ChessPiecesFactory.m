//
//  ChessPiecesFactory.m
//  MRBoardGames
//
//  Created by Danny Flax on 11/19/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import "ChessPiecesFactory.h"

@implementation ChessPiecesFactory

static int numPieces = 0;

+(BaseObject *)createNewQueen
{
  NSString *identifier = [NSString stringWithFormat:@"%@%i", kQueenName, numPieces];
  numPieces++;
  
  Point3D *dimensions = [[Point3D alloc] initWithX:13.46
                                                 Y:13.46
                                                 Z:29.949];
  
  return [[BaseObject alloc] initWithProperties:identifier HolderId:[NSNumber numberWithInt:0] Location:[Point3D zero] Dimensions:dimensions Scale:10.0 AndMeshName:kQueenName];
}

+(BaseObject *)createNewPawn
{
  NSString *identifier = [NSString stringWithFormat:@"%@%i", kPawnName, numPieces];
  numPieces++;
  
  Point3D *dimensions = [[Point3D alloc] initWithX:13.46
                                                 Y:13.46
                                                 Z:20.67];
  
  return [[BaseObject alloc] initWithProperties:identifier HolderId:[NSNumber numberWithInt:0] Location:[Point3D zero] Dimensions:dimensions Scale:10.0 AndMeshName:kPawnName];
}

+(BaseObject *)createNewKing
{
  NSString *identifier = [NSString stringWithFormat:@"%@%i", kKingName, numPieces];
  numPieces++;
  
  Point3D *dimensions = [[Point3D alloc] initWithX:13.46
                                                 Y:13.46
                                                 Z:36.47];
  
  return [[BaseObject alloc] initWithProperties:identifier HolderId:[NSNumber numberWithInt:0] Location:[Point3D zero] Dimensions:dimensions Scale:10.0 AndMeshName:kKingName];
}

+(BaseObject *)createNewRook
{
  NSString *identifier = [NSString stringWithFormat:@"%@%i", kRookName, numPieces];
  numPieces++;
  
  Point3D *dimensions = [[Point3D alloc] initWithX:13.46
                                                 Y:13.46
                                                 Z:20.67];
  
  return [[BaseObject alloc] initWithProperties:identifier HolderId:[NSNumber numberWithInt:0] Location:[Point3D zero] Dimensions:dimensions Scale:10.0 AndMeshName:kRookName];
}


+(BaseObject *)createNewKnight
{
  NSString *identifier = [NSString stringWithFormat:@"%@%i", kKnightName, numPieces];
  numPieces++;
  
  Point3D *dimensions = [[Point3D alloc] initWithX:15.00
                                                 Y:13.46
                                                 Z:22.73];
  
  return [[BaseObject alloc] initWithProperties:identifier HolderId:[NSNumber numberWithInt:0] Location:[Point3D zero] Dimensions:dimensions Scale:10.0 AndMeshName:kKnightName];
}


+(BaseObject *)createNewBishop
{
  NSString *identifier = [NSString stringWithFormat:@"%@%i", kBishopName, numPieces];
  numPieces++;
  
  Point3D *dimensions = [[Point3D alloc] initWithX:13.46
                                                 Y:13.46
                                                 Z:26.26];
  
  return [[BaseObject alloc] initWithProperties:identifier HolderId:[NSNumber numberWithInt:0] Location:[Point3D zero] Dimensions:dimensions Scale:10.0 AndMeshName:kBishopName];
}

@end
