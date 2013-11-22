//
//  PodcastViewController.m
//  
//
//  Created by Colin Tremblay on 11/12/13.
//
//

#import "PodcastViewController.h"
#import "Show.h"
#import "ShowsPodcastsViewController.h"

@interface PodcastViewController ()

@end

@implementation PodcastViewController

@synthesize showArray;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITabBarItem *item = self.tabBarItem;
    item.image = [UIImage imageNamed:@"mic-30.jpg"];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"kdic-navBar-short.png"] forBarMetrics:UIBarMetricsDefault];
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
    return showArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ShowCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Show *show = [showArray objectAtIndex:indexPath.row];
    cell.textLabel.text = show.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ShowSelect" sender:self];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"NowPlayingJump"])
        [[segue destinationViewController] setHidesBottomBarWhenPushed:YES];
    else if ([[segue identifier] isEqualToString:@"ShowSelect"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ShowsPodcastsViewController *showsPVC = (ShowsPodcastsViewController *)[segue destinationViewController];
        showsPVC.show = [showArray objectAtIndex:indexPath.row];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
