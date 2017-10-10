//
//  MainTabNav.h
//  CleantheCreeks
//
//  Created by Kimura Isoroku on 1/28/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "User.h"
@interface MainTabNav : UITabBarController<UITabBarControllerDelegate,UITabBarDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong,nonatomic )AppDelegate * mainDelegate;
@property ( nonatomic) bool freshLoad;
@property (nonatomic) User * current_user;
@end
