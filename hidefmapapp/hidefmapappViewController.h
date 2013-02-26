//
//  hidefmapappViewController.h
//  hidefmapapp
//
//  Created by Yingru Cheng on 2/23/13.
//  Copyright (c) 2013 Yingru Cheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface hidefmapappViewController : UIViewController /*<CLLocationManagerDelegate>*/
{
    CLLocationCoordinate2D myLocation;
    //CLLocationManager *locationManager;
}

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;
@property (strong, nonatomic) IBOutlet UIButton *displayButton;
@property (strong, nonatomic) FBRequestConnection *requestConnection;

- (IBAction)sendRequest:(id)sender;
- (void)showmap;
-(void)updatemap:(id)places;
-(void)searchplaces;
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error;
@end
