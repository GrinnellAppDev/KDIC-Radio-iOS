//
//  ViewController.h
//  KDIC
//
//  Created by Lea Marolt on 10/24/12.
//  Copyright (c) 2012 Lea Marolt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *playpause;
@property (nonatomic, strong) AVPlayer *streamer;
@property (nonatomic) BOOL playing;

@end
