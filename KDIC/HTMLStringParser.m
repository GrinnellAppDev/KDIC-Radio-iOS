//
//  HTMLStringParser.m
//  KDIC
//
//  Created by Colin Tremblay on 11/24/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "HTMLStringParser.h"

@implementation HTMLStringParser

- (NSString *)removeHTMLTags:(NSString *)str {
    str = [str stringByReplacingOccurrencesOfString:@"&#8217;" withString:@"'"];
    str = [str stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];
    str = [str stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    str = [str stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    str = [str stringByReplacingOccurrencesOfString:@"&#8211;" withString:@"-"];
    str = [str stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"</p>" withString:@"\n\n"];
    return str;
}

@end
