#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "BaseVC.h"
#import <FBAnnotationClustering/FBAnnotationClustering.h>
@interface LocationVC : BaseVC<UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate, FBClusteringManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *locationTable;

@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIButton *btnCountry;
@property (weak, nonatomic) IBOutlet UIButton *btnState;
@property (weak, nonatomic) IBOutlet UIButton *btnLocal;

@property (strong, nonatomic) UIActivityIndicatorView* spinner;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (retain) CLLocation * currentLocation;
@property (strong,nonatomic) NSMutableArray * locationArray;
@property (strong,nonatomic )AppDelegate * mainDelegate;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) NSInteger displayItemCount;
- (IBAction)listButtonTapped:(id)sender;
- (IBAction)mapButtonTapped:(id)sender;
@property (nonatomic) bool fromSlider, refreshed;
@property (nonatomic) User * user;
@end
