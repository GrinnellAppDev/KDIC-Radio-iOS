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

@synthesize playing, playpause, streamMPMoviePlayer, metaString, streamer, slider;

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(StreamMeta:) name:MPMoviePlayerTimedMetadataUpdatedNotification object:nil];
    slider.value = streamer.volume;
}

- (void)viewDidAppear:(BOOL)animated {
     NSURL *url = [NSURL URLWithString:@"http://kdic.grinnell.edu:8001/kdic128.m3u"];
    

    
    
    
     NSError *error = [NSError alloc];
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
             [playpause setImage:[UIImage imageNamed:@"pause.jpg"] forState:UIControlStateNormal];
             playing = YES;
         }
     }
    
    
    /*
    streamMPMoviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [streamMPMoviePlayer play];
    if (MPMoviePlaybackStatePlaying == streamMPMoviePlayer.playbackState) {
        NSLog(@"Playing");
    }
    else
        NSLog(@"Not Playing");
    NSLog(@"%ld", (long)[streamMPMoviePlayer playbackState]);*/
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
    if (playing) {
        [streamer pause];
        [streamMPMoviePlayer pause];
        [playpause setImage:[UIImage imageNamed:@"play.jpg"] forState:UIControlStateNormal];
        playing = NO;
    }
    else {
        [streamer play];
        [streamMPMoviePlayer play];
        [playpause setImage:[UIImage imageNamed:@"pause.jpg"] forState:UIControlStateNormal];
        playing = YES;
    }
}
- (IBAction)sliderValueChanged:(UISlider *)slide {
    streamer.volume = slide.value;
}
@end
