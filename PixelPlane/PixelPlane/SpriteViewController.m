//
//  SpriteViewController.m
//  PixelPlane
//
//  Created by Dario Safa on 23.05.14.
//  Copyright (c) 2014 Dario A. Safa. All rights reserved.
//
#import "SpriteViewController.h"
#import "nasdasIntro.h"
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>
#import <AVFoundation/AVFoundation.h>
#import "GameScene.h"
#import "SystemConfiguration/SystemConfiguration.h"

@interface SpriteViewController ()
@property CGRect screenRect;
@end

@implementation SpriteViewController

- (BOOL) connectedToInternet //Internet-Erreichbarkeit
{
    SCNetworkReachabilityFlags flags;
    BOOL receivedFlags;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [@"google.com" UTF8String]); //Checkt ob Google.com erreichbar ist
    receivedFlags = SCNetworkReachabilityGetFlags(reachability, &flags);
    CFRelease(reachability);
    
    if (!receivedFlags || (flags == 0) )
    {
        return FALSE; // keine Verbindung
    } else {
        return TRUE; //Google erreichbar -> Ads anzeigen
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    //Add view controller as observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"hideAd" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"showAd" object:nil];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO; // Sehr hilfreiche Einstellungen, die einem beim Debuggen helfen
    skView.showsNodeCount = NO; // // // // // // // // // //
    
    // Create and configure the scene.
    SKScene * scene = [GameScene sceneWithSize:skView.bounds.size]; //////////////////////////////////////////
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    
    
    /*adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    adView.frame = CGRectOffset(adView.frame, 0, 0.0f);
    adView.delegate=self;
    [self.view addSubview:adView];
    // Present the scene.*/ ////////////////////
    [skView presentScene:scene];
    
}

//Handle Notification
- (void)handleNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:@"hideAd"]) {
        [self hidesBanner];
    }else if ([notification.name isEqualToString:@"showAd"]) {
        [self showBanner];
    }else if ([notification.name isEqualToString:@"muteSound"])
        [self muteSound];
}




-(void)hidesBanner {
    [adView setAlpha:0];
    adView.hidden = YES;
    //NSLog(@"HIDING BANNER");
  
}


-(void)showBanner {
    
    if ([self connectedToInternet] == YES) {
        adView.hidden = NO;
        //NSLog(@"SHOWING BANNER");
        [adView setAlpha:1];
    }
    
}

-(void)muteSound {
    //NSLog(@"MUTE");

    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"quartersec" ofType:@"mp3"]];
    AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
    [player play];
}


- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
    
    
}



@end
