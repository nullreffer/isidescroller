//
//  Addon.h
//  SideScroller
//
//  Created by Jay Desai on 4/7/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sprite.h"

@interface Addon : NSObject

typedef enum {
    ADDON_STAR,
    ADDON_COLLIDING_STRAIGHT_GUN,
    ADDON_NONCOLLIDING_STRAIGHT_GUN,
    ADDON_COLLIDING_LINEAR_GUN,
    ADDON_COLLIDING_QUADRATIC_GUN,
    ADDON_NONCOLLIDING_LINEAR_GUN,
    ADDON_NONCOLLIDING_QUADRATIC_GUN,
    ADDON_RED_KEY,
    ADDON_GREEN_KEY,
    ADDON_BLUE_KEY,
    ADDON_JETPACK,
    ADDON_JUMPING_SHOES,
    ADDON_NOTHING
} _ADDON_TYPE;

@property _ADDON_TYPE type;
@property CGPoint position;
@property Sprite* addonSprite;

- (id) initAddonOfType:(NSString *)type andPositionX:(int)x andPositionY:(int)y;

- (id) initAddon:(_ADDON_TYPE)type andPositionX:(int)x andPositionY:(int)y;

- (void) execute;

- (void) draw:(long)ms withHorizontalOffset:(float)horizontalOffset ;

@end
