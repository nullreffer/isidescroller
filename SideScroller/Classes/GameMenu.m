//
//  GameMenu.m
//  SideScroller
//
//  Created by Jay Desai on 4/13/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import "GameMenu.h"
#import "Sprite.h"
#import "FontLibrary.h"
#import "MathUtil.h"

@interface GameMenu()

@property Game* game;
@property _MENU_STATE_ENUM MENU_STATE;

@property(nonatomic, retain) Sprite* mainMenuSprite;
@property(nonatomic, retain) Sprite* levelSelectSprite;

@property CGPoint initialTouchLocation;
@property CGPoint lastTouchMovedLocation;
@property const int SLIDE_THRESHOLD;
@property bool currentlyMoving;
@property int horizontalOffset;

@property CGRect playTextRect;

@property UITextField *codeInput;

@end

@implementation GameMenu

@synthesize MENU_STATE = _MENU_STATE;
@synthesize mainMenuSprite = _mainMenuSprite;
@synthesize levelSelectSprite = _levelSelectSprite;

@synthesize initialTouchLocation = _initialTouchLocation;
@synthesize lastTouchMovedLocation = _lastTouchMovedLocation;
@synthesize SLIDE_THRESHOLD = _SLIDE_THRESHOLD;
@synthesize currentlyMoving = _currentlyMoving;
@synthesize horizontalOffset = _horizontalOffset;

@synthesize playTextRect = _playTextRect;

@synthesize codeInput = _codeInput;

- (id)initMenuForGame:(Game*)game {
    
    if ([self init]){
        self.mainMenuSprite = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"menu_main.png"]];

        self.levelSelectSprite = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"menu_select_level.png"]];
        
        self.game = game;
        
        self.MENU_STATE = MENU_MAIN;
        
        self.SLIDE_THRESHOLD = 5; // in pixels
        self.currentlyMoving = false;
        self.horizontalOffset = 0;
        
        self.initialTouchLocation = CGPointMake(-1, -1);
        self.lastTouchMovedLocation = CGPointMake(-1, -1);
        
        self.codeInput = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
        self.codeInput.textColor = [UIColor whiteColor];
        
        return self;
    }
    
    return nil;
}

- (void)draw:(long)ms {
    
    if (self.MENU_STATE == MENU_MAIN){
        [self.mainMenuSprite renderWithSize:self.mainMenuSprite.size atX:0 andY:0];
        
        self.playTextRect = [[FontLibrary skiaWhite] renderString:@"play play" ofSize:40 atX:40 andY:200];
        
        [self.codeInput becomeFirstResponder];
        [self.game.view addSubview:self.codeInput];
        
    } else if (self.MENU_STATE == MENU_SELECT_LEVEL){
        [self.mainMenuSprite renderWithSize:self.mainMenuSprite.size atX:0 andY:0];
        
        if (!self.currentlyMoving){
            if (self.horizontalOffset > 0 ) self.horizontalOffset -= self.horizontalOffset/8;
            else if (self.horizontalOffset < 0) self.horizontalOffset -= self.horizontalOffset/8;
        }
        
        int levelCount = [self.game.levels count];
        
        int cc = 1;
        
        for (int row = 0; row <= levelCount / 5; row++){
            for (int col = 0; col < 5; col++){
                if (col + row * 5 >= levelCount) break;
                
                int posx = 40 + col * (60 + 25) + self.horizontalOffset;
                int posy = 320 - 40 - row * (60 + 25) - 60; // the minus 60 is because it draw upwards
                
                [self.levelSelectSprite renderWithSize:self.levelSelectSprite.size atX:posx andY:posy];
                
                [[FontLibrary skiaWhite] renderString:[NSString stringWithFormat:@"%d",cc++] ofSize:48 atX:posx+6 andY:posy+6];
            }
        }
        
    } else if (self.MENU_STATE == MENU_SCORES) {
        NSLog(@"You're on the sscores screen");
    } else if (self.MENU_STATE == MENU_SETTINGS) {
        NSLog(@"You're on the settings screen");
    } else if (self.MENU_STATE == MENU_ABOUT){
        NSLog(@"You're on the about screen");
    }
}

- (void) handleTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    UITouch* touch = [touches anyObject];
    
    self.initialTouchLocation = [touch locationInView:self.game.view];
    self.initialTouchLocation = CGPointMake(self.initialTouchLocation.x, 320 - self.initialTouchLocation.y);
    self.lastTouchMovedLocation = [touch locationInView:self.game.view];
    self.lastTouchMovedLocation = CGPointMake(self.lastTouchMovedLocation.x, 320 - self.lastTouchMovedLocation.y);
    self.currentlyMoving = true;
}

- (void) handleTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    
    if (self.MENU_STATE == MENU_MAIN) {
        if (CGRectContainsPoint(self.playTextRect, self.initialTouchLocation)){
            self.horizontalOffset = 0;
            self.currentlyMoving = false;
            self.MENU_STATE = MENU_SELECT_LEVEL;
            
            // hide keyboard
            [self.codeInput removeFromSuperview];
        } else {
            // Todo: other buttons on main_menu
        }
    } else if (self.MENU_STATE == MENU_SELECT_LEVEL) {
        self.currentlyMoving = false;
        
        if (fabs([MathUtil calculateHorizontalDistance:self.initialTouchLocation :self.lastTouchMovedLocation]) < self.SLIDE_THRESHOLD) {
            // tapped
            int tappedCol = (self.lastTouchMovedLocation.x - 40 - self.horizontalOffset) / (60 + 25);
            int tappedRow = ((320 - self.lastTouchMovedLocation.y) - 40) / (60 + 25);
            
            int tappedLevel = tappedCol + 1 + (tappedRow * 5);
            self.game.currentLevel = [self.game.levels objectForKey:[NSString stringWithFormat:@"%d",tappedLevel]];
            if (self.game.currentLevel == nil){
                return;
            }
            [self.game.currentLevel load];
            
            self.game.GAME_STATE = PLAYING;
            self.MENU_STATE = MENU_MAIN;
            
            // hide keyboard
            [self.codeInput removeFromSuperview];

        } else {
            // depending on distance change screen
        }
        
    } else if (self.MENU_STATE == MENU_SCORES) {
        // Todo
    } else if (self.MENU_STATE == MENU_SETTINGS) {
        // Todo
    } else if (self.MENU_STATE == MENU_ABOUT) {
        // Todo
    }
    
    self.initialTouchLocation = CGPointMake(-1, -1);
    self.lastTouchMovedLocation = CGPointMake(-1, -1);
}

- (void) handleTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    if (CGPointEqualToPoint(self.initialTouchLocation, CGPointMake(-1, -1))){
        return;
    }
    
    UITouch* touch = [touches anyObject];
    if (self.MENU_STATE == MENU_SELECT_LEVEL){
        // slide implementation
        self.currentlyMoving = true;
        self.lastTouchMovedLocation = [touch locationInView:self.game.view];
        float horizontalDistance = [MathUtil calculateHorizontalDistance:self.initialTouchLocation :self.lastTouchMovedLocation];
        
        if (fabs(horizontalDistance) > self.SLIDE_THRESHOLD) {
            self.horizontalOffset = horizontalDistance;
        }
    }
}

- (void) handleTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
    [self handleTouchesEnded:touches withEvent:event];
}

@end
