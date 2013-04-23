//
//  Controls.m
//  SideScroller
//
//  Created by Jay Desai on 4/13/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import "Controls.h"
#import "Sprite.h"
#import "MathUtil.h"

@interface Controls()

@property UIView* view;

@property Sprite* joystickBg;
@property Sprite* joystick;
@property Sprite* buttonA;
@property Sprite* buttonB;

// used to track Joystick
@property UITouch* joystickTouch;
@property bool joystickPressed;
@property CGPoint joystickInitialLocation;
@property CGPoint joystickMovedLocation;

@property bool aPressed;
@property bool bPressed;

@end

@implementation Controls

@synthesize view = _view;

@synthesize joystickBg = _joystickBg;
@synthesize joystick = _joystick;
@synthesize buttonA = _buttonA;
@synthesize buttonB = _buttonB;

@synthesize joystickTouch = _joystickTouch;
@synthesize joystickPressed = _joystickPressed;
@synthesize joystickInitialLocation = _joystickInitialLocation;
@synthesize joystickMovedLocation = _joystickMovedLocation;
@synthesize aPressed = _aPressed;
@synthesize bPressed = _bPressed;

-(id)initControlsForView:(UIView*)view {
    
    if ([self init]){
        
        self.joystickBg = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"controls_joystick_bg.png"]];
        self.joystick = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"controls_joystick.png"]];
        
        self.buttonA = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"controls_buttons_A.png"]];
        self.buttonB = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"controls_buttons_B.png"]];
        
        self.view = view;
        
        self.aPressed = false;
        self.bPressed = false;
        
        self.joystickTouch = nil;
        self.joystickPressed = false;
        self.joystickInitialLocation = CGPointMake(100, 100);
        self.joystickMovedLocation = CGPointMake(100, 100);
        
        return self;
    }
    
    return nil;
    
}

- (void) draw:(long)ms {
    [self.joystickBg renderWithSize:1.0 atX:40 andY:40];
    [self.joystick renderWithSize:1.0 atX:self.joystickMovedLocation.x-30 andY:self.joystickMovedLocation.y-30];
    
    [self.buttonA renderWithSize:1.0 atX:320 andY:70];
    [self.buttonB renderWithSize:1.0 atX:400 andY:70];
}

- (float) getJoystickDirection {
    // i remembered geometry! 100 because 70, 70 = bottom_left, with a radius of 30
    // NSLog(@"(%f,%f)\n",self.joystickMovedLocation.y-100,self.joystickMovedLocation.x-100);
    
    return atan2f( (self.joystickMovedLocation.y - 100) , (self.joystickMovedLocation.x - 100) );
}

- (float) getJoystickForce {
    // keeping it between 0 and 1, so it can be used with a speed scalar
    return ([MathUtil calculateDistance:self.joystickInitialLocation :self.joystickMovedLocation] / 30);
}

- (bool) isAPressed {
    return self.aPressed;
}

- (bool) isBPressed {
    return self.bPressed;
}

- (void) handleTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    for (UITouch* touch in touches){
        CGPoint touchPosition = [touch locationInView:self.view];
        touchPosition = CGPointMake(touchPosition.x, 320 - touchPosition.y);
        if (CGRectContainsPoint(self.joystick.enclosingRect, touchPosition)){
            self.joystickTouch = touch;
            self.joystickPressed = true;
        } else if (CGRectContainsPoint(self.buttonA.enclosingRect, touchPosition)){
            self.aPressed = true;
        } else if (CGRectContainsPoint(self.buttonB.enclosingRect, touchPosition)){
            self.bPressed = true;
        }
    }
}

- (void) handleTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    for (UITouch* touch in touches){
        CGPoint touchPosition = [touch locationInView:self.view];
        touchPosition = CGPointMake(touchPosition.x, 320 - touchPosition.y);
        if (touch == self.joystickTouch){
            self.joystickPressed = false;
            self.joystickMovedLocation = self.joystickInitialLocation;
        } else if (!CGRectContainsPoint(self.buttonB.enclosingRect, touchPosition)){
            self.aPressed = false;
        } else if (!CGRectContainsPoint(self.buttonA.enclosingRect, touchPosition)){
            self.bPressed = false;
        }
    }
}

- (void) handleTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    for (UITouch* touch in touches){
        CGPoint touchPosition = [touch locationInView:self.view];
        touchPosition = CGPointMake(touchPosition.x, 320 - touchPosition.y);
        if (touch == self.joystickTouch){
            self.joystickMovedLocation = touchPosition;
            
            // but it shall not break r^2= (x-h)^2 + (y-k)^2
            // my r = 30, h = 130, k = 130
            // if the distance > radius, then its outside!
            if ([MathUtil calculateDistance:self.joystickInitialLocation :self.joystickMovedLocation] > 60){
                float direction = [self getJoystickDirection];
                // NSLog(@"Direction: %f ", direction);
                // sin(direction) = opp/hypo; where hypo = 30 = radius, opp = y
                // cos(direction) = adj/hypo; where hypo = 30 = radius, adj = x
                self.joystickMovedLocation = CGPointMake(100 + 60 * cosf(direction), 100 + 60 * sinf(direction));
            }
        }
    }
}

- (void) handleTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
    [self handleTouchesEnded:touches withEvent:event];
}

@end
