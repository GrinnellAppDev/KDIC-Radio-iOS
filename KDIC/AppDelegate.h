//
//  AppDelegate.h
//  KDIC
//
//  Created by Colin Tremblay on 11/2/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MPMoviePlayerController *streamMPMoviePlayer;
@property (nonatomic, strong) NSString *artistText;
@property (nonatomic, strong) NSString *songText;
@property (nonatomic, strong) UIImage *showImage;


@end
