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

@end

@implementation AnimatedSprite

@synthesize currentFrame = _currentFrame;
@synthesize enclosingRect = _enclosingRect;

- (id)initWithImage:(UIImage *)image ofFrameWidth:(float)width {
    return [self initWithImage:image ofFrameWidth:width andManualFlip:NO];
}

- (id)initWithImage:(UIImage *)image ofFrameWidth:(float)width andManualFlip:(bool)manualFlip {

    if ([self init]){
        self.currentFrame = 0;

        // self.frames = [[NSMutableArray alloc] initWithCapacity:image.size.width/width];
        
        /*
        for (int x = 0; x < image.size.width / width; x++){
            Sprite *frame = [[Sprite alloc] initWithRect:[image CGImage] croppedTo:CGRectMake(x*width, 0, width, image.size.height) andOriginalSz:image.size andManualFlip:manualFlip];
            // frame.enclosingRect = CGRectMake(x*width, 0, width, image.size.height);
        
            [self.frames addObject:frame];

        }
        
        self.enclosingRect = [[self.frames objectAtIndex:0] enclosingRect];
         */
        
        self.framesSprite = [[Sprite alloc] initWithImage:image andManualFlip:manualFlip];
        
        return self;
    }
    
    return nil;
}

- (void)render:(long)ms frame:(int)frame withSize:(CGSize)size atX:(int)x andY:(int)y {
    [self render:ms frame:frame withSize:size atX:x andXOffset:0 andY:y andYOffset:0];
}

- (void)render:(long)ms frame:(int)frame withSize:(CGSize)size atX:(int)x andXOffset:(int)xoffset andY:(int)y andYOffset:(int)yoffset {
    [self render:ms frame:frame withSize:size atX:x andXOffset:xoffset andY:y andYOffset:yoffset flippedHorizontally:NO flippedVertically:NO];
}

- (void)render:(long)ms frame:(int)frame withSize:(CGSize)size atX:(int)x andXOffset:(int)xoffset andY:(int)y andYOffset:(int)yoffset flippedHorizontally:(bool)horz flippedVertically:(bool)vert {
    
    self.currentFrame = frame;
    [self.framesSprite renderWithSize:size atX:x andXOffset:xoffset andY:y andYOffset:yoffset flippedHorizontally:horz flippedVertically:vert];
    
}

@end
