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
#import "Addon.h"
#import "Bullet.h"

#define SPEED_SCALE_X 4.0
#define SPEED_SCALE_Y 0.5
#define JUMP_SCALE 50.0
#define SHOOT_DISTANCE 280.0
#define INITIAL_JUMP_FACTOR 2
#define NUMBER_OF_LIVES 90000

#define PHONE_SIZE CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)

@interface Character()

@property CGPoint lastPosition;

@property bool isJumping;
@property float jumpForce;
@property int jumpCounter;
@property bool linearJump;
@property bool isDoubleJumping;

@property bool isWalking;
@property int frameCounter;

@property NSMutableArray* collidedBlocks;

@property Sprite* lifeSprite;
@property int lives;
@property int lifeRemovedCounter;

@property float bulletForce;
@property int bulletFiredCounter;
@property int bulletFiredCounterReset;

@property NSMutableArray* bullets;

@end

@implementation Character

@synthesize isProtagonist = _isProtagonist;

@synthesize characterImage = _characterImage;
@synthesize characterSize = _characterSize;

@synthesize direction = _direction;
@synthesize lastDirection = _lastDirection;

@synthesize position = _position;
@synthesize lastPosition = _lastPosition;

@synthesize isJumping = _isJumping;
@synthesize jumpForce = _jumpForce;
@synthesize jumpCounter = _jumpCounter;
@synthesize linearJump = _linearJump;
@synthesize isDoubleJumping = _isDoubleJumping;

@synthesize isWalking = _isWalking;
@synthesize frameCounter = _frameCounter;

@synthesize level = _level;

@synthesize isDead = _isDead;

@synthesize lifeSprite = _lifeSprite;
@synthesize lives = _lives;
@synthesize lifeRemovedCounter = _lifeRemovedCounter;

@synthesize addons = _addons;
@synthesize pickedBlock = _pickedBlock;

@synthesize bullets = _bullets;
@synthesize bulletForce = _bulletForce;
@synthesize bulletFiredCounter = _bulletFiredCounter;
@synthesize bulletFiredCounterReset = _bulletFiredCounterReset;

@synthesize collidedBlocks = _collidedBlocks;

@synthesize autoMovement = _autoMovement;
@synthesize autoDirection = _autoDirection;

- (id) initProtagonistWithPositionX:(int)x andPositionY:(int)y andImage:(UIImage*)image andLevel:(Level*)level {
    if ([self initCharacterWithPositionX:x andPositionY:y andImage:image andLevel:level]){
    
        self.isProtagonist = YES;
        
        return self;
    }
    
    return nil;
}

- (id) initCharacterWithPositionX:(int)x andPositionY:(int)y andImage:(UIImage*)image andLevel:(Level*)level
{
    
    if ([self init]){
        
        self.isProtagonist = NO;
        self.isDead = NO;
        
        self.characterSize = CGSizeMake((image.size.width) / 5, image.size.height);
        
        self.characterImage = [[AnimatedSprite alloc] initWithImage:image andManualFlip:YES];
        
        self.direction = 0;
        self.lastDirection = 0;
        self.position = CGPointMake(x, y);
        self.lastPosition = CGPointMake(x, y);
        
        self.addons = [[NSMutableDictionary alloc] init];
        self.pickedBlock = nil;
        
        self.isJumping = NO;
        self.isDoubleJumping = NO;
        self.jumpForce = 0;
        self.jumpCounter = 0;
        self.linearJump = false;
        self.isWalking = NO;
        self.frameCounter = 0;
        
        self.level = level;
        
        self.lifeSprite = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"stats_life.png"]];
        self.lives = NUMBER_OF_LIVES;
        self.lifeRemovedCounter = 0;
        
        // one second
        self.bulletFiredCounterReset = 90;
        self.bulletFiredCounter = 0;
        self.bulletForce = 4.0;
        self.bullets = [[NSMutableArray alloc] init];
        
        self.collidedBlocks = [[NSMutableArray alloc] init];
        
        self.autoMovement = NO_MOVEMENT;
        self.autoDirection = -1;
        
        return self;
    }
    
    return nil;
}

- (void) initiateJumpWithForce:(float)force {
    if (self.isDead || self.level.levelState != LEVEL_PLAYING) {
        return;
    }
    
    if ([self.addons objectForKey:[NSNumber numberWithInt:ADDON_JETPACK]]){
        self.linearJump = true;
        
        self.jumpForce = force * 2;
    } else {
        if (self.isJumping) {
            
            bool againstGravity = false;
            
            if ((self.level.gravityPosition == GRAVITY_BOTTOM && self.position.y < self.lastPosition.y) ||
                (self.level.gravityPosition == GRAVITY_TOP && self.position.y > self.lastPosition.y)){
                // direction changed
                againstGravity = true;
            }
            
            // if double jump is enabled and if previous direction was against gravity, then do something
            if (againstGravity && !self.isDoubleJumping && [self.addons objectForKey:[NSNumber numberWithInt:ADDON_DOUBLE_JUMP]]){
                // continue adding force
                self.isDoubleJumping = true;
            } else if (againstGravity && [self.addons objectForKey:[NSNumber numberWithInt:ADDON_INFINITE_JUMP]]) {
                // continue with a jump
            } else {
                return;
            }
        }
        
        // JETPACK takes precedece against jumping shoes
        if ([self.addons objectForKey:[NSNumber numberWithInt:ADDON_JUMPING_SHOES]]){
            // force *= 2 * force;
            // self.jumpForce = force * JUMP_SCALE;
            self.jumpForce = force * 8;
        } else {
            // self.jumpForce = force * JUMP_SCALE;
            self.jumpForce = force * 6;
        }
    }
    
    self.jumpCounter = 0;
    self.isJumping = true;
    
    // if (self.level.gravityPosition == GRAVITY_TOP){
        self.jumpForce = -self.jumpForce;
    // }
}

- (void) doBActionWithJoystickDirection:(float)direction {
    if (self.isDead || self.level.levelState != LEVEL_PLAYING) {
        return;
    }

    // do with existing block first
    if (self.pickedBlock != nil){
        [self.pickedBlock doAction];
        return;
    }
    
    CGRect collisionRect = self.characterImage.enclosingRect;
    
    // if (gravity is up on down, then look left or right depending on player's direction)
    if (self.level.gravityPosition == GRAVITY_BOTTOM || self.level.gravityPosition == GRAVITY_TOP){
        // if player facing left
        
        if (fabs(self.lastDirection) > M_PI_2) {
            // check collision to the left
            collisionRect = CGRectMake(collisionRect.origin.x - collisionRect.size.width, collisionRect.origin.y, collisionRect.size.width, collisionRect.size.height);
        } else {
            collisionRect = CGRectMake(collisionRect.origin.x, collisionRect.origin.y, collisionRect.size.width * 2, collisionRect.size.height);
        }
    }
    // otherwise
    else {
        // nothing for now
    }

    bool foundProximBlock = false;
    // check for proxim blocks that can take action such as pickable/brakeable blocks
    for (Block * block in self.level.blocks) {
        if (block.BLOCK_TYPE != BLOCK_PICKABLE && block.BLOCK_TYPE != BLOCK_BREAKABLE)
            continue;
        
        if (CGRectIntersectsRect(block.blockSprite.enclosingRect, collisionRect)){
            [block doAction];
            self.pickedBlock = block;
            foundProximBlock = true;
        }
    }
    
    if (foundProximBlock) return;
    
    // shoot!!!
    for (NSNumber *addon_key in self.addons){
        Addon *addon = [self.addons objectForKey:addon_key];
        [addon execute];
        if (self.bulletFiredCounter <= 0 && ([addon_key intValue] == ADDON_COLLIDING_QUADRATIC_GUN || [addon_key intValue] == ADDON_NONCOLLIDING_QUADRATIC_GUN)){
            
            // fire a linear colliding bullet
            Bullet* bullet = [[Bullet alloc] initWithImage:[UIImage imageNamed:@"bullet_1.png"] ofType:[addon_key intValue] == ADDON_COLLIDING_QUADRATIC_GUN ? COLLIDING_QUADRATIC_BULLET : NONCOLLIDING_QUADRATIC_BULLET ownedBy:self atX:self.position.x + (self.characterSize.width / 2) andY:self.position.y + (self.characterSize.height / 2) withDirection:self.lastDirection andForce:self.bulletForce];
            
            [self.bullets addObject:bullet];
            
            self.bulletFiredCounter = self.bulletFiredCounterReset;
        } else if (self.bulletFiredCounter <= 0 && ([addon_key intValue] == ADDON_COLLIDING_LINEAR_GUN || [addon_key intValue] == ADDON_NONCOLLIDING_LINEAR_GUN)){
            
            // fire a linear colliding bullet
            Bullet* bullet = [[Bullet alloc] initWithImage:[UIImage imageNamed:@"bullet_1.png"] ofType:[addon_key intValue] == ADDON_COLLIDING_LINEAR_GUN ? COLLIDING_LINEAR_BULLET : NONCOLLIDING_LINEAR_BULLET ownedBy:self atX:self.position.x + (self.characterSize.width / 2) andY:self.position.y + (self.characterSize.height / 2) withDirection:self.lastDirection andForce:self.bulletForce];
            
            [self.bullets addObject:bullet];
            
            self.bulletFiredCounter = self.bulletFiredCounterReset;
        } else if (self.bulletFiredCounter <= 0 && ([addon_key intValue] == ADDON_COLLIDING_QUADRATIC_GUN || [addon_key intValue] == ADDON_NONCOLLIDING_QUADRATIC_GUN)) {
            
            self.bulletFiredCounter = self.bulletFiredCounterReset;
        }
    }

}

- (void) updateAI:(long)ms againstCharacter:(Character*)theman {

    float direction = self.autoDirection;
    if (self.autoMovement == PURSUE_CHARACTER){
        direction = atan2f(theman.position.y - self.position.y, theman.position.x - self.position.x);
    }
    
    if (self.isDead || self.level.levelState != LEVEL_PLAYING){
        return;
    }
    
    // float mDirection = direction;
    // if (self.level.gravityPosition == GRAVITY_BOTTOM || self.level.gravityPosition == GRAVITY_TOP){
    //     mDirection = theman.position.x < self.position.x ? M_PI : 0;
    // } else {
    //     mDirection = theman.position.y < self.position.y ? M_PI : 0;
    // }

    float joystickSpeed = 0;
    if (self.autoMovement != NO_MOVEMENT){
        // try to move closer to the man
        int rand = arc4random_uniform(900);
        if (rand % 897 == 0){
            [self initiateJumpWithForce:0.5];
        }
        
        joystickSpeed = 0.2;
    }
    
    if ([MathUtil calculateDistance:self.position :theman.position] < SHOOT_DISTANCE){

        // shoot!!!
        for (NSNumber *addon_key in self.addons){
            Addon *addon = [self.addons objectForKey:addon_key];
            [addon execute];
            if (self.bulletFiredCounter <= 0 && ([addon_key intValue] == ADDON_COLLIDING_LINEAR_GUN || [addon_key intValue] == ADDON_NONCOLLIDING_LINEAR_GUN || [addon_key intValue] == ADDON_COLLIDING_STRAIGHT_GUN || [addon_key intValue] == ADDON_NONCOLLIDING_STRAIGHT_GUN)){
            
                _BULLET_TYPE bulletType = [addon_key intValue] == ADDON_NONCOLLIDING_STRAIGHT_GUN ?NONCOLLIDING_STRAIGHT_BULLET : COLLIDING_STRAIGHT_BULLET;
                if ([addon_key intValue] == ADDON_NONCOLLIDING_LINEAR_GUN){
                    bulletType = NONCOLLIDING_LINEAR_BULLET;
                } else if ([addon_key intValue] == ADDON_COLLIDING_LINEAR_GUN) {
                    bulletType = COLLIDING_LINEAR_BULLET;
                } else if ([addon_key intValue] == ADDON_NONCOLLIDING_QUADRATIC_GUN){
                    bulletType = NONCOLLIDING_QUADRATIC_BULLET;
                } else if ([addon_key intValue] == ADDON_COLLIDING_QUADRATIC_GUN){
                    bulletType = COLLIDING_QUADRATIC_BULLET;
                }
                
                // fire a linear colliding bullet
                Bullet* bullet = [[Bullet alloc] initWithImage:[UIImage imageNamed:@"bullet_1.png"] ofType:bulletType ownedBy:self atX:self.position.x + self.characterSize.width / 2 andY:self.position.y + self.characterSize.height / 2 withDirection:direction andForce:self.bulletForce];
            
                [self.bullets addObject:bullet];
                
                self.bulletFiredCounter = self.bulletFiredCounterReset;
            } else if (self.bulletFiredCounter <= 0 && ([addon_key intValue] == ADDON_COLLIDING_QUADRATIC_GUN || [addon_key intValue] == ADDON_NONCOLLIDING_QUADRATIC_GUN)) {
            
                self.bulletFiredCounter = self.bulletFiredCounterReset;
            }
        }
        
        [self update:ms withJoystickSpeed:joystickSpeed andDirection:direction];

    } else {
        [self update:ms];
    }
}

-(void) update:(long)ms {
    [self update:ms withJoystickSpeed:0 andDirection:0];
}

- (void) update:(long)ms withJoystickSpeed:(float)speed andDirection:(float)direction {
    if (self.level.levelState != LEVEL_PLAYING){
        return;
    }
    
    // update bullets even if the character itself is dead
    // draw bullets
    NSMutableArray* to_be_kept_bullets = [[NSMutableArray alloc] init];
    for (Bullet* bullet in self.bullets){
        if (![bullet update]){
            [to_be_kept_bullets addObject:bullet];
        }
    }
    
    self.bullets = to_be_kept_bullets;
    
    if (self.isDead){
        return;
    }
    
    if (self.direction != direction){
        self.lastDirection = self.direction;
        self.direction = direction;
    }
    
    float scale_x = cosf(direction); // right or left movement only
    float scale_y = sinf(direction);
    
    // speed = SPEED_SCALE * speed;
    
    // changed velicoty x to 1 after slowing down jump up and down
    float velocity_x = SPEED_SCALE_X * speed * scale_x;
    float velocity_y = SPEED_SCALE_Y * speed * scale_y;
    
    if (((fabs(velocity_x) > 0.0) && (self.level.gravityPosition == GRAVITY_BOTTOM || self.level.gravityPosition == GRAVITY_TOP)) || ((fabs(velocity_y) > 0.0) && (self.level.gravityPosition == GRAVITY_RIGHT || self.level.gravityPosition == GRAVITY_LEFT))){
        self.isWalking = true;
    } else {
        self.isWalking = false;
    }
    
    float new_x = self.level.gravityPosition == GRAVITY_NONE || self.level.gravityPosition == GRAVITY_BOTTOM || self.level.gravityPosition == GRAVITY_TOP ? self.position.x + velocity_x  : self.position.x;
    float new_y = self.level.gravityPosition == GRAVITY_NONE || self.level.gravityPosition == GRAVITY_RIGHT || self.level.gravityPosition == GRAVITY_LEFT ? self.position.y + velocity_y  : self.position.y;

    CGPoint gravityOffset = CGPointMake(0, 0);

    // apply gravity
    if (self.isJumping ){
        self.jumpCounter++;
    }
    if (self.level.gravityPosition == GRAVITY_BOTTOM){
        if (self.jumpForce < -1) {
            new_y += self.jumpForce * self.jumpForce * SPEED_SCALE_Y;
            if (!self.linearJump) {
                self.jumpForce += SPEED_SCALE_Y;
            }
        } else if (self.jumpForce >= -1 && self.jumpForce < 1){
            self.jumpForce = 1;
            self.jumpCounter = 0;
        }
        else {
            gravityOffset = CGPointMake(0, -self.jumpForce);
            
            new_y -= self.jumpForce * self.jumpForce * SPEED_SCALE_Y;
            
            self.jumpForce += SPEED_SCALE_Y;
        }
    } else if (self.level.gravityPosition == GRAVITY_TOP) {
        if (self.jumpForce < -1) {
            new_y -= self.jumpForce * self.jumpForce * SPEED_SCALE_Y;
            if (!self.linearJump) {
                self.jumpForce += SPEED_SCALE_Y;
            }
        } else if (self.jumpForce >= -1 && self.jumpForce < 1){
            self.jumpForce = 1;
            self.jumpCounter = 0;
        }
        else {
            gravityOffset = CGPointMake(0, -self.jumpForce);
            
            new_y += self.jumpForce * self.jumpForce * SPEED_SCALE_Y;
            
            self.jumpForce += SPEED_SCALE_Y;
        }
    }
    

    
    // check collision
    bool intersect_bottom = false;
    bool intersect_top = false;
    bool intersect_left = false;
    bool intersect_right = false;
    CGRect charRect = [self.characterImage enclosingRect];
    
    CGRect vertical_rect1, horizontal_rect1, rect2;
    
    float new_new_y = new_y;
    float new_new_x = new_x;
    
    for (Block* block in self.level.blocks){
 
        bool inner_intersect_bottom = false;
        bool inner_intersect_top = false;
        bool inner_intersect_left = false;
        bool inner_intersect_right = false;
        
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
            if (new_new_y < self.position.y){
                [block onCollideFromTop:self withMovement:CGPointMake(new_x, new_y) andVelocity:CGPointMake(velocity_x, velocity_y) retX:&new_new_x retY:&new_new_y];
                intersect_bottom = true;
                inner_intersect_bottom = true;
            } else if (new_new_y > self.position.y) {
                [block onCollideFromBottom:self withMovement:CGPointMake(new_x, new_y) andVelocity:CGPointMake(velocity_x, velocity_y)  retX:&new_new_x retY:&new_new_y];
                intersect_top = true;
                inner_intersect_top = true;
            } // ignore when they're equal
            // new_new_y = self.position.y;
            else {
                intersect_top = true;
                inner_intersect_top = true;
                intersect_bottom = true;
                inner_intersect_bottom = true;
            }
        }
        
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
            
            if (new_new_x < self.position.x){
                [block onCollideFromRight:self withMovement:CGPointMake(new_x, new_y) andVelocity:CGPointMake(velocity_x, velocity_y)  retX:&new_new_x retY:&new_new_y];
                intersect_left = true;
                inner_intersect_left = true;
            } else if (new_new_x > self.position.x) {
                [block onCollideFromLeft:self withMovement:CGPointMake(new_x, new_y) andVelocity:CGPointMake(velocity_x, velocity_y) retX:&new_new_x retY:&new_new_y];
                intersect_right = true;
                inner_intersect_right = true;
            } // ignore when they're equal
            // new_new_x = self.position.x;
            else {
                intersect_left = true;
                inner_intersect_left = true;
                intersect_right = true;
                inner_intersect_right = true;
            }
        }
        
        if (inner_intersect_bottom || inner_intersect_left || inner_intersect_right || inner_intersect_top){
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

    if (self.linearJump && ((self.jumpForce > 0 && self.level.gravityPosition == GRAVITY_BOTTOM)
                         || (self.jumpForce < 0 && self.level.gravityPosition == GRAVITY_TOP))){
        self.jumpForce = 0;
    }
    
    if (intersect_bottom || intersect_left || intersect_right || intersect_top){
        self.autoDirection *= -1; // flip direction on collision
    }
    
    if (intersect_bottom && self.level.gravityPosition == GRAVITY_BOTTOM){
        self.isJumping = false;
        if (self.isProtagonist) {
            self.isDoubleJumping = false;
        }
        self.jumpForce = 0;
    } else if (intersect_top && self.level.gravityPosition == GRAVITY_TOP){
        self.isJumping = false;
        self.isDoubleJumping = false;
        self.jumpForce = 0;
    } else if (intersect_right && self.level.gravityPosition == GRAVITY_RIGHT){
        self.isJumping = false;
        self.isDoubleJumping = false;
        self.jumpForce = 0;
    } else if (intersect_left && self.level.gravityPosition == GRAVITY_LEFT){
        self.isJumping = false;
        self.isDoubleJumping = false;
        self.jumpForce = 0;
    }
    
    // now that we have a final position of the character
    // check if the character acquired some addons
    // only protagonist should be able to get level addons
    if (self.isProtagonist) {
        // reuse verical_rect, BUT it actually contians final movement
        vertical_rect1 = CGRectMake(self.position.x < new_new_x ? self.position.x : new_new_x, self.position.y < new_new_y ? self.position.y : new_new_y, charRect.size.width + fabs(self.position.x - new_new_x), charRect.size.height + fabs(new_new_y - self.position.y));
        
        NSMutableArray* to_be_removed_addons = [[NSMutableArray alloc] init];
        for (Addon* addon in self.level.addons){
     
            rect2 = addon.addonSprite.enclosingRect;
            
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
                [self.addons setObject:addon forKey:[NSNumber numberWithInt:addon.type]];
                [to_be_removed_addons addObject:addon];
            }
        }
        
        [self.level.addons removeObjectsInArray:to_be_removed_addons];
        
        // now check collision with enemies
        for (Character* enemy in self.level.characters){
            
            rect2 = enemy.characterImage.enclosingRect;
            
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
                [self removeLife];
            }
        }
    }
    

    if (!CGPointEqualToPoint(self.position, CGPointMake(new_new_x, new_new_y))) {
        self.lastPosition = self.position;
    }
    if (self.isProtagonist){
        self.level.horizontalOffset -= new_new_x - self.position.x;
    }
    
    self.position = CGPointMake(new_new_x, new_new_y);
    
    self.lifeRemovedCounter--;
    
    self.bulletFiredCounter--;
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
        
        if (self.lives <= 0 || (self.lifeRemovedCounter > 0 && self.lifeRemovedCounter % 3 != 0 && self.lifeRemovedCounter % 5 != 0)){
            self.characterImage.framesSprite.alpha = 0.5;
        } else {
            self.characterImage.framesSprite.alpha = 1.0;
        }
        
        [self.characterImage render:ms frame:frame withSize:self.characterSize atX:self.position.x andXOffset:horizontalOffset andY:self.position.y andYOffset:0 flippedHorizontally:fabs(self.lastDirection) > M_PI_2 flippedVertically:self.level.gravityPosition == GRAVITY_TOP ? YES : NO];
        
    } else if (self.level.gravityPosition == GRAVITY_RIGHT || self.level.gravityPosition == GRAVITY_LEFT) {
        // TODO
    }
    
    if (self.isProtagonist) {
        
        // draw lives
        float posy = PHONE_SIZE.height - 10.0 - self.lifeSprite.enclosingRect.size.height;
        int lives = self.lives > 5 ? 5 : self.lives;
        for (int x = 0; x < lives; x++){
            float posx = PHONE_SIZE.width - 30.0 - x * (self.lifeSprite.enclosingRect.size.width + 10);
            [self.lifeSprite renderWithSize:self.lifeSprite.enclosingRect.size atX:posx andXOffset:0 andY:posy andYOffset:0];
        }
        
        // draw addons maybed
    }
    
    // draw character's bullets
    for (Bullet* bullet in self.bullets){
        [bullet draw:ms withHorizontalOffset:horizontalOffset];
    }
}

- (void) removeLife {
    if (self.lifeRemovedCounter <= 0){
        self.lives--;
        // 3 second grace period
        self.lifeRemovedCounter = 90;
    }
    if (self.lives <= 0){
        self.isDead = YES;
        
        if (self.isProtagonist){
            // game over
            self.level.levelState = LEVEL_LOST;
        }
    }
}

-(int) nextFrameSequence:(int)frame previous:(int)previousFrame{
    
    // 0 -> 1, 1 -> 2, 2 -> 1, 1 -> 0
    int ret = frame == 1 && previousFrame == 2 ? 0 : frame + 1;
    if (ret >= 3) ret = 1;
    
    return ret;
}

@end
