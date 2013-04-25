//
//  Level.m
//  SideScroller
//
//  Created by Jay Desai on 4/3/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import "Level.h"
#import "Sprite.h"

@interface Level()

// -- Game specials

@property TBXMLElement* config;
@property Sprite* levelBg;

@end


@implementation Level

@synthesize levelBg = _levelBg;

@synthesize width = _width;
@synthesize height = _height;
@synthesize blocks = _blocks;
@synthesize theman = _theman;
@synthesize characters = _characters;

@synthesize config = _config;

@synthesize horizontalOffset = _horizontalOffset;

@synthesize gravityPosition = _gravityPosition;

-(id) initWithConfig:(TBXMLElement *)config {
    if ([self init]){
        self.config = config;
        
        self.horizontalOffset = 0;
        
        self.gravityPosition = GRAVITY_BOTTOM;        
        return self;
    }
    
    return nil;
}

- (void)load {
        
    NSString *levelWidth = [TBXML textForElement:[TBXML childElementNamed:@"width" parentElement:self.config]];
    self.width = [levelWidth intValue];
        
    NSString *levelHeight = [TBXML textForElement:[TBXML childElementNamed:@"height" parentElement:self.config]];
    self.height = [levelHeight intValue];
    
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
            
        Block *block = [[Block alloc] initBlockOfType:blockType andPositionX:positionX andPositionY:positionY];
        [self.blocks addObject:block];
            
    } while ((blockElement = blockElement->nextSibling));
        
    TBXMLElement *protagonistElement = [TBXML childElementNamed:@"protagonist" parentElement:self.config];
    positionX = [[TBXML textForElement:[TBXML childElementNamed:@"positionx" parentElement:protagonistElement]] intValue];
    positionY = [[TBXML textForElement:[TBXML childElementNamed:@"positiony" parentElement:protagonistElement]] intValue];
        
    self.theman = [[Character alloc] initCharacterWithPositionX:positionX andPositionY:positionY andImage:[UIImage imageNamed:@"character_main"] andLevel:self];
        
    TBXMLElement *charactersElement = [TBXML childElementNamed:@"characters" parentElement:self.config];
    TBXMLElement *characterElement = charactersElement->firstChild;
        
    self.characters = [[NSMutableArray alloc] init];
    do {
        positionX = [[TBXML textForElement:[TBXML childElementNamed:@"positionx" parentElement:characterElement]] intValue];
        positionY = [[TBXML textForElement:[TBXML childElementNamed:@"positiony" parentElement:characterElement]] intValue];
        Character *character = [[Character alloc] initCharacterWithPositionX:positionX andPositionY:positionY andImage:[UIImage imageNamed:@"enemy_1"] andLevel:self];
            
        [self.characters addObject:character];
    } while ((characterElement = characterElement->nextSibling));

}

-(void)unload {
    
    [self.blocks removeAllObjects];
    self.blocks = nil;
    self.theman = nil;
    [self.characters removeAllObjects];
    self.characters = nil;
}

-(void)doAPressed{
    [self.theman initiateJumpWithForce:1.0];
}

-(void)update:(long)ms withJoystickSpeed:(float)speed andDirection:(float)direction {
    // big function
    // check collision and update blocks and characters accordingly
    // direction = abs(direction) > M_PI_2 ? M_PI : 0;
    [self.theman update:ms withJoystickSpeed:speed andDirection:direction];
    
    // draw enemies and friends
    for (Character* character in self.characters){
        // [character update:ms];
    }
}

-(void)draw:(long)ms {
    
    [self.levelBg renderWithSize:self.levelBg.size atX:0 andY:0];
    
    // draw blocks
    for (Block* block in self.blocks){
        [block draw:ms withHorizontalOffset:(float)self.horizontalOffset];
    }
    
    // draw enemies and friends
    for (Character* character in self.characters){
        [character draw:ms withHorizontalOffset:(float)self.horizontalOffset];
    }

    // draw main character
    [self.theman draw:ms withHorizontalOffset:(float)self.horizontalOffset];
    
    // draw specials (teleportes, etc... stuff that goes in the foreground)
    
}

@end
