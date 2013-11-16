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
#import "DeckController.h"
#import "AppDelegate.h"

@interface LiveStreamViewController ()

@end

@implementation LiveStreamViewController {
    AppDelegate *appDel;
}

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
    appDel = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"kdic-navBar-short.png"] forBarMetrics:UIBarMetricsDefault];
    
    if (NULL == playerVC) {
        playerVC = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:Nil];
        [self performSegueWithIdentifier:@"LiveStream-to-Player" sender:self];
    }
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
    DeckController *deckVC = (DeckController *)[segue destinationViewController];
    [deckVC setHidesBottomBarWhenPushed:YES];
}

#pragma mark - Other methods
- (void)setLabels {
    artistLabel.text = appDel.artistText;
    songLabel.text = appDel.songText;
    albumArtView.image = appDel.showImage;
}

@end
