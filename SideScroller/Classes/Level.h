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

@interface Level : NSObject

typedef enum {
    GRAVITY_LEFT ,
    GRAVITY_RIGHT,
    GRAVITY_TOP,
    GRAVITY_BOTTOM
} _GRAVITY_POSITION;

@property int width;
@property int height;

@property float horizontalOffset;

@property _GRAVITY_POSITION gravityPosition;

@property(nonatomic, retain) NSMutableArray *blocks;

@property Character* theman;
@property(nonatomic, retain) NSMutableArray *characters;

- (id)initWithConfig:(TBXMLElement*) config;

- (void)load;

- (void)unload;

-(void)update:(long)ms withJoystickSpeed:(float)speed andDirection:(float)direction;

-(void) doAPressed;

- (void)draw:(long)ms;

@end
