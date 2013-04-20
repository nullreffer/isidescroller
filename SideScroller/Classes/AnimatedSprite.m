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

@property NSMutableArray* frames;
@property int interval;
@property int currentFrame;
@property int currentCounter;
@property long lastMs;

@end

@implementation AnimatedSprite

@synthesize frames = _frames;
@synthesize interval = _interval;
@synthesize currentFrame = _currentFrame;
@synthesize currentCounter = _currentCounter;

NSString* CLAZZ = @"AnimatedSpriteException";

- (id) initAnimatedSpriteWithFile:(NSString*)file andSpriteWidth:(int)width andInterval:(int)interval {

    if (interval == 0){
        [NSException raise:CLAZZ format:@" Interval was %d ", 0];
    }
    
    if ([self init]){
        self.interval = interval;
        self.currentFrame = 0;
        self.currentCounter = 0;
        
        UIImage *image = [UIImage imageNamed:file];

        for (int x = 0; x < image.size.width / width; x++){
            Sprite *frame = [[Sprite alloc] initWithRect:[image CGImage] croppedTo:CGRectMake(x*width, 0, width, image.size.height) andManualFlip:NO ];
        
            [self.frames addObject:frame];

        }
        
        return self;
    }
    
    return nil;
}

- (void) draw:(long)ms {
    
    if (self.currentCounter <= 0){
        
        [[self.frames objectAtIndex:(self.currentFrame++ % [self.frames count])] draw:ms];
        
        self.currentCounter = self.interval;
        
        self.lastMs = ms;
    }
    
    long timeDifference = ms - self.lastMs;
    
    self.currentCounter -= timeDifference;
    
}

@end
