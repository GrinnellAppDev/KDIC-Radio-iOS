//
//  Show.h
//  KDIC
//
//  Created by Colin Tremblay on 11/3/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Show : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *day;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger end;
@property (nonatomic, assign) BOOL isPodcast;

- (NSString *)formatTime;

@end
