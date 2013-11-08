//
//  ScheduleViewController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/3/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "AppDelegate.h"
#import "ScheduleViewController.h"
#import <Reachability.h>

@interface ScheduleViewController ()

@end

@implementation ScheduleViewController

@synthesize cellIdentifier, jsonDict, dayBegan, schedFromJSON, currentShow;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AppDelegate *appDel = [UIApplication sharedApplication].delegate;
    UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, appDel.window.frame.size.width, 20)];
    statusView.backgroundColor = [UIColor whiteColor];
    [appDel.window addSubview:statusView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    cellIdentifier = @"ScheduleCell";
    if (self.networkCheck){
        NSURL *scheduleURL = [NSURL URLWithString:@"http://tcdb.grinnell.edu/apps/glicious/KDIC/schedule.json"];
        NSData *data = [NSData dataWithContentsOfURL:scheduleURL];
        
        NSError *error;
        jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *comps = [cal components:NSWeekdayCalendarUnit | NSHourCalendarUnit fromDate:[NSDate date]];
        NSUInteger wkday = [comps weekday];
        int weekday = (int)wkday;
        NSUInteger hour = [comps hour];
        //NSLog(@"%lu", (unsigned long)hour);
        // Sunday = 1
        schedFromJSON = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", nil];
        
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
                show.start = [[actualShow objectForKey:@"start_time"] integerValue];
                show.end = [[actualShow objectForKey:@"end_time"] integerValue];
                if (0 == dayInt) {
                    if (show.end <= hour) {
                        dayBegan = YES;
                        [aWeekFromTodaysShows addObject:show];
                    }
                    else if (show.start <= hour) {
                        dayBegan = YES;
                        currentShow = show;
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
                        currentShow = show;
                        [thisMorningsShows addObject:show];
                    }
                    else if (start > hour) {
                        dayBegan = YES;
                        [thisMorningsShows addObject:show];
                    }
                }
                else
                    ;
                
            }
            if (0 != thisMorningsShows.count) {
                [schedFromJSON insertObject:thisMorningsShows atIndex:0];
                [lastNightsShows removeObjectsInArray:thisMorningsShows];
            }
        }
    }
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
    
    cell.textLabel.text = show.name;
    cell.detailTextLabel.text = [self formatTime:show];
    // Configure the cell...
    
    return cell;
}

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
@end
