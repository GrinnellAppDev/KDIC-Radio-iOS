//
//  PlayerViewController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/2/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "PlayerViewController.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import <MBProgressHUD.h>
#import "KDICNetworkManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayerViewController ()

@property (nonatomic, strong) NSString *metaString;
@property (nonatomic, weak) IBOutlet UIButton *playpause;
@property (nonatomic, weak) IBOutlet UIButton *ff;
@property (nonatomic, weak) IBOutlet UIButton *rw;
@property (nonatomic, weak) IBOutlet UILabel *songLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistLabel;
@property (nonatomic, weak) IBOutlet UIImageView *albumArtView;
@property (nonatomic, weak) IBOutlet UIView *volViewParent;

@end

@implementation PlayerViewController {
    AppDelegate *appDel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    appDel = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"kdic-navBar-short.png"];
    [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    // Add the volume slider to the view in the xib
    MPVolumeView *myVolView = [[MPVolumeView alloc] initWithFrame:self.volViewParent.bounds];
    [self.volViewParent addSubview:myVolView];
    
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
    [super viewDidAppear:animated];
    
    // Hide "Back" so that only the "<" shows in the top left
    // TODO: This doesn't work, try this: http://stackoverflow.com/questions/19078995/removing-the-title-text-of-an-ios-7-uibarbuttonitem
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -80.f) forBarMetrics:UIBarMetricsDefault];
    
    if ([KDICNetworkManager networkCheck]) {
        NSString *contentURL = [NSString stringWithFormat:@"%@", appDel.streamMPMoviePlayer.contentURL];
        BOOL equalURL = !self.urlString || [self.urlString isEqualToString:contentURL];
        
        if (!equalURL || MPMoviePlaybackStatePlaying != appDel.streamMPMoviePlayer.playbackState) {
            // HUD
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Loading Stream";
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
            
            NSURL *url;
            if (!self.urlString) {
                url = appDel.streamMPMoviePlayer.contentURL;
            } else {
                url = [NSURL URLWithString:self.urlString];
            }
            
            NSError *err;
            if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&err]) {
                NSLog(@"Audio sessions error %@, %@", err, [err userInfo]);
            } else {
                [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
                
                // Create stream using MPMoviePlayerController
                appDel.streamMPMoviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
                
                NSString *temp = [NSString stringWithFormat:@"%@", url];
                if (NSNotFound != [temp rangeOfString:@"m3u"].location) {
                    appDel.streamMPMoviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
                    [self hideFFandRW];
                } else {
                    appDel.streamMPMoviePlayer.movieSourceType = MPMovieSourceTypeFile;
                    [self unhideFFandRW];
                }
                
                appDel.streamMPMoviePlayer.shouldAutoplay = NO;
                [appDel.streamMPMoviePlayer prepareToPlay];
                [appDel.streamMPMoviePlayer play];
            }
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
        
        contentURL = [NSString stringWithFormat:@"%@", appDel.streamMPMoviePlayer.contentURL];
        if ([LIVE_STREAM_URL isEqualToString:contentURL]) {
            [self setLabels];
        } else {
            [self setPodcastLabels];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    NSString *contentURL = [NSString stringWithFormat:@"%@", appDel.streamMPMoviePlayer.contentURL];
    BOOL equalURL = !self.urlString || [self.urlString isEqualToString:contentURL];
    
    if (!equalURL || MPMoviePlaybackStatePlaying != appDel.streamMPMoviePlayer.playbackState) {
        // We're going to need to load a stream, so hide everything
        [self hideFFandRW];
        self.artistLabel.text = @"";
        self.songLabel.text = @"";
    } else {
        // A stream is loaded, set up the view
        NSURL *url;
        if (!self.urlString) {
            url = appDel.streamMPMoviePlayer.contentURL;
        } else {
            url = [NSURL URLWithString:self.urlString];
        }
        
        NSString *temp = [NSString stringWithFormat:@"%@", url];
        if (NSNotFound != [temp rangeOfString:@"m3u"].location) {
            [self hideFFandRW];
        } else {
            [self unhideFFandRW];
        }
        [self changeIcon];
        
        contentURL = [NSString stringWithFormat:@"%@", appDel.streamMPMoviePlayer.contentURL];
        if ([LIVE_STREAM_URL isEqualToString:contentURL]) {
            [self setLabels];
        } else {
            [self setPodcastLabels];
        }
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
    if ([segue.identifier isEqualToString:@"ViewDetails"]) {
        DetailViewController *detailVC = segue.destinationViewController;
        
        NSString *contentURL = [NSString stringWithFormat:@"%@", appDel.streamMPMoviePlayer.contentURL];
        if ([contentURL isEqualToString:LIVE_STREAM_URL]) {
            if (!appDel.currentShow) {
                detailVC.detailText = @"";
            } else {
                detailVC.detailText = [NSString stringWithFormat:@"%@\n%@", appDel.currentShow.name, appDel.currentShow.description];
            }
        } else if ([contentURL isEqualToString:@"(null)"]) {
            detailVC.detailText = @"";
        } else {
            detailVC.detailText = [NSString stringWithFormat:@"%@\n%@\n\n%@", appDel.podcast.show, appDel.podcast.title, appDel.podcast.description];
        }
    }
}

- (void)streamMeta:(NSNotification *)notification {
    if ([appDel.streamMPMoviePlayer timedMetadata] != nil) {
        MPTimedMetadata *meta = [[appDel.streamMPMoviePlayer timedMetadata] firstObject];
        self.metaString = meta.value;
    }
    //NSLog(@"%@", metaString);
}

// Change play/pause button when playback state changes
- (void)changeIcon:(NSNotification *)notification {
    if (MPMoviePlaybackStatePlaying == appDel.streamMPMoviePlayer.playbackState) {
        [self.playpause setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    } else {
        [self.playpause setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
}

- (void)changeIcon {
    if (MPMoviePlaybackStatePlaying == appDel.streamMPMoviePlayer.playbackState) {
        [self.playpause setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    } else {
        [self.playpause setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)seekingButtonHeld:(UIButton *)sender {
    if (sender == self.ff) {
        [appDel.streamMPMoviePlayer beginSeekingForward];
    } else {
        [appDel.streamMPMoviePlayer beginSeekingBackward];
    }
}

- (IBAction)seekingButtonReleased:(id)sender {
    [appDel.streamMPMoviePlayer endSeeking];
}

- (IBAction)playPauseButtonTap:(id)sender {
    // Note: Button gets changed by changeIcon (called because the playback state changes)
    if (MPMoviePlaybackStatePlaying == appDel.streamMPMoviePlayer.playbackState) {
        [appDel.streamMPMoviePlayer pause];
    } else {
        [appDel.streamMPMoviePlayer play];
    }
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
    if (appDel.currentShow) {
        self.songLabel.text = [NSString stringWithFormat:@"Current Show: %@", appDel.currentShow.name];
        self.artistLabel.text = [appDel.currentShow formatTime];
        [self getCurrentShow];
    } else {
        self.songLabel.text = @"WE ARE CURRENTLY ON AUTOPLAY";
        
        NSString *nextShow = [NSString stringWithFormat:@"Up Next: %@ (%@)", appDel.nextShow.name, [appDel.nextShow formatTime]];
        self.artistLabel.text = nextShow;
        
        [self updateExternalLabels];
    }
}

- (void)getCurrentShow {
    if (![KDICNetworkManager networkCheck]) {
        return;
    }
    
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
    
    [NSURLConnection sendAsynchronousRequest:request queue:NSOperationQueuePriorityNormal completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *connectionError) {
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
            
            appDel.currentShow.description = description;
        }
        
        start = [responseData rangeOfString:@"<meta property='og:image' content='" options:NSCaseInsensitiveSearch | NSBackwardsSearch];
        NSRange end = [responseData rangeOfString:@"<link rel='image_src" options:NSCaseInsensitiveSearch | NSBackwardsSearch];
        if (NSNotFound != start.location && NSNotFound != end.location) {
            start.location += start.length;
            start.length = end.location - start.location - 5;
            NSString *imgURLString = [responseData substringWithRange:start];
            NSURL *imgURL = [NSURL URLWithString:imgURLString];
            self.albumArtView.contentMode = UIViewContentModeScaleAspectFit;
            [self.albumArtView sd_setImageWithURL:imgURL placeholderImage:[UIImage imageNamed:@"iTunesArtwork"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [self updateInfoCenter];
            }];
        }
        
        [self updateExternalLabels];
    }];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if (MPMovieSourceTypeStreaming == appDel.streamMPMoviePlayer.movieSourceType) {
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
    } else {
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
}

// Updates the information in the app delegate and the info center (remote control)
- (void)updateExternalLabels {
    appDel.artistText = self.artistLabel.text;
    appDel.songText = self.songLabel.text;
    appDel.showImage = self.albumArtView.image;
    [self updateInfoCenter];
}

- (void)updateInfoCenter {
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    if (playingInfoCenter) {
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:self.albumArtView.image];
        if (self.songLabel.text) {
            [songInfo setObject:self.songLabel.text forKey:MPMediaItemPropertyTitle];
        }
        if (self.artistLabel.text) {
            [songInfo setObject:self.artistLabel.text forKey:MPMediaItemPropertyArtist];
        }
        if (albumArt) {
            [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        }
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
}

- (void)setPodcastLabels {
    self.artistLabel.text = appDel.podcast.title;
    UIImage *placeholderImage = [UIImage imageNamed:@"iTunesArtwork"];
    [self.albumArtView sd_setImageWithURL:[NSURL URLWithString:appDel.podcast.imageURL] placeholderImage:placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [self updateInfoCenter];
    }];
    self.songLabel.text = [NSString stringWithFormat:@"%@:", appDel.podcast.show];
    [self updateExternalLabels];
}

@end
