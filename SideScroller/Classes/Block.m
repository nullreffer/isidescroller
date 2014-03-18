//
//  Block.m
//  SideScroller
//
//  Created by Jay Desai on 4/3/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import "Block.h"
#import "Addon.h"

#define PICKUP_ANIMATION 4
#define BACTION_INTERVAL 20
#define LADDER_SPEED_FACTOR 3

@interface Block()

@property CGPoint position;
@property CGSize originalSize;

@property bool isHidden;

@property int isBeingPicked;
@property int pickupCounter;

@property int gravityCounter;

@property int lastActionTimer;

@property Level* level;

@end


@implementation Block

@synthesize BLOCK_TYPE = _BLOCK_TYPE;
@synthesize position = _position;
@synthesize originalSize = _originalSize;
@synthesize blockSprite = _blockSprite;
@synthesize isBeingPicked = _isBeingPicked;
@synthesize level = _level;
@synthesize gravityCounter = _gravityCounter;
@synthesize lastActionTimer = _lastActionTimer;

@synthesize isBroken;

- (id) initBlockOfType:(NSString*) type andPositionX:(int)x andPositionY:(int)y withinLevel:(Level *)level {
    if ([self init]){
        
        UIImage *blockImage;
        
        if ([type isEqualToString:@"BLOCK_FINISH"]){
            blockImage = [UIImage imageNamed:@"block_finish.png" ];
            self.BLOCK_TYPE = BLOCK_FINISH;
        } else if ([type isEqualToString:@"BLOCK_DOOR_RED"]){
            blockImage = [UIImage imageNamed:@"block_red_door.png" ];
            self.BLOCK_TYPE = BLOCK_DOOR_RED;
        } else if ([type isEqualToString:@"BLOCK_DOOR_BLUE"]){
            blockImage = [UIImage imageNamed:@"block_blue_door.png" ];
            self.BLOCK_TYPE = BLOCK_DOOR_BLUE;
        } else if ([type isEqualToString:@"BLOCK_DOOR_GREEN"]){
            blockImage = [UIImage imageNamed:@"block_green_door.png" ];
            self.BLOCK_TYPE = BLOCK_DOOR_GREEN;
        } else if ([type isEqualToString:@"BLOCK_PORTAL_RED"]){
            blockImage = [UIImage imageNamed:@"block_red_portal.png" ];
            self.BLOCK_TYPE = BLOCK_PORTAL_RED;
        } else if ([type isEqualToString:@"BLOCK_PORTAL_BLUE"]){
            blockImage = [UIImage imageNamed:@"block_blue_portal.png" ];
            self.BLOCK_TYPE = BLOCK_PORTAL_BLUE;
        } else if ([type isEqualToString:@"BLOCK_PORTAL_GREEN"]){
            blockImage = [UIImage imageNamed:@"block_green_portal.png" ];
            self.BLOCK_TYPE = BLOCK_PORTAL_GREEN;
        } else if ([type isEqualToString:@"BLOCK_SPIKES"]){
            blockImage = [UIImage imageNamed:@"block_spikes.png" ];
            self.BLOCK_TYPE = BLOCK_SPIKES;
        } else if ([type isEqualToString:@"BLOCK_STAIRS"]){
            blockImage = [UIImage imageNamed:@"block_stairs.png" ];
            self.BLOCK_TYPE = BLOCK_STAIRS;
        }  else if ([type isEqualToString:@"BLOCK_LADDER"]){
            blockImage = [UIImage imageNamed:@"block_ladder.png" ];
            self.BLOCK_TYPE = BLOCK_LADDDER;
        } else if ([type isEqualToString:@"BLOCK_BREAKABLE"]){
            blockImage = [UIImage imageNamed:@"block_standard.png" ];
            self.BLOCK_TYPE = BLOCK_BREAKABLE;
        } /*else if ([type isEqualToString:@"BLOCK_GRAVITY_LEFT"]){
            blockImage = [UIImage imageNamed:@"block_gravity_left.png" ];
            self.BLOCK_TYPE = BLOCK_GRAVITY_SHIFT_LEFT;
        } else if ([type isEqualToString:@"BLOCK_GRAVITY_RIGHT"]){
            blockImage = [UIImage imageNamed:@"block_gravity_right.png" ];
            self.BLOCK_TYPE = BLOCK_GRAVITY_SHIFT_RIGHT;
        } */else if ([type isEqualToString:@"BLOCK_GRAVITY_TOP"]){
            blockImage = [UIImage imageNamed:@"block_gravity_up.png" ];
            self.BLOCK_TYPE = BLOCK_GRAVITY_SHIFT_TOP;
        } else if ([type isEqualToString:@"BLOCK_GRAVITY_BOTTOM"]){
            blockImage = [UIImage imageNamed:@"block_gravity_down.png" ];
            self.BLOCK_TYPE = BLOCK_GRAVITY_SHIFT_BOTTOM;
        } else if ([type isEqualToString:@"BLOCK_PICKABLE"]){
            blockImage = [UIImage imageNamed:@"block_standard.png" ];
            self.BLOCK_TYPE = BLOCK_PICKABLE;
        } else if ([type isEqualToString:@"BLOCK_PUSHABLE"]){
            blockImage = [UIImage imageNamed:@"block_standard.png" ];
            self.BLOCK_TYPE = BLOCK_PUSHABLE;
        } else if ([type isEqualToString:@"BLOCK_STANDARD"]) {
            blockImage = [UIImage imageNamed:@"block_standard.png"];
            self.BLOCK_TYPE = BLOCK_STANDARD;
        } else {
            blockImage = [UIImage imageNamed:@"block_standard.png"];
            self.BLOCK_TYPE = BLOCK_NOTHING;
        }
        
        self.blockSprite = [[Sprite alloc] initWithImage:blockImage andManualFlip:YES];
        
        self.position = CGPointMake(x, y);
        self.originalSize = CGSizeMake(blockImage.size.width, blockImage.size.height);
        
        self.isBroken = false;
        self.isHidden = false;
        
        self.isBeingPicked = 0;
        self.pickupCounter = 0;
        
        self.gravityCounter = 0;
        self.lastActionTimer = 0;
        
        self.level = level;
        
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

    float newx = self.position.x;
    float newy = self.position.y;
    
    if (self.isBeingPicked > 0){

        
        if (self.level.gravityPosition == GRAVITY_BOTTOM){
            
            // if block is not yet above the person, then move it up
            if (self.pickupCounter < self.level.theman.characterSize.height){
                newx = fabs(self.level.theman.lastDirection) > M_PI_2 ? self.level.theman.position.x - self.blockSprite.size.width - 1.01 : self.level.theman.position.x + self.level.theman.characterSize.width + 1.01;
                
                self.pickupCounter += PICKUP_ANIMATION;
                
                newy = self.level.theman.position.y + self.pickupCounter + 1.01;
            } else if (self.pickupCounter > self.level.theman.characterSize.height &&
                       self.pickupCounter < (self.level.theman.characterSize.height + self.level.theman.characterSize.width)) {

                self.pickupCounter += PICKUP_ANIMATION;
                float dist = self.pickupCounter - self.level.theman.characterSize.height;
                newx = fabs(self.level.theman.lastDirection) > M_PI_2 ? self.level.theman.position.x - self.blockSprite.size.width + (dist) : self.level.theman.position.x + self.level.theman.characterSize.width - (dist);
                
            } else if (self.pickupCounter == self.level.theman.characterSize.height ||
                       self.pickupCounter == (self.level.theman.characterSize.width + self.level.theman.characterSize.height)) {
                self.pickupCounter += PICKUP_ANIMATION;
            } else {
                newx = self.level.theman.position.x;
                newy = self.level.theman.position.y + self.level.theman.characterSize.height + 1.01;
            }
            
        } else if (self.level.gravityPosition == GRAVITY_TOP) {
            
            // if block is not yet below the person, then move it up
            if (self.pickupCounter < self.level.theman.characterSize.height){
                newx = fabs(self.level.theman.lastDirection) > M_PI_2 ? self.level.theman.position.x - self.blockSprite.size.width - 1.01 : self.level.theman.position.x + self.level.theman.characterSize.width + 1.01;
                
                self.pickupCounter += PICKUP_ANIMATION;
                
                newy = self.level.theman.position.y - self.pickupCounter - 1.01;
            } else if (self.pickupCounter > self.level.theman.characterSize.height &&
                       self.pickupCounter < (self.level.theman.characterSize.height + self.level.theman.characterSize.width)) {
                
                self.pickupCounter += PICKUP_ANIMATION;
                float dist = self.pickupCounter - self.level.theman.characterSize.height;
                newx = fabs(self.level.theman.lastDirection) > M_PI_2 ? self.level.theman.position.x - self.blockSprite.size.width + (dist) : self.level.theman.position.x + self.level.theman.characterSize.width - (dist);
                
            } else if (self.pickupCounter == self.level.theman.characterSize.height ||
                       self.pickupCounter == (self.level.theman.characterSize.width + self.level.theman.characterSize.height)) {
                self.pickupCounter += PICKUP_ANIMATION;
            } else {
                newx = self.level.theman.position.x;
                newy = self.level.theman.position.y - self.level.theman.characterSize.height - 1.01;
            }
            
        }
        
        // self.position = CGPointMake(newx, newy);
    } else if (self.isBeingPicked < 0) {
        // being dropped
        
        if (self.level.gravityPosition == GRAVITY_BOTTOM){

            if (self.pickupCounter > (self.level.theman.characterSize.height)) {
                self.pickupCounter -= PICKUP_ANIMATION;
            
                float dist = self.pickupCounter - self.level.theman.characterSize.height - 1.01;
                newx = fabs(self.level.theman.lastDirection) > M_PI_2 ? self.level.theman.position.x - self.blockSprite.size.width + (dist) : self.level.theman.position.x + self.level.theman.characterSize.width - (dist);
            } else if (self.pickupCounter == self.level.theman.characterSize.height) {
                self.pickupCounter -= PICKUP_ANIMATION;
            } else {
                NSLog(@"Being Picked: 0");
                self.isBeingPicked = 0;
                self.level.theman.pickedBlock = nil;
            }
        } else if (self.level.gravityPosition == GRAVITY_TOP) {
            
            if (self.pickupCounter > (self.level.theman.characterSize.height)) {
                self.pickupCounter -= PICKUP_ANIMATION;
                
                float dist = self.pickupCounter - self.level.theman.characterSize.height - 1.01;
                newx = fabs(self.level.theman.lastDirection) > M_PI_2 ? self.level.theman.position.x - self.blockSprite.size.width + (dist) : self.level.theman.position.x + self.level.theman.characterSize.width - (dist);
            } else if (self.pickupCounter == self.level.theman.characterSize.height) {
                self.pickupCounter -= PICKUP_ANIMATION;
            } else {
                NSLog(@"Being Picked: 0");
                self.isBeingPicked = 0;
                self.level.theman.pickedBlock = nil;
            }
            
        }
    }
    
    if (self.BLOCK_TYPE == BLOCK_PUSHABLE || self.BLOCK_TYPE == BLOCK_PICKABLE) { // (self.BLOCK_TYPE == BLOCK_PICKABLE && !self.isBeingPicked)){
        
        float desiredx = newx; // self.position.x;
        float desiredy = newy; // self.position.y;
        
        // ignore gravity when picked, or being picked, or being dropped
        if (self.isBeingPicked == 0) {
            if (self.level.gravityPosition == GRAVITY_BOTTOM){
                desiredy -= ++self.gravityCounter * self.gravityCounter;
            } else if (self.level.gravityPosition == GRAVITY_TOP){
                desiredy += ++self.gravityCounter * self.gravityCounter;
            }
        }
        
        CGRect rect2, vertical_rect1, horizontal_rect1;
        CGRect charRect = self.blockSprite.enclosingRect;
        float new_new_x = desiredx;
        float new_new_y = desiredy;
        
        bool intersected = false;
        for (Block *block in self.level.blocks){
            
            // this breaks gravity, block falls upside down
            if (block == self) continue;
            
            rect2 = block.blockSprite.enclosingRect;
            
            vertical_rect1 = CGRectMake(self.position.x, self.position.y < new_new_y ? self.position.y : new_new_y, charRect.size.width, charRect.size.height + fabs(new_new_y - self.position.y));
            horizontal_rect1 = CGRectMake(self.position.x < new_new_x ? self.position.x : new_new_x, self.position.y, charRect.size.width + fabs(self.position.x - new_new_x), charRect.size.height);
            
            // vertical rect intersection
            // if the bottom of the char is greater than block's top
            // or the top of the char is less than the block's bottom
            if (vertical_rect1.origin.y > rect2.origin.y + rect2.size.height ||
                vertical_rect1.origin.y + vertical_rect1.size.height < rect2.origin.y){
                // no y intersection
            }
            // if the left of the char is greater than the block's right
            // or the right of the char is less than the block's left
            else if (vertical_rect1.origin.x > rect2.origin.x + rect2.size.width ||
                     vertical_rect1.origin.x + vertical_rect1.size.width < rect2.origin.x){
                // no x intersection
                
            } else {
                if (desiredy < self.position.y){
                    if (desiredy < block.blockSprite.enclosingRect.origin.y + block.blockSprite.enclosingRect.size.height + 0.01) {
                        desiredy = block.blockSprite.enclosingRect.origin.y + block.blockSprite.enclosingRect.size.height + 0.01;
                        intersected = true;
                    }
                } else if (desiredy > self.position.y) {
                    if (desiredy + self.blockSprite.size.height > block.blockSprite.enclosingRect.origin.y - 0.01){
                        desiredy = block.blockSprite.enclosingRect.origin.y - self.blockSprite.size.height - 0.01;
                        intersected = true;
                    }
                } // ignore when they're equal
                // new_new_y = self.position.y;
            }
            
            // horizontal rect intersection
            // if the bottom of the char is greater than block's top
            // or the top of the char is less than the block's bottom
            if (horizontal_rect1.origin.y > rect2.origin.y + rect2.size.height ||
                     horizontal_rect1.origin.y + horizontal_rect1.size.height < rect2.origin.y){
                // no y intersection
            }
            // if the left of the char is greater than the block's right
            // or the right of the char is less than the block's left
            else if (horizontal_rect1.origin.x > rect2.origin.x + rect2.size.width ||
                     horizontal_rect1.origin.x + horizontal_rect1.size.width < rect2.origin.x){
                // no x intersection
            } else {
                if (desiredx < self.position.x){
                    desiredx = block.blockSprite.enclosingRect.origin.x + block.blockSprite.enclosingRect.size.width + 0.01;
                    intersected = true;
                } else if (desiredx > self.position.x) {
                    desiredx = block.blockSprite.enclosingRect.origin.x - self.blockSprite.size.width - 0.01;
                    intersected = true;
                } // ignore when they're equal
                // new_new_x = self.position.x;
            }
            
            new_new_x = desiredx;
            new_new_y = desiredy;
        } // end blocks loop
        
        if (intersected) {
            self.gravityCounter = 0;
        }
        
        self.position = CGPointMake(new_new_x, new_new_y);
    }
    
    [self.blockSprite renderWithSize:size atX:self.position.x andXOffset:horizontalOffset andY:self.position.y andYOffset:0];
    
    self.lastActionTimer = self.lastActionTimer > 0 ? self.lastActionTimer - 1 : 0;
}

- (bool) doAction {
    
    if (self.BLOCK_TYPE == BLOCK_PICKABLE && self.lastActionTimer == 0){
        if (self.isBeingPicked == 1) {
            self.isBeingPicked = -1;
        } else  {
            self.isBeingPicked = 1;
        }
        self.lastActionTimer = BACTION_INTERVAL;
        NSLog(@"Being Picked: %d", self.isBeingPicked);
        return true;
    }
    
    return false;
}

- (void) onCollisionComplete:(Character*)character {
    // to prevent a infinite portal swapping
    if (self.BLOCK_TYPE == BLOCK_PORTAL_BLUE || self.BLOCK_TYPE == BLOCK_PORTAL_GREEN || self.BLOCK_TYPE == BLOCK_PORTAL_RED){
        self.isBroken = false;
    }
}

- (void) onCollideFromTop:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity retX:(float*)new_new_x retY:(float*)new_new_y {
    if (self.isBroken){
        return;
    }

    if (self.BLOCK_TYPE == BLOCK_STAIRS){
        if (*new_new_y < self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01) {
            *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
        }
    } else if (self.BLOCK_TYPE == BLOCK_LADDDER){
        /*
         *new_new_x = movement.x; // + gravityOffset.x; //  + velocity.x;
        *new_new_y = movement.y; // + gravityOffset.y + velocity.y;
        
        if (*new_new_y > self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height){
            *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
        }
         */
        if (character.isProtagonist){
            *new_new_x = *new_new_x;
            *new_new_y = *new_new_y + (velocity.y > 0 ? LADDER_SPEED_FACTOR : ( velocity.y < 0 ? -LADDER_SPEED_FACTOR : 0 ) );
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
    } else if (self.BLOCK_TYPE == BLOCK_DOOR_GREEN){
        if ([character.addons objectForKey:[NSNumber numberWithInt:ADDON_GREEN_KEY]]){
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
        
    } else if (self.BLOCK_TYPE == BLOCK_GRAVITY_SHIFT_BOTTOM){
        // same as standard block
        if (*new_new_y < self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01) {
            *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
        }
        
    } else if (self.BLOCK_TYPE == BLOCK_FINISH){
        if (character.isProtagonist) {
            character.level.levelState = LEVEL_COMPLETE;
        }
    } else if (self.BLOCK_TYPE == BLOCK_PORTAL_BLUE){
        
        for (Block *b in character.level.blocks){
            if (b == self) continue;
            if (b.BLOCK_TYPE == BLOCK_PORTAL_BLUE){
                *new_new_x = b.position.x;
                *new_new_y = b.position.y;
                b.isBroken = true;
            }
        }
        
    } else if (self.BLOCK_TYPE == BLOCK_PORTAL_RED){
        
        for (Block *b in character.level.blocks){
            if (b == self) continue;
            if (b.BLOCK_TYPE == BLOCK_PORTAL_RED){
                *new_new_x = b.position.x;
                *new_new_y = b.position.y;
                b.isBroken = true;
            }
        }
        
    } else if (self.BLOCK_TYPE == BLOCK_PORTAL_GREEN){
        
        for (Block *b in character.level.blocks){
            if (b == self) continue;
            if (b.BLOCK_TYPE == BLOCK_PORTAL_GREEN){
                *new_new_x = b.position.x;
                *new_new_y = b.position.y;
                b.isBroken = true;
            }
        }
        
    } else if (self.BLOCK_TYPE == BLOCK_PUSHABLE) {
        if (*new_new_y < self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01) {
            *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
        }
    } else if (self.BLOCK_TYPE == BLOCK_PICKABLE) {
        if (!self.isBeingPicked) {
            if (*new_new_y < self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01) {
                *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
            }
        }
    } else if (self.BLOCK_TYPE == BLOCK_STANDARD) {
        if (*new_new_y < self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01) {
            *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
        }
    }
}

- (void) onCollideFromBottom:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity retX:(float*)new_new_x retY:(float*)new_new_y {
    if (self.isBroken){
        return;
    }

    if (self.BLOCK_TYPE == BLOCK_STAIRS){
        if (*new_new_y > self.blockSprite.enclosingRect.origin.y - 0.01){
            *new_new_y = self.blockSprite.enclosingRect.origin.y - 0.01;
        }
    } else if (self.BLOCK_TYPE == BLOCK_LADDDER){
        /*
        *new_new_x = movement.x; // + gravityOffset.x; //  + velocity.x;
        *new_new_y = movement.y; // + gravityOffset.y + velocity.y;
        
        if (*new_new_y + character.characterSize.height < self.blockSprite.enclosingRect.origin.y ){
            *new_new_y = self.blockSprite.enclosingRect.origin.y - character.characterSize.height - 0.01;
        }
         */
        if (character.isProtagonist){
            *new_new_x = *new_new_x;
            *new_new_y = *new_new_y + (velocity.y > 0 ? LADDER_SPEED_FACTOR : ( velocity.y < 0 ? -LADDER_SPEED_FACTOR : 0 ) );
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
    } else if (self.BLOCK_TYPE == BLOCK_DOOR_GREEN){
        if ([character.addons objectForKey:[NSNumber numberWithInt:ADDON_GREEN_KEY]]){
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
        
    } else if (self.BLOCK_TYPE == BLOCK_GRAVITY_SHIFT_TOP){
        // same as standard
        if (*new_new_y + character.characterSize.height > self.blockSprite.enclosingRect.origin.y - 0.01){
            *new_new_y = self.blockSprite.enclosingRect.origin.y - character.characterSize.height - 0.01;
        }
        
    } else if (self.BLOCK_TYPE == BLOCK_FINISH){
        if (character.isProtagonist) {
            character.level.levelState = LEVEL_COMPLETE;
        }
    } else if (self.BLOCK_TYPE == BLOCK_PORTAL_BLUE){
        
        for (Block *b in character.level.blocks){
            if (b == self) continue;
            if (b.BLOCK_TYPE == BLOCK_PORTAL_BLUE){
                *new_new_x = b.position.x;
                *new_new_y = b.position.y;
                b.isBroken = true;
            }
        }
        
    } else if (self.BLOCK_TYPE == BLOCK_PORTAL_RED){
        
        for (Block *b in character.level.blocks){
            if (b == self) continue;
            if (b.BLOCK_TYPE == BLOCK_PORTAL_RED){
                *new_new_x = b.position.x;
                *new_new_y = b.position.y;
                b.isBroken = true;
            }
        }
        
    } else if (self.BLOCK_TYPE == BLOCK_PORTAL_GREEN){
        
        for (Block *b in character.level.blocks){
            if (b == self) continue;
            if (b.BLOCK_TYPE == BLOCK_PORTAL_GREEN){
                *new_new_x = b.position.x;
                *new_new_y = b.position.y;
                b.isBroken = true;
            }
        }
        
    } else if (self.BLOCK_TYPE == BLOCK_PUSHABLE ){
        if (*new_new_y + character.characterSize.height > self.blockSprite.enclosingRect.origin.y - 0.01){
            *new_new_y = self.blockSprite.enclosingRect.origin.y - character.characterSize.height - 0.01;
        }
    } else if (self.BLOCK_TYPE == BLOCK_PICKABLE) {
        if (!self.isBeingPicked) {
            if (*new_new_y + character.characterSize.height > self.blockSprite.enclosingRect.origin.y - 0.01){
                *new_new_y = self.blockSprite.enclosingRect.origin.y - character.characterSize.height - 0.01;
            }
        }
    } else if (self.BLOCK_TYPE == BLOCK_STANDARD) {
        if (*new_new_y + character.characterSize.height > self.blockSprite.enclosingRect.origin.y - 0.01){
            *new_new_y = self.blockSprite.enclosingRect.origin.y - character.characterSize.height - 0.01;
        }
    }
    
}

- (void) onCollideFromLeft:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity retX:(float*)new_new_x retY:(float*)new_new_y {
    if (self.isBroken){
        return;
    }
    
    if (self.BLOCK_TYPE == BLOCK_STAIRS){
        *new_new_y = self.blockSprite.enclosingRect.origin.y + self.blockSprite.enclosingRect.size.height + 0.01;
    } else if (self.BLOCK_TYPE == BLOCK_LADDDER) {
        /*
        *new_new_x = movement.x; // + gravityOffset.x; // + velocity.x;
        *new_new_y = movement.y; // + gravityOffset.y + velocity.y;
         */
        if (character.isProtagonist){
            *new_new_x = *new_new_x;
            *new_new_y = *new_new_y + (velocity.y > 0 ? LADDER_SPEED_FACTOR : ( velocity.y < 0 ? -LADDER_SPEED_FACTOR : 0 ) );
        }
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
    } else if (self.BLOCK_TYPE == BLOCK_DOOR_GREEN){
        if ([character.addons objectForKey:[NSNumber numberWithInt:ADDON_GREEN_KEY]]){
            self.isBroken = true;
        } else {
            *new_new_x = self.blockSprite.enclosingRect.origin.x - character.characterImage.enclosingRect.size.width - 0.01;
        }
    } else if (self.BLOCK_TYPE == BLOCK_GRAVITY_SHIFT_BOTTOM || self.BLOCK_TYPE == BLOCK_GRAVITY_SHIFT_TOP){
        // same as standard
        *new_new_x = self.blockSprite.enclosingRect.origin.x - character.characterImage.enclosingRect.size.width - 0.01;

    } else if (self.BLOCK_TYPE == BLOCK_FINISH){
        if (character.isProtagonist) {
            character.level.levelState = LEVEL_COMPLETE;
        }
    } else if (self.BLOCK_TYPE == BLOCK_PORTAL_BLUE){
        
        for (Block *b in character.level.blocks){
            if (b == self) continue;
            if (b.BLOCK_TYPE == BLOCK_PORTAL_BLUE){
                *new_new_x = b.position.x;
                *new_new_y = b.position.y;
                b.isBroken = true;
            }
        }
        
    } else if (self.BLOCK_TYPE == BLOCK_PORTAL_RED){
        
        for (Block *b in character.level.blocks){
            if (b == self) continue;
            if (b.BLOCK_TYPE == BLOCK_PORTAL_RED){
                *new_new_x = b.position.x;
                *new_new_y = b.position.y;
                b.isBroken = true;
            }
        }
        
    } else if (self.BLOCK_TYPE == BLOCK_PORTAL_GREEN){
        
        for (Block *b in character.level.blocks){
            if (b == self) continue;
            if (b.BLOCK_TYPE == BLOCK_PORTAL_GREEN){
                *new_new_x = b.position.x;
                *new_new_y = b.position.y;
                b.isBroken = true;
            }
        }
        
    } else if (self.BLOCK_TYPE == BLOCK_PUSHABLE){
        self.position = CGPointMake(self.position.x + abs(velocity.x), self.position.y);
        *new_new_x = self.position.x - character.characterImage.enclosingRect.size.width - 0.01;
    } else if (self.BLOCK_TYPE == BLOCK_PICKABLE) {
        if (!self.isBeingPicked){
            *new_new_x = self.blockSprite.enclosingRect.origin.x - character.characterImage.enclosingRect.size.width - 0.01;
        }
    } else {
        *new_new_x = self.blockSprite.enclosingRect.origin.x - character.characterImage.enclosingRect.size.width - 0.01;
    }
    
}

- (void) onCollideFromRight:(Character*)character withMovement:(CGPoint)movement andVelocity:(CGPoint)velocity retX:(float*)new_new_x retY:(float*)new_new_y {
    if (self.isBroken){
        return;
    }
    
    if (self.BLOCK_TYPE == BLOCK_STAIRS){
        *new_new_x = self.blockSprite.enclosingRect.origin.x + self.blockSprite.enclosingRect.size.width + 0.01;
        // *new_new_y = self.blockSprite.enclosingRect.origin.y + character.characterImage.enclosingRect.size.height + 0.01;
    } else if (self.BLOCK_TYPE == BLOCK_LADDDER) {
        /*
        *new_new_x = movement.x; // + gravityOffset.x; // + velocity.x;
        *new_new_y = movement.y; // + gravityOffset.y + velocity.y;
         */
        if (character.isProtagonist){
            *new_new_x = *new_new_x;
            *new_new_y = *new_new_y + (velocity.y > 0 ? LADDER_SPEED_FACTOR : ( velocity.y < 0 ? -LADDER_SPEED_FACTOR : 0 ) );
        }
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
    } else if (self.BLOCK_TYPE == BLOCK_DOOR_GREEN){
        if ([character.addons objectForKey:[NSNumber numberWithInt:ADDON_GREEN_KEY]]){
            self.isBroken = true;
        } else {
            *new_new_x = self.blockSprite.enclosingRect.origin.x + self.blockSprite.enclosingRect.size.width + 0.01;
        }
    } else if (self.BLOCK_TYPE == BLOCK_GRAVITY_SHIFT_BOTTOM || self.BLOCK_TYPE == BLOCK_GRAVITY_SHIFT_TOP){
        // same as standard
        *new_new_x = self.blockSprite.enclosingRect.origin.x + self.blockSprite.enclosingRect.size.width + 0.01;
        
    } else if (self.BLOCK_TYPE == BLOCK_FINISH){
        if (character.isProtagonist) {
            character.level.levelState = LEVEL_COMPLETE;
        }
    } else if (self.BLOCK_TYPE == BLOCK_PORTAL_BLUE){
        
        for (Block *b in character.level.blocks){
            if (b == self) continue;
            if (b.BLOCK_TYPE == BLOCK_PORTAL_BLUE){
                *new_new_x = b.position.x;
                *new_new_y = b.position.y;
                b.isBroken = true;
            }
        }
        
    } else if (self.BLOCK_TYPE == BLOCK_PORTAL_RED){
        
        for (Block *b in character.level.blocks){
            if (b == self) continue;
            if (b.BLOCK_TYPE == BLOCK_PORTAL_RED){
                *new_new_x = b.position.x;
                *new_new_y = b.position.y;
                b.isBroken = true;
            }
        }
        
    } else if (self.BLOCK_TYPE == BLOCK_PORTAL_GREEN){
        
        for (Block *b in character.level.blocks){
            if (b == self) continue;
            if (b.BLOCK_TYPE == BLOCK_PORTAL_GREEN){
                *new_new_x = b.position.x;
                *new_new_y = b.position.y;
                b.isBroken = true;
            }
        }
        
    } else if (self.BLOCK_TYPE == BLOCK_PUSHABLE){
        self.position = CGPointMake(self.position.x - abs(velocity.x), self.position.y);
        *new_new_x = self.position.x + self.blockSprite.enclosingRect.size.width + 0.01;
    } else if (self.BLOCK_TYPE == BLOCK_PICKABLE) {
        if (!self.isBeingPicked){
            *new_new_x = self.blockSprite.enclosingRect.origin.x + self.blockSprite.enclosingRect.size.width + 0.01;
        }
    } else {
        *new_new_x = self.blockSprite.enclosingRect.origin.x + self.blockSprite.enclosingRect.size.width + 0.01;
    }

}

@end
