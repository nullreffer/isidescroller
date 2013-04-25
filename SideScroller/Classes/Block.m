//
//  Block.m
//  SideScroller
//
//  Created by Jay Desai on 4/3/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import "Block.h"

@interface Block()

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
        
        if ([type isEqualToString:@"FINISH"]){
            blockImage = [UIImage imageNamed:@"block_door.png" ];
            self.BLOCK_TYPE = FINISH;
        } else if ([type isEqualToString:@"SPIKES"]){
            blockImage = [UIImage imageNamed:@"block_spikes.png" ];
            self.BLOCK_TYPE = SPIKES;
        } else if ([type isEqualToString:@"STAIRS"]){
            blockImage = [UIImage imageNamed:@"block_stairs.png" ];
            self.BLOCK_TYPE = STAIRS;
        }  else if ([type isEqualToString:@"LADDER"]){
            blockImage = [UIImage imageNamed:@"block_ladder.png" ];
            self.BLOCK_TYPE = LADDER;
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
    
    TexturedQuad quad = self.blockSprite.quad;
    quad.bl.textureVertex = CGPointMake(0, 0);
    quad.br.textureVertex = CGPointMake(1, 0);
    quad.tl.textureVertex = CGPointMake(0, 1);
    quad.tr.textureVertex = CGPointMake(1, 1);
    
    self.blockSprite.quad = quad;
    
    [self.blockSprite renderWithSize:self.blockSprite.size atX:self.position.x andXOffset:horizontalOffset andY:self.position.y andYOffset:0];
}

- (void) onCollisionComplete:(Character*)character {
    // nothing here yet
}

- (void) onCollideFromTop:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity andGravityOffset:(CGPoint)gravityOffset retX:(float*)new_new_x retY:(float*)new_new_y {
    if (self.isBroken){
        return;
    }

    if (self.BLOCK_TYPE == STAIRS){
        if (*new_new_y < self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01) {
            *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
        }
    } else if (self.BLOCK_TYPE == LADDER){
        *new_new_x = movement.x + gravityOffset.x + velocity.x;
        *new_new_y = movement.y + gravityOffset.y + velocity.y;
        
        if (*new_new_y > self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height){
            *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
        }
    } else if (self.BLOCK_TYPE == SPIKES){
        [character removeLife];
        if (*new_new_y < self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01) {
            *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
        }
    } else if (self.BLOCK_TYPE == FINISH){
        // set game state to something
    } else {
        if (*new_new_y < self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01) {
            *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
        }
    }
}

- (void) onCollideFromBottom:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity andGravityOffset:(CGPoint)gravityOffset retX:(float*)new_new_x retY:(float*)new_new_y {
    if (self.isBroken){
        return;
    }
    
    if (self.BLOCK_TYPE == STAIRS){
        if (*new_new_y > self.blockSprite.enclosingRect.origin.y - 0.01){
            *new_new_y = self.blockSprite.enclosingRect.origin.y - 0.01;
        }
    } else if (self.BLOCK_TYPE == LADDER){
        *new_new_x = movement.x + gravityOffset.x + velocity.x;
        *new_new_y = movement.y + gravityOffset.y + velocity.y;
        
        if (*new_new_y + character.characterSize.height < self.blockSprite.enclosingRect.origin.y ){
            *new_new_y = self.blockSprite.enclosingRect.origin.y - character.characterSize.height - 0.01;
        }
    } else if (self.BLOCK_TYPE == SPIKES){
        [character removeLife];
        if (*new_new_y > self.blockSprite.enclosingRect.origin.y - 0.01){
            *new_new_y = self.blockSprite.enclosingRect.origin.y - 0.01;
        }
    } else if (self.BLOCK_TYPE == FINISH){
        // set game state to something
    } else {
        if (*new_new_y > self.blockSprite.enclosingRect.origin.y - 0.01){
            *new_new_y = self.blockSprite.enclosingRect.origin.y - 0.01;
        }
    }
    
}

- (void) onCollideFromLeft:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity andGravityOffset:(CGPoint)gravityOffset retX:(float*)new_new_x retY:(float*)new_new_y {
    if (self.isBroken){
        return;
    }
    
    if (self.BLOCK_TYPE == STAIRS){
        *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
    } else if (self.BLOCK_TYPE == LADDER) {
        *new_new_x = movement.x + gravityOffset.x + velocity.x;
        *new_new_y = movement.y + gravityOffset.y + velocity.y;
    } else if (self.BLOCK_TYPE == SPIKES){
        [character removeLife];
        *new_new_x = self.blockSprite.enclosingRect.origin.x - character.characterImage.enclosingRect.size.width - 0.01;
    } else if (self.BLOCK_TYPE == FINISH){
        // set game state to something
    } else {
        *new_new_x = self.blockSprite.enclosingRect.origin.x - character.characterImage.enclosingRect.size.width - 0.01;
    }
    
}

- (void) onCollideFromRight:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity andGravityOffset:(CGPoint)gravityOffset retX:(float*)new_new_x retY:(float*)new_new_y {
    if (self.isBroken){
        return;
    }
    
    if (self.BLOCK_TYPE == STAIRS){
        *new_new_x = self.blockSprite.enclosingRect.origin.x + self.blockSprite.enclosingRect.size.width + 0.01;
        // *new_new_y = self.blockSprite.enclosingRect.origin.y + character.characterImage.enclosingRect.size.height + 0.01;
    } else if (self.BLOCK_TYPE == LADDER) {
        *new_new_x = movement.x + gravityOffset.x + velocity.x;
        *new_new_y = movement.y + gravityOffset.y + velocity.y;
    } else if (self.BLOCK_TYPE == SPIKES){
        [character removeLife];
        *new_new_x = self.blockSprite.enclosingRect.origin.x + self.blockSprite.enclosingRect.size.width + 0.01;
    } else if (self.BLOCK_TYPE == FINISH){
        // set game state to something
    } else {
        *new_new_x = self.blockSprite.enclosingRect.origin.x + self.blockSprite.enclosingRect.size.width + 0.01;
    }

}

@end
