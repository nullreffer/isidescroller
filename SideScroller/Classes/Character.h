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

typedef enum {
    STRAIGHT_MOVEMENT,
    PURSUE_CHARACTER,
    NO_MOVEMENT
} _AUTO_MOVE;

@property bool isProtagonist;

@property bool isDead;

@property CGPoint position;
@property float direction;
@property float lastDirection;

@property AnimatedSprite* characterImage;
@property CGSize characterSize;

@property Level* level;

@property NSMutableDictionary *addons;

@property _AUTO_MOVE autoMovement;
@property int autoDirection;

- (id) initProtagonistWithPositionX:(int)x andPositionY:(int)y andImage:(UIImage*)image andLevel:(Level*)level;

- (id) initCharacterWithPositionX:(int)x andPositionY:(int)y andImage:(UIImage*)image andLevel:(Level*)level;

- (void) initiateJumpWithForce:(float)force;

- (void) doBActionWithJoystickDirection:(float)direction;

- (void) updateAI:(long)ms againstCharacter:(Character*)theman;

- (void) update:(long)ms ;

- (void) update:(long)ms withJoystickSpeed:(float)speed andDirection:(float)direction;

- (void) draw:(long)ms withHorizontalOffset:(float)horizontalOffset;

- (void) removeLife;

@end
