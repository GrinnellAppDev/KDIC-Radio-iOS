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
#import <ViewDeck/IIViewDeckController.h>

@interface ViewController : UIViewController


@property (nonatomic, assign) BOOL playing;
@property (nonatomic, strong) AVPlayer *streamer;
@property (nonatomic, strong) MPMoviePlayerController *streamMPMoviePlayer;

@property (nonatomic, strong) NSString *metaString;
@property (nonatomic, weak) IBOutlet UIButton *playpause;
@property (nonatomic, weak) IBOutlet UISlider *slider;
@property (nonatomic, weak) IBOutlet UILabel *songLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistLabel;
@property (nonatomic, weak) IBOutlet UIImageView *albumArtView;

@property (nonatomic, weak) IBOutlet UIView *volViewParent;


- (IBAction)playPauseButtonTap:(id)sender;
- (IBAction)menuButton:(id)sender;
- (void)streamMeta:(NSNotification *)notification;
- (void)changeIcon:(NSNotification *)notification;
- (BOOL)networkCheck;

@end
