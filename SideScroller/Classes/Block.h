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
    
    BLOCK_STANDARD,
    BLOCK_BREAKABLE,
    BLOCK_GRAVITY_SHIFT_LEFT,
    BLOCK_GRAVITY_SHIFT_RIGHT,
    BLOCK_GRAVITY_SHIFT_TOP,
    BLOCK_GRAVITY_SHIFT_BOTTOM,
    BLOCK_BOUNCER,
    BLOCK_FINISH,
    BLOCK_SPIKES,
    BLOCK_STAIRS,
    BLOCK_LADDER,
    BLOCK_PORTAL,
    BLOCK_DOOR_RED,
    BLOCK_DOOR_BLUE
    
} _BLOCK_TYPE_ENUM;

@property _BLOCK_TYPE_ENUM BLOCK_TYPE;

@property bool isBroken;

@property Sprite *blockSprite;

- (id) initBlockOfType:(NSString*) type andPositionX:(int)x andPositionY:(int)y;

- (void)draw:(long)ms withHorizontalOffset:(float)horizontalOffset;

- (void) onCollideFromTop:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity andGravityOffset:(CGPoint)gravityOffset retX:(float*)new_new_x retY:(float*)new_new_y;

- (void) onCollideFromBottom:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity andGravityOffset:(CGPoint)gravityOffset retX:(float*)new_new_x retY:(float*)new_new_y;

- (void) onCollideFromLeft:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity andGravityOffset:(CGPoint)gravityOffset retX:(float*)new_new_x retY:(float*)new_new_y;

- (void) onCollideFromRight:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity andGravityOffset:(CGPoint)gravityOffset retX:(float*)new_new_x retY:(float*)new_new_y;

- (void) onCollisionComplete:(Character*)character;

@end
