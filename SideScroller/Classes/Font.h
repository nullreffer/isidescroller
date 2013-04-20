//
//  Font.h
//  SideScroller
//
//  Created by Jay Desai on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Font : NSObject {
    
}

- (id)initWithFontFile:(NSString *)fileName andFontImage:(NSString *)fontImage ;
- (CGRect)renderString:(NSString*)str ofSize:(int)sz atX:(int)x andY:(int)y;
@end
