//
//  Podcast.h
//  KDIC
//
//  Created by Colin Tremblay on 11/17/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Podcast : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *streamURL;
@property (nonatomic, strong) NSString *pageURL;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *show;

@end
