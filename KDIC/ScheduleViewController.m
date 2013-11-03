//
//  ScheduleViewController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/3/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

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

- (void)viewDidLoad {
    [super viewDidLoad];
    cellIdentifier = @"ScheduleCell";
    NSData  *data = [NSData dataWithContentsOfFile:@"schedule.json"];
    NSError *error;
    jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    NSUInteger weekday = [comps weekday];
    NSLog(@"%d", weekday);
    
    NSDictionary *sched = jsonDict;
    
    schedFromJSON = [[NSMutableArray alloc] init];
    NSArray *shows = [[NSArray alloc] init];

    for (NSString *day in sched) {
        NSDictionary *dayDict = [sched objectForKey:day];
        NSMutableArray *todaysShows = [[NSMutableArray alloc] init];
        shows = [dayDict allKeys];
        
        for (int i = 0; i < shows.count; i++) {
            Show *show = [[Show alloc] init];
            NSDictionary *actualShow = [shows objectAtIndex:i];
            show.name = [actualShow objectForKey:@"name"];
            show.day = day;
            show.start = [[actualShow objectForKey:@"start_time"] integerValue];
            show.end = [[actualShow objectForKey:@"end_time"] integerValue];
            [todaysShows addObject:show];
        }
        [schedFromJSON addObject:todaysShows];
    }
    for (Show *show in schedFromJSON) {
        NSLog(@"%@", show.name);
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView registerNib:[UINib nibWithNibName:@"ScheduleCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}

    cell.textLabel.text = @"Show Name";
    cell.detailTextLabel.text = @"DayOfWeek, TimeOfDay";
    // Configure the cell...
    
    return cell;
}

@end
