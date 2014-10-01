//
//  ScheduleViewController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/3/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "ScheduleViewController.h"
#import "PodcastViewController.h"
#import "ShowsPodcastsViewController.h"
#import "PlayerViewController.h"
#import "NSString+HTMLParser.h"
#import "KDICNetworkManager.h"
#import "KDICMusicManager.h"
#import "KDICConstants.h"
#import "Show.h"

@interface ScheduleViewController ()
@property (nonatomic, strong) NSDictionary *jsonDict;
@property (nonatomic, assign) BOOL dayBegan;
@property (nonatomic, strong) NSMutableArray *schedFromJSON;
@property (nonatomic, strong) NSMutableArray *showArray;
@property (nonatomic, strong) NSMutableArray *namesOfPodcasts;

// TODO: This is kind of a bad idea...
@property (nonatomic, strong) PlayerViewController *playerVC;
@end

@implementation ScheduleViewController

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
    
    if ([KDICNetworkManager networkCheck]) {
        [self getShowsWithPodcasts];
        [self getSchedule];

        if (!self.playerVC) {
            self.playerVC = [[PlayerViewController alloc] initWithNibName:PLAYER_VC_NIB_NAME bundle:nil];
            [self performSegueWithIdentifier:APP_OPENS_SEGUE sender:self];
        }
    }
    
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
    if (self.dayBegan && ![self.schedFromJSON[0] isKindOfClass:[NSString class]] && ![self.schedFromJSON[7] isKindOfClass:[NSString class]]) {
        return 8;
    } else {
        return 7;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([self.schedFromJSON[0] isKindOfClass:[NSString class]]) {
        return [self.schedFromJSON[section+1] count];
    } else {
        return [self.schedFromJSON[section] count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.schedFromJSON[0] isKindOfClass:[NSString class]]) {
        Show *show = self.schedFromJSON[section+1][0];
        return show.day;
    } else {
        if ([self.schedFromJSON[section] count]) {
            Show *show = self.schedFromJSON[section][0];
            return show.day;
        }
        
        return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ScheduleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Show *show;
    if ([self.schedFromJSON[0] isKindOfClass:[NSString class]]) {
        show = self.schedFromJSON[indexPath.section+1][indexPath.row];
    } else {
        show = self.schedFromJSON[indexPath.section][indexPath.row];
    }
    
    if (show.isPodcast) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.userInteractionEnabled = YES;
    
    cell.textLabel.text = show.name;
    cell.detailTextLabel.text = [show formatTime];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Show *show;
    if ([self.schedFromJSON[0] isKindOfClass:[NSString class]]) {
        show = self.schedFromJSON[indexPath.section+1][indexPath.row];
    } else {
        show = self.schedFromJSON[indexPath.section][indexPath.row];
    }
    
    if ([self.namesOfPodcasts containsObject:show.name]) {
        [self performSegueWithIdentifier:SHOW_SELECT_SEGUE sender:self];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SHOW_SELECT_SEGUE]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ShowsPodcastsViewController *showsPVC = (ShowsPodcastsViewController *)[segue destinationViewController];
        Show *show;
        if ([self.schedFromJSON[0] isKindOfClass:[NSString class]]) {
            show = self.schedFromJSON[indexPath.section+1][indexPath.row];
        } else {
            show = self.schedFromJSON[indexPath.section][indexPath.row];
        }
        showsPVC.show = self.showArray[[self.namesOfPodcasts indexOfObject:show.name]];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        self.navigationController.navigationBar.topItem.title = @"";
        if ([segue.identifier isEqualToString:APP_OPENS_SEGUE]) {
            PlayerViewController *playerViewC = [segue destinationViewController];
            playerViewC.urlString = LIVE_STREAM_URL;
        }
    }
}

#pragma mark - Custom methods

- (void)getShowsWithPodcasts {
    [NSURLConnection sendAsynchronousRequest:[KDICNetworkManager urlRequestWithURLString:KDIC_URL] queue:NSOperationQueuePriorityNormal completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *connectionError) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)urlResponse;
        if (connectionError || response.statusCode < 200 || response.statusCode >= 400) {
            NSLog(@"Connection Error: %@\nStatus Code: %ld", connectionError.localizedDescription, (long)response.statusCode);
            return;
        }
        
        NSString *responseData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSRange start = [responseData rangeOfString:@"\">Podcasts</a>" options:NSCaseInsensitiveSearch];
        NSString *temp = [responseData substringFromIndex:start.location + start.length];
        NSRange end = [temp rangeOfString:@"</ul>" options:NSCaseInsensitiveSearch];
        temp = [temp substringToIndex:end.length + end.location];
        start = [temp rangeOfString:@"<a href=\""];
        
        self.showArray = [[NSMutableArray alloc] init];
        self.namesOfPodcasts = [[NSMutableArray alloc] init];
        
        while (NSNotFound != start.location) {
            NSString *showString = [temp substringFromIndex:start.location + start.length];
            end = [showString rangeOfString:@"</a></li>"];
            showString = [showString substringToIndex:end.location];
            
            showString = [showString removeHTMLTags];
            
            start = [showString rangeOfString:@"\">"];
            
            NSString *showURL = [showString substringToIndex:start.location];
            NSString *showName = [showString substringFromIndex:start.location + start.length];
            
            Show *show = [[Show alloc] init];
            show.name = showName;
            show.url = [NSURL URLWithString:showURL];
            
            [self.showArray addObject:show];
            [self.namesOfPodcasts addObject:show.name];
            end = [temp rangeOfString:@"</a></li>"];
            temp = [temp substringFromIndex:end.location + end.length];
            start = [temp rangeOfString:@"<a href=\""];
        }
        
        UINavigationController *tempNavC = [self.tabBarController viewControllers][1];
        PodcastViewController *podcastVC = tempNavC.childViewControllers[0];
        podcastVC.showArray = self.showArray;
    }];
}

- (void)getSchedule {
    NSURL *scheduleURL = [NSURL URLWithString:KDIC_SCHEDULE_URL];
    NSData *data = [NSData dataWithContentsOfURL:scheduleURL];
    
    // FOR TESTING
    //   NSString *path = [[NSBundle mainBundle] pathForResource:@"schedule" ofType:@"json"];
    //   data = [NSData dataWithContentsOfFile:path];
    
    // TODO: This is synchronous still
    NSError *error;
    self.jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSWeekdayCalendarUnit | NSHourCalendarUnit fromDate:[NSDate date]];
    NSInteger weekday = [comps weekday];
    NSUInteger hour = [comps hour];
    self.schedFromJSON = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", nil];
    
    KDICMusicManager *musicManager = [KDICMusicManager sharedInstance];
    musicManager.currentShow = nil;
    
    NSDictionary *sched = self.jsonDict;
    for (NSString *day in sched) {
        NSArray *showsInDay = sched[day];
        NSInteger dayInt = 1 - weekday;
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
        
        for (int i = 0; i < [showsInDay count]; i++) {
            Show *show = [[Show alloc] init];
            NSDictionary *actualShow = showsInDay[i];
            show.name = actualShow[@"name"];
            show.day = day;
            show.url = [NSURL URLWithString:actualShow[@"url"]];
            show.start = [actualShow[@"start_time"] integerValue];
            show.end = [actualShow[@"end_time"] integerValue];
            show.isPodcast = [self.namesOfPodcasts containsObject:show.name];
            if (0 == dayInt) {
                if (show.end <= hour) {
                    self.dayBegan = YES;
                    [aWeekFromTodaysShows addObject:show];
                }
                else if (show.start <= hour) {
                    self.dayBegan = YES;
                    musicManager.currentShow = show;
                    [todaysShows addObject:show];
                }
                else [todaysShows addObject:show];
            }
            else
                [todaysShows addObject:show];
        }
        if (0 == dayInt && 0 != [aWeekFromTodaysShows count]) {
            if (0 != [todaysShows count]) {
                self.schedFromJSON[0] = todaysShows;
                self.schedFromJSON[7] = aWeekFromTodaysShows;
            }
            else {
                self.schedFromJSON[7] = aWeekFromTodaysShows;
            }
        }
        else {
            self.schedFromJSON[dayInt] = todaysShows;
        }
    }
    // Make sure there isn't currently a late night show
    if (!self.dayBegan) {
        NSMutableArray *lastNightsShows = self.schedFromJSON[6];
        NSMutableArray *thisMorningsShows = [[NSMutableArray alloc] init];
        for (Show *show in lastNightsShows) {
            NSInteger start = show.start;
            NSInteger end = show.end;
            if (24 <= end) {
                if (24 >= start)
                    start = 0;
                else
                    start -= 24;
                end -= 24;
                
                if (start <= hour && end > hour) {
                    self.dayBegan = YES;
                    musicManager.currentShow = show;
                    [thisMorningsShows addObject:show];
                }
                else if (start > hour) {
                    self.dayBegan = YES;
                    [thisMorningsShows addObject:show];
                }
            }
        }
        if (0 != [thisMorningsShows count]) {
            [self.schedFromJSON insertObject:thisMorningsShows atIndex:0];
            [lastNightsShows removeObjectsInArray:thisMorningsShows];
        }
    }
    [self setNextShow];
}

- (void)setNextShow {
    Show *show;
    if ([self.schedFromJSON[0] isKindOfClass:[NSString class]]) {
        show = self.schedFromJSON[1][0];
    } else {
        show = self.schedFromJSON[0][0];
    }
    [KDICMusicManager sharedInstance].nextShow = show;
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
