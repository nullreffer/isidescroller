//
//  Block.m
//  SideScroller
//
//  Created by Jay Desai on 4/3/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import "Block.h"
#import "Addon.h"

@interface Block()

@property CGPoint position;
@property CGSize originalSize;

@property bool isHidden;

@end


@implementation Block

@synthesize BLOCK_TYPE = _BLOCK_TYPE;
@synthesize position = _position;
@synthesize originalSize = _originalSize;
@synthesize blockSprite = _blockSprite;

@synthesize isBroken;

- (id) initBlockOfType:(NSString*) type andPositionX:(int)x andPositionY:(int)y {
    if ([self init]){
        
        UIImage *blockImage;
        
        if ([type isEqualToString:@"FINISH"]){
            blockImage = [UIImage imageNamed:@"block_finish.png" ];
            self.BLOCK_TYPE = BLOCK_FINISH;
        } else if ([type isEqualToString:@"DOOR_RED"]){
            blockImage = [UIImage imageNamed:@"block_red_door.png" ];
            self.BLOCK_TYPE = BLOCK_DOOR_RED;
        } else if ([type isEqualToString:@"DOOR_BLUE"]){
            blockImage = [UIImage imageNamed:@"block_blue_door.png" ];
            self.BLOCK_TYPE = BLOCK_DOOR_BLUE;
        } else if ([type isEqualToString:@"SPIKES"]){
            blockImage = [UIImage imageNamed:@"block_spikes.png" ];
            self.BLOCK_TYPE = BLOCK_SPIKES;
        } else if ([type isEqualToString:@"STAIRS"]){
            blockImage = [UIImage imageNamed:@"block_stairs.png" ];
            self.BLOCK_TYPE = BLOCK_STAIRS;
        }  else if ([type isEqualToString:@"LADDER"]){
            blockImage = [UIImage imageNamed:@"block_ladder.png" ];
            self.BLOCK_TYPE = BLOCK_LADDER;
        } else if ([type isEqualToString:@"BREAKABLE"]){
            blockImage = [UIImage imageNamed:@"block_standard.png" ];
            self.BLOCK_TYPE = BLOCK_BREAKABLE;
        } else if ([type isEqualToString:@"GRAVITY_LEFT"]){
            blockImage = [UIImage imageNamed:@"block_gravity_left.png" ];
            self.BLOCK_TYPE = BLOCK_GRAVITY_SHIFT_LEFT;
        } else if ([type isEqualToString:@"GRAVITY_RIGHT"]){
            blockImage = [UIImage imageNamed:@"block_gravity_right.png" ];
            self.BLOCK_TYPE = BLOCK_GRAVITY_SHIFT_RIGHT;
        } else if ([type isEqualToString:@"GRAVITY_TOP"]){
            blockImage = [UIImage imageNamed:@"block_gravity_up.png" ];
            self.BLOCK_TYPE = BLOCK_GRAVITY_SHIFT_TOP;
        } else if ([type isEqualToString:@"GRAVITY_BOTTOM"]){
            blockImage = [UIImage imageNamed:@"block_gravity_down.png" ];
            self.BLOCK_TYPE = BLOCK_GRAVITY_SHIFT_BOTTOM;
        } else {
            blockImage = [UIImage imageNamed:@"block_standard.png"];
            self.BLOCK_TYPE = BLOCK_STANDARD;
        }
        
        self.blockSprite = [[Sprite alloc] initWithImage:blockImage andManualFlip:YES];
        
        self.position = CGPointMake(x, y);
        self.originalSize = CGSizeMake(blockImage.size.width, blockImage.size.height);
        
        self.isBroken = false;
        self.isHidden = false;
        
        return self;
    }
    
    return nil;
}

- (void)draw:(long)ms withHorizontalOffset:(float)horizontalOffset {
    
    TexturedQuad quad = self.blockSprite.quad;
    
    if (!self.isBroken) {
        quad.bl.textureVertex = CGPointMake(0, 0);
        quad.br.textureVertex = CGPointMake(0.5, 0);
        quad.tl.textureVertex = CGPointMake(0, 1);
        quad.tr.textureVertex = CGPointMake(0.5, 1);
    } else {
        quad.bl.textureVertex = CGPointMake(0.5, 0);
        quad.br.textureVertex = CGPointMake(1, 0);
        quad.tl.textureVertex = CGPointMake(0.5, 1);
        quad.tr.textureVertex = CGPointMake(1, 1);
    }
        
    self.blockSprite.quad = quad;
    
    CGSize size = CGSizeMake(self.originalSize.width / 2, self.originalSize.height);
    
    [self.blockSprite renderWithSize:size atX:self.position.x andXOffset:horizontalOffset andY:self.position.y andYOffset:0];
}

- (void) onCollisionComplete:(Character*)character {
    // nothing here yet
}

- (void) onCollideFromTop:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity andGravityOffset:(CGPoint)gravityOffset retX:(float*)new_new_x retY:(float*)new_new_y {
    if (self.isBroken){
        return;
    }

    if (self.BLOCK_TYPE == BLOCK_STAIRS){
        if (*new_new_y < self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01) {
            *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
        }
    } else if (self.BLOCK_TYPE == BLOCK_LADDER){
        *new_new_x = movement.x + gravityOffset.x; //  + velocity.x;
        *new_new_y = movement.y + gravityOffset.y + velocity.y;
        
        if (*new_new_y > self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height){
            *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
        }
    } else if (self.BLOCK_TYPE == BLOCK_SPIKES){
        [character removeLife];
        if (*new_new_y < self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01) {
            *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
        }
    } else if (self.BLOCK_TYPE == BLOCK_DOOR_BLUE){
        if ([character.addons objectForKey:[NSNumber numberWithInt:ADDON_BLUE_KEY]]){
            self.isBroken = true;
        } else {
            if (*new_new_y < self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01) {
                *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
            }
        }
    } else if (self.BLOCK_TYPE == BLOCK_DOOR_RED){
        if ([character.addons objectForKey:[NSNumber numberWithInt:ADDON_RED_KEY]]){
            self.isBroken = true;
        } else {
            if (*new_new_y < self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01) {
                *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
            }
        }
    } else if (self.BLOCK_TYPE == BLOCK_GRAVITY_SHIFT_TOP){
        character.level.gravityPosition = GRAVITY_TOP;
        
        if (*new_new_y < self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01) {
            *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
        }
        
    } else if (self.BLOCK_TYPE == BLOCK_FINISH){
        if (character.isProtagonist) {
            character.level.levelState = LEVEL_COMPLETE;
        }
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
    
    if (self.BLOCK_TYPE == BLOCK_STAIRS){
        if (*new_new_y > self.blockSprite.enclosingRect.origin.y - 0.01){
            *new_new_y = self.blockSprite.enclosingRect.origin.y - 0.01;
        }
    } else if (self.BLOCK_TYPE == BLOCK_LADDER){
        *new_new_x = movement.x + gravityOffset.x; //  + velocity.x;
        *new_new_y = movement.y + gravityOffset.y + velocity.y;
        
        if (*new_new_y + character.characterSize.height < self.blockSprite.enclosingRect.origin.y ){
            *new_new_y = self.blockSprite.enclosingRect.origin.y - character.characterSize.height - 0.01;
        }
    } else if (self.BLOCK_TYPE == BLOCK_SPIKES){
        [character removeLife];
        if (*new_new_y > self.blockSprite.enclosingRect.origin.y - 0.01){
            *new_new_y = self.blockSprite.enclosingRect.origin.y - 0.01;
        }
    } else if (self.BLOCK_TYPE == BLOCK_DOOR_BLUE){
        if ([character.addons objectForKey:[NSNumber numberWithInt:ADDON_BLUE_KEY]]){
            self.isBroken = true;
        } else {
            if (*new_new_y > self.blockSprite.enclosingRect.origin.y - 0.01){
                *new_new_y = self.blockSprite.enclosingRect.origin.y - 0.01;
            }
        }
    } else if (self.BLOCK_TYPE == BLOCK_DOOR_RED){
        if ([character.addons objectForKey:[NSNumber numberWithInt:ADDON_RED_KEY]]){
            self.isBroken = true;
        } else {
            if (*new_new_y > self.blockSprite.enclosingRect.origin.y - 0.01){
                *new_new_y = self.blockSprite.enclosingRect.origin.y - 0.01;
            }
        }
    } else if (self.BLOCK_TYPE == BLOCK_GRAVITY_SHIFT_BOTTOM){
        character.level.gravityPosition = GRAVITY_BOTTOM;
        
        if (*new_new_y + character.characterSize.height > self.blockSprite.enclosingRect.origin.y - 0.01){
            *new_new_y = self.blockSprite.enclosingRect.origin.y - character.characterSize.height - 0.01;
        }
        
    }else if (self.BLOCK_TYPE == BLOCK_FINISH){
        if (character.isProtagonist) {
            character.level.levelState = LEVEL_COMPLETE;
        }
    } else {
        if (*new_new_y + character.characterSize.height > self.blockSprite.enclosingRect.origin.y - 0.01){
            *new_new_y = self.blockSprite.enclosingRect.origin.y - character.characterSize.height - 0.01;
        }
    }
    
}

- (void) onCollideFromLeft:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity andGravityOffset:(CGPoint)gravityOffset retX:(float*)new_new_x retY:(float*)new_new_y {
    if (self.isBroken){
        return;
    }
    
    if (self.BLOCK_TYPE == BLOCK_STAIRS){
        *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
    } else if (self.BLOCK_TYPE == BLOCK_LADDER) {
        *new_new_x = movement.x + gravityOffset.x; // + velocity.x;
        *new_new_y = movement.y + gravityOffset.y + velocity.y;
    } else if (self.BLOCK_TYPE == BLOCK_SPIKES){
        [character removeLife];
        *new_new_x = self.blockSprite.enclosingRect.origin.x - character.characterImage.enclosingRect.size.width - 0.01;
    } else if (self.BLOCK_TYPE == BLOCK_DOOR_BLUE){
        if ([character.addons objectForKey:[NSNumber numberWithInt:ADDON_BLUE_KEY]]){
            self.isBroken = true;
        } else {
            *new_new_x = self.blockSprite.enclosingRect.origin.x - character.characterImage.enclosingRect.size.width - 0.01;
        }
    } else if (self.BLOCK_TYPE == BLOCK_DOOR_RED){
        if ([character.addons objectForKey:[NSNumber numberWithInt:ADDON_RED_KEY]]){
            self.isBroken = true;
        } else {
            *new_new_x = self.blockSprite.enclosingRect.origin.x - character.characterImage.enclosingRect.size.width - 0.01;
        }
    } else if (self.BLOCK_TYPE == BLOCK_FINISH){
        if (character.isProtagonist) {
            character.level.levelState = LEVEL_COMPLETE;
        }
    } else {
        *new_new_x = self.blockSprite.enclosingRect.origin.x - character.characterImage.enclosingRect.size.width - 0.01;
    }
    
}

- (void) onCollideFromRight:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity andGravityOffset:(CGPoint)gravityOffset retX:(float*)new_new_x retY:(float*)new_new_y {
    if (self.isBroken){
        return;
    }
    
    if (self.BLOCK_TYPE == BLOCK_STAIRS){
        *new_new_x = self.blockSprite.enclosingRect.origin.x + self.blockSprite.enclosingRect.size.width + 0.01;
        // *new_new_y = self.blockSprite.enclosingRect.origin.y + character.characterImage.enclosingRect.size.height + 0.01;
    } else if (self.BLOCK_TYPE == BLOCK_LADDER) {
        *new_new_x = movement.x + gravityOffset.x; // + velocity.x;
        *new_new_y = movement.y + gravityOffset.y + velocity.y;
    } else if (self.BLOCK_TYPE == BLOCK_SPIKES){
        [character removeLife];
        *new_new_x = self.blockSprite.enclosingRect.origin.x + self.blockSprite.enclosingRect.size.width + 0.01;
    } else if (self.BLOCK_TYPE == BLOCK_DOOR_BLUE){
        if ([character.addons objectForKey:[NSNumber numberWithInt:ADDON_BLUE_KEY]]){
            self.isBroken = true;
        } else {
            *new_new_x = self.blockSprite.enclosingRect.origin.x + self.blockSprite.enclosingRect.size.width + 0.01;
        }
    } else if (self.BLOCK_TYPE == BLOCK_DOOR_RED){
        if ([character.addons objectForKey:[NSNumber numberWithInt:ADDON_RED_KEY]]){
            self.isBroken = true;
        } else {
            *new_new_x = self.blockSprite.enclosingRect.origin.x + self.blockSprite.enclosingRect.size.width + 0.01;
        }
    } else if (self.BLOCK_TYPE == BLOCK_FINISH){
        if (character.isProtagonist) {
            character.level.levelState = LEVEL_COMPLETE;
        }
    } else {
        *new_new_x = self.blockSprite.enclosingRect.origin.x + self.blockSprite.enclosingRect.size.width + 0.01;
    }

}

@end
