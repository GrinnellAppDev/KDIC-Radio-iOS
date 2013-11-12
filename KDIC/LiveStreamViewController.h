//
//  LiveStreamViewController.h
//  KDIC
//
//  Created by Colin Tremblay on 11/12/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerViewController.h"

@interface LiveStreamViewController : UIViewController

@property (nonatomic, strong) PlayerViewController *playerVC;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UILabel *songLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistLabel;
@property (nonatomic, weak) IBOutlet UIImageView *albumArtView;

- (void)setLabels;

@end
