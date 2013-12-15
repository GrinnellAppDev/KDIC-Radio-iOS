//
//  LiveStreamViewController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/12/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "LiveStreamViewController.h"
#import "ScheduleViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"
#import "PodcastViewController.h"
#import "PlayerViewController.h"

@interface LiveStreamViewController ()

@end

@implementation LiveStreamViewController {
    AppDelegate *appDel;
}

@synthesize albumArtView, artistLabel, songLabel, playButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    appDel = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"kdic-navBar-short.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setLabels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[segue destinationViewController] setHidesBottomBarWhenPushed:YES];
    if ([[segue identifier] isEqualToString:@"LiveStream-to-Player"]) {
        PlayerViewController *playerVC = [segue destinationViewController];
        playerVC.urlString = @"http://kdic.grinnell.edu:8001/kdic128.m3u";
    }
}

#pragma mark - Other methods
- (void)setLabels {
    artistLabel.text = appDel.artistText;
    songLabel.text = appDel.songText;
    albumArtView.image = appDel.showImage;
}

@end
