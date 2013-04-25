//
//  AnimatedSprite.h
//  SideScroller
//
//  Created by Jay Desai on 4/7/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sprite.h"

@interface AnimatedSprite : NSObject

@property Sprite* framesSprite;

@property int currentFrame;
@property int previousFrame;

- (id)initWithImage:(UIImage *)image andManualFlip:(bool)manualFlip;


- (void)render:(long)ms frame:(int)frame withSize:(CGSize)size atX:(int)x andY:(int)y;

- (void)render:(long)ms frame:(int)frame withSize:(CGSize)size atX:(int)x andXOffset:(int)xoffset andY:(int)y andYOffset:(int)yoffset;

- (void)render:(long)ms frame:(int)frame withSize:(CGSize)size atX:(int)x andXOffset:(int)xoffset andY:(int)y andYOffset:(int)yoffset flippedHorizontally:(bool)horz flippedVertically:(bool)vert;

- (CGRect) enclosingRect;

@end
