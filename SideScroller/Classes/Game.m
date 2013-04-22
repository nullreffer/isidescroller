//
//  Game.m
//  SideScroller
//
//  Created by Jay Desai on 3/31/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import "Game.h"
#import "GameMenu.h"
#import "Controls.h"
#import "Sprite.h"

@interface Game()

@property GameMenu* menu;
@property Controls* controls;

@end


@implementation Game

@synthesize GAME_STATE = _GAME_STATE;
@synthesize view = _view;
@synthesize menu = _menu;
@synthesize controls = _controls;
@synthesize currentLevel = _currentLevel;
@synthesize levels = _levels;

- (id)initWithCode:(NSString *)code  andConfig:(TBXMLElement*) config forView:(UIView *)view {
    
    if ([self init]){
        self.GAME_STATE = LOADING_APP;
        
        // Load levels
        self.levels = [[NSMutableDictionary alloc] init];
        
        TBXMLElement *levelsElement = [TBXML childElementNamed:@"levels" parentElement:config];
        TBXMLElement *levelElement = levelsElement->firstChild;
        
        do {
            NSString *levelId = [TBXML textForElement:[TBXML childElementNamed:@"id" parentElement:levelElement]];
            
            Level *l = [[Level alloc] initWithConfig:levelElement];
            
            [self.levels setObject:l forKey:levelId];
        } while ((levelElement = levelElement->nextSibling));
        
        self.menu = [[GameMenu alloc] initMenuForGame:self];
        self.GAME_STATE = MENU;
        
        self.view = view;
        
        self.controls = [[Controls alloc] initControlsForView:view];
        
        return self;
    }
    
    return nil;
}

- (void)update:(long)ms {
    
    float direction = [self.controls getJoystickDirection];
    
    if ([self.controls isAPressed]){
        [self.currentLevel doAPressed];
    }
    
    [self.currentLevel update:ms withJoystickSpeed:[self.controls getJoystickForce] andDirection:direction];
}

- (void)draw:(long)ms {
    
    if (self.GAME_STATE == LOADING_APP){
        return;
    }
    
    if (self.GAME_STATE == MENU){
        [self.menu draw:ms];
    } else if (self.GAME_STATE == PLAYING){
        [self.currentLevel draw:ms];
        [self.controls draw:ms];
    }
    
}


- (void) handleTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (self.GAME_STATE == MENU){
        [self.menu handleTouchesBegan:touches withEvent:event];
    } else if (self.GAME_STATE == PAUSED){
        // Depends on my pause dialog
    } else if (self.GAME_STATE == PLAYING){
        [self.controls handleTouchesBegan:touches withEvent:event];
    }
}

- (void) handleTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (self.GAME_STATE == MENU){
        [self.menu handleTouchesEnded:touches withEvent:event];
    } else if (self.GAME_STATE == PAUSED){
        // Depends on my pause dialog
    } else if (self.GAME_STATE == PLAYING){
        [self.controls handleTouchesEnded:touches withEvent:event];
    }
}

- (void) handleTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (self.GAME_STATE == MENU){
        [self.menu handleTouchesMoved:touches withEvent:event];
    } else if (self.GAME_STATE == PAUSED){
        // Depends on my pause dialog
    } else if (self.GAME_STATE == PLAYING){
        [self.controls handleTouchesMoved:touches withEvent:event];
        
        // [self.currentLevel.theman handleJoystickWithSpeed:[self.controls getJoystickForce] andDirection:[self.controls getJoystickDirection]];
    }
}

- (void) handleTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (self.GAME_STATE == PLAYING){
        self.GAME_STATE = PAUSED;
    }
    [self handleTouchesEnded:touches withEvent:event];
}

@end
