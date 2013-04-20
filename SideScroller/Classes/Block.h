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
    GRAVITY_LEFT,
    GRAVITY_RIGHT,
    GRAVITY_TOP,
    GRAVITY_BOTTOM,
    BOUNCER,
    COIN,
    POTION,
    SPIKES,
    PORTAL
    
} _BLOCK_TYPE_ENUM;

@property Sprite *blockSprite;

- (id) initBlockOfType:(NSString*) type andPositionX:(int)x andPositionY:(int)y;

- (void)draw:(long)ms withHorizontalOffset:(float)horizontalOffset;

-(void) onCollideWithChar:(Character*)character inLevel:(Level*)level;

@end
