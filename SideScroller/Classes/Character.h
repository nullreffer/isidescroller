//
//  Character.h
//  SideScroller
//
//  Created by Jay Desai on 4/3/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnimatedSprite.h"

@class Level;

@interface Character : NSObject

@property bool isDead;

@property CGPoint position;

@property AnimatedSprite* characterImage;

@property Level* level;

@property NSMutableDictionary *addons;

- (id) initCharacterWithPositionX:(int)x andPositionY:(int)y andImage:(UIImage*)image andLevel:(Level*)level;

- (void) initiateJumpWithForce:(float)force;

- (void) update:(long)ms ;

- (void) update:(long)ms withJoystickSpeed:(float)speed andDirection:(float)direction;

- (void) draw:(long)ms withHorizontalOffset:(float)horizontalOffset;

@end
