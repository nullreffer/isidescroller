//
//  Bullet.h
//  SideScroller
//
//  Created by Jay Desai on 4/25/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Character.h"
#import "Level.h"

@interface Bullet : NSObject

typedef enum {
    COLLIDING_STRAIGHT_BULLET,
    NONCOLLIDING_STRAIGHT_BULLET,
    COLLIDING_LINEAR_BULLET,
    COLLIDING_QUADRATIC_BULLET,
    NONCOLLIDING_LINEAR_BULLET,
    NONCOLLIDING_QUADRATIC_BULLET
} _BULLET_TYPE;

@property _BULLET_TYPE bulletType;
@property Character *owner;

- (id) initWithImage:(UIImage*)image ofType:(_BULLET_TYPE)type ownedBy:(Character*)owner atX:(float)x andY:(float)y withDirection:(float)direction andForce:(float)force;

- (bool) update;

- (void) draw:(long)ms withHorizontalOffset:(float)horizontalOffset ;

@end
