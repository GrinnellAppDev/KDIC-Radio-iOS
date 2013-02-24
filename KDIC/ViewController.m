//
//  ViewController.m
//  KDIC
//
//  Created by Lea Marolt on 10/24/12.
//  Copyright (c) 2012 Lea Marolt. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize playpause, streamer, playing;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Bad way to load the stream..
    NSString *urlstr = @"http://kdic.grinnell.edu:8001/kdic128.m3u";
    NSURL *url = [NSURL URLWithString:urlstr];
    NSError *error = [NSError alloc];
    
    self.streamer = [[AVPlayer alloc] initWithURL:url];
    
    if (self.streamer == nil)
        NSLog(@"%@", [error description]);
    else {
        [streamer play];
        [playpause setTitle:@"Pause" forState: UIControlStateNormal];
        playing = YES;
    }
    
}

- (IBAction)playPauseCallback:(id)sender
{
    NSLog(@"%@", @"Hello\n");
    if (playing) {
        [streamer pause];
        [playpause setTitle:@"Play" forState: UIControlStateNormal];
        playing = NO;
    } else {
        [streamer play];
        [playpause setTitle:@"Pause" forState: UIControlStateNormal];
        playing = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
