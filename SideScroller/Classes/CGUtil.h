//
//  CGUtil.h
//  SideScroller
//
//  Created by Jay Desai on 4/20/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct
{
	CGPoint point1;
	CGPoint point2;
} CGLine;

CG_INLINE CGLine
CGLineMake(CGPoint p1, CGPoint p2){
    CGLine c;
    c.point1 = p1;
    c.point2 = p2;
    return c;
}

CG_INLINE CGPoint
CGLineIntersection(CGLine line1, CGLine line2){
    float line1_A = line1.point2.y-line1.point1.y;
    float line1_B = line1.point1.x-line1.point2.x;
    float line1_C = line1_A * line1.point1.x + line1_B * line1.point1.y;
    
    float line2_A = line2.point2.y-line2.point1.y;
    float line2_B = line2.point1.x-line2.point2.x;
    float line2_C = line2_A * line2.point1.x + line2_B * line2.point1.y;
    
    double det = line1_A * line2_B - line2_A * line1_B;
    if(det == 0){
        return CGPointMake(FLT_MAX, FLT_MAX);
    }
    
    float x = (line2_B * line1_C - line1_B * line2_C)/det;
    float y = (line1_A * line2_C - line2_A * line1_C)/det;
    return CGPointMake(x, y);
}

CG_INLINE bool
CGPointIsNull(CGPoint c){
    if (CGPointEqualToPoint(c, CGPointMake(FLT_MAX, FLT_MAX))){
        return YES;
    }
    return NO;
}

@interface CGUtil : NSObject


@end
