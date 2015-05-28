//
//  SpriteViewController.h
//  PixelPlane
//

//  Copyright (c) 2014 Dario A. Safa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>

@interface SpriteViewController : UIViewController <ADBannerViewDelegate> {
ADBannerView *adView;
}

-(void)showBanner;
-(void)hidesBanner;




@end
