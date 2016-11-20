//
//  ChessPiecesFactory.m
//  MRBoardGames
//
//  Created by Danny Flax on 11/19/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import "ChessPiecesFactory.h"

@implementation ChessPiecesFactory
static const float kBoardSize = 200;
static const float kBoardPadding = 50.0;
static int numPieces = 0;

+ (NSArray *)createNewChessGame
{
  NSMutableArray *chessPieces = [NSMutableArray new];
  
  for (int side = 0; side < 2; side++) {
    bool isWhite = (side == 0);
    
    int backRow = (side == 0) ? 7 : 0;
    int secondRow = (side == 0) ? 6 : 1;
    
    for (int i = 0; i < 8; i++) {
      ChessObject *pawn = (ChessObject *)[ChessPiecesFactory createNewPawn];
      pawn.location = [ChessPiecesFactory getLocationForX:i Y:secondRow];
      pawn.isWhite = isWhite;
      [chessPieces addObject:pawn];
    }
    
    for (int i = 0; i < 2; i++) {
      ChessObject *rook = (ChessObject *)[ChessPiecesFactory createNewRook];
      rook.location = [ChessPiecesFactory getLocationForX:(i == 0) ? 0 : 7 Y:backRow];
      [chessPieces addObject:rook];
      rook.isWhite = isWhite;
      
      ChessObject *knight = (ChessObject *)[ChessPiecesFactory createNewKnight];
      knight.location = [ChessPiecesFactory getLocationForX:(i == 0) ? 1 : 6 Y:backRow];
      [chessPieces addObject:knight];
      knight.isWhite = isWhite;
      
      ChessObject *bishop = (ChessObject *)[ChessPiecesFactory createNewBishop];
      bishop.location = [ChessPiecesFactory getLocationForX:(i == 0) ? 2 : 5 Y:backRow];
      [chessPieces addObject:bishop];
      bishop.isWhite = isWhite;
    }
    
    ChessObject *queen = (ChessObject *)[ChessPiecesFactory createNewQueen];
    queen.location = [ChessPiecesFactory getLocationForX:3 Y:backRow];
    [chessPieces addObject:queen];
    queen.isWhite = isWhite;
    
    ChessObject *king = (ChessObject *)[ChessPiecesFactory createNewKing];
    king.location = [ChessPiecesFactory getLocationForX:4 Y:backRow];
    [chessPieces addObject:king];
    king.isWhite = isWhite;
  }
  
  return chessPieces;
}

+(BaseObject *)createNewQueen
{
  NSString *identifier = [NSString stringWithFormat:@"%@%i", kQueenName, numPieces];
  numPieces++;
  
  Point3D *dimensions = [[Point3D alloc] initWithX:13.46
                                                 Y:13.46
                                                 Z:29.949];
  
  return [[ChessObject alloc] initWithProperties:identifier HolderId:[NSNumber numberWithInt:0] Location:[Point3D zero] Dimensions:dimensions Scale:10.0 AndMeshName:kQueenName];
}

+(BaseObject *)createNewPawn
{
  NSString *identifier = [NSString stringWithFormat:@"%@%i", kPawnName, numPieces];
  numPieces++;
  
  Point3D *dimensions = [[Point3D alloc] initWithX:13.46
                                                 Y:13.46
                                                 Z:20.67];
  
  return [[ChessObject alloc] initWithProperties:identifier HolderId:[NSNumber numberWithInt:0] Location:[Point3D zero] Dimensions:dimensions Scale:10.0 AndMeshName:kPawnName];
}

+(BaseObject *)createNewKing
{
  NSString *identifier = [NSString stringWithFormat:@"%@%i", kKingName, numPieces];
  numPieces++;
  
  Point3D *dimensions = [[Point3D alloc] initWithX:13.46
                                                 Y:13.46
                                                 Z:36.47];
  
  return [[ChessObject alloc] initWithProperties:identifier HolderId:[NSNumber numberWithInt:0] Location:[Point3D zero] Dimensions:dimensions Scale:10.0 AndMeshName:kKingName];
}

+(BaseObject *)createNewRook
{
  NSString *identifier = [NSString stringWithFormat:@"%@%i", kRookName, numPieces];
  numPieces++;
  
  Point3D *dimensions = [[Point3D alloc] initWithX:13.46
                                                 Y:13.46
                                                 Z:20.67];
  
  return [[ChessObject alloc] initWithProperties:identifier HolderId:[NSNumber numberWithInt:0] Location:[Point3D zero] Dimensions:dimensions Scale:10.0 AndMeshName:kRookName];
}


+(BaseObject *)createNewKnight
{
  NSString *identifier = [NSString stringWithFormat:@"%@%i", kKnightName, numPieces];
  numPieces++;
  
  Point3D *dimensions = [[Point3D alloc] initWithX:15.00
                                                 Y:13.46
                                                 Z:22.73];
  
  return [[ChessObject alloc] initWithProperties:identifier HolderId:[NSNumber numberWithInt:0] Location:[Point3D zero] Dimensions:dimensions Scale:10.0 AndMeshName:kKnightName];
}


+(BaseObject *)createNewBishop
{
  NSString *identifier = [NSString stringWithFormat:@"%@%i", kBishopName, numPieces];
  numPieces++;
  
  Point3D *dimensions = [[Point3D alloc] initWithX:13.46
                                                 Y:13.46
                                                 Z:26.26];
  
  return [[ChessObject alloc] initWithProperties:identifier HolderId:[NSNumber numberWithInt:0] Location:[Point3D zero] Dimensions:dimensions Scale:10.0 AndMeshName:kBishopName];
}


+ (Point3D *)getLocationForX:(int)tileX Y:(int)tileY
{
  Point3D *point = [Point3D zero];
  
  point.x = -kBoardSize/2.0 + kBoardSize/16.0 + tileX*kBoardSize/8.0;
  point.y = -kBoardSize/2.0 + kBoardSize/16.0 + tileY*kBoardSize/8.0;
  
  return point;
}

@end
