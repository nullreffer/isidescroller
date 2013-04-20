//
//  MathUtil.h
//  SideScroller
//
//  Created by Jay Desai on 4/14/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MathUtil : NSObject

+ (float) calculateDistance:(CGPoint)a :(CGPoint)b;

+ (float) calculateVerticalDistance:(CGPoint)a :(CGPoint)b ;

+ (float) calculateHorizontalDistance:(CGPoint)a :(CGPoint)b ;

@end
