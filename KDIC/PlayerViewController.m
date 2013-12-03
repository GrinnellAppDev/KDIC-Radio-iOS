//
//  PlayerViewController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/2/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "PlayerViewController.h"
#import <MBProgressHUD.h>
#import <Reachability.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "ScheduleViewController.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "HTMLStringParser.h"

@interface PlayerViewController ()

@end

@implementation PlayerViewController {
    AppDelegate *appDel;
}

@synthesize playpause, metaString, volViewParent, songLabel, artistLabel, albumArtView, urlString, ff, rw;

- (void)viewDidLoad {
    [super viewDidLoad];
    appDel = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"kdic-navBar-short.png"] forBarMetrics:UIBarMetricsDefault];
    
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
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -80.f) forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    if (self.networkCheck) {
        BOOL equalURL;
        if (NULL == urlString || [urlString isEqualToString:[NSString stringWithFormat:@"%@", appDel.streamMPMoviePlayer.contentURL]])
            equalURL = TRUE;
        else equalURL = FALSE;
        
        if (!equalURL || MPMoviePlaybackStatePlaying != appDel.streamMPMoviePlayer.playbackState) {
            // HUD
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Loading Stream";
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
            
            NSURL *url;
            if (NULL == urlString)
                url = appDel.streamMPMoviePlayer.contentURL;
            else url = [NSURL URLWithString:urlString];
            
            NSError *err;
            if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&err])
                NSLog(@"Audio sessions error %@, %@", err, [err userInfo]);
            else {
                [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
                
                // Create stream using MPMoviePlayerController
                appDel.streamMPMoviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
                NSString *temp = [NSString stringWithFormat:@"%@", url];
                if (NSNotFound != [temp rangeOfString:@"m3u"].location) {
                    appDel.streamMPMoviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
                    rw.hidden = YES;
                    ff.hidden = YES;
                }
                else {
                    appDel.streamMPMoviePlayer.movieSourceType = MPMovieSourceTypeFile;
                    rw.hidden = NO;
                    ff.hidden = NO;
                }
                
                appDel.streamMPMoviePlayer.shouldAutoplay = NO;
                [appDel.streamMPMoviePlayer prepareToPlay];
                [appDel.streamMPMoviePlayer play];
            }
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
        else [self changeIcon];
        
        if ([@"http://kdic.grinnell.edu:8001/kdic128.m3u" isEqualToString:[NSString stringWithFormat:@"%@", appDel.streamMPMoviePlayer.contentURL]])
            [self setLabels];
        else [self setPodcastLabels];
        
    }
    else [self showNoNetworkAlert];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ViewDetails"]) {
        DetailViewController *detailVC = [segue destinationViewController];
        if ([@"http://kdic.grinnell.edu:8001/kdic128.m3u" isEqualToString:[NSString stringWithFormat:@"%@", appDel.streamMPMoviePlayer.contentURL]]) {
            if (NULL == appDel.currentShow)
                detailVC.description = [self getKDICDescription];
            else detailVC.description = [NSString stringWithFormat:@"%@\n%@", appDel.currentShow.name, appDel.currentShow.description];
        }
        else
            detailVC.description = [NSString stringWithFormat:@"%@\n%@\n\n%@", appDel.podcast.show, appDel.podcast.title, appDel.podcast.description];
    }
}

- (void)streamMeta:(NSNotification *)notification {
    if ([appDel.streamMPMoviePlayer timedMetadata] != nil) {
        MPTimedMetadata *meta = [[appDel.streamMPMoviePlayer timedMetadata] firstObject];
        metaString = meta.value;
    }
    //NSLog(@"%@", metaString);
}

// Change play/pause button when playback state changes
- (void)changeIcon:(NSNotification *)notification {
    if (MPMoviePlaybackStatePlaying == appDel.streamMPMoviePlayer.playbackState)
        [playpause setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    else
        [playpause setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
}

- (void)changeIcon {
    if (MPMoviePlaybackStatePlaying == appDel.streamMPMoviePlayer.playbackState)
        [playpause setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    else
        [playpause setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
}

- (IBAction)seekingButtonHeld:(id)sender {
    if ([sender tag] == [ff tag])
        [appDel.streamMPMoviePlayer beginSeekingForward];
    else
        [appDel.streamMPMoviePlayer beginSeekingBackward];
}

- (IBAction)seekingButtonReleased:(id)sender {
    [appDel.streamMPMoviePlayer endSeeking];
}

- (IBAction)playPauseButtonTap:(id)sender {
    // Note: Button gets changed by changeIcon (called because the playback state changes)
    if (MPMoviePlaybackStatePlaying == appDel.streamMPMoviePlayer.playbackState)
        [appDel.streamMPMoviePlayer pause];
    else
        [appDel.streamMPMoviePlayer play];
}

- (IBAction)triggerTimer:(id)sender {
    // Set up screen updates on the hour
    NSTimer *timer = [NSTimer timerWithTimeInterval:3600.0f target:self selector:@selector(updateLabels:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [self setLabels];
}

// Update labels
- (IBAction)updateLabels:(id)sender {
    [self setLabels];
}

- (void)setLabels {
    ScheduleViewController *schedVC = [[ScheduleViewController alloc] init];
    
    if (NULL != appDel.currentShow) {
        songLabel.text = [NSString stringWithFormat:@"Current Show: %@", appDel.currentShow.name];
        artistLabel.text = [schedVC formatTime:appDel.currentShow];
        @try{
            NSURL *showURL = appDel.currentShow.url;
            NSString *post =[[NSString alloc] initWithFormat:@""];
            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:showURL];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/html" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            
            NSError *error = [[NSError alloc] init];
            NSHTTPURLResponse *response = nil;
            NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if([response statusCode] >= 200 && [response statusCode] < 300){
                NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
                NSRange start = [responseData rangeOfString:@"<meta property='og:description' content='" options:NSCaseInsensitiveSearch];
                if (NSNotFound != start.location) {
                    NSString *description = [responseData substringFromIndex:start.location + start.length];
                    start = [description rangeOfString:@"' />"];
                    description = [description substringToIndex:start.location];
                    description = [description stringByReplacingOccurrencesOfString:@"CST." withString:@"CST"];
                    description = [description stringByReplacingOccurrencesOfString:@"CDT." withString:@"CDT"];
                    description = [description stringByReplacingOccurrencesOfString:@"CST" withString:@"CST\n\n"];
                    description = [description stringByReplacingOccurrencesOfString:@"CDT" withString:@"CDT\n\n"];
                    
                    appDel.currentShow.description = description;
                }
                
                start = [responseData rangeOfString:@"<meta property='og:image' content='" options:NSCaseInsensitiveSearch | NSBackwardsSearch];
                NSRange end = [responseData rangeOfString:@"<link rel='image_src" options:NSCaseInsensitiveSearch | NSBackwardsSearch];
                if (NSNotFound != start.location && NSNotFound != end.location) {
                    start.location += start.length;
                    start.length = end.location - start.location - 5;
                    NSString *imgURLString = [responseData substringWithRange:start];
                    NSURL *imgURL = [NSURL URLWithString:imgURLString];
                    albumArtView.contentMode = UIViewContentModeScaleAspectFit;
                    [albumArtView setImageWithURL:imgURL placeholderImage:[UIImage imageNamed:@"iTunesArtwork"]completed:^(UIImage *img, NSError *err, SDImageCacheType cacheType) {
                        [self updateExternalLabels];
                    }];
                }
            }
        }
        @catch (NSException *e) {
            NSLog(@"Error getting image: %@", e);
        }
    }
    else {
        songLabel.text = @"WE ARE CURRENTLY ON AUTOPLAY";
        
        NSString *nextShow = [NSString stringWithFormat:@"Up Next: %@ (%@ CT)", appDel.nextShow.name, [schedVC formatTime:appDel.nextShow]];
        artistLabel.text = nextShow;
    }
    [self updateExternalLabels];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if (MPMovieSourceTypeStreaming == appDel.streamMPMoviePlayer.movieSourceType)
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [appDel.streamMPMoviePlayer play];
                break;
            case UIEventSubtypeRemoteControlPause:
                [appDel.streamMPMoviePlayer pause];
                break;
            default:
                break;
        }
    else
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [appDel.streamMPMoviePlayer play];
                break;
            case UIEventSubtypeRemoteControlPause:
                [appDel.streamMPMoviePlayer pause];
                break;
            case UIEventSubtypeRemoteControlBeginSeekingBackward:
                [appDel.streamMPMoviePlayer beginSeekingBackward];
                break;
            case UIEventSubtypeRemoteControlEndSeekingBackward:
                [appDel.streamMPMoviePlayer endSeeking];
                break;
            case UIEventSubtypeRemoteControlBeginSeekingForward:
                [appDel.streamMPMoviePlayer beginSeekingForward];
                break;
            case UIEventSubtypeRemoteControlEndSeekingForward:
                [appDel.streamMPMoviePlayer endSeeking];
                break;
            default:
                break;
        }
}

// Updates the information in the app delegate and the info center (remote control)
- (void)updateExternalLabels {
    appDel.artistText = artistLabel.text;
    appDel.songText = songLabel.text;
    appDel.showImage = albumArtView.image;
    [self updateInfoCenter];
}
- (void)updateInfoCenter {
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    if (playingInfoCenter) {
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:albumArtView.image];
        [songInfo setObject:songLabel.text forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:artistLabel.text forKey:MPMediaItemPropertyArtist];
        [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
}
- (void)setPodcastLabels {
    artistLabel.text = appDel.podcast.title;
    [albumArtView setImageWithURL:[NSURL URLWithString:appDel.podcast.imageURL] placeholderImage:[UIImage imageNamed:@"iTunesArtwork"] completed:^(UIImage *img, NSError *err, SDImageCacheType cacheType) {
        [self updateInfoCenter];
    }];
    songLabel.text = [NSString stringWithFormat:@"%@:", appDel.podcast.show];
    [self updateExternalLabels];
}

- (NSString *)getKDICDescription {
    @try{
        NSURL *URL = [NSURL URLWithString:@"http://kdic.grinnell.edu/about-us/"];
        NSString *post =[[NSString alloc] initWithFormat:@""];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:URL];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/html" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *response = nil;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if([response statusCode] >= 200 && [response statusCode] < 300){
            NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
            
            NSRange start = [responseData rangeOfString:@"<h1>About</h1>" options:NSCaseInsensitiveSearch];
            if (NSNotFound != start.location) {
                NSString *description = [responseData substringFromIndex:start.location + start.length];
                start = [description rangeOfString:@"If you&#"];
                description = [description substringToIndex:start.location];
                
                HTMLStringParser *sp = [[HTMLStringParser alloc] init];
                description = [sp removeHTMLTags:description];
                
                return description;
            }
        }
    }
    @catch (NSException *e) {
        NSLog(@"Error getting image: %@", e);
    }
    return NULL;
}

@end
