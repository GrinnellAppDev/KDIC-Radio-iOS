//
//  ShowsPodcastsViewController.h
//  KDIC
//
//  Created by Colin Tremblay on 11/12/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Show.h"

@interface ShowsPodcastsViewController : UITableViewController

@property (nonatomic, strong) Show *show;
@property (nonatomic, strong) NSMutableArray *podcastsArray;

@end
