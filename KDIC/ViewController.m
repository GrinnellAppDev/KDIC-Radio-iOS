//
//  ViewController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/2/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize playing, playpause, streamMPMoviePlayer, metaString, streamer, volViewParent;

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    // Add the volume slider to the view in the xib
    MPVolumeView *myVolView = [[MPVolumeView alloc] initWithFrame:volViewParent.bounds];
    [volViewParent addSubview:myVolView];
    
    // Create callback for when metadata changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(StreamMeta:) name:MPMoviePlayerTimedMetadataUpdatedNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
     NSURL *url = [NSURL URLWithString:@"http://kdic.grinnell.edu:8001/kdic128.m3u"];
    

    
    // Create stream using AVPlayer
    /*     NSError *error = [NSError alloc];
     [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
     [[AVAudioSession sharedInstance] setActive: YES error:&error];
     streamer = [[AVPlayer alloc] initWithURL:url];
     if (streamer == nil)
         NSLog(@"%@", [error description]);
     else {
         [streamer play];
         if (0.0 == streamer.rate)
             NSLog(@"Not Playing");
         else {
             NSLog(@"Playing");
             [playpause setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
             playing = YES;
             slider.value = streamer.volume;
         }
     }*/
    
    
    // Create stream using MPMoviePlayerController
    streamMPMoviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    if (!streamMPMoviePlayer.isPreparedToPlay) {
        NSLog(@"Error... stream not prepared to play");
    }
    else {
        [streamMPMoviePlayer play];
        if (MPMoviePlaybackStatePlaying == streamMPMoviePlayer.playbackState) {
            [playpause setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
            NSLog(@"Playing");
        }
        else
            NSLog(@"Not Playing");
        NSLog(@"%ld", (long)[streamMPMoviePlayer playbackState]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)StreamMeta:(NSNotification *)notification {
    if ([streamMPMoviePlayer timedMetadata] != nil) {
        MPTimedMetadata *meta = [[streamMPMoviePlayer timedMetadata] firstObject];
        metaString = meta.value;
    }
    NSLog(@"%@", metaString);
}

- (IBAction)playPauseButtonTap:(id)sender {
   // if (playing) {
        //[streamer pause];
        //playing = NO;
    if (MPMoviePlaybackStatePlaying == streamMPMoviePlayer.playbackState) {
        [streamMPMoviePlayer pause];
        [playpause setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
    else {
        //[streamer play];
        //playing = YES;
        [streamMPMoviePlayer play];
        [playpause setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
}

@end
