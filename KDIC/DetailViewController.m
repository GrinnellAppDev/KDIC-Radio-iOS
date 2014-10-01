//
//  DetailViewController.m
//  KDIC
//
//  Created by Colin Tremblay on 11/20/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import "DetailViewController.h"
#import "KDICNetworkManager.h"
#import "NSString+HTMLParser.h"

@interface DetailViewController ()
@property (nonatomic, weak) IBOutlet UITextView *textView;
@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.detailText) {
        self.textView.text = self.detailText;
    }
    else {
        if ([KDICNetworkManager networkCheck]) {
            [self getKDICDescription];
        }
    }
}

- (void)getKDICDescription {
    NSString *post =[[NSString alloc] initWithFormat:@""];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)postData.length];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:KDIC_ABOUT_URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/html" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:NSOperationQueuePriorityNormal completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *connectionError) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)urlResponse;
        if (connectionError || response.statusCode < 200 || response.statusCode >= 400) {
            NSLog(@"Connection Error: %@\nStatus Code: %ld", connectionError.localizedDescription, (long)response.statusCode);
            return;
        }
        
        NSString *responseData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        NSRange start = [responseData rangeOfString:@"<h1>About</h1>" options:NSCaseInsensitiveSearch];
        if (NSNotFound != start.location) {
            NSString *description = [responseData substringFromIndex:start.location + start.length];
            start = [description rangeOfString:@"If you&#"];
            description = [description substringToIndex:start.location];
            
            description = [description removeHTMLTags];
            self.textView.text = description;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
