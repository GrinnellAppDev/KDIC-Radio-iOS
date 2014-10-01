//
//  NSString+HTMLParser.m
//  KDIC
//
//  Created by Tremblay on 9/30/14.
//  Copyright (c) 2014 Colin Tremblay. All rights reserved.
//

#import "NSString+HTMLParser.h"

@implementation NSString (HTMLParser)

- (NSString *)removeHTMLTags {
    NSString *str = [self stringByReplacingOccurrencesOfString:@"&#8217;" withString:@"'"];
    str = [str stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];
    str = [str stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    str = [str stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    str = [str stringByReplacingOccurrencesOfString:@"&#8211;" withString:@"-"];
    str = [str stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"</p>" withString:@"\n\n"];
    return str;
}

@end
