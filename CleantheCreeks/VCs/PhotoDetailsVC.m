//
//  PhotoDetails.m
//  CleantheCreeks
//
//  Created by Kimura Isoroku on 1/31/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "PhotoDetailsVC.h"
#import "DetailCell.h"
#import "CommentCell.h"
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSS3/AWSS3.h>
#import "FacebookPostVC.h"
#import "TGCameraColor.h"
@implementation PhotoDetailsVC

- (void)registerForKeyboardNotifications
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.

- (void)keyboardWasShown:(NSNotification*)aNotification

{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.detailTable.contentInset = contentInsets;
    self.detailTable.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    
    // Your app might not need or want this behavior.
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.commentView.frame.origin) ) {
        
        [self.detailTable scrollRectToVisible:self.commentView.frame animated:YES];
        CGRect commentFrame=self.commentView.frame;
        commentFrame.origin.y-=kbSize.height;
        [self.commentView setFrame:commentFrame];
    }
    NSLog(@"keyboard was shown");
}
// Called when the UIKeyboardWillHideNotification is sent

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.detailTable.contentInset = contentInsets;
    self.detailTable.scrollIndicatorInsets = contentInsets;
    NSLog(@"keyboard hidden");
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField

{
    [textField resignFirstResponder];
    return YES;
}

-(void)dismissKeyboard {
    [self.txtComment resignFirstResponder];
    [self.detailTable reloadData];
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.delegate cameraRefresh:NO];
    [self registerForKeyboardNotifications];
    
    [self.tabBarController.tabBar setHidden:YES];
    UIColor *tintColor = [UIColor colorWithRed:1/255.0 green:122/255.0 blue:1 alpha:1.0];
    [TGCameraColor setTintColor:tintColor];
    _locationManager=[[CLLocationManager alloc] init];
    self.mainDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    if(self.location==nil)
    {
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined)
            [_locationManager requestWhenInUseAuthorization];
        
        _locationManager.delegate=self;
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        _locationManager.distanceFilter=100;
        self.locationManager=_locationManager;
        
        if([CLLocationManager locationServicesEnabled]){
            
            [self.locationManager startUpdatingLocation];
        }
        else
        {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainDelegate loadData];
        });
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        
        AWSS3TransferManagerDownloadRequest *firstRequest = [AWSS3TransferManagerDownloadRequest new];
        firstRequest.bucket = @"cleanthecreeks";
        NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self.location.location_id stringByAppendingString:@"a"]];
        NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
        NSString * beforeKey=[self.location.location_id stringByAppendingString:@"a"];
        firstRequest.key = beforeKey;
        firstRequest.downloadingFileURL = downloadingFileURL;
        [[transferManager download:firstRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task2) {
            if (task2.result) {
                self.takenPhoto =[[UIImage alloc]init];
                self.takenPhoto = [UIImage imageWithContentsOfFile:downloadingFilePath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.detailTable reloadData];
                });
            }
            return nil;
        }];
    }
    if(self.secondPhototaken)
        [self.nextButton setEnabled:YES];
    else
        [self.nextButton setEnabled:NO];
    self.commentText = @"";
    self.txtComment.delegate=self;
    [self.detailTable reloadData];
    self.detailTable.estimatedRowHeight = 5.f;
    self.detailTable.rowHeight = UITableViewAutomaticDimension;
    
    // Adding shadows on the comment box
    self.commentView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.commentView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.commentView.layer.shadowRadius = 10.0f;
    self.commentView.layer.shadowOpacity = 0.9f;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([_txtComment.text length] > 255)
        return NO;
    else
        return YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.commentView.hidden= YES;
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Adding new location"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.currentLocation = newLocation;
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    [ceo reverseGeocodeLocation:self.currentLocation
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                  //NSLog(@"placemark %@",placemark);
                  //String to hold address
                  NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                  NSLog(@"addressDictionary %@", placemark.addressDictionary);
                  
                  NSLog(@"region %@",placemark.region);
                  NSLog(@"country %@",placemark.country);  // Give Country Name
                  NSLog(@"locality %@",placemark.locality); // Extract the city name
                  NSLog(@"name %@",placemark.name);
                  NSLog(@"ocean %@",placemark.ocean);
                  NSLog(@"postalcode %@",placemark.postalCode);
                  NSLog(@"sublocality%@",placemark.subLocality);
                  
                  NSLog(@"location %@",placemark.location);
                  //Print the location to console
                  NSLog(@"I am currently at %@",locatedAt);
                  self.locationName1=[placemark.addressDictionary valueForKey:@"Name"];
                  self.locationName2=placemark.locality;
                  self.countryName=placemark.country;
                  self.stateName=[placemark.addressDictionary valueForKey:@"State"];
                  [self.nextButton setEnabled:YES];
                  [self.detailTable reloadData];
              }
     ];
    
    [_locationManager stopUpdatingLocation];
}


- (UITableViewCell*)parentCellFor:(UIView*)view
{
    if (!view)
        return nil;
    if ([view isMemberOfClass:[UITableViewCell class]])
        return (UITableViewCell*)view;
    return [self parentCellFor:view.superview];
}

-(void) setSecondPhoto:(BOOL)set photo:(UIImage*)photo
{
    self.secondPhototaken = set;
    self.cleanedPhoto = [[UIImage alloc]init];
    self.cleanedPhoto = photo;
    self.cleanedDate = [[NSDate date] timeIntervalSince1970];
    [self.detailTable reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count=0;
    if(section == 0)
        count = 2;
    else if(section == 1)
    {
        if(self.secondPhototaken)
            count = 4;
        else
            count = 3;
    }
    else if(section == 2)
    {
        
        if(self.location.comments == nil)
            count = 2;
        else
            count = self.location.comments.count+2;
        
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell=[[UITableViewCell alloc]init];
    
    if(indexPath.section == 0)
    {
        if(indexPath.row==0)
            cell = [tableView dequeueReusableCellWithIdentifier:@"FirstBar"];
        else if(indexPath.row==1)
        {
            cell = (PhotoViewCell*)[tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
            [((PhotoViewCell*)cell).firstPhoto setImage:[PhotoDetailsVC scaleImage:self.takenPhoto toSize:CGSizeMake(320.0,320.0)]];
            UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhoto)];
            singleTap.numberOfTapsRequired=1;
            [((PhotoViewCell*)cell).secondPhoto setUserInteractionEnabled:YES];
            [((PhotoViewCell*)cell).secondPhoto addGestureRecognizer:singleTap];
            if(self.secondPhototaken)
                [((PhotoViewCell*)cell).secondPhoto setImage:[PhotoDetailsVC scaleImage:self.cleanedPhoto toSize:CGSizeMake(320.0,320.0)]];
            else
                [((PhotoViewCell*)cell).secondPhoto setImage:[UIImage imageNamed:@"camera"]];
            ((PhotoViewCell*)cell).delegate=self;
        }
    }
    else if(indexPath.section == 1)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *user_name = [defaults objectForKey:@"user_name"];
        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd, yyyy"];
        
        if(indexPath.row==0)
            cell = [tableView dequeueReusableCellWithIdentifier:@"SecondBar"];
        else if(indexPath.row==1)
        {
            cell = (DetailCell*)[tableView dequeueReusableCellWithIdentifier:@"FirstDetailCell"];
            if(self.location==nil)
            {
                [((DetailCell*)cell).locationName1 setText:self.locationName1];
                NSString * subLocation = [[NSString alloc]initWithFormat:@"%@, %@, %@",self.locationName2, self.stateName, self.countryName];
                [((DetailCell*)cell).locationName2 setText:subLocation];
            }
            else
            {
                [((DetailCell*)cell).locationName1 setText:self.location.location_name];
                NSString * subLocation = [[NSString alloc]initWithFormat:@"%@, %@, %@",self.location.locality, self.location.state, self.location.country];
                [((DetailCell*)cell).locationName2 setText:subLocation];
            }
            
        }
        else if(indexPath.row == 2)
        {
            cell = (DetailCell*)[tableView dequeueReusableCellWithIdentifier:@"SecondDetailCell"];
            if(self.location!=nil)
                [((DetailCell*)cell).finderName setText:self.location.found_by];
            else
                [((DetailCell*)cell).finderName setText:user_name];
            NSDate* founddate=[[NSDate alloc]initWithTimeIntervalSince1970:self.foundDate];
            [((DetailCell*)cell).foundDate setText:[dateFormatter stringFromDate:founddate]];
            
            
        }
        else if(indexPath.row==3)
        {
            cell = (DetailCell*)[tableView dequeueReusableCellWithIdentifier:@"ThirdDetailCell"];
            [((DetailCell*)cell).cleanerName setText:user_name];
            NSDate* cleanDate=[[NSDate alloc]initWithTimeIntervalSince1970:self.cleanedDate];
            [((DetailCell*)cell).cleanedDate setText:[dateFormatter stringFromDate:cleanDate]];
        }
        
    }
    else if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
            cell = [tableView dequeueReusableCellWithIdentifier:@"ThirdBar"];
        else
        {
            cell = (CommentCell*)[tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
            if(self.location!=nil && indexPath.row <= [self.location.comments count])
            {
                NSMutableDictionary *commentItem = [self.location.comments objectAtIndex:indexPath.row-1];
                
                User * commentUser = [self.mainDelegate.userArray objectForKey:[commentItem objectForKey:@"id"]];
                NSString *commentUserName = commentUser.user_name;
                
                [((CommentCell*)cell).commentLabel setAttributedText:[self generateCommentString:commentUserName content:[commentItem objectForKey:@"text"]]];
            }
            else
            {
                if(self.commentText.length > 0)
                {
                    self.defaults=[NSUserDefaults standardUserDefaults];
                    NSString *user_name = [self.defaults objectForKey:@"user_name"];
                    
                    [((CommentCell*)cell).commentLabel setAttributedText:[self generateCommentString:user_name content:self.commentText]];
                }
                else
                {
                   [((CommentCell*)cell).commentLabel setText:@"Tap to add comments"];
                    UITapGestureRecognizer *tapClean = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showComment:)];
                    tapClean.numberOfTapsRequired = 1;
                    ((CommentCell*)cell).commentLabel.userInteractionEnabled = YES;
                    [((CommentCell*)cell).commentLabel addGestureRecognizer:tapClean];
                }
                
                
            }
        }
        
    }
    if(!cell){
        cell = nil;
        
    }
    return cell;
}

-(void) takePhoto
{
    //    UIImagePickerController *picker=[[UIImagePickerController alloc] init];
    //    picker.allowsEditing = YES;
    //    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]==NO)
    //    {
    //        picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    //    }
    //    else
    //    {
    //        picker.sourceType=UIImagePickerControllerSourceTypeCamera;
    //        picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    //    }
    //    picker.delegate=self;
    //    [self.window.rootViewController presentViewController:picker animated:YES completion:nil];
    
    TGCameraNavigationController *navigationController =
    [TGCameraNavigationController newWithCameraDelegate:self];

    self.secondPhototaken = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void)showComment:(id)sender
{
    self.commentView.hidden=NO;
    [self.txtComment becomeFirstResponder];
}

- (NSMutableAttributedString *)generateCommentString:(NSString*)name content:(NSString*)content
{
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@""];
    UIColor * color1 = [UIColor colorWithRed:(1/255.0) green:(122/255.0) blue:(255/255.0) alpha:1.0];
    UIColor * color2= [UIColor colorWithRed:(51/255.0) green:(51/255.0) blue:(51/255.0) alpha:1.0];
    
    NSDictionary * attributes1 = [NSDictionary dictionaryWithObject:color1 forKey:NSForegroundColorAttributeName];
    
    NSDictionary * attributes2 = [NSDictionary dictionaryWithObject:color2 forKey:NSForegroundColorAttributeName];
    if(name!=nil)
    {
        NSAttributedString * nameStr = [[NSAttributedString alloc] initWithString:name attributes:attributes1];
        [string appendAttributedString:nameStr];
        
    }
    NSAttributedString * space = [[NSAttributedString alloc] initWithString:@" " attributes:attributes2];
    [string appendAttributedString:space];
    if(content!=nil)
    {
        NSAttributedString * middleStr = [[NSAttributedString alloc] initWithString:content attributes:attributes2];
        [string appendAttributedString:middleStr];
    }
    
    return string;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* title;
    if(section == 0)
        title = @"Photos";
    else if(section == 1)
        title = @"Details";
    else if(section == 2)
        title = @"Comments";
    return title;
}

-(void) generateNotification:(bool)mode
{
    self.defaults=[NSUserDefaults standardUserDefaults];
    NSString *user_name = [self.defaults objectForKey:@"user_name"];
    NSString *current_user_id = [self.defaults objectForKey:@"user_id"];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    NSString * attributedString;
    if(!mode)
    {
        attributedString=[NSString stringWithFormat:@"%@ found a new dirty spot %@", user_name, self.location.location_name];
        
    }
    else
    {
        attributedString=[NSString stringWithFormat:@"%@ has cleaned %@", user_name, self.location.location_name];
        
    }
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    [[dynamoDBObjectMapper scan:[User class] expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.result) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             for(User * user in paginatedOutput.items)
             {
                 if(user.device_token)
                 {
                     CLLocation* userLocation=[[CLLocation alloc]initWithLatitude:user.latitude longitude:user.longitude];
                     if(self.currentLocation==nil)
                         self.currentLocation = [[CLLocation alloc]initWithLatitude:self.location.latitude longitude:self.location.longitude];
                     CLLocationDistance distance=  [userLocation distanceFromLocation:self.currentLocation];
                     distance=distance/1000.0;
                     if(distance<100.0 || [AppDelegate isFollowed:user] || [self.location.found_by isEqualToString:current_user_id])
                         [self.mainDelegate send_notification:user message:attributedString];
                 }
             }
         }
         return nil;
     }];
}

- (IBAction)nextPage:(id)sender {
    
    if(self.secondPhototaken)
    {
        [self storeData:false];
        [self generateNotification:YES];
        [self performSegueWithIdentifier:@"cleanedFBPost" sender:self];
        
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"New Dirty Location Found!" message:@"Would you like to post this location on the map as a new dirty location with the just the before photo so others or your self can clean it up later? Or post the after clean up photo now?" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"I’ve Cleaned It Up" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            TGCameraNavigationController *navigationController =
            [TGCameraNavigationController newWithCameraDelegate:self];
            
            [self presentViewController:navigationController animated:YES completion:nil];
            self.secondPhototaken=YES;
                    }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Post New Dirty Location" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self storeData:true];
            [self generateNotification:NO];
            [self performSegueWithIdentifier:@"foundFBPost" sender:self];

        }]];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self presentViewController:alertController animated:YES completion:nil];
        });
        
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    FacebookPostVC* vc = (FacebookPostVC*)segue.destinationViewController;
    if([segue.identifier isEqualToString:@"foundFBPost"])
    {
        vc.firstPhoto=[[UIImage alloc]init];
        vc.firstPhoto=[PhotoDetailsVC scaleImage:self.takenPhoto toSize:CGSizeMake(320.0,320.0)];
        vc.secondPhoto=[[UIImage alloc]init];
        vc.secondPhoto=[UIImage imageNamed:@"CleanMe"];
        
        vc.cleaned=NO;
        vc.locationID = self.location.location_id;
    }
    else if([segue.identifier isEqualToString:@"cleanedFBPost"])
    {
        vc.firstPhoto=[[UIImage alloc]init];
        vc.firstPhoto=[PhotoDetailsVC scaleImage:self.takenPhoto toSize:CGSizeMake(320.0,320.0)];
        vc.secondPhoto=[[UIImage alloc]init];
        vc.secondPhoto=[PhotoDetailsVC scaleImage:self.cleanedPhoto toSize:CGSizeMake(320.0,320.0)];
        vc.locationID = self.location.location_id;
        vc.cleaned=YES;
    }
    
}

- (IBAction)prevPage:(id)sender {
//    UIImagePickerController *picker=[[UIImagePickerController alloc] init];
//    picker.allowsEditing = YES;
//    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]==NO)
//    {
//        picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
//    }
//    else
//    {
//        picker.sourceType=UIImagePickerControllerSourceTypeCamera;
//        picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
//    }
//    picker.delegate=self;
//    [self presentViewController:picker animated:YES completion:nil];
    TGCameraNavigationController *navigationController =
    [TGCameraNavigationController newWithCameraDelegate:self];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    //[self dismissVC];
}

-(void)storeData:(BOOL)isDirty
{
    self.mainDelegate.shouldRefreshLocation = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_name = [defaults objectForKey:@"user_name"];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    
    NSMutableArray * commentArray=[[NSMutableArray alloc] init];
    
    NSMutableDictionary *commentItem=[[NSMutableDictionary alloc]init];
    [commentItem setObject:user_id forKey:@"id"];
    double date =[[NSDate date]timeIntervalSince1970];
    if(self.commentText.length>0)
    {
        NSString *dateString=[NSString stringWithFormat:@"%f",date];
        [commentItem setObject:dateString forKey:@"time"];
        [commentItem setObject:self.commentText forKey:@"text"];
        [commentArray addObject:commentItem];
    }
    if(self.location == nil)
    {
        self.location = [Location new];
        NSString *location_id = [NSString stringWithFormat:@"%f,%f",
                                 self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
        self.location.location_id = location_id;
        self.location.location_name = self.locationName1;
        self.location.locality = self.locationName2;
        self.location.state = self.stateName;
        self.location.country = self.countryName;
        self.location.found_by = user_name;
        self.location.founder_id = user_id;
        
        self.location.found_date = self.foundDate;
        self.location.latitude = self.currentLocation.coordinate.latitude;
        self.location.longitude = self.currentLocation.coordinate.longitude;
       
    }
    if(!isDirty)
    {
        self.location.isDirty = @"false";
        self.location.cleaner_id = user_id;
        self.location.cleaner_name = user_name;
        self.location.cleaned_date = self.cleanedDate;
    }
    else
        self.location.isDirty=@"true";
    if([commentArray count] > 0)
        self.location.comments = commentArray;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    [[dynamoDBObjectMapper save:self.location]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             NSLog(@"Data updated");
         }
         return nil;
     }];
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dirtyPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@a.jpg", self.location.location_id]];
    NSString *cleanPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@b.jpg", self.location.location_id]];
    UIImage *cimage = [PhotoDetailsVC scaleImage:self.takenPhoto toSize:CGSizeMake(320.0,320.0)];
    [UIImageJPEGRepresentation(cimage, 0.8) writeToFile:dirtyPath atomically:YES];
    NSURL* dirtyURL = [NSURL fileURLWithPath:dirtyPath];
    
    UIImage* cimage2 = [PhotoDetailsVC scaleImage:self.cleanedPhoto toSize:CGSizeMake(320.0,320.0)];
    [UIImageJPEGRepresentation(cimage2,0.8) writeToFile:cleanPath atomically:YES];
    NSURL* cleanURL = [NSURL fileURLWithPath:cleanPath];
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.body = dirtyURL;
    uploadRequest.bucket = @"cleanthecreeks";
    uploadRequest.contentType = @"image/jpg";
    if(self.location==nil)
        uploadRequest.key = [NSString stringWithFormat:@"%f,%fa",
                             self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
    else
        uploadRequest.key = [NSString stringWithFormat:@"%f,%fa",
                             self.location.latitude, self.location.longitude];
    
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        break;
                        
                    default:
                        NSLog(@"Error: %@", task.error);
                        break;
                }
            } else {
                // Unknown error.
                NSLog(@"Error: %@", task.error);
            }
        }
        
        if (task.result)
        {
            NSLog(@"First photo uploaded");
        }
        return nil;
    }];
    if(self.secondPhototaken)
    {
        AWSS3TransferManagerUploadRequest *seconduploadRequest = [AWSS3TransferManagerUploadRequest new];
        seconduploadRequest.bucket = @"cleanthecreeks";
        seconduploadRequest.contentType = @"image/jpg";
        seconduploadRequest.body = cleanURL;
        if(self.location==nil)
            seconduploadRequest.key = [NSString stringWithFormat:@"%f,%fb",
                                       self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
        else
            seconduploadRequest.key = [NSString stringWithFormat:@"%f,%fb",
                                       self.location.latitude, self.location.longitude];
        [[transferManager upload:seconduploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
            if (task.error) {
                if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                    switch (task.error.code) {
                        case AWSS3TransferManagerErrorCancelled:
                        case AWSS3TransferManagerErrorPaused:
                            break;
                            
                        default:
                            NSLog(@"Error: %@", task.error);
                            break;
                    }
                } else {
                    // Unknown error.
                    NSLog(@"Error: %@", task.error);
                }
            }
            
            if (task.result) {
                NSLog(@"Second photo uploaded");
            }
            return nil;
        }];
    }
}

//-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
//{
//    NSLog(@"Photo taken");
//    UIImage * photo=[[UIImage alloc]init];
//    photo = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
//    if(self.location)
//    {
//        self.secondPhototaken=YES;
//    }
//    if(self.secondPhototaken)
//    {
//        [self setSecondPhoto:YES photo:photo];
//    }
//    else
//    {
//        self.takenPhoto = photo;
//    }
//   
//    [picker dismissViewControllerAnimated:YES completion:NULL];
//    [self.detailTable reloadData];
//}

- (void)cameraDidTakePhoto:(UIImage *)image
{
    
    if(self.location)
    {
        self.secondPhototaken=YES;
    }
    if(self.secondPhototaken)
    {
        [self setSecondPhoto:YES photo:image];
    }
    else
    {
        self.takenPhoto = image;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.detailTable reloadData];
    
}

//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    [picker dismissViewControllerAnimated:YES completion:NULL];
//    
//    if(self.secondPhototaken) //do not remove the item when it's clean mode from location view
//    {
//        if(self.location==nil)
//        {
//            self.secondPhototaken=NO; //One step backward by removing the 2nd taken photo when adding new location
//            [self setSecondPhoto:NO photo:nil];
//            
//        }
//        else  //Going back to location view when cleaning the exisitng lcoation
//        {
//           
//            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//        }
//        
//    }
//    else
//    {
//        //[self.delegate cameraRefresh:YES];
//        
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//       
//        
//    }
//}
- (void)cameraDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if(self.secondPhototaken) //do not remove the item when it's clean mode from location view
    {
        if(self.location==nil)
        {
            self.secondPhototaken=NO; //One step backward by removing the 2nd taken photo when adding new location
            [self setSecondPhoto:NO photo:nil];
            
        }
        else  //Going back to location view when cleaning the exisitng lcoation
        {
            
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        
    }
    else
    {
        //[self.delegate cameraRefresh:YES];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
        
    }
}


+(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize
{
    
    CGAffineTransform scaleTransform;
    CGPoint origin;
    
    if (image.size.width > image.size.height) {
        CGFloat scaleRatio = newSize.width / image.size.height;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(-(image.size.width - image.size.height) / 2.0f, 0);
    } else {
        CGFloat scaleRatio = newSize.width / image.size.width;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0f);
    }
    
    CGSize size = CGSizeMake(newSize.width, newSize.height);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    
    [image drawAtPoint:origin];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (IBAction)closeComment:(id)sender {
    [self dismissKeyboard];
    self.commentView.hidden=YES;
}

- (IBAction)btnSendComment:(id)sender {
    if([self.txtComment.text length]>0)
    {
        self.commentText = self.txtComment.text;
        self.commentView.hidden=YES;
        [self dismissKeyboard];
        [self.detailTable reloadData];
    }
    else
    {
        [self commentError];
    }
}
-(void) generateNotification:(NSString*) target_id mode:(NSString*) mode
{
    self.defaults=[NSUserDefaults standardUserDefaults];
    NSString *user_name = [self.defaults objectForKey:@"user_name"];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    NSString * attributedString;
    if([mode isEqualToString:@"comment"])
        attributedString=[NSString stringWithFormat:@"%@ commented on your clean up location", user_name];
    else if([mode isEqualToString:@"clean"])
        attributedString=[NSString stringWithFormat:@"%@ commented on your clean up location", user_name];
    
    [[dynamoDBObjectMapper load:[User class] hashKey:target_id rangeKey:nil]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.result) {
             User * user=task.result;
             
             if(user.device_token)
             {
                 [self.mainDelegate send_notification:user message:attributedString];
             }
             
         }
         return nil;
     }];
}
@end
