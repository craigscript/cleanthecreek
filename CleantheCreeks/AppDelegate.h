//
//  AppDelegate.h
//  CleantheCreeks
//
//  Created by ship8-2 on 1/27/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Google/Analytics.h>
#import "User.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//Add a location manager property to this app delegate
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableDictionary * locationData;
@property (strong, nonatomic) NSMutableArray *followersArray;
@property (strong, nonatomic) NSMutableArray *followingArray;
@property (strong, nonatomic) NSMutableDictionary *userArray;
@property (strong, nonatomic) CLLocation * currentLocation;
@property(nonatomic) bool shouldRefreshLocation;
@property(nonatomic) bool shouldRefreshActivity;
@property(nonatomic) bool shouldRefreshProfile;
@property(nonatomic) NSInteger notificationCount;


+(BOOL) isFollowing:(User*) user;
+(BOOL) isFollowed:(User*) user;
-(void) loadData;

-(void) send_notification:(User*)user message:(NSString*)message;

@end

