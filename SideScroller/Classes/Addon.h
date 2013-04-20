//
//  Addon.h
//  SideScroller
//
//  Created by Jay Desai on 4/7/13.
//  Copyright (c) 2013 Jay Desai. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSString *ADDON_STAR = @"STAR";
static const NSString *ADDON_RED_KEY = @"RED_KEY";
static const NSString *ADDON_BLUE_KEY = @"BLUE_KEY";
static const NSString *ADDON_JETPACK = @"JETPACK";
static const NSString *ADDON_BUBBLE = @"BUBBLE";

@interface Addon : NSObject

-(id) initAddonOfType:(NSString*)type andPositionX:(int)x andPositionY:(int)y;

@end
