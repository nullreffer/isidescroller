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
    
    STANDARD,
    BREAKABLE,
    STICKY,
    GRAVITY_SHIFT_LEFT,
    GRAVITY_SHIFT_RIGHT,
    GRAVITY_SHIFT_TOP,
    GRAVITY_SHIFT_BOTTOM,
    BOUNCER,
    COIN,
    POTION,
    SPIKES,
    STAIRS,
    LADDER,
    PORTAL
    
} _BLOCK_TYPE_ENUM;

@property _BLOCK_TYPE_ENUM BLOCK_TYPE;

@property Sprite *blockSprite;

- (id) initBlockOfType:(NSString*) type andPositionX:(int)x andPositionY:(int)y;

- (void)draw:(long)ms withHorizontalOffset:(float)horizontalOffset;

- (void) onCollideFromTop:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity andGravityOffset:(CGPoint)gravityOffset retX:(float*)new_new_x retY:(float*)new_new_y;

- (void) onCollideFromBottom:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity andGravityOffset:(CGPoint)gravityOffset retX:(float*)new_new_x retY:(float*)new_new_y;

- (void) onCollideFromLeft:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity andGravityOffset:(CGPoint)gravityOffset retX:(float*)new_new_x retY:(float*)new_new_y;

- (void) onCollideFromRight:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity andGravityOffset:(CGPoint)gravityOffset retX:(float*)new_new_x retY:(float*)new_new_y;

- (void) onCollisionComplete:(Character*)character;

@end
