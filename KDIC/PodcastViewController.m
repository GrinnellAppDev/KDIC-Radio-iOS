//
//  PodcastViewController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/12/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "PodcastViewController.h"
#import "Show.h"
#import "ShowsPodcastsViewController.h"
#import "KDICConstants.h"

@interface PodcastViewController ()

@end

@implementation PodcastViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:KDIC_NAVBAR_IMAGE] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.showArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ShowCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Show *show = self.showArray[indexPath.row];
    cell.textLabel.text = show.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:SHOW_SELECT_SEGUE sender:self];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NOW_PLAYING_SEGUE]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        self.navigationController.navigationBar.topItem.title = @"";
    } else if ([segue.identifier isEqualToString:SHOW_SELECT_SEGUE]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ShowsPodcastsViewController *showsPVC = (ShowsPodcastsViewController *)segue.destinationViewController;
        showsPVC.show = self.showArray[indexPath.row];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
