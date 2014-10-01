//
//  Show.m
//  KDIC
//
//  Created by Colin Tremblay on 11/3/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "Show.h"

@interface Show ()
@property (nonatomic, strong) NSString *formattedTime;
@end

@implementation Show

@synthesize name, day, start, end, url, isPodcast, description;

- (NSString *)formatTime {
    if (!self.formattedTime) {
        
        if (24 == self.start) {
            self.formattedTime = [NSString stringWithFormat:@"12 A.M. - %d A.M. CT", self.end - 24];
        } else if (24 < self.start) {
            self.formattedTime = [NSString stringWithFormat:@"%d A.M. - %d A.M. CT", self.start - 24, self.end - 24];
        } else if (24 == self.end) {
            self.formattedTime = [NSString stringWithFormat:@"%d P.M. - 12 A.M. CT", self.start - 12];
        } else if (24 < self.end) {
            self.formattedTime = [NSString stringWithFormat:@"%d P.M. - %d A.M. CT", self.start - 12, self.end - 24];
        } else {
            self.formattedTime = [NSString stringWithFormat:@"%d P.M. - %d P.M. CT", self.start - 12, self.end - 12];
        }
    }
    return self.formattedTime;
}

@end
