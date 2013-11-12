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

@interface LiveStreamViewController ()

@end

@implementation LiveStreamViewController

@synthesize playerVC, albumArtView, artistLabel, songLabel, playButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"kdic-navBar.png"] forBarMetrics:UIBarMetricsDefault];
    
    if (NULL == playerVC) {
        playerVC = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:Nil];
        playerVC.hidesBottomBarWhenPushed = YES;
        [self performSegueWithIdentifier:@"LiveStream-to-Player" sender:self];
    }
}

// CALL THIS ON RETURN FROM SEGUE
//    [self setLabels];

- (void)setLabels {
    songLabel.text = playerVC.songLabel.text;
    artistLabel.text = playerVC.artistLabel.text;
    albumArtView.image = playerVC.albumArtView.image;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
