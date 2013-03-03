//
//  ViewController.m
//  KDIC
//
//  Created by Lea Marolt on 10/24/12.
//  Copyright (c) 2012 Lea Marolt. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property(nonatomic, strong) IBOutlet UIImageView *reflectionView;

- (UIImage *)reflectedImage:(UIImageView *)fromImage withHeight:(NSUInteger)height;

@end

@implementation ViewController

// image reflection
static const CGFloat kDefaultReflectionFraction = 0.65;
static const CGFloat kDefaultReflectionOpacity = 0.40;

@synthesize playpause, streamer, playing;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Bad way to load the stream..
    NSString *urlstr = @"http://kdic.grinnell.edu:8001/kdic128.m3u";
    NSURL *url = [NSURL URLWithString:urlstr];
    NSError *error = [NSError alloc];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    self.streamer = [[AVPlayer alloc] initWithURL:url];
    
    if (self.streamer == nil)
        NSLog(@"%@", [error description]);
    else {
        [streamer play];
        [playpause setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];

        playing = YES;
    }
    
    
    // Determine the size of the reflection to create
    NSUInteger reflectionHeight = self.imageView.bounds.size.height * kDefaultReflectionFraction;
    // Create the reflection image and assign it to the ReflectionView
    self.reflectionView.image = [self reflectedImage:self.imageView withHeight:reflectionHeight];
    self.reflectionView.alpha = kDefaultReflectionOpacity;
    
}

- (IBAction)playPauseCallback:(id)sender
{
    if (playing) {
        [streamer pause];
        [playpause setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        playing = NO;
    } else {
        [streamer play];
        [playpause setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];

        playing = YES;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}



#pragma mark - Image Reflection
// DrJid - Image Reflection Code Sample from Apple. This is what they use in iTunes and iPod Player Apps. 
CGImageRef CreateGradientImage(int pixelsWide, int pixelsHigh)
{
    CGImageRef theCGImage = NULL;
    
    // gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // create the bitmap context
    CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh,
                                                               8, 0, colorSpace, kCGImageAlphaNone);
    
    // define the start and end grayscale values (with the alpha, even though
    // our bitmap context doesn't support alpha the gradient requires it)
    CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
    
    // create the CGGradient and then release the gray color space
    CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
    CGColorSpaceRelease(colorSpace);
    
    // create the start and end points for the gradient vector (straight down)
    CGPoint gradientStartPoint = CGPointZero;
    CGPoint gradientEndPoint = CGPointMake(0, pixelsHigh);
    
    // draw the gradient into the gray bitmap context
    CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(grayScaleGradient);
    
    // convert the context into a CGImageRef and release the context
    theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
    CGContextRelease(gradientBitmapContext);
    
    // return the imageref containing the gradient
    return theCGImage;
}

CGContextRef MyCreateBitmapContext(int pixelsWide, int pixelsHigh)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create the bitmap context
    CGContextRef bitmapContext = CGBitmapContextCreate (NULL, pixelsWide, pixelsHigh, 8,
                                                        0, colorSpace,
                                                        // this will give us an optimal BGRA format for the device:
                                                        (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
    CGColorSpaceRelease(colorSpace);
    
    return bitmapContext;
}

- (UIImage *)reflectedImage:(UIImageView *)fromImage withHeight:(NSUInteger)height
{
    if(height == 0)
        return nil;
    
    // create a bitmap graphics context the size of the image
    CGContextRef mainViewContentContext = MyCreateBitmapContext(fromImage.bounds.size.width, height);
    
    // create a 2 bit CGImage containing a gradient that will be used for masking the
    // main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
    // function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
    CGImageRef gradientMaskImage = CreateGradientImage(1, height);
    
    // create an image by masking the bitmap of the mainView content with the gradient view
    // then release the  pre-masked content bitmap and the gradient bitmap
    CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, fromImage.bounds.size.width, height), gradientMaskImage);
    CGImageRelease(gradientMaskImage);
    
    // In order to grab the part of the image that we want to render, we move the context origin to the
    // height of the image that we want to capture, then we flip the context so that the image draws upside down.
    CGContextTranslateCTM(mainViewContentContext, 0.0, height);
    CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);
    
    // draw the image into the bitmap context
    CGContextDrawImage(mainViewContentContext, fromImage.bounds, fromImage.image.CGImage);
    
    // create CGImageRef of the main view bitmap content, and then release that bitmap context
    CGImageRef reflectionImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    // convert the finished reflection image to a UIImage
    UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
    
    // image is retained by the property setting above, so we can release the original
    CGImageRelease(reflectionImage);
    
    return theImage;
}


@end
