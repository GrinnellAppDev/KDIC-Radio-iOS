//
//  DeckController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/3/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "DeckController.h"

@interface DeckController ()

@end

@implementation DeckController

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
	// Do any additional setup after loading the view.
    
    UIStoryboard *storyboard;
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
        else
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    
    self.centerController = [storyboard instantiateViewControllerWithIdentifier:@"StreamView"];
    self.leftController = [storyboard instantiateViewControllerWithIdentifier:@"Schedule"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end