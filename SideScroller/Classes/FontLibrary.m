//
//  FontLibrary.m
//  SideScroller
//
//  Created by Jay Desai on 4/26/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import "FontLibrary.h"

@implementation FontLibrary

+ (Font*)seguoWhite
{
    static dispatch_once_t pred = 0;
    __strong static id seguoWhite = nil;
    dispatch_once(&pred, ^{
        seguoWhite = [[Font alloc] initWithFontFile:@"seguo_normal.fnt" andFontImage:@"seguo_normal_0.png"];
    });
    return seguoWhite;
}

+ (Font*)skiaWhite
{
    static dispatch_once_t pred = 0;
    __strong static id skiaWhite = nil;
    dispatch_once(&pred, ^{
        skiaWhite = [[Font alloc] initWithFontFile:@"skia_normal.fnt" andFontImage:@"skia_normal_0.png"];
    });
    return skiaWhite;
}

+ (Font*)skiaWhiteBold
{
    static dispatch_once_t pred = 0;
    __strong static id skiaWhiteBold = nil;
    dispatch_once(&pred, ^{
        skiaWhiteBold = [[Font alloc] initWithFontFile:@"skia_bold.fnt" andFontImage:@"skia_bold_0.png"];
    });
    return skiaWhiteBold;
}


@end
