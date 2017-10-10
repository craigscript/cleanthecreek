#import "LocationVC.h"
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
#import "MainTabNav.h"

@interface LocationVC()
@property (nonatomic,strong) UIRefreshControl * refreshControl;
@property (nonatomic,strong) CustomInfiniteIndicator *infiniteIndicator;
@property(strong,nonatomic) Location * annotationLocation;

@property (strong, nonatomic) NSMutableDictionary* annotationArray;
@property (nonatomic, strong) FBClusteringManager *clusteringManager;
@end


@implementation LocationVC

- (void)viewDidLoad{
    [super viewDidLoad];
    [_locationManager requestWhenInUseAuthorization];
    _locationManager=[[CLLocationManager alloc] init];
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined)
        [_locationManager requestWhenInUseAuthorization];
    
    _locationManager.delegate=self;
    _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 500.f;
    self.locationManager=_locationManager;
    if([CLLocationManager locationServicesEnabled]){
        [self.locationManager startUpdatingLocation];
    }
    else{
        
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.locationArray = [[NSMutableArray alloc]init];
    [self.locationArray removeAllObjects];
    self.mapView.delegate=self;
    self.mapView.showsUserLocation=YES;
    //self.mapView.mapType = MKMapTypeSatellite;
    self.mainDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.locationTable addSubview:self.refreshControl];
    self.displayItemCount = 8;
    self.defaults = [NSUserDefaults standardUserDefaults];
    self.current_user_id = [self.defaults objectForKey:@"user_id"];
    [self.refreshControl addTarget:self action:@selector(updateData) forControlEvents:UIControlEventValueChanged];
    self.locationTable.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    self.infiniteIndicator = [[CustomInfiniteIndicator alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.clusteringManager = [[FBClusteringManager alloc] initWithAnnotations:[self.annotationArray allValues]];
    self.clusteringManager.delegate = self;
    self.locationTable.infiniteScrollIndicatorView = self.infiniteIndicator;
    self.defaults = [NSUserDefaults standardUserDefaults];
    [self.locationTable addInfiniteScrollWithHandler:^(UITableView* tableView) {
        self.displayItemCount += 10;
        self.displayItemCount = MIN(self.locationArray.count,self.displayItemCount);
        [self.infiniteIndicator startAnimating];
        [tableView reloadData];
        [tableView finishInfiniteScroll];
    }];
   
}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"LocationVC"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    self.mainDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    if([self.defaults objectForKey:@"user_id"])
        [self.tabBarController.tabBar setHidden:NO];
    else
        [self.tabBarController.tabBar setHidden:YES];
    
    [self.refreshControl beginRefreshing];
    [self updateData];
    if (self.locationTable.contentOffset.y == 0) {
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
            
            self.locationTable.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
            
        } completion:^(BOOL finished){
            
        }];
        
    }
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma TableViewDelegate Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    long count = 0;
    if(section==0)
        count = 1;
    else if(section==1)
    {
        count=0;
        if([self.locationArray count]>0)
            count = self.displayItemCount;
        
    }
    return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = nil;
    if(indexPath.section==0)
    {
        if(indexPath.row==0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"separator" forIndexPath:indexPath];
        }
    }
    else if(indexPath.section==1)
    {
        cell = (locationCell*)[tableView dequeueReusableCellWithIdentifier:@"locationCell" forIndexPath:indexPath];
        if([self.locationArray count]>0 && indexPath.row <= [self.locationArray count]-1)
        {
            Location * location=[self.locationArray objectAtIndex:indexPath.row];
            [((locationCell*)cell).locationName setText:location.location_name];
            CLLocation*exitingLocation=[[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
            CLLocationDistance distance=[exitingLocation distanceFromLocation:self.currentLocation];
            NSString * unit=@"KM";
            
            if([self.defaults objectForKey:@"measurement"])
            {
                if([[self.defaults objectForKey:@"measurement"] isEqualToString:@"miles"])
                    distance = distance/1609.344;
                else
                    distance = distance/1000.0;
                unit=[self.defaults objectForKey:@"measurement"];
            }
            else
                distance = distance/1000.0;
            NSString*distanceText=[[NSString alloc]initWithFormat:@"%.02f %@",distance,unit];
            [((locationCell*)cell).distance setText:distanceText];
            if(self.mainDelegate.locationData[location.location_id]!=nil)
            {
                ((locationCell*)cell).image.image=(UIImage*)(self.mainDelegate.locationData[location.location_id]);
            }
            
            
            UITapGestureRecognizer *viewTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClicked:)];
            viewTap.numberOfTapsRequired=1;
            UITapGestureRecognizer *viewTap2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClicked:)];
            viewTap.numberOfTapsRequired=1;
            UITapGestureRecognizer *viewTap3=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClicked:)];
            viewTap.numberOfTapsRequired=1;
            
            ((locationCell*)cell).image.tag = indexPath.row;
            ((locationCell*)cell).distance.tag = indexPath.row;
            ((locationCell*)cell).locationName.tag = indexPath.row;
            [((locationCell*)cell).image addGestureRecognizer:viewTap];
            [((locationCell*)cell).distance addGestureRecognizer:viewTap2];
            [((locationCell*)cell).locationName addGestureRecognizer:viewTap3];
            ((locationCell*)cell).image.userInteractionEnabled = YES;
            ((locationCell*)cell).distance.userInteractionEnabled = YES;
            ((locationCell*)cell).locationName.userInteractionEnabled = YES;
            
            ((locationCell*)cell).rightUtilityButtons = [self rightButtons];
        }
        ((locationCell*)cell).delegate = self;
    }
    if(!cell){
        cell=(locationCell*)[[UITableViewCell alloc]init];
    }
    
    return cell;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.9375 green:0.9375f blue:0.9375f alpha:1.0]
                                                 icon:[UIImage imageNamed:@"IconListClean"]];
    return rightUtilityButtons;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height=0;
    if(indexPath.section==0)
    {
        if(indexPath.row==0)
            height = 5;
        
    }
    else if(indexPath.section>0)
    {
        height = 81;
    }
    return height;
}

-(void)imageClicked:(id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    self.selectedIndex = gesture.view.tag;
    [self performSegueWithIdentifier:@"showLocationDetails" sender:self];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex=indexPath.row;
    [self performSegueWithIdentifier:@"showLocationDetails" sender:self];
}

-(void) fbLogin
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sign in with Facebook" message:@"In order to take a photo you must be signed in to your facebook account." preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login
         logInWithReadPermissions: @[@"public_profile",@"email"]
         fromViewController:self
         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
             if (error) {
                 NSLog(@"Process error");
             } else if (result.isCancelled) {
                 NSLog(@"Cancelled");
             }
             else
             {
                 
                 NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
                 [parameters setValue:@"id,name,location,about" forKey:@"fields"];
                 [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
                  startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                      
                      if (!error) {
                          [self.tabBarController.tabBar setHidden:NO];
                          NSLog(@"fetched user:%@  and Email : %@", result,result[@"email"]);
                          NSUserDefaults *loginInfo = [NSUserDefaults standardUserDefaults];
                          NSString *fbUsername = [[result valueForKey:@"link"] lastPathComponent];
                          [loginInfo setObject:fbUsername forKey:@"username"];
                          [loginInfo setObject:result[@"id"] forKey:@"user_id"];
                          [loginInfo setObject:result[@"name"] forKey:@"user_name"];
                          //[loginInfo setObject:result[@"email"] forKey:@"user_email"];
                          [loginInfo setObject:result[@"location"] forKey:@"user_location"];
                          [loginInfo setObject:result[@"about"] forKey:@"user_about"];
                          [loginInfo synchronize];
                          User * user_info = [User new];
                          user_info.user_id = result[@"id"];
                          
                          user_info.user_name = result[@"name"];
                          user_info.device_token = [loginInfo objectForKey:@"devicetoken"];
//                          user_info.user_email= [loginInfo objectForKey:@"user_email"];
                          user_info.user_about=[loginInfo objectForKey:@"user_about"];
                          
                          AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
                          updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorAppendSet;
                          AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
                          [[dynamoDBObjectMapper save:user_info configuration:updateMapperConfig]
                           continueWithBlock:^id(AWSTask *task) {
                               
                               if (task.result) {
                                   [self.tabBarController.tabBar setHidden:NO];
                               }
                               return nil;
                           }];
                          
                      }
                      
                  }];
             }
         }];
        
    }]];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self presentViewController:alertController animated:YES completion:nil];
    });
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if([self.locationArray count]>0)
    {
        
        Location * location=[self.locationArray objectAtIndex:self.selectedIndex];
        if([segue.identifier isEqualToString:@"showLocationDetails"])
        {
            ActivityPhotoDetailsVC* vc = (ActivityPhotoDetailsVC*)segue.destinationViewController;
            vc.location = [[Location alloc]init];
            
            vc.location = location;
            if(self.mainDelegate.locationData[location.location_id])
                vc.beforePhoto = (UIImage*)(self.mainDelegate.locationData[location.location_id]);
            vc.cleaned = NO;
            vc.fromLocationView = NO;
            
            if(location.kudos!=nil)
            {
                for(NSDictionary *kudo_gaver in location.kudos)
                {
                    if([[kudo_gaver objectForKey:@"id"] isEqualToString:self.current_user_id])
                    {
                        vc.isKudoed=YES;
                        break;
                    }
                }
            }
            
        }
        else if([segue.identifier isEqualToString:@"showMapDetails"])
        {
            ActivityPhotoDetailsVC* vc = (ActivityPhotoDetailsVC*)segue.destinationViewController;
            vc.location = self.annotationLocation;
            vc.beforePhoto = (UIImage*)(self.mainDelegate.locationData[self.annotationLocation.location_id]);
            vc.cleaned = NO;
            vc.fromLocationView = NO;
        }
        
    }
}

#pragma CLLocationDelegate

- (void) updateData
{
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    [[dynamoDBObjectMapper load:[User class] hashKey:self.current_user_id rangeKey:nil]
     continueWithBlock:^id(AWSTask *task) {
         if (task.result) {
             self.user=task.result;
            
         }
         return nil;
     }];

    self.locationArray=[[NSMutableArray alloc]init];
    self.annotationArray = [[NSMutableDictionary alloc]init];
    [self.annotationArray removeAllObjects];
    self.mainDelegate.locationData=[[NSMutableDictionary alloc] init];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.filterExpression = @"isDirty = :val";
    scanExpression.expressionAttributeValues = @{@":val":@"true"};
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.clusteringManager= [[FBClusteringManager alloc]init];
    [[dynamoDBObjectMapper scan:[Location class] expression:scanExpression] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            
            [self networkError];
            [self.refreshControl endRefreshing];
        }
        if (task.exception) {
            
            [self networkError];
            [self.refreshControl endRefreshing];
        }
        if (task.result) {
            AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
            for (int i=0;i<paginatedOutput.items.count;i++) {
                Location * location= [paginatedOutput.items objectAtIndex:i];
                if(location)
                {
                if(![self.locationArray containsObject:location])
                {
                    if(!([self.user.blocked_by containsObject:location.founder_id] || [self.user.blocked_by containsObject:location.cleaner_id]))
                        [self.locationArray addObject:location];
                }
                    
                }
                //Setting the annotation
                LocationAnnotation *annotation=[[LocationAnnotation alloc]init];
                annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
                
                if(!self.mainDelegate.locationData[location.location_id])
                {
                    
                    NSString *userImageURL = [NSString stringWithFormat:@"https://s3-ap-northeast-1.amazonaws.com/cleanthecreeks/%@%@", location.location_id,@"a"];
                    NSURL *url = [NSURL URLWithString:userImageURL];
                    
                    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        if (data) {
                            UIImage *image = [UIImage imageWithData:data];
                            if (image) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    {
                                        [self.mainDelegate.locationData setObject:image forKey:location.location_id];
                                        
                                        [self.annotationArray setObject:annotation forKey:location.location_id];
                                        
                                        [self.clusteringManager setAnnotations:[_annotationArray allValues]];
                                        
                                        // Update annotations on the map
                                        [self mapView:self.mapView regionDidChangeAnimated:NO];
                                        [self.locationTable reloadData];
                                        
                                    }
                                    
                                });
                            }
                        }
                    }];
                    [task resume];
                }
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.locationArray = (NSMutableArray*)[self.locationArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    CLLocation*locationA=[[CLLocation alloc]initWithLatitude:((Location*)a).latitude longitude:((Location*)a).longitude];
                    CLLocationDistance distanceA=[locationA distanceFromLocation:self.currentLocation];
                    
                    CLLocation*locationB=[[CLLocation alloc]initWithLatitude:((Location*)b).latitude longitude:((Location*)b).longitude];
                    CLLocationDistance distanceB=[locationB distanceFromLocation:self.currentLocation];
                    return distanceA>distanceB;
                }];
                self.displayItemCount = MIN(self.locationArray.count,self.displayItemCount);
                [self.locationTable reloadData];
                //[self.mapClusterController addAnnotations:self.annotationArray withCompletionHandler:NULL];
                [self.refreshControl endRefreshing];
                
            });
            
            
        }
        return nil;
        
    }];
    
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
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
    region.span = span;
    region.center = cLocation;
    self.currentLocation=newLocation;
    self.mainDelegate.currentLocation=newLocation;
    if(![self.refreshControl isRefreshing])
    {
        [self.refreshControl beginRefreshing];
    }
    if(!self.refreshed)
    {
        [self.mapView setRegion:region animated:YES];
        [self.mapView setShowsUserLocation:YES];
        
        self.refreshed = YES;
    }
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    [ceo reverseGeocodeLocation:self.currentLocation
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                  [self.btnCountry setTitle:placemark.country forState:UIControlStateNormal];
                  [self.btnState setTitle:[placemark.addressDictionary valueForKey:@"State"] forState:UIControlStateNormal];
                  [self.btnLocal setTitle:placemark.locality forState:UIControlStateNormal];
                  self.defaults = [NSUserDefaults standardUserDefaults];
                  
                  User * user_info = [User new];
                  user_info.user_id = [self.defaults objectForKey:@"user_id"];
                  user_info.location = placemark.locality;
                  user_info.state = [placemark.addressDictionary valueForKey:@"State"];
                  user_info.country = placemark.country;
                  user_info.latitude= newLocation.coordinate.latitude;
                  user_info.longitude= newLocation.coordinate.longitude;
                  AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
                  updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorAppendSet;
                  AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
                  [[dynamoDBObjectMapper save:user_info configuration:updateMapperConfig]
                   continueWithBlock:^id(AWSTask *task) {
                       if (task.error) {
                           NSLog(@"The request failed. Error: [%@]", task.error);
                       }
                       if (task.exception) {
                           NSLog(@"The request failed. Exception: [%@]", task.exception);
                       }
                       if (task.result) {
                           NSLog(@"user location updated");
                       }
                       return nil;
                   }];
                  
              }
     ];
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
            
        case 0:
        {
            // Delete button was pressed
            NSUserDefaults *loginInfo = [NSUserDefaults standardUserDefaults];
            if(![loginInfo objectForKey:@"user_id"])
            {
                [self fbLogin];
            }
            else
            {
                NSIndexPath *cellIndexPath = [self.locationTable indexPathForCell:cell];
                self.selectedIndex = cellIndexPath.row;
                CameraVC * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraVC"];
                Location * location = [self.locationArray objectAtIndex:self.selectedIndex];
                vc.photoTaken = NO;
                vc.dirtyPhoto=(UIImage*)(self.mainDelegate.locationData[location.location_id]);
                vc.location = [[Location alloc]init];
                vc.location = location;
                UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:vc];
                [navC.navigationBar setHidden:YES];
                [self presentViewController:navC animated:YES completion:nil];
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [[NSOperationQueue new] addOperationWithBlock:^{
        double scale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
        NSArray *annotations = [self.clusteringManager clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:scale];
        
        [self.clusteringManager displayAnnotations:annotations onMapView:mapView];
    }];
    
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
        if ([annotation isKindOfClass:[FBAnnotationCluster class]]) {
            FBAnnotationCluster *cluster = (FBAnnotationCluster *)annotation;
            cluster.title = [NSString stringWithFormat:@"%lu", (unsigned long)cluster.annotations.count];
            NSMutableArray * clusterArray = [[NSMutableArray alloc]initWithArray:cluster.annotations];
            LocationAnnotation * ann = (LocationAnnotation*) clusterArray[0];
            NSString *location_id = [NSString stringWithFormat:@"%f,%f",
                                     ann.coordinate.latitude, ann.coordinate.longitude];
            annotationView.image =[PhotoDetailsVC scaleImage:self.mainDelegate.locationData[location_id] toSize:CGSizeMake(50.0,50.0)];
            annotationView.canShowCallout = NO;
        }
        else {
            NSString *location_id = [NSString stringWithFormat:@"%f,%f",
                                     annotation.coordinate.latitude, annotation.coordinate.longitude];
            annotationView.image =[PhotoDetailsVC scaleImage:self.mainDelegate.locationData[location_id] toSize:CGSizeMake(50.0,50.0)];
            annotationView.canShowCallout = NO;
        }
        
        return annotationView;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    CLLocationCoordinate2D coordinate=[view.annotation coordinate];
    NSString * location_id=[NSString stringWithFormat:@"%f,%f",coordinate.latitude,coordinate.longitude];
    self.annotationLocation=[[Location alloc]init];
    for(Location * loc in self.locationArray)
    {
        if([loc.location_id isEqualToString:location_id])
        {
            self.annotationLocation = loc;
            break;
        }
    }
    if(view.annotation !=mapView.userLocation && self.annotationLocation.location_id)
        [self performSegueWithIdentifier:@"showMapDetails" sender:self];
    NSLog(@"annotation");
}

- (IBAction)listButtonTapped:(id)sender{
    [self.refreshControl beginRefreshing];
    [self updateData];
    [self.locationTable setHidden:NO];
    [self.mapView setHidden:YES];
    [self.mapButton setImage:[UIImage imageNamed:@"HeaderMapBtnUnselected"] forState:UIControlStateNormal];
    [self.listButton setImage:[UIImage imageNamed:@"HeaderMenuBtnSelected"] forState:UIControlStateNormal];
    [self.view bringSubviewToFront:self.locationTable];
}

- (IBAction)mapButtonTapped:(id)sender{
    [self updateData];
    [self.locationTable setHidden:YES];
    [self.mapView setHidden:NO];
    [self.mapButton setImage:[UIImage imageNamed:@"HeaderMapBtnSelected"] forState:UIControlStateNormal];
    [self.listButton setImage:[UIImage imageNamed:@"HeaderMenuBtnUnselected"] forState:UIControlStateNormal];
    [self.view bringSubviewToFront:self.mapView];
}

@end
