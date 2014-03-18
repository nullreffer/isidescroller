//
//  Block.h
//  SideScroller
//
//  Created by Jay Desai on 4/3/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sprite.h"
#import "Character.h"
#import "Level.h"

@interface Block : NSObject

typedef enum {
    BLOCK_NOTHING,
    BLOCK_STANDARD,
    BLOCK_BREAKABLE,
    //BLOCK_GRAVITY_SHIFT_LEFT,
    //BLOCK_GRAVITY_SHIFT_RIGHT,
    BLOCK_GRAVITY_SHIFT_TOP,
    BLOCK_GRAVITY_SHIFT_BOTTOM,
    BLOCK_BOUNCER,
    BLOCK_FINISH,
    BLOCK_SPIKES,
    BLOCK_STAIRS,
    BLOCK_LADDDER,
    BLOCK_PORTAL_RED,
    BLOCK_PORTAL_BLUE,
    BLOCK_PORTAL_GREEN,
    BLOCK_DOOR_RED,
    BLOCK_DOOR_BLUE,
    BLOCK_DOOR_GREEN,
    BLOCK_PICKABLE,
    BLOCK_PUSHABLE
} _BLOCK_TYPE_ENUM;

@property _BLOCK_TYPE_ENUM BLOCK_TYPE;

@property bool isBroken;

@property Sprite *blockSprite;

- (id) initBlockOfType:(NSString*) type andPositionX:(int)x andPositionY:(int)y withinLevel:(Level*)level;

- (void)draw:(long)ms withHorizontalOffset:(float)horizontalOffset;

- (bool) doAction;

- (void) onCollideFromTop:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity retX:(float*)new_new_x retY:(float*)new_new_y;

- (void) onCollideFromBottom:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity retX:(float*)new_new_x retY:(float*)new_new_y;

- (void) onCollideFromLeft:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity retX:(float*)new_new_x retY:(float*)new_new_y;

- (void) onCollideFromRight:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity retX:(float*)new_new_x retY:(float*)new_new_y;

- (void) onCollisionComplete:(Character*)character;

@end
