//
//  LiveStreamViewController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/12/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "LiveStreamViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PodcastViewController.h"
#import "PlayerViewController.h"
#import "KDICNetworkManager.h"
#import "KDICMusicManager.h"

@interface LiveStreamViewController ()
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UILabel *songLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistLabel;
@property (nonatomic, weak) IBOutlet UIImageView *albumArtView;
@end

@implementation LiveStreamViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"kdic-navBar-short.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setLabels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    if ([segue.identifier isEqualToString:@"LiveStream-to-Player"] || [segue.identifier isEqualToString:@"LiveStream-to-Player-PlayButton"]) {
        PlayerViewController *playerVC = [segue destinationViewController];
        playerVC.urlString = LIVE_STREAM_URL;
    }
}

#pragma mark - Other methods
- (void)setLabels {
    KDICMusicManager *musicManager = [KDICMusicManager sharedInstance];
    
    self.artistLabel.text = musicManager.artistText;
    self.songLabel.text = musicManager.songText;
    if (musicManager.showImage) {
        self.albumArtView.image = musicManager.showImage;
    } else {
        self.albumArtView.image = [UIImage imageNamed:@"iTunesArtwork"];
    }
}

@end
