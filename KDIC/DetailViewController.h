//
//  DetailViewController.h
//  KDIC
//
//  Created by Colin Tremblay on 11/20/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextView *textView;

- (IBAction)done;

@end
