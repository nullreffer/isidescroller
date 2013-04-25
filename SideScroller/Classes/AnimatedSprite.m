//
//  AnimatedSprite.m
//  SideScroller
//
//  Created by Jay Desai on 4/7/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import "AnimatedSprite.h"
#import "Sprite.h"

@interface AnimatedSprite()

@property Sprite* framesSprite;

@property CGSize fullSize;

@end

@implementation AnimatedSprite

@synthesize currentFrame = _currentFrame;
@synthesize previousFrame = _previousFrame;
@synthesize fullSize = _fullSize;

- (id)initWithImage:(UIImage *)image andManualFlip:(bool)manualFlip {

    if ([self init]){
        self.currentFrame = 0;
        
        self.framesSprite = [[Sprite alloc] initWithImage:image andManualFlip:manualFlip];
        
        self.fullSize = image.size;
        
        return self;
    }
    
    return nil;
}

- (CGRect) enclosingRect {
    return [self.framesSprite enclosingRect];
}

- (void)render:(long)ms frame:(int)frame withSize:(CGSize)size atX:(int)x andY:(int)y {
    [self render:ms frame:frame withSize:size atX:x andXOffset:0 andY:y andYOffset:0];
}

- (void)render:(long)ms frame:(int)frame withSize:(CGSize)size atX:(int)x andXOffset:(int)xoffset andY:(int)y andYOffset:(int)yoffset {
    [self render:ms frame:frame withSize:size atX:x andXOffset:xoffset andY:y andYOffset:yoffset flippedHorizontally:NO flippedVertically:NO];
}

- (void)render:(long)ms frame:(int)frame withSize:(CGSize)size atX:(int)x andXOffset:(int)xoffset andY:(int)y andYOffset:(int)yoffset flippedHorizontally:(bool)horz flippedVertically:(bool)vert {
    
    if (frame != self.currentFrame) {
        self.previousFrame = self.currentFrame;
    }
    
    self.currentFrame = frame;
    
    TexturedQuad quad = self.framesSprite.quad;
    quad.bl.textureVertex = CGPointMake((frame * size.width) / self.fullSize.width, 0);
    quad.br.textureVertex = CGPointMake((frame * size.width + size.width) / self.fullSize.width, 0);
    quad.tl.textureVertex = CGPointMake((frame * size.width) / self.fullSize.width, 1);
    quad.tr.textureVertex = CGPointMake((frame * size.width + size.width) / self.fullSize.width, 1);
    
    self.framesSprite.quad = quad;
    
    [self.framesSprite renderWithSize:size atX:x andXOffset:xoffset andY:y andYOffset:yoffset flippedHorizontally:horz flippedVertically:vert];
    
}

@end
