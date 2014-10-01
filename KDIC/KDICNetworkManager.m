//
//  KDICNetworkManager.m
//  KDIC
//
//  Created by Tremblay on 9/30/14.
//  Copyright (c) 2014 Colin Tremblay. All rights reserved.
//

#import "KDICNetworkManager.h"
#import <Reachability.h>

NSString * const KDIC_URL = @"http://kdic.grinnell.edu";
NSString * const LIVE_STREAM_URL = @"http://kdic.grinnell.edu:8001/kdic128.m3u";
NSString * const KDIC_ABOUT_URL = @"http://kdic.grinnell.edu/about-us/";
NSString * const KDIC_SCHEDULE_URL = @"http://tcdb.grinnell.edu/apps/glicious/KDIC/schedule.json";

@implementation KDICNetworkManager

+ (BOOL)networkCheck {
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {
        [[[UIAlertView alloc] initWithTitle:@"No Network Connection" message:@"Turn on cellular data or use Wi-Fi to access the server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
    
    Reachability *kdicReachability = [Reachability reachabilityWithHostname:KDIC_URL];
    NetworkStatus kdicStatus = [kdicReachability currentReachabilityStatus];
    if (kdicStatus == NotReachable) {
        [[[UIAlertView alloc] initWithTitle:@"No Connection to KDIC" message:@"We're sorry, but the connection to kdic.grinnell.edu does not seem to be working" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
    
    return YES;
}

+ (NSMutableURLRequest *)urlRequestWithURL:(NSURL *)url {
    NSString *post =[[NSString alloc] initWithFormat:@""];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)postData.length];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/html" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    return request;
}

+ (NSMutableURLRequest *)urlRequestWithURLString:(NSString *)urlString {
    return [self urlRequestWithURL:[NSURL URLWithString:urlString]];
}

@end
