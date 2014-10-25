//
//  ShowsPodcastsViewController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/12/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "ShowsPodcastsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PlayerViewController.h"
#import "NSString+HTMLParser.h"
#import "KDICNetworkManager.h"
#import "KDICMusicManager.h"
#import "KDICConstants.h"
#import "Show.h"
#import "Podcast.h"

@interface ShowsPodcastsViewController ()
@property (nonatomic, strong) NSMutableArray *podcastsArray;
@end

@implementation ShowsPodcastsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.podcastsArray = [[NSMutableArray alloc] init];
    
    if (![KDICNetworkManager networkCheckForURL:self.show.url]) {
        return;
    }
    
    [NSURLConnection sendAsynchronousRequest:[KDICNetworkManager urlRequestWithURL:self.show.url] queue:NSOperationQueuePriorityNormal completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *connectionError) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)urlResponse;
        if (connectionError || response.statusCode < 200 || response.statusCode >= 400) {
            NSLog(@"Connection Error: %@\nStatus Code: %ld", connectionError.localizedDescription, (long)response.statusCode);
            return;
        }
        
        NSString *responseData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        NSRange start = [responseData rangeOfString:@"<h2 class=\"post-title\">" options:NSCaseInsensitiveSearch];
        NSString *temp;
        if (NSNotFound != start.location) {
            temp = [responseData substringFromIndex:start.location + start.length];
        }
        
        while (NSNotFound != start.location) {
            start = [temp rangeOfString:@"<a href=\"" options:NSCaseInsensitiveSearch];
            
            NSString *podcastString = [temp substringFromIndex:start.location + start.length];
            NSRange end = [podcastString rangeOfString:@"</a>" options:NSCaseInsensitiveSearch];
            podcastString = [podcastString substringToIndex:end.location];
            
            podcastString = [podcastString removeHTMLTags];
            
            start = [podcastString rangeOfString:@"\">"];
            NSString *pageURL = [podcastString substringToIndex:start.location];
            NSString *podcastTitle = [podcastString substringFromIndex:start.location + start.length];
            
            end = [pageURL rangeOfString:@"\" rel=" options:NSCaseInsensitiveSearch];
            pageURL = [pageURL substringToIndex:end.location];
            
            Podcast *podcast = [[Podcast alloc] init];
            podcast.title = podcastTitle;
            podcast.pageURL = pageURL;
            podcast.show = self.show.name;
            
            start = [responseData rangeOfString:[NSString stringWithFormat:@"<a href=\"%@", pageURL] options:NSCaseInsensitiveSearch];
            if (NSNotFound != start.location) {
                NSString *imgURL = [responseData substringFromIndex:start.location];
                start = [imgURL rangeOfString:@"src=\""];
                end = [imgURL rangeOfString:@"\" class="];
                start.location += start.length;
                start.length = end.location - start.location;
                imgURL = [imgURL substringWithRange:start];
                podcast.imageURL = imgURL;
            } else {
                podcast.imageURL = nil;
            }
            
            [self.podcastsArray addObject:podcast];
            
            start = [temp rangeOfString:@"<h2 class=\"post-title\">" options:NSCaseInsensitiveSearch];
            if (NSNotFound != start.location)
                temp = [temp substringFromIndex:start.location + start.length];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.podcastsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PodcastCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Podcast *podcast = self.podcastsArray[indexPath.row];
    cell.textLabel.text = podcast.title;
    if (podcast.imageURL) {
        UIImage *placeholder = [UIImage imageNamed:APP_ICON_THUMBNAIL];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:podcast.imageURL] placeholderImage:placeholder];
    } else {
        cell.imageView.image = nil;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // GET STREAM URL
    //Visit page URL, find stream url
    Podcast *podcast = self.podcastsArray[indexPath.row];
    
    if (![KDICNetworkManager networkCheckForURLString:podcast.pageURL]) {
        return;
    }
    
    [NSURLConnection sendAsynchronousRequest:[KDICNetworkManager urlRequestWithURLString:podcast.pageURL] queue:NSOperationQueuePriorityNormal completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *connectionError) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)urlResponse;
        if (connectionError || response.statusCode < 200 || response.statusCode >= 400) {
            NSLog(@"Connection Error: %@\nStatus Code: %ld", connectionError.localizedDescription, (long)response.statusCode);
            return;
        }
        
        NSString *responseData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        NSRange range = [responseData rangeOfString:@"<meta property='og:description' content='" options:NSCaseInsensitiveSearch];
        if (NSNotFound != range.location) {
            NSString *description = [responseData substringFromIndex:range.location + range.length];
            range = [description rangeOfString:@"' />"];
            description = [description substringToIndex:range.location];
            range = [description rangeOfString:@"Audio clip: Adobe"];
            if (NSNotFound != range.location) {
                description = [description substringToIndex:range.location];
            }
            
            description = [description removeHTMLTags];
            
            podcast.description = description;
        }
        
        range = [responseData rangeOfString:@"<a href=\"https://dl.dropbox" options:NSCaseInsensitiveSearch];
        if (NSNotFound != range.location) {
            NSString *temp = [responseData substringFromIndex:range.location];
            temp = [temp substringFromIndex:@"<a href=\"".length];
            range = [temp rangeOfString:@"\">(Right" options:NSCaseInsensitiveSearch];
            temp = [temp substringToIndex:range.location];
            podcast.streamURL = temp;
        }

        [self performSegueWithIdentifier:PLAY_PODCAST_SEGUE sender:self];
    }];
}

#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    self.navigationController.navigationBar.topItem.title = @"";
    if ([segue.identifier isEqualToString:PLAY_PODCAST_SEGUE]){
        PlayerViewController *playerVC = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Podcast *podcast = self.podcastsArray[indexPath.row];
        KDICMusicManager *musicManager = [KDICMusicManager sharedInstance];
        musicManager.podcast = podcast;
        playerVC.urlString = podcast.streamURL;
    }
}

@end
