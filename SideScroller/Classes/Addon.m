//
//  Addon.m
//  SideScroller
//
//  Created by Jay Desai on 4/7/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import "Addon.h"

@interface Addon()

@end

@implementation Addon

@synthesize type = _type;
@synthesize position = _position;
@synthesize addonSprite = _addonSprite;

- (id) initAddonOfType:(NSString *)type andPositionX:(int)x andPositionY:(int)y {
    
    _ADDON_TYPE addonType = ADDON_NOTHING;
    if ([type isEqualToString:@"STAR"]){
        addonType = ADDON_STAR;
    } else if ([type isEqualToString:@"ADDON_COLLIDING_STRAIGHT_GUN"]){
        addonType = ADDON_COLLIDING_STRAIGHT_GUN;
    } else if ([type isEqualToString:@"ADDON_NONCOLLIDING_STRAIGHT_GUN"]){
        addonType = ADDON_NONCOLLIDING_STRAIGHT_GUN;
    } else if ([type isEqualToString:@"ADDON_COLLIDING_LINEAR_GUN"]){
        addonType = ADDON_COLLIDING_LINEAR_GUN;
    } else if ([type isEqualToString:@"ADDON_COLLIDING_QUADRATIC_GUN"]){
        addonType = ADDON_COLLIDING_QUADRATIC_GUN;
    } else if ([type isEqualToString:@"ADDON_NONCOLLIDING_LINEAR_GUN"]){
        addonType = ADDON_NONCOLLIDING_LINEAR_GUN;
    } else if ([type isEqualToString:@"ADDON_NONCOLLIDING_QUADRATIC_GUN"]){
        addonType = ADDON_NONCOLLIDING_QUADRATIC_GUN;
    } else if ([type isEqualToString:@"ADDON_RED_KEY"]){
        addonType = ADDON_RED_KEY;
    } else if ([type isEqualToString:@"ADDON_BLUE_KEY"]){
        addonType = ADDON_BLUE_KEY;
    } else if ([type isEqualToString:@"ADDON_GREEN_KEY"]){
        addonType = ADDON_GREEN_KEY;
    } else if ([type isEqualToString:@"ADDON_JETPACK"]){
        addonType = ADDON_JETPACK;
    } else if ([type isEqualToString:@"ADDON_JUMPING_SHOES"]){
        addonType = ADDON_JUMPING_SHOES;
    }
    
    return [self initAddon:addonType andPositionX:x andPositionY:y];
}

-(id) initAddon:(_ADDON_TYPE)type andPositionX:(int)x andPositionY:(int)y {
    
    if ([self init]){
        
        self.type = type;
        
        if (type == ADDON_STAR){
            self.addonSprite = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"addon_star.png"]];
        } else if (type == ADDON_COLLIDING_STRAIGHT_GUN){
            self.addonSprite = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"addon_linear_gun.png"]];
        } else if (type == ADDON_NONCOLLIDING_STRAIGHT_GUN){
            self.addonSprite = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"addon_linear_gun.png"]];
        } else if (type == ADDON_COLLIDING_LINEAR_GUN){
            self.addonSprite = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"addon_linear_gun.png"]];
        } else if (type == ADDON_COLLIDING_QUADRATIC_GUN){
            self.addonSprite = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"addon_quadratic_gun.png"]];
        } else if (type == ADDON_NONCOLLIDING_LINEAR_GUN){
            self.addonSprite = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"addon_linear_gun.png"]];
        } else if (type == ADDON_NONCOLLIDING_QUADRATIC_GUN){
            self.addonSprite = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"addon_quadratic_gun.png"]];
        } else if (type == ADDON_RED_KEY){
            self.addonSprite = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"addon_red_key.png"]];
        } else if (type == ADDON_BLUE_KEY){
            self.addonSprite = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"addon_blue_key.png"]];
        } else if (type == ADDON_GREEN_KEY){
            self.addonSprite = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"addon_blue_key.png"]];
        } else if (type == ADDON_JETPACK){
            self.addonSprite = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"addon_jetpack.png"]];
        } else if (type == ADDON_JUMPING_SHOES){
            self.addonSprite = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"addon_jumping_shoes.png"]];
        }
        
        self.position = CGPointMake(x, y);
        
        return self;
    }
    
    return nil;
}

- (void) execute {
    // I'll come up with a use for this function
}

- (void) draw:(long)ms withHorizontalOffset:(float)horizontalOffset {
    
    if (self.type == ADDON_NOTHING) return;
    
    [self.addonSprite renderWithSize:self.addonSprite.enclosingRect.size atX:self.position.x andXOffset:horizontalOffset andY:self.position.y andYOffset:0];
}

@end
