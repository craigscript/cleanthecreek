#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "BaseVC.h"
#import "Location.h"
#import <FBAnnotationClustering/FBAnnotationClustering.h>
@interface MapVC : BaseVC<MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIButton *btnCountry;
@property (weak, nonatomic) IBOutlet UIButton *btnState;
@property (weak, nonatomic) IBOutlet UIButton *btnLocal;
- (IBAction)backClicked:(id)sender;


@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong,nonatomic) Location*  currentLocation;
@property UIImage * currentImage;
@property (strong,nonatomic )AppDelegate * mainDelegate;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;



@end
