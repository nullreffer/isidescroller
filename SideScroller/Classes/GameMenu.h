//
//  GameMenu.h
//  SideScroller
//
//  Created by Jay Desai on 4/13/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"

@interface GameMenu : NSObject

typedef enum {

    MENU_MAIN = 3,
    MENU_SELECT_LEVEL = 4,
    MENU_SETTINGS = 5,
    MENU_SCORES = 6,
    MENU_ABOUT = 7

} _MENU_STATE_ENUM;

- (id)initMenuForGame:(Game*)game;

- (void)draw:(long)ms;

- (void) handleTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;

- (void) handleTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;

- (void) handleTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;

- (void) handleTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event;

@end
