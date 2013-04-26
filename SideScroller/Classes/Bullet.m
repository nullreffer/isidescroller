//
//  Bullet.m
//  SideScroller
//
//  Created by Jay Desai on 4/25/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import "MathUtil.h"
#import "Bullet.h"
#import "Sprite.h"

#define SPEED_SCALE 0.5
#define DISTANCE_THRESHOLD 400

@interface Bullet()

@property Sprite* bulletSprite;
@property CGPoint position;
@property CGPoint lastPosition;
@property float direction;
@property float lastDirection;
@property float force;

@property float gravityForce;

// hack (temporary maybe)
@property bool firstUpdate;

@end

@implementation Bullet

@synthesize bulletSprite = _bulletSprite;
@synthesize position = _position;
@synthesize lastPosition = _lastPosition;
@synthesize direction = _direction;
@synthesize lastDirection = _lastDirection;
@synthesize force = _force;
@synthesize gravityForce = _gravityForce;
@synthesize bulletType = _bulletType;
@synthesize owner = _owner;

- (id) initWithImage:(UIImage*)image ofType:(_BULLET_TYPE)type ownedBy:(Character*)owner atX:(float)x andY:(float)y withDirection:(float)direction andForce:(float)force {
    
    if ([self init]){
        
        self.bulletSprite = [[Sprite alloc] initWithImage:image andManualFlip:YES];
        self.position = CGPointMake(x, y);
        self.lastPosition = CGPointMake(x, y);
        self.direction = direction;
        self.lastDirection = direction;
        self.force = force;
        self.gravityForce = 2.0/force;
        self.bulletType = type;
        self.owner = owner;
        
        self.firstUpdate = YES;
        
        return self;
    }
    
    return nil;
}

- (bool) update {
    
    if (self.firstUpdate){
        self.firstUpdate = NO;
        return false;
    }
    
    // if bullets too far, then it can be gotten rid of
    if ([MathUtil calculateDistance:self.position :self.owner.position] > DISTANCE_THRESHOLD){
        return true;
    }
    
    
    float new_x = self.position.x;
    float new_y = self.position.y;
    
    float scale_x = cosf(self.direction); // right or left movement only
    float scale_y = sinf(self.direction);
    
    float speed = SPEED_SCALE * self.force;
    
    float velocity_x = speed * scale_x;
    float velocity_y = speed * scale_y;
    
    if (self.bulletType == COLLIDING_QUADRATIC_BULLET || self.bulletType == NONCOLLIDING_QUADRATIC_BULLET){
        
        // quadratic reduces force
        self.force /= 2.0;
        
        // and changes velocity towards gravity
        if (self.owner.level.gravityPosition == GRAVITY_BOTTOM){
            velocity_y -= self.gravityForce;
            self.gravityForce *= 2.0;
        }
    }
    
    new_x += velocity_x;
    new_y += velocity_y;
    
    self.lastDirection = self.direction;
    self.direction = atan2f(new_y - self.position.y, new_x - self.position.x);
    
    CGRect charRect = [self.bulletSprite enclosingRect];
    CGRect bulletRect = CGRectMake(self.position.x < new_x ? self.position.x : new_x, self.position.y < new_y ? self.position.y : new_y, charRect.size.width + fabs(self.position.x - new_x), charRect.size.height + fabs(new_y - self.position.y));
    
    self.lastPosition = self.position;
    self.position = CGPointMake(new_x, new_y);
    
    bool collided = false;
    
    if (self.bulletType == COLLIDING_LINEAR_BULLET || self.bulletType == COLLIDING_QUADRATIC_BULLET){
        // check collision in level with all blocks
        
        for (Block *block in self.owner.level.blocks){
            CGRect rect2 = [block.blockSprite enclosingRect];
            
            // vertical rect intersection
            // if the bottom of the char is greater than block's top
            // or the top of the char is less than the block's bottom
            if (bulletRect.origin.y > rect2.origin.y + rect2.size.height ||
                bulletRect.origin.y + bulletRect.size.height < rect2.origin.y){
                // no y intersection
            }
            // if the left of the char is greater than the block's right
            // or the right of the char is less than the block's left
            else if (bulletRect.origin.x > rect2.origin.x + rect2.size.width ||
                     bulletRect.origin.x + bulletRect.size.width < rect2.origin.x){
                // no x intersection
            } else {
                collided = true;
            }
        }
        
    }
    
    if (!collided){
        
        for (Character* character in self.owner.level.characters){
            // can a man kill himself with his own bullets?
            if (character == self.owner || character.isDead) continue;
            
            CGRect rect2 = [character.characterImage enclosingRect];
            
            // vertical rect intersection
            // if the bottom of the char is greater than block's top
            // or the top of the char is less than the block's bottom
            if (bulletRect.origin.y > rect2.origin.y + rect2.size.height ||
                bulletRect.origin.y + bulletRect.size.height < rect2.origin.y){
                // no y intersection
            }
            // if the left of the char is greater than the block's right
            // or the right of the char is less than the block's left
            else if (bulletRect.origin.x > rect2.origin.x + rect2.size.width ||
                     bulletRect.origin.x + bulletRect.size.width < rect2.origin.x){
                // no x intersection
            } else {
                collided = true;
                [character removeLife];
            }
        }
        
    }
    
    return collided;
}

- (void) draw:(long)ms withHorizontalOffset:(float)horizontalOffset {
    TexturedQuad quad = self.bulletSprite.quad;
    
    quad.bl.textureVertex = CGPointMake(0, 0);
    quad.br.textureVertex = CGPointMake(1, 0);
    quad.tl.textureVertex = CGPointMake(0, 1);
    quad.tr.textureVertex = CGPointMake(1, 1);
    
    self.bulletSprite.quad = quad;
    
    [self.bulletSprite renderWithSize:self.bulletSprite.enclosingRect.size andRotation:self.direction atX:self.position.x andXOffset:horizontalOffset andY:self.position.y andYOffset:0 flippedHorizontally:NO flippedVertically:NO];
}

@end
