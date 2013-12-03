//
//  PlayerViewController.h
//  KDIC
//
//  Created by Colin Tremblay on 11/2/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayerViewController : UIViewController

@property (nonatomic, strong) NSString *metaString;
@property (nonatomic, weak) IBOutlet UIButton *playpause;
@property (nonatomic, weak) IBOutlet UIButton *ff;
@property (nonatomic, weak) IBOutlet UIButton *rw;
@property (nonatomic, weak) IBOutlet UILabel *songLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistLabel;
@property (nonatomic, weak) IBOutlet UIImageView *albumArtView;
@property (nonatomic, weak) IBOutlet UIView *volViewParent;
@property (nonatomic, strong) NSString *urlString;

- (IBAction)playPauseButtonTap:(id)sender;
- (IBAction)seekingButtonHeld:(id)sender;
- (IBAction)seekingButtonReleased:(id)sender;
- (IBAction)updateLabels:(id)sender;
- (IBAction)triggerTimer:(id)sender;
- (void)streamMeta:(NSNotification *)notification;
- (void)changeIcon:(NSNotification *)notification;
- (void)setLabels;
- (void)setPodcastLabels;
- (BOOL)networkCheck;

@end
