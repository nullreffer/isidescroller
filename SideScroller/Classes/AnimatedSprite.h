//
//  AnimatedSprite.h
//  SideScroller
//
//  Created by Jay Desai on 4/7/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnimatedSprite : NSObject

@property int currentFrame;
@property CGRect enclosingRect;

- (id)initWithImage:(UIImage *)image ofFrameWidth:(float)width;

- (id)initWithImage:(UIImage *)image ofFrameWidth:(float)width andManualFlip:(bool)manualFlip;


- (void)render:(long)ms frame:(int)frame withSize:(CGSize)size atX:(int)x andY:(int)y;

- (void)render:(long)ms frame:(int)frame withSize:(CGSize)size atX:(int)x andXOffset:(int)xoffset andY:(int)y andYOffset:(int)yoffset;

- (void)render:(long)ms frame:(int)frame withSize:(CGSize)size atX:(int)x andXOffset:(int)xoffset andY:(int)y andYOffset:(int)yoffset flippedHorizontally:(bool)horz flippedVertically:(bool)vert;

@end
