//
//  ViewController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/2/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "ViewController.h"
#import <MBProgressHUD.h>
#import <Reachability.h>

@interface ViewController ()

@end

@implementation ViewController

@synthesize playing, playpause, streamMPMoviePlayer, metaString, streamer, volViewParent;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add the volume slider to the view in the xib
    MPVolumeView *myVolView = [[MPVolumeView alloc] initWithFrame:volViewParent.bounds];
    [volViewParent addSubview:myVolView];
    
    // Create callback for when metadata changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamMeta:) name:MPMoviePlayerTimedMetadataUpdatedNotification object:nil];
    
    // Change icon to play when the state becomes playing
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeIcon:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
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
        [streamMPMoviePlayer play];
        
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

// Open Schedule
- (IBAction)menuButton:(id)sender {
    [self.viewDeckController toggleLeftViewAnimated:YES];
}

@end
