//
//  ViewController.h
//  KDIC
//
//  Created by Colin Tremblay on 11/2/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) AVPlayer *streamer;
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, weak) IBOutlet UIButton *playpause;
@property (nonatomic, strong) MPMoviePlayerController *streamMPMoviePlayer;
@property (nonatomic, strong) NSString *metaString;
@property (nonatomic, weak) IBOutlet UISlider *slider;

- (IBAction)playPauseButtonTap:(id)sender;

@end
