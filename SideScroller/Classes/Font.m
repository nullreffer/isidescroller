//
//  Font.m
//  SideScroller
//
//  Created by Jay Desai on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Font.h"
#import "Sprite.h"

@interface Font ()
@property (strong) NSMutableDictionary *alphalets;
@property (strong) Sprite* fontSprite;
@end

@implementation Font
@synthesize alphalets = _alphalets;
@synthesize fontSprite = _fontSprite;

- (id)initWithFontFile:(NSString *)fileName andFontImage:(NSString *)fontImage {
    
    if ([self init]) {
        self.alphalets = [[NSMutableDictionary alloc] initWithCapacity:255];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:fontImage ofType:nil];
        UIImage *fntImage = [[UIImage alloc] initWithContentsOfFile:path];
        self.fontSprite = [[Sprite alloc] initWithImage:fntImage andManualFlip:NO];
        // UIImage *fntImage = [UIImage imageNamed:fileName];
        
        NSString *allowedChars  = @"abcdefghijklmnopqrstuvwxyz_ABCDEFGHIJKLMNOPQRSTUVWXYZ-1234567890 !@#$%^&*()=+:'\".,?";
        
        path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        NSString *fntContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

        
        NSArray *fntLines = [fntContents componentsSeparatedByString:@"\n"];
        for(NSString *line in fntLines){
            NSArray *fntColumns = [line componentsSeparatedByString:@" "];
            NSString *lineType = [fntColumns objectAtIndex:0];
            if (![lineType isEqualToString:@"char"]) {
                // we only care about char types
                
                // TODO kernings later
                continue;
            }
            
            NSCharacterSet *space = [NSCharacterSet characterSetWithCharactersInString:@" "];
            NSCharacterSet *alset = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
            
            int char_id = [[[[fntColumns objectAtIndex:1] componentsSeparatedByCharactersInSet:alset ] componentsJoinedByString:@"" ] intValue];
            if ([allowedChars rangeOfString:[NSString stringWithFormat:@"%c",char_id]].location == NSNotFound) {
                continue;
            }
            
            int char_x = 0;
            int char_y = 0;
            int char_width = 0;
            int char_height = 0;
            
            for(NSString *colValue in fntColumns) {
                // great way to do str_replace isn't it?
                NSString *colVal = [[colValue componentsSeparatedByCharactersInSet:space] componentsJoinedByString:@""];
                NSArray *keyAndValue = [colVal componentsSeparatedByString:@"="];
                if ([[keyAndValue objectAtIndex:0] isEqualToString:@"x"]) {
                    char_x = [[keyAndValue objectAtIndex:1] intValue];
                } else if ([[keyAndValue objectAtIndex:0] isEqualToString:@"y"]) {
                    char_y = [[keyAndValue objectAtIndex:1] intValue];
                } else if ([[keyAndValue objectAtIndex:0] isEqualToString:@"width"]) {
                    char_width = [[keyAndValue objectAtIndex:1] intValue];
                } else if ([[keyAndValue objectAtIndex:0] isEqualToString:@"height"]) {
                    char_height = [[keyAndValue objectAtIndex:1] intValue];
                } 
            }
            
            // CGRect char_rect = CGRectMake(0, 0, 512, 512);
            CGRect char_rect = CGRectMake(char_x, char_y, char_width, char_height);
            // CGImageRef imageRef = CGImageCreateWithImageInRect(fntImage.CGImage, char_rect);
            // UIImage *image = [UIImage imageWithData:UIImagePNGRepresentation([UIImage imageWithCGImage:imageRef])];
            // CGImageRef char_ref = CGImageCreateWithImageInRect(image.CGImage, char_rect);
            
            
            // CGImageRef char_ref = fntImage.CGImage;
            // Sprite *char_sprite = [[Sprite alloc] initWithRect:char_ref croppedTo:char_rect andOriginalSz:CGSizeMake(512, 512) andManualFlip:NO];
            
            
            [self.alphalets setObject:[NSValue valueWithCGRect:char_rect] forKey:[NSString stringWithFormat:@"%c",char_id]];
        }
        
        return self;
    }
    
    return nil;
}

- (CGRect)renderString:(NSString*)str ofSize:(int)sz atX:(int)x andY:(int)y {
    // float sc = sz  / 512.0; // 72.0; // assuming sz = 72, a size of 72 = sc of 1, sz of 36 = sc = 0.5
    
    int width = 0;
    int origX = x;
    for (int i = 0; i < str.length; i++) {
        NSString *char_key = [[NSString alloc] initWithFormat:@"%c",[str characterAtIndex:i]];
        CGRect char_rect = [[self.alphalets valueForKey:char_key] CGRectValue];
        
        TexturedQuad quad = self.fontSprite.quad;
        quad.bl.textureVertex = CGPointMake(char_rect.origin.x / 512, (512 - char_rect.origin.y - char_rect.size.height) / 512);
        quad.br.textureVertex = CGPointMake( (char_rect.origin.x + char_rect.size.width) / 512, (512 - char_rect.origin.y - char_rect.size.height) / 512);
        quad.tl.textureVertex = CGPointMake(char_rect.origin.x / 512, (512 - char_rect.origin.y)/ 512);
        quad.tr.textureVertex = CGPointMake( (char_rect.origin.x + char_rect.size.width) / 512, (512 - char_rect.origin.y)/ 512);
        
        self.fontSprite.quad = quad;
        
        [self.fontSprite renderWithSize:char_rect.size atX:x andXOffset:0 andY:y andYOffset:0];
            
        // then update x
        x = x + char_rect.size.width;
        // x = x + (char_sprite.quad.tr.geometryVertex.x - char_sprite.quad.tl.geometryVertex.x);
        // width = x + char_sprite.enclosingRect.size.width;
    }
    
    width = x - origX;
    return CGRectMake(origX, y, width, sz);
}

@end
