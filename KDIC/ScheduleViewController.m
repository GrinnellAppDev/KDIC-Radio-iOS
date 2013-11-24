//
//  ScheduleViewController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/3/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "AppDelegate.h"
#import "ScheduleViewController.h"
#import "PodcastViewController.h"
#import "ShowsPodcastsViewController.h"
#import "HTMLStringParser.h"
#import <Reachability.h>

@interface ScheduleViewController ()

@end

@implementation ScheduleViewController {
    AppDelegate *appDel;
}

@synthesize cellIdentifier, jsonDict, dayBegan, schedFromJSON, playerVC, showArray, namesOfPodcasts;

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
    
    appDel = [UIApplication sharedApplication].delegate;
    
    cellIdentifier = @"ScheduleCell";
    
    if (self.networkCheck) {
        [self getShowsWithPodcasts];
        [self getSchedule];
        UINavigationController *tempNavC = [[self.tabBarController viewControllers] objectAtIndex:1];
        PodcastViewController *podcastVC = [tempNavC.childViewControllers objectAtIndex:0];
        podcastVC.showArray = showArray;
        if (NULL == playerVC) {
            playerVC = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:Nil];
            [self performSegueWithIdentifier:@"AppOpens" sender:self];
        }
    }
    else [self showNoNetworkAlert];
    
    // Set up screen update timer
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    NSUInteger second = [comps second];
    second += [comps minute] * 60;
    second = 3600 - second;
    NSTimer *timerTimer = [NSTimer timerWithTimeInterval:second target:self selector:@selector(triggerTimer:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timerTimer forMode:NSRunLoopCommonModes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (dayBegan && ![[schedFromJSON objectAtIndex:0] isKindOfClass:[NSString class]]
        && ![[schedFromJSON objectAtIndex:7] isKindOfClass:[NSString class]])
        return 8;
    else
        return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([[schedFromJSON objectAtIndex:0] isKindOfClass:[NSString class]]) {
        return [[schedFromJSON objectAtIndex:section+1] count];
    }
    else return [[schedFromJSON objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[schedFromJSON objectAtIndex:0] isKindOfClass:[NSString class]]) {
        Show *show = [[schedFromJSON objectAtIndex:section+1] objectAtIndex:0];
        return show.day;
    }
    else {
        Show *show = [[schedFromJSON objectAtIndex:section] objectAtIndex:0];
        return show.day;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView registerNib:[UINib nibWithNibName:@"ScheduleCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
    Show *show;
    if ([[schedFromJSON objectAtIndex:0] isKindOfClass:[NSString class]])
        show = [[schedFromJSON objectAtIndex:indexPath.section+1] objectAtIndex:indexPath.row];
    else
        show = [[schedFromJSON objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    if (show.isPodcast) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.userInteractionEnabled = YES;
    }
    else {
         cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = YES;
    }
    
    cell.textLabel.text = show.name;
    cell.detailTextLabel.text = [self formatTime:show];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Show *show;
    if ([[schedFromJSON objectAtIndex:0] isKindOfClass:[NSString class]])
        show = [[schedFromJSON objectAtIndex:indexPath.section+1] objectAtIndex:indexPath.row];
    else
        show = [[schedFromJSON objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([namesOfPodcasts containsObject:show.name])
        [self performSegueWithIdentifier:@"ShowSelect" sender:self];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowSelect"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ShowsPodcastsViewController *showsPVC = (ShowsPodcastsViewController *)[segue destinationViewController];
        Show *show;
        if ([[schedFromJSON objectAtIndex:0] isKindOfClass:[NSString class]])
            show = [[schedFromJSON objectAtIndex:indexPath.section+1] objectAtIndex:indexPath.row];
        else
            show = [[schedFromJSON objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        showsPVC.show = [showArray objectAtIndex:[namesOfPodcasts indexOfObject:show.name]];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        [[segue destinationViewController] setHidesBottomBarWhenPushed:YES];
        if ([[segue identifier] isEqualToString:@"AppOpens"]) {
            PlayerViewController *playerViewC = [segue destinationViewController];
            playerViewC.urlString = @"http://kdic.grinnell.edu:8001/kdic128.m3u";
        }
    }
}

#pragma mark UIAlertViewDelegate Methods
// Called when an alert button is tapped.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    return;
}

- (void)showNoNetworkAlert {
    UIAlertView *network = [[UIAlertView alloc]
                            initWithTitle:@"No Network Connection"
                            message:@"Turn on cellular data or use Wi-Fi to access the server"
                            delegate:self
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil
                            ];
    [network show];
}

#pragma mark - Custom methods
- (NSString *)formatTime:(Show *)show {
    if (24 == show.start)
        return [NSString stringWithFormat:@"12 A.M. - %d A.M. CT", show.end - 24];
    else if (24 < show.start)
        return [NSString stringWithFormat:@"%d A.M. - %d A.M. CT", show.start - 24, show.end - 24];
    else if (24 == show.end)
        return [NSString stringWithFormat:@"%d P.M. - 12 A.M. CT", show.start - 12];
    else if (24 < show.end)
        return [NSString stringWithFormat:@"%d P.M. - %d A.M. CT", show.start - 12, show.end - 24];
    else
        return [NSString stringWithFormat:@"%d P.M. - %d P.M. CT", show.start - 12, show.end - 12];
}

//Method to determine the availability of network Connections using the Reachability Class
- (BOOL)networkCheck {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return (!(networkStatus == NotReachable));
}

- (void)getShowsWithPodcasts {
    showArray = [[NSMutableArray alloc] init];
    namesOfPodcasts = [[NSMutableArray alloc] init];
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
                
                HTMLStringParser *sp = [[HTMLStringParser alloc] init];
                showString = [sp removeHTMLTags:showString];
                
                start = [showString rangeOfString:@"\">"];
                
                NSString *showURL = [showString substringToIndex:start.location];
                NSString *showName = [showString substringFromIndex:start.location + start.length];
                
                Show *show = [[Show alloc] init];
                show.name = showName;
                show.url = [NSURL URLWithString:showURL];
                
                [showArray addObject:show];
                [namesOfPodcasts addObject:show.name];
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

- (void)getSchedule {
    NSURL *scheduleURL = [NSURL URLWithString:@"http://tcdb.grinnell.edu/apps/glicious/KDIC/schedule.json"];
    NSData *data = [NSData dataWithContentsOfURL:scheduleURL];
    
    // FOR TESTING
    //   NSString *path = [[NSBundle mainBundle] pathForResource:@"schedule" ofType:@"json"];
    //   data = [NSData dataWithContentsOfFile:path];
    
    NSError *error;
    jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSWeekdayCalendarUnit | NSHourCalendarUnit fromDate:[NSDate date]];
    NSUInteger wkday = [comps weekday];
    int weekday = (int)wkday;
    NSUInteger hour = [comps hour];
    schedFromJSON = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", nil];
    
    appDel.currentShow = NULL;
    
    NSDictionary *sched = jsonDict;
    for (NSString *day in sched) {
        NSArray *showsInDay = [sched objectForKey:day];
        int dayInt = 1 - weekday;
        if ([day isEqualToString:@"Monday"])
            dayInt = 2 - weekday;
        else if ([day isEqualToString:@"Tuesday"])
            dayInt = 3 - weekday;
        else if ([day isEqualToString:@"Wednesday"])
            dayInt = 4 - weekday;
        else if ([day isEqualToString:@"Thursday"])
            dayInt = 5 - weekday;
        else if ([day isEqualToString:@"Friday"])
            dayInt = 6 - weekday;
        else if ([day isEqualToString:@"Saturday"])
            dayInt = 7 - weekday;
        if (0 > dayInt) {
            dayInt = 7 + dayInt;
        }
        NSMutableArray *todaysShows = [[NSMutableArray alloc] init];
        NSMutableArray *aWeekFromTodaysShows = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < showsInDay.count; i++) {
            Show *show = [[Show alloc] init];
            NSDictionary *actualShow = [showsInDay objectAtIndex:i];
            show.name = [actualShow objectForKey:@"name"];
            show.day = day;
            show.url = [NSURL URLWithString:[actualShow objectForKey:@"url"]];
            show.start = [[actualShow objectForKey:@"start_time"] integerValue];
            show.end = [[actualShow objectForKey:@"end_time"] integerValue];
            show.isPodcast = [namesOfPodcasts containsObject:show.name];
            if (0 == dayInt) {
                if (show.end <= hour) {
                    dayBegan = YES;
                    [aWeekFromTodaysShows addObject:show];
                }
                else if (show.start <= hour) {
                    dayBegan = YES;
                    appDel.currentShow = show;
                    [todaysShows addObject:show];
                }
                else [todaysShows addObject:show];
            }
            else
                [todaysShows addObject:show];
        }
        if (0 == dayInt && 0 != aWeekFromTodaysShows.count) {
            if (0 != todaysShows.count) {
                [schedFromJSON setObject:todaysShows atIndexedSubscript:0];
                [schedFromJSON setObject:aWeekFromTodaysShows atIndexedSubscript:7];
            }
            else {
                [schedFromJSON setObject:aWeekFromTodaysShows atIndexedSubscript:7];
            }
        }
        else {
            [schedFromJSON setObject:todaysShows atIndexedSubscript:dayInt];
        }
    }
    // Make sure there isn't currently a late night show
    if (!dayBegan) {
        NSMutableArray *lastNightsShows = [schedFromJSON objectAtIndex:6];
        NSMutableArray *thisMorningsShows = [[NSMutableArray alloc] init];
        for (Show *show in lastNightsShows) {
            int start = show.start;
            int end = show.end;
            if (24 <= end) {
                if (24 >= start)
                    start = 0;
                else
                    start -= 24;
                end -= 24;
                
                if (start <= hour && end > hour) {
                    dayBegan = YES;
                    appDel.currentShow = show;
                    [thisMorningsShows addObject:show];
                }
                else if (start > hour) {
                    dayBegan = YES;
                    [thisMorningsShows addObject:show];
                }
            }
        }
        if (0 != thisMorningsShows.count) {
            [schedFromJSON insertObject:thisMorningsShows atIndex:0];
            [lastNightsShows removeObjectsInArray:thisMorningsShows];
        }
    }
    [self setNextShow];
}

- (void)setNextShow {
    Show *show;
    if ([[schedFromJSON objectAtIndex:0] isKindOfClass:[NSString class]])
        show = [[schedFromJSON objectAtIndex:1] objectAtIndex:0];
    else
        show = [[schedFromJSON objectAtIndex:0] objectAtIndex:0];
    appDel.nextShow = show;
}

- (IBAction)triggerTimer:(id)sender {
    // Set up screen updates on the hour
    NSTimer *timer = [NSTimer timerWithTimeInterval:3600.0f target:self selector:@selector(updateSchedule:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [self updateSchedule:sender];
}

- (void) updateSchedule:(id)sender {
    [self getSchedule];
    [self reloadInputViews];
}

@end
