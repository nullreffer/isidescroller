//
//  MathUtil.m
//  SideScroller
//
//  Created by Jay Desai on 4/14/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import "MathUtil.h"

@implementation MathUtil

+ (float) calculateDistance:(CGPoint)a :(CGPoint)b {
    float xDist = (b.x - a.x);
    float yDist = (b.y - a.y);
    return sqrtf((xDist * xDist) + (yDist * yDist));
}

+ (float) calculateVerticalDistance:(CGPoint)a :(CGPoint)b {
    return (b.y - a.y);
}

+ (float) calculateHorizontalDistance:(CGPoint)a :(CGPoint)b {
    return (b.x - a.x);
}

@end
