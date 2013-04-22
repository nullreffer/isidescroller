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
#import "Sprite.h"

#define SPEED_SCALE 2.0
#define JUMP_SCALE 40.0
#define GRAVITY_CONSTANT 10.0

@interface Character()

@property Sprite* characterImage;

@property float direction;

@property CGPoint position;
@property CGPoint lastPosition;

@property bool isJumping;
@property float jumpForce;

@property Level* level;

@end

@implementation Character

@synthesize direction = _direction;

@synthesize position = _position;
@synthesize lastPosition = _lastPosition;

@synthesize isJumping = _isJumping;
@synthesize jumpForce = _jumpForce;

@synthesize level = _level;

@synthesize isDead = _isDead;
@synthesize addons = _addons;

- (id) initCharacterWithPositionX:(int)x andPositionY:(int)y andImage:(UIImage*)image andLevel:(Level*)level
{
    
    if ([self init]){
        
        self.characterImage = [[Sprite alloc] initWithImage:image andManualFlip:YES];
        
        self.direction = 0;
        self.position = CGPointMake(x, y);
        self.lastPosition = CGPointMake(x, y);
        
        self.addons = [[NSMutableDictionary alloc] init];
        
        self.isJumping = false;
        self.jumpForce = 0;
        self.level = level;
        
        return self;
    }
    
    return nil;
}

- (void) initiateJumpWithForce:(float)force {
    if (self.isJumping)
        return;
    
    self.jumpForce = force * JUMP_SCALE;
    
    // if (self.jumpForce <= 0) {
        // self.jumpForce = force;
    // } else {
        // self.jumpForce -= self.level.gravity;
    // }
}

// This will be used by ortho-graphic view 2D games which require no gravity
- (void) update:(long)ms withJoystickSpeed:(float)speed andDirection:(float)direction {
    float scale_x = cosf(direction);
    float scale_y = sinf(direction);
    
    speed = SPEED_SCALE * speed;
    
    float velocity_x = speed * scale_x;
    float velocity_y = speed * scale_y;
    
    float new_x = self.position.x + velocity_x;
    float new_y = self.position.y + velocity_y;
    
    // apply gravity
    if (self.level.verticalGravity){
        new_y += self.jumpForce;
        if (self.jumpForce > 0) {
            self.jumpForce = self.jumpForce / 2;
        }
        float verticalDistance = (self.position.y / (4 * GRAVITY_CONSTANT)) - self.level.gravityLocation.y;
        float gravityForce = (self.level.gravity * 4 * GRAVITY_CONSTANT) / (verticalDistance * verticalDistance);
        new_y -= gravityForce;
        self.isJumping = true;
    } else {
        // else jump would be directed against the gravity point
        // and gravity pull would be towards the gravity point
    }
    
    // check collision
    bool intersect_bottom = false;
    // bool intersect_top = false;
    // bool intersect_left = false;
    bool intersect_right = false;
    CGRect vertical_rect1 = CGRectMake(self.position.x, self.position.y, self.characterImage.enclosingRect.size.width, (self.position.y - new_y) + self.characterImage.enclosingRect.size.height);
    CGRect horizontal_rect1 = CGRectMake(self.position.x, self.position.y, (new_x - self.position.x) + self.characterImage.enclosingRect.size.width, self.characterImage.enclosingRect.size.height);

    
    for (Block* block in self.level.blocks){
 
        CGRect rect2 = block.blockSprite.enclosingRect;
        
        if (vertical_rect1.origin.y - vertical_rect1.size.height > rect2.origin.y ||
            vertical_rect1.origin.y < rect2.origin.y - rect2.size.height) {
            // no y intersection
        } else if (vertical_rect1.origin.x > rect2.origin.x + rect2.size.width ||
                   vertical_rect1.origin.x + vertical_rect1.size.width < rect2.origin.x ){
            // no x intersection
        } else {
            new_y = self.position.y;
            intersect_bottom = true;
        }
        
        if (horizontal_rect1.origin.y - horizontal_rect1.size.height > rect2.origin.y ||
            horizontal_rect1.origin.y < rect2.origin.y - rect2.size.height) {
            // no y intersection
        } else if (horizontal_rect1.origin.x > rect2.origin.x + rect2.size.width ||
                   horizontal_rect1.origin.x + horizontal_rect1.size.width < rect2.origin.x ){
            // no x intersection
        } else {
            new_x = self.position.x;
            intersect_right = true;
        }
        
    }
    
    if (intersect_bottom){
        self.isJumping = false;
    }
    
    if (!CGPointEqualToPoint(self.position, CGPointMake(new_x, new_y))) {
        self.lastPosition = self.position;
    }
    self.level.horizontalOffset -= new_x - self.position.x;
    self.position = CGPointMake(new_x, new_y);
    
}

-(void) draw:(long)ms withHorizontalOffset:(float)horizontalOffset {
    [self.characterImage renderWithSize:1.0 atX:self.position.x andXOffset:horizontalOffset andY:self.position.y andYOffset:0];

}

@end
