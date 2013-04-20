//
//  AnimatedSprite.h
//  SideScroller
//
//  Created by Jay Desai on 4/7/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnimatedSprite : NSObject

- (id) initAnimatedSpriteWithFile:(NSString*)file andSpriteWidth:(int)width andInterval:(int)interval;

- (void) draw:(long)ms;

@end
