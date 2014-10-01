//
//  KDICMusicManager.h
//  KDIC
//
//  Created by Tremblay on 9/30/14.
//  Copyright (c) 2014 Colin Tremblay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPMoviePlayerController, Show, Podcast;
@interface KDICMusicManager : NSObject

+ (KDICMusicManager *)sharedInstance;

@property (nonatomic, strong) MPMoviePlayerController *streamMPMoviePlayer;
@property (nonatomic, strong) NSString *artistText;
@property (nonatomic, strong) NSString *songText;
@property (nonatomic, strong) UIImage *showImage;
@property (nonatomic, strong) Podcast *podcast;
@property (nonatomic, strong) Show *currentShow;
@property (nonatomic, strong) Show *nextShow;

@end
