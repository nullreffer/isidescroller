//
//  Character.m
//  SideScroller
//
//  Created by Jay Desai on 4/3/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import "MathUtil.h"
#import "CGUtil.h"
#import "Character.h"
#import "Level.h"

#define SPEED_SCALE 2.0
#define JUMP_SCALE 50.0

@interface Character()

@property float direction;
@property float lastDirection;

@property CGPoint lastPosition;

@property bool isJumping;
@property float jumpForce;

@property bool isWalking;
@property int frameCounter;

@property NSMutableArray* collidedBlocks;

@end

@implementation Character

@synthesize characterImage = _characterImage;
@synthesize characterSize = _characterSize;

@synthesize direction = _direction;
@synthesize lastDirection = _lastDirection;

@synthesize position = _position;
@synthesize lastPosition = _lastPosition;

@synthesize isJumping = _isJumping;
@synthesize jumpForce = _jumpForce;

@synthesize isWalking = _isWalking;
@synthesize frameCounter = _frameCounter;

@synthesize level = _level;

@synthesize isDead = _isDead;
@synthesize addons = _addons;

@synthesize collidedBlocks = _collidedBlocks;

- (id) initCharacterWithPositionX:(int)x andPositionY:(int)y andImage:(UIImage*)image andLevel:(Level*)level
{
    
    if ([self init]){
        
        self.characterSize = CGSizeMake((image.size.width) / 5, image.size.height);
        
        self.characterImage = [[AnimatedSprite alloc] initWithImage:image andManualFlip:YES];
        // self.characterImage = [[Sprite alloc] initWithRect:[image CGImage] croppedTo:CGRectMake(0, 0, characterWidth, image.size.height) andManualFlip:NO];
        
        self.direction = 0;
        self.lastDirection = 0;
        self.position = CGPointMake(x, y);
        self.lastPosition = CGPointMake(x, y);
        
        self.addons = [[NSMutableDictionary alloc] init];
        
        self.isJumping = false;
        self.jumpForce = 0;
        self.isWalking = false;
        self.frameCounter = 0;
        
        self.level = level;
        
        self.collidedBlocks = [[NSMutableArray alloc] init];
        
        return self;
    }
    
    return nil;
}

- (void) initiateJumpWithForce:(float)force {
    if (self.isJumping)
        return;
    
    self.jumpForce = force * JUMP_SCALE;
    self.isJumping = true;
}

-(void) update:(long)ms {
    [self update:ms withJoystickSpeed:0 andDirection:0];
}

- (void) update:(long)ms withJoystickSpeed:(float)speed andDirection:(float)direction {
    
    if (self.direction != direction){
        self.lastDirection = self.direction;
        self.direction = direction;
    }
    
    float scale_x = cosf(direction); // right or left movement only
    float scale_y = sinf(direction);
    
    speed = SPEED_SCALE * speed;
    
    float velocity_x = speed * scale_x;
    float velocity_y = speed * scale_y;
    
    if (((abs(velocity_x) > 0.0) && (self.level.gravityPosition == GRAVITY_BOTTOM || self.level.gravityPosition == GRAVITY_TOP)) || ((abs(velocity_y) > 0.0) && (self.level.gravityPosition == GRAVITY_RIGHT || self.level.gravityPosition == GRAVITY_LEFT))){
        self.isWalking = true;
    } else {
        self.isWalking = false;
    }
    
    float new_x = self.level.gravityPosition == GRAVITY_NONE || self.level.gravityPosition == GRAVITY_BOTTOM || self.level.gravityPosition == GRAVITY_TOP ? self.position.x + velocity_x  : self.position.x;
    float new_y = self.level.gravityPosition == GRAVITY_NONE || self.level.gravityPosition == GRAVITY_RIGHT || self.level.gravityPosition == GRAVITY_LEFT ? self.position.y + velocity_y  : self.position.y;
    
    CGPoint gravityOffset = CGPointMake(0, 0);
    
    // apply gravity
    if (self.level.gravityPosition == GRAVITY_BOTTOM){
        gravityOffset = CGPointMake(0, -self.jumpForce);
        if (self.jumpForce > 1) {
            new_y += self.jumpForce;
            self.jumpForce = self.jumpForce / 2;
        } else if (self.jumpForce <= 1 && self.jumpForce > -1){
            self.jumpForce = -1;
        }
        else {
            new_y += self.jumpForce;
            self.jumpForce = self.jumpForce * 2;
        }
    } else if (self.level.gravityPosition == GRAVITY_TOP) {
        gravityOffset = CGPointMake(0, self.jumpForce);
        if (self.jumpForce < -1) {
            new_y += self.jumpForce;
            self.jumpForce = self.jumpForce / 2;
        } else if (self.jumpForce >= -1 && self.jumpForce < 1){
            self.jumpForce = 1;
        }
        else {
            new_y += self.jumpForce;
            self.jumpForce = self.jumpForce * 2;
        }
    }
    
    // check collision
    bool intersect_bottom = false;
    bool intersect_top = false;
    bool intersect_left = false;
    bool intersect_right = false;
    CGRect charRect = [self.characterImage enclosingRect];
    CGRect vertical_rect1 = new_y < self.position.y ? CGRectMake(self.position.x, self.position.y, charRect.size.width, (self.position.y - new_y) + self.characterImage.enclosingRect.size.height) : CGRectMake(self.position.x, new_y, charRect.size.width, (new_y - self.position.y) + self.characterImage.enclosingRect.size.height);
    CGRect horizontal_rect1 = new_x > self.position.x ? CGRectMake(self.position.x, self.position.y, (new_x - self.position.x) + self.characterImage.enclosingRect.size.width, self.characterImage.enclosingRect.size.height) : CGRectMake(new_x, self.position.y, (self.position.x - new_x) + self.characterImage.enclosingRect.size.width, self.characterImage.enclosingRect.size.height);

    float new_new_y = new_y;
    float new_new_x = new_x;
    
    for (Block* block in self.level.blocks){
 
        CGRect rect2 = block.blockSprite.enclosingRect;
        
        // vertical rect intersection
        if (vertical_rect1.origin.y - vertical_rect1.size.height > rect2.origin.y ||
            vertical_rect1.origin.y < rect2.origin.y - rect2.size.height) {
            // no y intersection
        } else if (vertical_rect1.origin.x > rect2.origin.x + rect2.size.width ||
                   vertical_rect1.origin.x + vertical_rect1.size.width < rect2.origin.x ){
            // no x intersection
        } else {
            if (new_y < self.position.y){
                [block onCollideFromTop:self withMovement:CGPointMake(new_x, new_y) andVelocity:CGPointMake(velocity_x, velocity_y) andGravityOffset:gravityOffset retX:&new_new_x retY:&new_new_y];
                intersect_bottom = true;
            } else if (new_y > self.position.y) {
                [block onCollideFromBottom:self withMovement:CGPointMake(new_x, new_y) andVelocity:CGPointMake(velocity_x, velocity_y) andGravityOffset:gravityOffset retX:&new_new_x retY:&new_new_y];
                intersect_top = true;
            } // ignore when they're equal
        }
        
        if (!intersect_top && !intersect_bottom) {
            // horizontal rect intersection
            if (horizontal_rect1.origin.y - horizontal_rect1.size.height > rect2.origin.y ||
                horizontal_rect1.origin.y < rect2.origin.y - rect2.size.height) {
                // no y intersection
            } else if (horizontal_rect1.origin.x > rect2.origin.x + rect2.size.width ||
                       horizontal_rect1.origin.x + horizontal_rect1.size.width < rect2.origin.x ){
                // no x intersection
            } else {
                if (new_x < self.position.x){
                    [block onCollideFromRight:self withMovement:CGPointMake(new_x, new_y) andVelocity:CGPointMake(velocity_x, velocity_y) andGravityOffset:gravityOffset retX:&new_new_x retY:&new_new_y];
                    intersect_left = true;
                } else if (new_x > self.position.x) {
                    [block onCollideFromLeft:self withMovement:CGPointMake(new_x, new_y) andVelocity:CGPointMake(velocity_x, velocity_y) andGravityOffset:gravityOffset retX:&new_new_x retY:&new_new_y];
                    intersect_right = true;
                } // ignore when they're equal
            }
        }
        
        if (intersect_bottom || intersect_left || intersect_right || intersect_top){
            // some side of the block collided
            [self.collidedBlocks addObject:block];
        } else {
            // no collision between character and block
            if ([self.collidedBlocks containsObject:block]){
                [self.collidedBlocks removeObject:block];
                [block onCollisionComplete:self];
            }
        }
    
    }

    if (intersect_bottom && self.level.gravityPosition == GRAVITY_BOTTOM){
        self.isJumping = false;
        self.jumpForce = 0;
    } else if (intersect_top && self.level.gravityPosition == GRAVITY_TOP){
        self.isJumping = false;
        self.jumpForce = 0;
    } else if (intersect_right && self.level.gravityPosition == GRAVITY_RIGHT){
        self.isJumping = false;
        self.jumpForce = 0;
    } else if (intersect_left && self.level.gravityPosition == GRAVITY_LEFT){
        self.isJumping = false;
        self.jumpForce = 0;
    }

    if (!CGPointEqualToPoint(self.position, CGPointMake(new_new_x, new_new_y))) {
        self.lastPosition = self.position;
    }
    self.level.horizontalOffset -= new_new_x - self.position.x;
    self.position = CGPointMake(new_new_x, new_new_y);
    
}

-(void) draw:(long)ms withHorizontalOffset:(float)horizontalOffset {
    int frame = self.characterImage.currentFrame;
    if (self.level.gravityPosition == GRAVITY_BOTTOM || self.level.gravityPosition == GRAVITY_TOP){
        
        // 0 standing, 1 walk step 1, 2 = walk step 2
        // so I want 0, 1, 2, 1, 0, 1, 2,
        frame = !self.isWalking ? 0 : (self.frameCounter-- > 0 ? frame : [self nextFrameSequence:frame previous:self.characterImage.previousFrame]);
        if (self.frameCounter < 0){
            self.frameCounter = 2;
        }
        
        frame = self.isJumping ? 3 : frame;
        
        [self.characterImage render:ms frame:frame withSize:self.characterSize atX:self.position.x andXOffset:horizontalOffset andY:self.position.y andYOffset:8 flippedHorizontally:abs(self.lastDirection) > M_PI_2 flippedVertically:NO];
        // [self.characterImage renderWithSize:self.characterSize atX:self.position.x andXOffset:horizontalOffset andY:self.position.y andYOffset:0];
    } else if (self.level.gravityPosition == GRAVITY_RIGHT || self.level.gravityPosition == GRAVITY_LEFT) {
        // TODO
    }
    
}

-(int) nextFrameSequence:(int)frame previous:(int)previousFrame{
    
    // 0 -> 1, 1 -> 2, 2 -> 1, 1 -> 0
    int ret = frame == 1 && previousFrame == 2 ? 0 : frame + 1;
    if (ret == 3) ret = 1;
    
    return ret;
}

@end
