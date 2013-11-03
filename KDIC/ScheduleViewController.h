//
//  ScheduleViewController.h
//  KDIC
//
//  Created by Colin Tremblay on 11/3/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleViewController : UITableViewController
@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) NSDictionary *jsonDict;
@property (nonatomic, assign) BOOL *dayBegan;
@property (nonatomic, strong) NSMutableArray *schedFromJSON;
@end
