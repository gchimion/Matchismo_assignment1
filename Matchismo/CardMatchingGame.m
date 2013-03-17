//
//  CardMatchingGame.m
//  Matchismo
//
//  Created by Martin Mandl on 09.02.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "CardMatchingGame.h"

@interface CardMatchingGame()

@property (readwrite, nonatomic) int score;

@property (readwrite, nonatomic) NSString *result;

@property (strong, nonatomic) NSMutableArray *cards; // of Card

@end

@implementation CardMatchingGame

- (NSMutableArray *)cards
{
    if (!_cards) {
        _cards = [[NSMutableArray alloc] init];
    }
    return _cards;
}

- (id)initWithCardCount:(NSUInteger)count
              usingDeck:(Deck *)deck
{
    self = [super init];
    
    if (self) {
        for (int i = 0; i < count; i++) {
            Card *card = [deck drawRandomCard];
            if (card) {
                self.cards[i] = card;
            } else {
                self = nil;
                break;
            }            
        }
    }
    
    self.score = 0;
    self.result = @"New Game";
    return self;
}

- (Card *)cardAtIndex:(NSUInteger)index
{
    return (index < [self.cards count] ? self.cards[index] : nil);
}

#define MATCH_BONUS_2_CARDS 4
#define MATCH_BONUS_3_CARDS 8
#define MISMATCH_PENALTY 2
#define FLIP_COST 1



- (void)flipCardAtIndex:(NSUInteger)index withThreeCardsGameMode:(BOOL)threeCardsGameMode
{
    Card *card = [self cardAtIndex:index];
    
    if (card && !card.isUnplayable) {
        if (!card.isFaceUp) {
            
            self.result =
                        [NSString stringWithFormat:@"%@ flipped up", card.contents];
            
            for (Card *secondCard in self.cards) {
                if (secondCard.isFaceUp && !secondCard.isUnplayable) {
                    
                    self.result =
                    [NSString stringWithFormat:@"%@ and %@ flipped up", card.contents,secondCard.contents];
                    
                    if (!threeCardsGameMode)
                    {
                        int matchScore = [card match:@[secondCard]];
                        if (matchScore) {
                            card.unplayable = YES;
                            secondCard.unplayable = YES;
                            self.score += matchScore * MATCH_BONUS_2_CARDS;
                            self.result =
                            [NSString stringWithFormat:@"Matched %@ and %@ for %d points", card.contents, secondCard.contents, MATCH_BONUS_2_CARDS];
                            
                        } else {
                            secondCard.faceUp = NO;
                            self.score -= MISMATCH_PENALTY;
                            self.result =
                            [NSString stringWithFormat:@"%@ and %@ don't match : %d points penalty", card.contents, secondCard.contents, MISMATCH_PENALTY];

                        }
                        break;
                    }
                    else
                        //3 cards game mode
                    {
                        
                       
                        
                        for (Card *thirdCard in self.cards){
                            
                            // check if 3rd card is faceup, then do the match
                            if (thirdCard.faceUp &&
                                ![thirdCard.contents isEqualToString:secondCard.contents]
                                && !secondCard.isUnplayable && !thirdCard.isUnplayable
                                ){
                                int matchScore = [card match:@[secondCard]]
                                + [card match:@[thirdCard]]
                                + [secondCard match:@[thirdCard]];
                                
                                
                                if (matchScore==3) {
                                    card.unplayable = YES;
                                    secondCard.unplayable = YES;
                                    thirdCard.unplayable = YES;
                                    self.score += matchScore * MATCH_BONUS_2_CARDS;
                                    self.result =
                                    [NSString stringWithFormat:@"Matched %@ and %@ and %@ for %d points", card.contents, secondCard.contents, thirdCard.contents, MATCH_BONUS_3_CARDS];
                                    
                                } else {
                                    secondCard.faceUp = NO;
                                    thirdCard.faceUp = NO;
                                    
                                    self.score -= MISMATCH_PENALTY;
                                    self.result =
                                    [NSString stringWithFormat:@"%@ and %@ and %@ don't match : %d points penalty", card.contents, secondCard.contents, thirdCard.contents, MISMATCH_PENALTY];
                                    
                                }
                                break;
                            }
                        }
                        //end for 
                        
                    }
                    
                }
            }
            self.score -= FLIP_COST;
        }
        card.faceUp = !card.faceUp;
    }
}



- (void)resetGame{
    self.score = 0;
    self.result = @"New Game";
}

    
@end
