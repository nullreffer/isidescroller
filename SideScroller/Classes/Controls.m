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

#define JOYSTICK_THRESHOLD 0.4
#define PHONE_SIZE CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)

@interface Controls()

@property Game* game;
@property UIView* view;

@property Sprite* joystickBg;
@property Sprite* joystick;
@property Sprite* buttonA;
@property Sprite* buttonB;
@property Sprite* buttonPause;
@property Sprite* pausedMessage;

// used to track Joystick
@property UITouch* joystickTouch;
@property bool joystickPressed;
@property CGPoint joystickInitialLocation;
@property CGPoint joystickMovedLocation;

@property bool aPressed;
@property bool bPressed;

@end

@implementation Controls

@synthesize game = _game;
@synthesize view = _view;

@synthesize joystickBg = _joystickBg;
@synthesize joystick = _joystick;
@synthesize buttonA = _buttonA;
@synthesize buttonB = _buttonB;
@synthesize buttonPause = _buttonPause;
@synthesize pausedMessage = _pausedMessage;

@synthesize joystickTouch = _joystickTouch;
@synthesize joystickPressed = _joystickPressed;
@synthesize joystickInitialLocation = _joystickInitialLocation;
@synthesize joystickMovedLocation = _joystickMovedLocation;
@synthesize aPressed = _aPressed;
@synthesize bPressed = _bPressed;

-(id)initControlsForView:(UIView*)view inGame:(Game*)game {
    
    if ([self init]){
        
        self.joystickBg = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"controls_joystick_bg.png"]];
        self.joystick = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"controls_joystick.png"]];
        
        self.buttonA = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"controls_buttons_A.png"]];
        self.buttonB = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"controls_buttons_B.png"]];
        self.buttonPause = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"controls_buttons_pause.png"]];
        self.pausedMessage = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"game_paused.png"]];
        
        self.game = game;
        self.view = view;
        
        self.aPressed = false;
        self.bPressed = false;
        
        self.joystickTouch = nil;
        self.joystickPressed = false;
        self.joystickInitialLocation = CGPointMake(90, 90);
        self.joystickMovedLocation = CGPointMake(90, 90);
        
        return self;
    }
    
    return nil;
    
}

- (void) draw:(long)ms {
    [self.joystickBg renderWithSize:self.joystickBg.size atX:30 andY:30];
    [self.joystick renderWithSize:self.joystick.size atX:self.joystickMovedLocation.x-30 andY:self.joystickMovedLocation.y-30];
    
    [self.buttonA renderWithSize:self.buttonA.size atX:PHONE_SIZE.width - 180 andY:30];
    [self.buttonB renderWithSize:self.buttonB.size atX:PHONE_SIZE.width - 100 andY:30];
    
    if (self.game.currentLevel.levelState == LEVEL_PAUSED) {
        // draw the level paused dialog in the center
        float posx = PHONE_SIZE.width / 2 - self.pausedMessage.enclosingRect.size.width / 2;
        float posy = PHONE_SIZE.height / 2 - self.pausedMessage.enclosingRect.size.height / 2;
        [self.pausedMessage renderWithSize:self.pausedMessage.size atX:posx andY:posy];
    } else if (self.game.currentLevel.levelState == LEVEL_PLAYING) {
        [self.buttonPause renderWithSize:self.buttonPause.size atX:10 andY:250];
    }
}

- (float) getJoystickDirection {
    // i remembered geometry! 100 because 70, 70 = bottom_left, with a radius of 30
    // NSLog(@"(%f,%f)\n",self.joystickMovedLocation.y-100,self.joystickMovedLocation.x-100);
    
    return atan2f( (self.joystickMovedLocation.y - 100) , (self.joystickMovedLocation.x - 100) );
}

- (float) getJoystickForce {
    // keeping it between 0 and 1, so it can be used with a speed scalar
    float dist = [MathUtil calculateDistance:self.joystickInitialLocation :self.joystickMovedLocation] / 30;
    return dist > JOYSTICK_THRESHOLD ? dist : 0;
}

- (bool) isAPressed {
    return self.aPressed;
}

- (bool) isBPressed {
    return self.bPressed;
}

- (void) handleTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    
    if (self.game.currentLevel.levelState == LEVEL_PAUSED){
        
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self.view];
        if (CGRectContainsPoint(self.pausedMessage.enclosingRect, touchPoint)){
            if (touchPoint.y > self.pausedMessage.enclosingRect.origin.y + self.pausedMessage.enclosingRect.size.height / 2) {
                if (touchPoint.x < self.pausedMessage.enclosingRect.origin.x + self.pausedMessage.enclosingRect.size.width / 2) {
                    // resume tapped
                    self.game.currentLevel.levelState = LEVEL_PLAYING;
                } else {
                    // quit tapped
                    self.game.currentLevel.levelState = LEVEL_LOST;
                }
            }
        }
        
        return;
    }
    
    for (UITouch* touch in touches){
        CGPoint touchPosition = [touch locationInView:self.view];
        touchPosition = CGPointMake(touchPosition.x, PHONE_SIZE.height - touchPosition.y);
        if (CGRectContainsPoint([self.joystick enclosingRect], touchPosition)){
            self.joystickTouch = touch;
            self.joystickPressed = true;
        } else if (CGRectContainsPoint([self.buttonA enclosingRect], touchPosition)){
            self.aPressed = true;
        } else if (CGRectContainsPoint([self.buttonB enclosingRect], touchPosition)){
            self.bPressed = true;
        } else if (CGRectContainsPoint([self.buttonPause enclosingRect], touchPosition)){
            self.game.currentLevel.levelState = LEVEL_PAUSED;
        }
    }
}

- (void) handleTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    for (UITouch* touch in touches){
        CGPoint touchPosition = [touch locationInView:self.view];
        touchPosition = CGPointMake(touchPosition.x, PHONE_SIZE.height - touchPosition.y);
        if (touch == self.joystickTouch){
            self.joystickPressed = false;
            self.joystickMovedLocation = self.joystickInitialLocation;
        } else if (!CGRectContainsPoint([self.buttonB enclosingRect], touchPosition)){
            self.aPressed = false;
        } else if (!CGRectContainsPoint([self.buttonA enclosingRect], touchPosition)){
            self.bPressed = false;
        }
    }
}

- (void) handleTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    for (UITouch* touch in touches){
        CGPoint touchPosition = [touch locationInView:self.view];
        touchPosition = CGPointMake(touchPosition.x, PHONE_SIZE.height - touchPosition.y);
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
