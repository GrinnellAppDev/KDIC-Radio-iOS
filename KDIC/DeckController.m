//
//  DeckController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/3/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "DeckController.h"
#import "PlayerViewController.h"

@interface DeckController ()

@end

@implementation DeckController

@synthesize urlString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.centerController = [self.storyboard instantiateViewControllerWithIdentifier:@"StreamView"];
    PlayerViewController *playerVC = (PlayerViewController *) self.centerController;
    playerVC.urlString = urlString;
    self.rightController = [self.storyboard instantiateViewControllerWithIdentifier:@"Schedule"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// Open Schedule
- (IBAction)menuButton:(id)sender {
    [self toggleRightViewAnimated:YES];
}

@end
