//
//  PhotoDetails.h
//  CleantheCreeks
//
//  Created by Kimura Isoroku on 1/31/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotoViewCell.h"
#import <CoreLocation/CoreLocation.h>
#import "Location.h"
#import "BaseVC.h"
#import "AppDelegate.h"
#import "TGCameraViewController.h"
@protocol CameraRefreshDelegate<NSObject>
@optional
-(void) cameraRefresh:(BOOL)set;
@end
@interface PhotoDetailsVC : BaseVC<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,SetPhotoDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,TGCameraDelegate>
@property(nonatomic, strong) Location* location;
@property (strong,nonatomic) UIImage*takenPhoto;
@property (strong,nonatomic) UIImage*cleanedPhoto;
@property (strong,nonatomic) NSURL*firstPath;

@property (weak, nonatomic) IBOutlet UITableView *detailTable;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (retain) CLLocation * currentLocation;
@property (nonatomic) double foundDate;
@property (nonatomic) double cleanedDate;
@property (nonatomic,strong) NSString* locationName1;
- (IBAction)nextPage:(id)sender;
- (IBAction)prevPage:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property(nonatomic, strong) NSString* locationName2;
@property(nonatomic, strong) NSString* stateName;
@property(nonatomic, strong) NSString* countryName;
@property(nonatomic, strong) NSString* commentText;
+(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize;
@property (strong,nonatomic )AppDelegate * mainDelegate;
-(void) setSecondPhoto:(BOOL)set;

@property(nonatomic, retain) id<CameraRefreshDelegate> delegate;

@property(nonatomic) bool secondPhototaken;
@property (weak, nonatomic) IBOutlet UIView *commentView;

- (IBAction)closeComment:(id)sender;
- (IBAction)btnSendComment:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtComment;

@end

