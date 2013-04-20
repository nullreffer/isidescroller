//
//  Block.m
//  SideScroller
//
//  Created by Jay Desai on 4/3/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import "Block.h"

@interface Block()

@property _BLOCK_TYPE_ENUM BLOCK_TYPE;
@property CGPoint position;

@property bool isBroken;
@property bool isHidden;

@end


@implementation Block

@synthesize BLOCK_TYPE = _BLOCK_TYPE;
@synthesize position = _position;
@synthesize blockSprite = _blockSprite;

@synthesize isBroken;

- (id) initBlockOfType:(NSString*) type andPositionX:(int)x andPositionY:(int)y {
    if ([self init]){
        
        UIImage *blockImage;
        
        if ([type isEqualToString:@"SPIKES"]){
            blockImage = [UIImage imageNamed:@"block_spikes.png" ];
            self.BLOCK_TYPE = SPIKES;
        } else if ([type isEqualToString:@"COIN"]){
            blockImage = [UIImage imageNamed:@"block_spikes.png" ];
            self.BLOCK_TYPE = COIN;
        } else if ([type isEqualToString:@"POTION"]){
            blockImage = [UIImage imageNamed:@"block_spikes.png" ];
            self.BLOCK_TYPE = POTION;
        } else if ([type isEqualToString:@"BREAKABLE"]){
            blockImage = [UIImage imageNamed:@"block_spikes.png" ];
            self.BLOCK_TYPE = BREAKABLE;
        } else if ([type isEqualToString:@"GRAVITY_LEFT"]){
            blockImage = [UIImage imageNamed:@"block_spikes.png" ];
            self.BLOCK_TYPE = GRAVITY_LEFT;
        } else if ([type isEqualToString:@"GRAVITY_RIGHT"]){
            blockImage = [UIImage imageNamed:@"block_spikes.png" ];
            self.BLOCK_TYPE = GRAVITY_RIGHT;
        } else if ([type isEqualToString:@"GRAVITY_TOM"]){
            blockImage = [UIImage imageNamed:@"block_spikes.png" ];
            self.BLOCK_TYPE = GRAVITY_TOP;
        } else if ([type isEqualToString:@"GRAVITY_BOTTOM"]){
            blockImage = [UIImage imageNamed:@"block_spikes.png" ];
            self.BLOCK_TYPE = GRAVITY_BOTTOM;
        } else {
            blockImage = [UIImage imageNamed:@"block_standard.png"];
            self.BLOCK_TYPE = STANDARD;
        }
        
        self.blockSprite = [[Sprite alloc] initWithImage:blockImage andManualFlip:YES];
        
        self.position = CGPointMake(x, y);
        
        self.isBroken = false;
        self.isHidden = false;
        
        return self;
    }
    
    return nil;
}

- (void)draw:(long)ms withHorizontalOffset:(float)horizontalOffset {
    [self.blockSprite renderWithSize:1.0 atX:self.position.x andXOffset:horizontalOffset andY:self.position.y andYOffset:0];
}

-(void) onCollideWithChar:(Character*)character inLevel:(Level*)level {
    if (self.isBroken){
        return;
    }
    
    
}

@end
