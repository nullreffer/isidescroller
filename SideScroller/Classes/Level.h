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

- (id)initWithConfig:(TBXMLElement*) config;

- (void)load;

- (void)unload;

-(void)update:(long)ms withJoystickSpeed:(float)speed andDirection:(float)direction;

-(void) doAPressed;

- (void)draw:(long)ms;

@property int width;
@property int height;

@property float gravity;
@property bool verticalGravity;

@property CGPoint gravityLocation;

@property float horizontalOffset;

@property(nonatomic, retain) NSMutableArray *blocks;

@property Character* theman;
@property(nonatomic, retain) NSMutableArray *characters;

@end
