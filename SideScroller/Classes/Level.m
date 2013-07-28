//
//  Level.m
//  SideScroller
//
//  Created by Jay Desai on 4/3/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import "Game.h"
#import "Level.h"
#import "Sprite.h"
#import "FontLibrary.h"
#import "Addon.h"
#import "Bullet.h"

#define MESSAGE_VIEW_TIME 90
#define PHONE_SIZE CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)

@interface Level()

@property TBXMLElement* config;
@property Game* game;
@property Sprite* levelBg;

@property Sprite* finishMessageBg;
@property CGRect messageRect;
@property int messageCounter;

@end


@implementation Level

@synthesize game = _game;
@synthesize config = _config;

@synthesize levelState =_levelState;

@synthesize levelBg = _levelBg;
@synthesize finishMessageBg = _finishMessageBg;
@synthesize messageRect = _messageRect;
@synthesize messageCounter = _messageCounter;

@synthesize blocks = _blocks;
@synthesize theman = _theman;
@synthesize characters = _characters;
@synthesize addons = _addons;

@synthesize horizontalOffset = _horizontalOffset;

@synthesize gravityPosition = _gravityPosition;

-(id) initWithConfig:(TBXMLElement *)config forGame:(Game *)game {
    if ([self init]){
        self.config = config;
        self.game = game;
        
        self.horizontalOffset = 0;
        
        self.gravityPosition = GRAVITY_BOTTOM;
        
        self.finishMessageBg = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"game_message.png"]];
        self.messageRect = CGRectMake(-1, -1, 1, 1); // off screen so touches aren't invoked
        self.messageCounter = 0;
        
        self.levelState = LEVEL_PLAYING;
        
        return self;
    }
    
    return nil;
}

- (void)load {

    TBXMLElement *playbgImageNameElement = [TBXML childElementNamed:@"playbg" parentElement:self.config];
    if (playbgImageNameElement != nil && [UIImage imageNamed:[TBXML textForElement:playbgImageNameElement]]){
        self.levelBg = [[Sprite alloc] initWithImage:[UIImage imageNamed:[TBXML textForElement:playbgImageNameElement]]];
    } else {
        self.levelBg = [[Sprite alloc] initWithImage:[UIImage imageNamed:@"repeating_bg.png"]];
    }
    
    
    TBXMLElement *blockElement = [TBXML childElementNamed:@"blocks" parentElement:self.config];
    blockElement = blockElement->firstChild;
        
    int positionX, positionY;
        
    self.blocks = [[NSMutableArray alloc] init];
    do {
        NSString *blockType = [TBXML textForElement:[TBXML childElementNamed:@"type" parentElement:blockElement]];
        positionX = [[TBXML textForElement:[TBXML childElementNamed:@"positionx" parentElement:blockElement]] intValue];
        positionY = [[TBXML textForElement:[TBXML childElementNamed:@"positiony" parentElement:blockElement]] intValue];
            
        Block *block = [[Block alloc] initBlockOfType:blockType andPositionX:positionX andPositionY:positionY withinLevel:self];
        [self.blocks addObject:block];
            
    } while ((blockElement = blockElement->nextSibling));
        
    TBXMLElement *protagonistElement = [TBXML childElementNamed:@"protagonist" parentElement:self.config];
    positionX = [[TBXML textForElement:[TBXML childElementNamed:@"positionx" parentElement:protagonistElement]] intValue];
    
    self.horizontalOffset = PHONE_SIZE.width / 2 - positionX;
    positionY = [[TBXML textForElement:[TBXML childElementNamed:@"positiony" parentElement:protagonistElement]] intValue];
        
    self.theman = [[Character alloc] initProtagonistWithPositionX:positionX andPositionY:positionY andImage:[UIImage imageNamed:@"character_main.png"] andLevel:self];
        
    TBXMLElement *charactersElement = [TBXML childElementNamed:@"enemies" parentElement:self.config];
    TBXMLElement *characterElement = charactersElement->firstChild;
        
    self.characters = [[NSMutableArray alloc] init];
    do {
        positionX = [[TBXML textForElement:[TBXML childElementNamed:@"positionx" parentElement:characterElement]] intValue];
        positionY = [[TBXML textForElement:[TBXML childElementNamed:@"positiony" parentElement:characterElement]] intValue];
        NSString* autoMoving = [TBXML textForElement:[TBXML childElementNamed:@"type" parentElement:characterElement]];

        Character *character = [[Character alloc] initCharacterWithPositionX:positionX andPositionY:positionY andImage:[UIImage imageNamed:@"enemy_1.png"] andLevel:self];
        if ([autoMoving isEqualToString:@"PURSUE_CHARACTER"]){
            character.autoMovement = PURSUE_CHARACTER;
        } else if ([autoMoving isEqualToString:@"STRAIGHT_MOVEMENT"]){
            character.autoMovement = STRAIGHT_MOVEMENT;
        } else {
            character.autoMovement = NO_MOVEMENT;
        }
        
        TBXMLElement *characterAddonElement = [TBXML childElementNamed:@"addon" parentElement:characterElement];
        if (characterAddonElement != nil){
            NSString* addonType = [TBXML textForElement:characterAddonElement];
            Addon* addon = [[Addon alloc] initAddonOfType:addonType andPositionX:positionX andPositionY:positionY];
            [character.addons setObject:addon forKey:[NSNumber numberWithInt: addon.type]];
        }
        
        
        [self.characters addObject:character];
        
    } while ((characterElement = characterElement->nextSibling));
    
    TBXMLElement *addonsElement = [TBXML childElementNamed:@"addons" parentElement:self.config];
    TBXMLElement *addonElement = addonsElement->firstChild;
    
    self.addons = [[NSMutableArray alloc] init];
    do {
        NSString *addonType = [TBXML textForElement:[TBXML childElementNamed:@"type" parentElement:addonElement]];
        positionX = [[TBXML textForElement:[TBXML childElementNamed:@"positionx" parentElement:addonElement]] intValue];
        positionY = [[TBXML textForElement:[TBXML childElementNamed:@"positiony" parentElement:addonElement]] intValue];
        Addon *addon = [[Addon alloc] initAddonOfType:addonType andPositionX:positionX andPositionY:positionY];
        
        [self.addons addObject:addon];
    } while ((addonElement = addonElement->nextSibling));
    // need to write code to parse addon information from xml

}

-(void)unload {
    
    self.horizontalOffset = 0;
    self.messageCounter = 0;
    self.messageRect = CGRectMake(-1, -1, 1, 1); // off screen so touches aren't invoked
    self.game.GAME_STATE = MENU;
    self.levelState = LEVEL_PLAYING;
    
    [self.blocks removeAllObjects];
    self.blocks = nil;
    self.theman = nil;
    [self.characters removeAllObjects];
    self.characters = nil;
    [self.addons removeAllObjects];
    self.addons = nil;
}

-(void)doAPressed{
    [self.theman initiateJumpWithForce:1.0];
}

-(void)doBPressedWithJoystickDirection:(float)direction{
    [self.theman doBActionWithJoystickDirection:direction];
}

-(void)update:(long)ms withJoystickSpeed:(float)speed andDirection:(float)direction {
    // big function
    // check collision and update blocks and characters accordingly
    // direction = abs(direction) > M_PI_2 ? M_PI : 0;
    [self.theman update:ms withJoystickSpeed:speed andDirection:direction];
    
    // draw enemies and friends
    for (Character* character in self.characters){
        [character updateAI:ms againstCharacter:self.theman];
    }
    
    // draw addons
    for (Addon* addon in self.addons){
        // addons don't ever actually get updated
        // unless there is an addon which...?
        // [addon update:ms];
    }

}

-(void)draw:(long)ms {
    
    [self.levelBg renderWithSize:self.levelBg.size atX:0 andY:0];
    
    // draw blocks
    for (Block* block in self.blocks){
        [block draw:ms withHorizontalOffset:self.horizontalOffset];
    }
    
    // draw enemies and friends
    for (Character* character in self.characters){
        [character draw:ms withHorizontalOffset:self.horizontalOffset];
    }

    // draw main character
    [self.theman draw:ms withHorizontalOffset:self.horizontalOffset];
    
    // draw addons
    for (Addon* addon in self.addons){
        [addon draw:ms withHorizontalOffset:self.horizontalOffset];
    }
    
    if (self.levelState == LEVEL_COMPLETE){
        // draw the level finished dialog in the center
        float posx = PHONE_SIZE.width / 2 - self.finishMessageBg.enclosingRect.size.width / 2;
        float posy = PHONE_SIZE.height / 2 - self.finishMessageBg.enclosingRect.size.height / 2;
        [self.finishMessageBg renderWithSize:self.finishMessageBg.size atX:posx andY:posy];
        
        self.messageRect = [[FontLibrary seguoWhite] renderString:@"You Win" ofSize:36 centeredAtX:PHONE_SIZE.width / 2 andY:PHONE_SIZE.height / 2.0];
        
        if (self.messageCounter++ > MESSAGE_VIEW_TIME){
            
            [self unload];
        }
        
    } else if (self.levelState == LEVEL_LOST){
        // draw the level finished dialog in the center
        float posx = PHONE_SIZE.width / 2 - self.finishMessageBg.enclosingRect.size.width / 2;
        float posy = PHONE_SIZE.height / 2 - self.finishMessageBg.enclosingRect.size.height / 2;
        [self.finishMessageBg renderWithSize:self.finishMessageBg.size atX:posx andY:posy];
        
        self.messageRect = [[FontLibrary seguoWhite] renderString:@"You Lose" ofSize:36 centeredAtX:PHONE_SIZE.width / 2 andY:PHONE_SIZE.height / 2.0];
        
        if (self.messageCounter++ > MESSAGE_VIEW_TIME){
            
            [self unload];
        }
        
    } else if (self.levelState == LEVEL_PAUSED){
        // handled by Controls
    }
}

@end
