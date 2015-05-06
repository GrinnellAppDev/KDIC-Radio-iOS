//
//  PlayerViewController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/2/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "PlayerViewController.h"
#import <MBProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DetailViewController.h"
#import "KDICNetworkManager.h"
#import "KDICMusicManager.h"
#import "KDICConstants.h"
#import "Show.h"
#import "Podcast.h"

// @"http://132.161.21.31:8000/stream" = LIVE_STREAM_URL

@interface PlayerViewController ()

@property (nonatomic, strong) NSString *metaString;
@property (nonatomic, weak) IBOutlet UIButton *playpause;
@property (nonatomic, weak) IBOutlet UIButton *ff;
@property (nonatomic, weak) IBOutlet UIButton *rw;
@property (nonatomic, weak) IBOutlet UIView *volViewParent;

@end

@implementation PlayerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *backgroundImage = [UIImage imageNamed:KDIC_NAVBAR_IMAGE];
    [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    // Add the volume slider to the view in the xib
    MPVolumeView *myVolView = [[MPVolumeView alloc] initWithFrame:self.volViewParent.bounds];
    [self.volViewParent addSubview:myVolView];
    
    // Create callback for when metadata changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamMeta:) name:MPMoviePlayerTimedMetadataUpdatedNotification object:nil];
    
    // Change icon to play when the state becomes playing
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeIcon:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    KDICMusicManager *musicManager = [KDICMusicManager sharedInstance];
    if (![KDICNetworkManager networkCheckForURL:musicManager.streamMPMoviePlayer.contentURL]) {
        return;
    }
    
    NSString *contentURL = [NSString stringWithFormat:@"%@", musicManager.streamMPMoviePlayer.contentURL];
    BOOL equalURL = !self.urlString || [self.urlString isEqualToString:contentURL];
    
    if (!equalURL || MPMoviePlaybackStatePlaying != musicManager.streamMPMoviePlayer.playbackState) {
        // HUD
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading Stream";
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
        
        NSURL *url;
        if (!self.urlString) {
            url = musicManager.streamMPMoviePlayer.contentURL;
        } else {
            url = [NSURL URLWithString:self.urlString];
        }
        
        NSError *err;
        if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&err]) {
            if (err) {
                NSLog(@"Audio sessions error: %@", err.localizedDescription);
            }
        } else {
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            
            // Create stream using MPMoviePlayerController
            musicManager.streamMPMoviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
            
            NSString *temp = [NSString stringWithFormat:@"%@", url];
            if (NSNotFound != [temp rangeOfString:@"m3u"].location) {
                musicManager.streamMPMoviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
                [self hideFFandRW];
            } else {
                musicManager.streamMPMoviePlayer.movieSourceType = MPMovieSourceTypeFile;
                [self unhideFFandRW];
            }
            
            musicManager.streamMPMoviePlayer.shouldAutoplay = NO;
            [musicManager.streamMPMoviePlayer prepareToPlay];
            [musicManager.streamMPMoviePlayer play];
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }
    
    contentURL = @"http://132.161.21.31:8000/stream";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    KDICMusicManager *musicManager = [KDICMusicManager sharedInstance];
    NSString *contentURL = [NSString stringWithFormat:@"%@", musicManager.streamMPMoviePlayer.contentURL];
    BOOL equalURL = !self.urlString || [self.urlString isEqualToString:contentURL];
    
    if (!equalURL || MPMoviePlaybackStatePlaying != musicManager.streamMPMoviePlayer.playbackState) {
        // We're going to need to load a stream, so hide everything
        [self hideFFandRW];
    } else {
        // A stream is loaded, set up the view
        NSURL *url;
        if (!self.urlString) {
            url = musicManager.streamMPMoviePlayer.contentURL;
        } else {
            url = [NSURL URLWithString:self.urlString];
        }
        
        NSString *temp = [NSString stringWithFormat:@"%@", url];
        if (NSNotFound != [temp rangeOfString:@"m3u"].location) {
            [self hideFFandRW];
        } else {
            [self unhideFFandRW];
        }
        [self changeIcon:nil];
        
        contentURL = [NSString stringWithFormat:@"%@", musicManager.streamMPMoviePlayer.contentURL];
           }
}

- (void)hideFFandRW {
    self.rw.hidden = YES;
    self.ff.hidden = YES;
}

- (void)unhideFFandRW {
    self.rw.hidden = NO;
    self.ff.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:VIEW_DETAILS_SEGUE]) {
        DetailViewController *detailVC = segue.destinationViewController;
        KDICMusicManager *musicManager = [KDICMusicManager sharedInstance];
        NSString *contentURL = [NSString stringWithFormat:@"%@", musicManager.streamMPMoviePlayer.contentURL];
        if ([contentURL isEqualToString:@"http://132.161.21.31:8000/stream"]) {
            if (!musicManager.currentShow) {
                detailVC.detailText = @"";
            } else {
                detailVC.detailText = [NSString stringWithFormat:@"%@\n%@", musicManager.currentShow.name, musicManager.currentShow.description];
            }
        } else if ([contentURL isEqualToString:@"(null)"]) {
            detailVC.detailText = @"";
        } else {
            detailVC.detailText = [NSString stringWithFormat:@"%@\n%@\n\n%@", musicManager.podcast.show, musicManager.podcast.title, musicManager.podcast.description];
        }
    }
}

- (void)streamMeta:(NSNotification *)notification {
    KDICMusicManager *musicManager = [KDICMusicManager sharedInstance];
    if ([musicManager.streamMPMoviePlayer timedMetadata]) {
        MPTimedMetadata *meta = [[musicManager.streamMPMoviePlayer timedMetadata] firstObject];
        self.metaString = meta.value;
    }
    NSLog(@"%@", self.metaString);
}

// Change play/pause button when playback state changes
- (void)changeIcon:(NSNotification *)notification {
    if (MPMoviePlaybackStatePlaying == [KDICMusicManager sharedInstance].streamMPMoviePlayer.playbackState) {
        [self.playpause setImage:[UIImage imageNamed:PAUSE_IMAGE] forState:UIControlStateNormal];
    } else {
        [self.playpause setImage:[UIImage imageNamed:PLAY_IMAGE] forState:UIControlStateNormal];
    }
}

- (IBAction)seekingButtonHeld:(UIButton *)sender {
    KDICMusicManager *musicManager = [KDICMusicManager sharedInstance];
    if (sender == self.ff) {
        [musicManager.streamMPMoviePlayer beginSeekingForward];
    } else {
        [musicManager.streamMPMoviePlayer beginSeekingBackward];
    }
}

- (IBAction)seekingButtonReleased:(id)sender {
    [[KDICMusicManager sharedInstance].streamMPMoviePlayer endSeeking];
}

- (IBAction)playPauseButtonTap:(id)sender {
    KDICMusicManager *musicManager = [KDICMusicManager sharedInstance];
    
    // Note: Button gets changed by changeIcon (called because the playback state changes)
    if (MPMoviePlaybackStatePlaying == musicManager.streamMPMoviePlayer.playbackState) {
        [musicManager.streamMPMoviePlayer pause];
    } else {
        [musicManager.streamMPMoviePlayer play];
    }
}

- (IBAction)triggerTimer:(id)sender {
    // Set up screen updates on the hour
    NSTimer *timer = [NSTimer timerWithTimeInterval:3600.0f target:self selector:@selector(updateLabels:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

// Update labels
- (IBAction)updateLabels:(id)sender {
}


- (void)getCurrentShow {
    KDICMusicManager *musicManager = [KDICMusicManager sharedInstance];
    if (![KDICNetworkManager networkCheckForURL:musicManager.currentShow.url]) {
        return;
    }
    
    [NSURLConnection sendAsynchronousRequest:[KDICNetworkManager urlRequestWithURL:musicManager.currentShow.url] queue:NSOperationQueuePriorityNormal completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *connectionError) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)urlResponse;
        if (connectionError || response.statusCode < 200 || response.statusCode >= 400) {
            NSLog(@"Connection Error: %@\nStatus Code: %ld", connectionError.localizedDescription, (long)response.statusCode);
            return;
        }
        
        NSString *responseData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSRange start = [responseData rangeOfString:@"<meta property='og:description' content='" options:NSCaseInsensitiveSearch];
        if (NSNotFound != start.location) {
            NSString *description = [responseData substringFromIndex:start.location + start.length];
            start = [description rangeOfString:@"' />"];
            description = [description substringToIndex:start.location];
            description = [description stringByReplacingOccurrencesOfString:@"CST." withString:@"CST"];
            description = [description stringByReplacingOccurrencesOfString:@"CDT." withString:@"CDT"];
            description = [description stringByReplacingOccurrencesOfString:@"CST" withString:@"CST\n\n"];
            description = [description stringByReplacingOccurrencesOfString:@"CDT" withString:@"CDT\n\n"];
            
            musicManager.currentShow.description = description;
        }
        

        
    }];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    KDICMusicManager *musicManager = [KDICMusicManager sharedInstance];
    
    if (MPMovieSourceTypeStreaming == musicManager.streamMPMoviePlayer.movieSourceType) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [musicManager.streamMPMoviePlayer play];
                break;
            case UIEventSubtypeRemoteControlPause:
                [musicManager.streamMPMoviePlayer pause];
                break;
            default:
                break;
        }
    } else {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [musicManager.streamMPMoviePlayer play];
                break;
            case UIEventSubtypeRemoteControlPause:
                [musicManager.streamMPMoviePlayer pause];
                break;
            case UIEventSubtypeRemoteControlBeginSeekingBackward:
                [musicManager.streamMPMoviePlayer beginSeekingBackward];
                break;
            case UIEventSubtypeRemoteControlEndSeekingBackward:
                [musicManager.streamMPMoviePlayer endSeeking];
                break;
            case UIEventSubtypeRemoteControlBeginSeekingForward:
                [musicManager.streamMPMoviePlayer beginSeekingForward];
                break;
            case UIEventSubtypeRemoteControlEndSeekingForward:
                [musicManager.streamMPMoviePlayer endSeeking];
                break;
            default:
                break;
        }
    }
}


@end
