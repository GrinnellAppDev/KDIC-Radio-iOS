//
//  ScheduleViewController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/3/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "AppDelegate.h"
#import "ScheduleViewController.h"
#import "Show.h"

@interface ScheduleViewController ()

@end

@implementation ScheduleViewController

@synthesize cellIdentifier, jsonDict, dayBegan, schedFromJSON;

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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"schedule" ofType:@"json"];
    NSData  *data = [NSData dataWithContentsOfFile:path];
    
    NSError *error;
    jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    NSUInteger weekday = [comps weekday];
    // Sunday = 1
    
    NSDictionary *sched = jsonDict;
    
    schedFromJSON = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", @"", @"", nil];

    for (NSString *day in sched) {
        NSArray *showsInDay = [sched objectForKey:day];
        int dayInt = 0;
        if ([day isEqualToString:@"Monday"])
            dayInt = 1;
        else if ([day isEqualToString:@"Tuesday"])
            dayInt = 2;
        else if ([day isEqualToString:@"Wednesday"])
            dayInt = 3;
        else if ([day isEqualToString:@"Thursday"])
            dayInt = 4;
        else if ([day isEqualToString:@"Friday"])
            dayInt = 5;
        else if ([day isEqualToString:@"Saturday"])
            dayInt = 6;
        
        NSMutableArray *todaysShows = [[NSMutableArray alloc] init];
        for (int i = 0; i < showsInDay.count; i++) {
            Show *show = [[Show alloc] init];
            NSDictionary *actualShow = [showsInDay objectAtIndex:i];
            show.name = [actualShow objectForKey:@"name"];
            show.day = day;
            show.start = [[actualShow objectForKey:@"start_time"] integerValue];
            show.end = [[actualShow objectForKey:@"end_time"] integerValue];
            [todaysShows addObject:show];
        }
        [schedFromJSON setObject:todaysShows atIndexedSubscript:dayInt];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (dayBegan)
        return 8;
    else
        return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[schedFromJSON objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    Show *show = [[schedFromJSON objectAtIndex:section] objectAtIndex:0];
    return show.day;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView registerNib:[UINib nibWithNibName:@"ScheduleCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
    Show *show = [[schedFromJSON objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *timeStr;
    
    if (24 == show.start)
        timeStr = [NSString stringWithFormat:@"12 A.M. - %d A.M.", show.end - 24];
    else if (24 < show.start)
        timeStr = [NSString stringWithFormat:@"%d A.M. - %d A.M.", show.start - 24, show.end - 24];
    else if (24 == show.end)
        timeStr = [NSString stringWithFormat:@"%d P.M. - 12 A.M.", show.start - 12];
    else if (24 < show.end)
        timeStr = [NSString stringWithFormat:@"%d P.M. - %d A.M.", show.start - 12, show.end - 24];
    else
        timeStr = [NSString stringWithFormat:@"%d P.M. - %d P.M.", show.start - 12, show.end - 12];
    cell.textLabel.text = show.name;
    cell.detailTextLabel.text = timeStr;
    // Configure the cell...
    
    return cell;
}

@end
