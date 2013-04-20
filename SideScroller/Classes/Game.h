//
//  Game.h
//  SideScroller
//
//  Created by Jay Desai on 3/31/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"
#import "Level.h"


@interface Game : NSObject

typedef enum {
    
    LOADING_APP = 1,
    MENU = 2,
    LOADING_GAME = 8,
    PLAYING = 9,
    LEVEL_COMPLETE = 10,
    LEVEL_LOST = 11,
    PAUSED = 12
    
} _GAME_STATE_ENUM;

@property(atomic) _GAME_STATE_ENUM GAME_STATE;

@property(nonatomic, retain) UIView* view;

// Game levels/maps <from xml resource>
@property(nonatomic, retain) NSMutableDictionary *levels;
@property(nonatomic, retain) Level *currentLevel;

- (id)initWithCode:(NSString *)code andConfig:(TBXMLElement*) config forView:(UIView*)view;

- (void)update:(long)ms;

- (void)draw:(long)ms;

- (void) handleTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;

- (void) handleTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;

- (void) handleTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;

- (void) handleTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event;

@end
