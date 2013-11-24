//
//  ShowsPodcastsViewController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/12/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "ShowsPodcastsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"
#import "PlayerViewController.h"
#import "HTMLStringParser.h"

@interface ShowsPodcastsViewController ()

@end

@implementation ShowsPodcastsViewController

@synthesize show, podcastsArray;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    podcastsArray = [[NSMutableArray alloc] init];
    @try{
        NSString *post =[[NSString alloc] initWithFormat:@""];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:show.url];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/html" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *response = nil;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if([response statusCode] >= 200 && [response statusCode] < 300){
            NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
            
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
                
                HTMLStringParser *sp = [[HTMLStringParser alloc] init];
                podcastString = [sp removeHTMLTags:podcastString];

                start = [podcastString rangeOfString:@"\">"];
                NSString *pageURL = [podcastString substringToIndex:start.location];
                NSString *podcastTitle = [podcastString substringFromIndex:start.location + start.length];

                end = [pageURL rangeOfString:@"\" rel=" options:NSCaseInsensitiveSearch];
                pageURL = [pageURL substringToIndex:end.location];
                
                Podcast *podcast = [[Podcast alloc] init];
                podcast.title = podcastTitle;
                podcast.pageURL = pageURL;
                podcast.show = show.name;
                
                start = [responseData rangeOfString:[NSString stringWithFormat:@"<a href=\"%@", pageURL] options:NSCaseInsensitiveSearch];
                if (NSNotFound != start.location){
                    NSString *imgURL = [responseData substringFromIndex:start.location];
                    start = [imgURL rangeOfString:@"src=\""];
                    end = [imgURL rangeOfString:@"\" class="];
                    start.location += start.length;
                    start.length = end.location - start.location;
                    imgURL = [imgURL substringWithRange:start];
                    podcast.imageURL = imgURL;
                }
                else podcast.imageURL = NULL;
                
                [podcastsArray addObject:podcast];
                
                start = [temp rangeOfString:@"<h2 class=\"post-title\">" options:NSCaseInsensitiveSearch];
                if (NSNotFound != start.location)
                    temp = [temp substringFromIndex:start.location + start.length];
            }
        }
        else NSLog(@"Error: Response Code is %ld", (long)[response statusCode]);
    }
    @catch (NSException *e) {
        NSLog(@"Error getting image: %@", e);
    }
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
    return podcastsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PodcastCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Podcast *podcast = [podcastsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = podcast.title;
    if (NULL != podcast.imageURL)
        [cell.imageView setImageWithURL:[NSURL URLWithString:podcast.imageURL] placeholderImage:[UIImage imageNamed:@"icon-40"]];
    else cell.imageView.image = NULL;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // GET STREAM URL
        //Visit page URL, find stream url
    Podcast *podcast = [podcastsArray objectAtIndex:indexPath.row];
    @try{
        NSString *post =[[NSString alloc] initWithFormat:@""];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:podcast.pageURL]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/html" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *response = nil;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if([response statusCode] >= 200 && [response statusCode] < 300){
            NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
            
            NSRange range = [responseData rangeOfString:@"<meta property='og:description' content='" options:NSCaseInsensitiveSearch];
            if (NSNotFound != range.location) {
                NSString *description = [responseData substringFromIndex:range.location + range.length];
                range = [description rangeOfString:@"' />"];
                description = [description substringToIndex:range.location];
                range = [description rangeOfString:@"Audio clip: Adobe"];
                if (NSNotFound != range.location)
                    description = [description substringToIndex:range.location];
                
                HTMLStringParser *sp = [[HTMLStringParser alloc] init];
                description = [sp removeHTMLTags:description];

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
        }
        else NSLog(@"Error: Response Code is %ld", (long)[response statusCode]);
    }
    @catch (NSException *e) {
        NSLog(@"Error getting image: %@", e);
    }

    [self performSegueWithIdentifier:@"PlayPodcast" sender:self];
}

#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[segue destinationViewController] setHidesBottomBarWhenPushed:YES];
    if ([[segue identifier] isEqualToString:@"PlayPodcast"]){
        PlayerViewController *playerVC = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Podcast *podcast = [podcastsArray objectAtIndex:indexPath.row];
        AppDelegate *appDel = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        appDel.podcast = podcast;
        playerVC.urlString = podcast.streamURL;
    }
}

@end
