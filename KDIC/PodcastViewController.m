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
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"kdic-navBar-short.png"] forBarMetrics:UIBarMetricsDefault];
    showArray = [[NSMutableArray alloc] init];
    @try{
        NSString *post =[[NSString alloc] initWithFormat:@""];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"http://kdic.grinnell.edu"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/html" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *response = nil;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if([response statusCode] >= 200 && [response statusCode] < 300){
            NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
            NSRange start = [responseData rangeOfString:@"\">Podcasts</a>" options:NSCaseInsensitiveSearch];
            NSString *temp = [responseData substringFromIndex:start.location + start.length];
            NSRange end = [temp rangeOfString:@"</ul>" options:NSCaseInsensitiveSearch];
            temp = [temp substringToIndex:end.length + end.location];
            start = [temp rangeOfString:@"<a href=\""];
            while (NSNotFound != start.location) {
                NSString *showString = [temp substringFromIndex:start.location + start.length];
                end = [showString rangeOfString:@"</a></li>"];
                showString = [showString substringToIndex:end.location];
                showString = [showString stringByReplacingOccurrencesOfString:@"&#8217;" withString:@"'"];
                start = [showString rangeOfString:@"\">"];
                
                NSString *showURL = [showString substringToIndex:start.location];
                NSString *showName = [showString substringFromIndex:start.location + start.length];

                Show *show = [[Show alloc] init];
                show.name = showName;
                show.url = [NSURL URLWithString:showURL];
                
                [showArray addObject:show];
                
                end = [temp rangeOfString:@"</a></li>"];
                temp = [temp substringFromIndex:end.location + end.length];
                start = [temp rangeOfString:@"<a href=\""];
            }
        }
        else NSLog(@"Error: Response Code is %d", [response statusCode]);
    }
    @catch (NSException *e) {
        NSLog(@"Error getting image: %@", e);
    }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ShowCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Show *show = [showArray objectAtIndex:indexPath.row];
    cell.textLabel.text = show.name;
    
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
