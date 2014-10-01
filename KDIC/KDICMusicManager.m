//
//  KDICMusicManager.m
//  KDIC
//
//  Created by Tremblay on 9/30/14.
//  Copyright (c) 2014 Colin Tremblay. All rights reserved.
//

#import "KDICMusicManager.h"

@implementation KDICMusicManager

__strong static KDICMusicManager *sharedInstance = nil;

+ (id)sharedInstance {
    static dispatch_once_t p = 0;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        sharedInstance = [[self alloc] init];
    });
    
    // returns the same object each time
    return sharedInstance;
}

@end
