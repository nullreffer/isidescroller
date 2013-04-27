//
//  Level.h
//  SideScroller
//
//  Created by Jay Desai on 4/3/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"
#import "Block.h"
#import "Character.h"

@class Game;

@interface Level : NSObject

typedef enum {
    
    LEVEL_PLAYING,
    LEVEL_COMPLETE,
    LEVEL_LOST,
    LEVEL_PAUSED
    
} _LEVEL_STATE_ENUM;

@property(atomic) _LEVEL_STATE_ENUM levelState;

typedef enum {
    GRAVITY_LEFT,
    GRAVITY_RIGHT,
    GRAVITY_TOP,
    GRAVITY_BOTTOM,
    GRAVITY_NONE
} _GRAVITY_POSITION;

@property int width;
@property int height;

@property float horizontalOffset;

@property _GRAVITY_POSITION gravityPosition;

@property(nonatomic, retain) NSMutableArray *blocks;

@property Character* theman;
@property(nonatomic, retain) NSMutableArray *characters;

// bullets have levels, but they apply to the entire level
@property NSMutableArray *addons;

- (id)initWithConfig:(TBXMLElement*)config forGame:(Game*)game;

- (void)load;

- (void)unload;

- (void)update:(long)ms withJoystickSpeed:(float)speed andDirection:(float)direction;

- (void) doAPressed;

- (void) doBPressedWithJoystickDirection:(float)direction;

- (void)draw:(long)ms;

@end
