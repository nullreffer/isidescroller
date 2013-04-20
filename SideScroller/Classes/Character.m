//
//  Character.m
//  SideScroller
//
//  Created by Jay Desai on 4/3/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

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
    bool intersect_x = false;
    bool intersect_y = false;
    // CGRect rect1 =  CGRectMake(new_x, new_y, self.characterImage.enclosingRect.size.width, self.characterImage.enclosingRect.size.height); // self.characterImage.enclosingRect;
    CGRect rect1 = CGRectMake(self.position.x, self.position.y, (new_x - self.position.x) + self.characterImage.enclosingRect.size.width, (self.position.y - new_y) + self.characterImage.enclosingRect.size.height);
    CGLine rect1_top = CGLineMake(rect1.origin, CGPointMake(rect1.origin.x + rect1.size.width, rect1.origin.y));
    CGLine rect1_bottom = CGLineMake(CGPointMake(rect1.origin.x, rect1.origin.y - rect1.size.height), CGPointMake(rect1.origin.x + rect1.size.width, rect1.origin.y - rect1.size.height));
    CGLine rect1_left = CGLineMake(rect1.origin, CGPointMake(rect1.origin.x, rect1.origin.y - rect1.size.height));
    CGLine rect1_right = CGLineMake(CGPointMake(rect1.origin.x + rect1.size.width, rect1.origin.y), CGPointMake(rect1.origin.x + rect1.size.width, rect1.origin.y - rect1.size.height));
    CGPoint rect1_center = CGPointMake(rect1.origin.x + (rect1.size.width / 2), rect1.origin.y + (rect1.size.height / 2));

    
    for (Block* block in self.level.blocks){
        /* Attempt 101:
        // if new position will collide
        // Rectangle 1′s bottom edge is higher than Rectangle 2′s top edge.
        // Rectangle 1′s top edge is lower than Rectangle 2′s bottom edge.
        // Rectangle 1′s left edge is to the right of Rectangle 2′s right edge.
        // Rectangle 1′s right edge is to the left of Rectangle 2′s left edge.
        // if the else if happened, that means we were clear on y, but x intersected
        bool y_did_intersect = false;
        CGRect rect2 = block.blockSprite.enclosingRect;
        if (rect1.origin.y - rect1.size.height > rect2.origin.y ||
            rect1.origin.y < rect2.origin.y - rect2.size.height) {
            // no y intersection
        } else if (!(y_did_intersect = true) || // makes sense
                   rect1.origin.x > rect2.origin.x + rect2.size.width ||
                   rect1.origin.x + rect1.size.width < rect2.origin.x ){
            // no x intersection
        } else {
            
            if (!y_did_intersect){
                intersect_x = true;
                new_x = self.position.x;
            } else {
                intersect_y = true;
                new_y = self.position.y;
            }
            
            break;
        }
        
        // also need to make sure the force in gravity didn't cause jumping through a block thus avoiding prior collision detection
        // however, I can just make the rect1 from the previous collision detection enclose the starting point aka self.position
        */
        
        // New attempt
        CGRect intersectionRect = CGRectIntersection(rect1, block.blockSprite.enclosingRect);
        if (!CGRectIsNull(intersectionRect)){
            CGPoint rect2_center = CGPointMake(block.blockSprite.enclosingRect.origin.x + (block.blockSprite.enclosingRect.size.width / 2), block.blockSprite.enclosingRect.origin.y + (block.blockSprite.enclosingRect.size.height / 2));
            CGLine center_to_center = CGLineMake(rect1_center, rect2_center);
            CGPoint intersectionPoint = CGLineIntersection(center_to_center, rect1_top);
            if (!CGPointIsNull(intersectionPoint)){
                // top intersection
                // if (atan2(self.character.direction) > 0)
                //     intersection happened from top to bottom
                // else it happened from bottom to top
                intersect_y = true;
                new_y = self.position.y;
            } else if (!CGPointIsNull(intersectionPoint = CGLineIntersection(center_to_center, rect1_bottom))){
                // bottom intersection
                intersect_y = true;
                new_y = self.position.y;
            } else if (!CGPointIsNull(intersectionPoint = CGLineIntersection(center_to_center, rect1_left))){
                // left intersection
                intersect_x = true;
                new_x = self.position.x;
            } else if (!CGPointIsNull(intersectionPoint = CGLineIntersection(center_to_center, rect1_right))){
                // right intersection
                intersect_x = true;
                new_x = self.position.x;
            }
        }
    }
    
    if (intersect_y){
        self.isJumping = false;
    }
    
    if (!intersect_x && !intersect_y) {
        self.lastPosition = self.position;
    }
    self.level.horizontalOffset -= new_x - self.position.x;
    self.position = CGPointMake(new_x, new_y);
    
}

-(void) draw:(long)ms withHorizontalOffset:(float)horizontalOffset {
    [self.characterImage renderWithSize:1.0 atX:self.position.x andXOffset:horizontalOffset andY:self.position.y andYOffset:0];

}

@end
