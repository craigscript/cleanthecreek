#import "MapVC.h"
#import "AppDelegate.h"

#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

#import <AWSS3/AWSS3.h>

#import "Location.h"
#import "locationCell.h"

#import "LocationAnnotation.h"
#import "ActivityPhotoDetailsVC.h"
#import "CameraVC.h"
#import "Clean the Creek-Bridging-Header.h"
#import <UIScrollView+InfiniteScroll.h>
#import "CustomInfiniteIndicator.h"
#import "LocationOverlayView.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#define MAP_PADDING 1.4

// we'll make sure that our minimum vertical span is about a kilometer
// there are ~111km to a degree of latitude. regionThatFits will take care of
// longitude, which is more complicated, anyway.
#define MINIMUM_VISIBLE_LATITUDE 0.01

@implementation MapVC

- (void)viewDidLoad{
    
    [super viewDidLoad];
    [_locationManager requestWhenInUseAuthorization];
    _locationManager = [[CLLocationManager alloc] init];
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined)
        [_locationManager requestWhenInUseAuthorization];
    
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 500.f;
    self.locationManager =_locationManager;
    if([CLLocationManager locationServicesEnabled]){
        [self.locationManager startUpdatingLocation];
    }
    else{
        
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.mapView.delegate=self;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"MapVC"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    self.mainDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    if([self.defaults objectForKey:@"user_id"])
        [self.tabBarController.tabBar setHidden:NO];
    else
        [self.tabBarController.tabBar setHidden:YES];
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma CLLocationDelegate

- (void) updateData
{
    LocationAnnotation *currentAnnotation=[[LocationAnnotation alloc]init];
    currentAnnotation.coordinate = CLLocationCoordinate2DMake(_currentLocation.latitude, _currentLocation.longitude);
    [self.mapView addAnnotation:currentAnnotation];
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.2;
    span.longitudeDelta = 0.2;
    CLLocationCoordinate2D cLocation;
    cLocation.latitude = newLocation.coordinate.latitude;
    cLocation.longitude = newLocation.coordinate.longitude;
   
    region.center.latitude = (newLocation.coordinate.latitude + _currentLocation.latitude) / 2;
    region.center.longitude = (newLocation.coordinate.longitude + _currentLocation.longitude) / 2;
    float maxLatitude = MAX( newLocation.coordinate.latitude, _currentLocation.latitude);
    float minLatitude = MIN( newLocation.coordinate.latitude, _currentLocation.latitude);
    float maxLongitude = MAX( newLocation.coordinate.longitude, _currentLocation.longitude);
    float minLongitude = MIN( newLocation.coordinate.longitude, _currentLocation.longitude);
    region.span.latitudeDelta = (maxLatitude - minLatitude) * MAP_PADDING;
    
    region.span.latitudeDelta = (region.span.latitudeDelta < MINIMUM_VISIBLE_LATITUDE)
    ? MINIMUM_VISIBLE_LATITUDE
    : region.span.latitudeDelta;
    
    region.span.longitudeDelta = (maxLongitude - minLongitude) * MAP_PADDING;
    
    MKCoordinateRegion scaledRegion = [self.mapView regionThatFits:region];
    [self.mapView setRegion:scaledRegion animated:YES];
    
    LocationAnnotation *currentAnnotation=[[LocationAnnotation alloc]init];
    currentAnnotation.coordinate = CLLocationCoordinate2DMake(_currentLocation.latitude, _currentLocation.longitude);
    
    [self.mapView addAnnotation:currentAnnotation];
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    [ceo reverseGeocodeLocation:newLocation
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                  NSString*locationTitle = [[NSString alloc]initWithFormat:@"%@, %@, %@",placemark.locality, [placemark.addressDictionary valueForKey:@"State"],placemark.country];
                 
                  [self.titleLabel setText:locationTitle];
              }
     ];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(LocationAnnotation * )annotation{
    if(annotation == mapView.userLocation)
    {
        MKAnnotationView *pin = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: @"VoteSpotPin"];
        if (pin == nil)
        {
            
            pin = [[MKAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"CurrentPin"] ;
        }
        else
        {
            pin.annotation = annotation;
        }
        
        [pin setImage:[UIImage imageNamed:@"Dot"]];
        pin.canShowCallout = NO;
        pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return pin;
        
    }
    else
    {
        
        static NSString *const AnnotatioViewReuseID = @"AnnotatioViewReuseID";
        LocationOverlayView *annotationView = (LocationOverlayView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotatioViewReuseID];
        
        if (!annotationView) {
            annotationView = [[LocationOverlayView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotatioViewReuseID];
        }
        
        // This is how you can check if annotation is a cluster
        annotationView.image =[PhotoDetailsVC scaleImage:self.currentImage toSize:CGSizeMake(50.0,50.0)];
        annotationView.canShowCallout = NO;
        
        
        return annotationView;
    }
}

- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
