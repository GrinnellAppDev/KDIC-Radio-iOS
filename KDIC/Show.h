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
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) int start;
@property (nonatomic, assign) int end;


@end
