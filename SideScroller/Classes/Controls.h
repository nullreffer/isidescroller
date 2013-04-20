//
//  Controls.h
//  SideScroller
//
//  Created by Jay Desai on 4/13/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Controls : NSObject

- (id) initControlsForView:(UIView*)game;

- (float) getJoystickDirection;

- (float) getJoystickForce;

- (bool) isAPressed;

- (bool) isBPressed;

- (void) draw:(long)ms;

- (void) handleTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;

- (void) handleTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;

- (void) handleTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;

- (void) handleTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event;

@end
