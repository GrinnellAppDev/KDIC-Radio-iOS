//
//  LiveStreamViewController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/12/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "LiveStreamViewController.h"

@interface LiveStreamViewController ()

@end

@implementation LiveStreamViewController

@synthesize playerVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"kdic-wide.jpg"] forBarMetrics:UIBarMetricsDefault];
    if (NULL == playerVC) {
        playerVC = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:Nil];
        [self performSegueWithIdentifier:@"LiveStream-to-Player" sender:self];
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
