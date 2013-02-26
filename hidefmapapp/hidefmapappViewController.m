//
//  hidefmapappViewController.m
//  hidefmapapp
//
//  Created by Yingru Cheng on 2/23/13.
//  Copyright (c) 2013 Yingru Cheng. All rights reserved.
//

#import "hidefmapappViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <FacebookSDK/FacebookSDK.h>

@interface hidefmapappViewController ()

@end

@implementation hidefmapappViewController{
    GMSMapView *mapView_;
}

@synthesize displayButton;
@synthesize loadIndicator;

static const double lat = 39.750655;
static const double lgt =  -104.999127;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    //start location manager to get current location or in .gpx, but this case, the location is hardcoded
    /*self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = 50;
    [self.locationManager startUpdatingLocation];
     */
    
    [self.displayButton setEnabled:NO];
    [self.loadIndicator startAnimating];
    myLocation = CLLocationCoordinate2DMake(lat,lgt);
    
    [self showmap];
    [self.loadIndicator stopAnimating];
    [self.displayButton setEnabled:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//only for portrait orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
    [_requestConnection cancel];
}
/*
//get current location, show googel map
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //validate all inputs: not empty
    CLLocation* location = [locations lastObject];
    [self.locationManager stopUpdatingLocation];
    myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);

    //show map view for current location
    [self showmap];
    [self.loadIndicator stopAnimating];
    [self.displayButton setEnabled:YES];

}
*/

//"display locations" clicked
- (IBAction)sendRequest:(id)sender {
    
    [self.view bringSubviewToFront:self.loadIndicator];
    [self.loadIndicator startAnimating];
    [self.displayButton setEnabled:NO];

    if (!FBSession.activeSession.isOpen)
    {
        
        [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
            
            [self sessionStateChanged:session state:state error:error];
        }];
        
     }
   else
   {
       //search places
       [self searchplaces];
   }
 }

//search places around current location
-(void)searchplaces
{
    //request
    FBRequest *request = [FBRequest requestForPlacesSearchAtCoordinate:myLocation radiusInMeters:50000 resultsLimit:10000 searchText:nil];
    //connection
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    
    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        // output the results of the request
        [self requestCompleted:connection  result:result error:error];
    };
    
    //send request
    [connection addRequest:request completionHandler:handler];
    [connection start];
}

//FBSession activesession state change
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            //session opened, starting searching places
            [self searchplaces];
            break;
        case FBSessionStateClosed:
            break;
        case FBSessionStateClosedLoginFailed:
            break;
        default:
            break;
    }
 
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

//FBRequest completed
- (void)requestCompleted:(FBRequestConnection *)connection
                   result:(id)result
                   error:(NSError *)error {
    // not the completion we were looking for...
    if (self.requestConnection &&
        connection != self.requestConnection) {
        return;
    }
    
    // clean this up, for posterity
    self.requestConnection = nil;
    
    //show 25 places: remove previuos 25 first
    [mapView_ clear];
    [self updatemap:result];
 
}

//show google map
-(void)showmap
{
    //init mapview
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:myLocation.latitude
                                                            longitude:myLocation.longitude
                                                             zoom:14];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height*0.65) camera:camera];
    mapView_.myLocationEnabled = YES;
    [self.view addSubview:mapView_];
    GMSMarkerOptions *options = [[GMSMarkerOptions alloc] init];
    options.position = CLLocationCoordinate2DMake( myLocation.latitude,myLocation.longitude);
    options.title = @"You are here";
    [mapView_ addMarkerWithOptions:options];
}

//pick and show 25 places randomly from results
-(void)updatemap:(id)places
{
    NSMutableArray *returnedLocations = [places objectForKey:@"data"];
    long count = returnedLocations.count;
    //randomly pick 25 places
    for (int i=0; i<25;i++){
        int index = arc4random()%count;
        FBGraphObject<FBGraphPlace> *loc = [returnedLocations objectAtIndex:index];    
        NSNumber *lat = [loc.location latitude];
        NSNumber *longt = [loc.location longitude];
        GMSMarkerOptions *options = [[GMSMarkerOptions alloc] init];
        options.position = CLLocationCoordinate2DMake([lat doubleValue], [longt doubleValue]);
        options.title = loc.name;
        
        [mapView_ addMarkerWithOptions:options];
    }
    [self.loadIndicator stopAnimating];
    [self.displayButton setEnabled:YES];

    return;
}

@end
