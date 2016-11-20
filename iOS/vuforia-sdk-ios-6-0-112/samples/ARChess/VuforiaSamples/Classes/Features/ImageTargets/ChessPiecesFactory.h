//
//  ChessPiecesFactory.h
//  MRBoardGames
//
//  Created by Danny Flax on 11/19/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChessObject.h"

static NSString *kQueenName = @"queen";
static NSString *kPawnName = @"pawn";
static NSString *kKingName = @"king";
static NSString *kRookName = @"rook";
static NSString *kKnightName = @"knight";
static NSString *kBishopName = @"bishop";

@interface ChessPiecesFactory : NSObject

+(BaseObject *)createNewQueen;
+(BaseObject *)createNewPawn;
+(BaseObject *)createNewKing;
+(BaseObject *)createNewRook;
+(BaseObject *)createNewKnight;
+(BaseObject *)createNewBishop;
@end
