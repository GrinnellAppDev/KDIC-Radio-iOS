//
//  ViewController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/2/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "ViewController.h"
#import "ScheduleViewController.h"
#import <MBProgressHUD.h>
#import <Reachability.h>

@interface ViewController ()

@end

@implementation ViewController

@synthesize playpause, streamMPMoviePlayer, metaString, volViewParent, songLabel, artistLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add the volume slider to the view in the xib
    MPVolumeView *myVolView = [[MPVolumeView alloc] initWithFrame:volViewParent.bounds];
    [volViewParent addSubview:myVolView];
    
    // Create callback for when metadata changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamMeta:) name:MPMoviePlayerTimedMetadataUpdatedNotification object:nil];
    
    // Change icon to play when the state becomes playing
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeIcon:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    // Set up screen update timer
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    NSUInteger second = [comps second];
    second += [comps minute] * 60;
    second = 3600 - second;
    NSTimer *timerTimer = [NSTimer timerWithTimeInterval:second target:self selector:@selector(triggerTimer:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timerTimer forMode:NSRunLoopCommonModes];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.networkCheck)
        [self showNoNetworkAlert];
    else {
        // HUD
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading Stream";
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
        
        NSURL *url = [NSURL URLWithString:@"http://kdic.grinnell.edu:8001/kdic128.m3u"];
        
        // Create stream using MPMoviePlayerController
        streamMPMoviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
        streamMPMoviePlayer.movieSourceType = MPMovieSourceTypeStreaming;

        [streamMPMoviePlayer prepareToPlay];
        [streamMPMoviePlayer play];
        streamMPMoviePlayer.shouldAutoplay = YES;
        
        [self setLabels];
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Method to determine the availability of network Connections using the Reachability Class
- (BOOL)networkCheck {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return (!(networkStatus == NotReachable));
}

#pragma mark UIAlertViewDelegate Methods
// Called when an alert button is tapped.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    return;
}

- (void)showNoNetworkAlert {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *network = [[UIAlertView alloc]
                            initWithTitle:@"No Network Connection"
                            message:@"Turn on cellular data or use Wi-Fi to access the server"
                            delegate:self
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil
                            ];
    [network show];
}

- (void)streamMeta:(NSNotification *)notification {
    if ([streamMPMoviePlayer timedMetadata] != nil) {
        MPTimedMetadata *meta = [[streamMPMoviePlayer timedMetadata] firstObject];
        metaString = meta.value;
    }
    NSLog(@"%@", metaString);
}

// Change play/pause button when playback state changes
- (void)changeIcon:(NSNotification *)notification {
   // NSLog(@"%@", [[streamMPMoviePlayer timedMetadata] firstObject]);
    if (MPMoviePlaybackStatePlaying == streamMPMoviePlayer.playbackState)
        [playpause setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    else
        [playpause setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
}

- (IBAction)playPauseButtonTap:(id)sender {
    // Note: Button gets changed by changeIcon (called because the playback state changes)
    if (MPMoviePlaybackStatePlaying == streamMPMoviePlayer.playbackState)
        [streamMPMoviePlayer pause];
    else
        [streamMPMoviePlayer play];
}

- (IBAction)triggerTimer:(id)sender {
    // Set up screen updates on the hour
    NSTimer *timer = [NSTimer timerWithTimeInterval:3600.0f target:self selector:@selector(updateLabels:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [self updateLabels:sender];
}

// Update labels
- (IBAction)updateLabels:(id)sender {
    [self.viewDeckController.leftController viewDidLoad];
    [self setLabels];
}

- (void)setLabels {
    ScheduleViewController *schedVC = (ScheduleViewController *)self.viewDeckController.leftController;
    
    if (NULL != schedVC.currentShow) {
        songLabel.text = [NSString stringWithFormat:@"Current Show: %@", schedVC.currentShow.name];
        artistLabel.text = [schedVC formatTime:schedVC.currentShow];
    }
    else {
        songLabel.text = @"WE ARE CURRENTLY ON AUTOPLAY";
        UITableViewCell *nextShowCell = [schedVC.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        NSString *timeStr = nextShowCell.detailTextLabel.text;
        NSRange range = [timeStr rangeOfString:@"M."];
        range.length += range.location;
        range.location = 0;
        timeStr = [timeStr substringWithRange:range];
        NSString *nextShow = [NSString stringWithFormat:@"Up Next: %@ (%@ CT)", nextShowCell.textLabel.text, timeStr];
        artistLabel.text = nextShow;
    }
}

// Open Schedule
- (IBAction)menuButton:(id)sender {
    [self.viewDeckController toggleLeftViewAnimated:YES];
}
@end
