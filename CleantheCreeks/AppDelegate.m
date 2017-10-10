//
//  AppDelegate.m
//  CleantheCreeks
//
//  Created by ship8-2 on 1/27/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import <AWSSNS/AWSSNS.h>
#import "User.h"
#import "Constants.h"
#import "Flurry.h"
#import "Bolts/Bolts.h"
#define kGeoCodingString @"http://maps.google.com/maps/geo?q=%f,%f&output=csv"
@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize window = _window;
@synthesize locationManager=_locationManager;
@synthesize locationData=_locationData;


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    ];
    
    if (handled) {
        return handled;
    }
    
    // If the SDK did not handle the incoming URL, check it for app link data
    BFURL *parsedUrl = [BFURL URLWithInboundURL:url sourceApplication:sourceApplication];
    if ([parsedUrl appLinkData]) {
        NSURL *targetUrl = [parsedUrl targetURL];
        
        // ...process app link data...
        
        return YES;
    }
    
    // ...add any other custom processing...
    
    return YES;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    UIColor *backgroundColor = [UIColor whiteColor];
    _locationData=[[NSMutableDictionary alloc]init];
    _followingArray=[[NSMutableArray alloc]init];
    _followersArray=[[NSMutableArray alloc]init];
    _userArray=[[NSMutableDictionary alloc]init];
    // set the bar background color
    [[UITabBar appearance] setBackgroundImage:[AppDelegate imageFromColor:backgroundColor forSize:CGSizeMake(320, 49) withCornerRadius:0]];
    
    // set the text color for selected state
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil] forState:UIControlStateSelected];
    // set the text color for unselected state
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
    
    // set the selected icon color
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [UITabBar appearance].tintColor=[UIColor whiteColor];
    // remove the shadow
    [[UITabBar appearance] setShadowImage:nil];
    
    // Set the dark color to selected tab (the dimmed background)
    [[UITabBar appearance] setSelectionIndicatorImage:[AppDelegate imageFromColor:[UIColor colorWithRed:1/255.0 green:122/255.0 blue:255/255.0 alpha:1] forSize:CGSizeMake(self.window.frame.size.width/4, 49) withCornerRadius:0]];
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionAPNortheast1
                                                          identityPoolId:@"ap-northeast-1:709bfbb9-9e4d-4ebc-9e98-253f29e9a4d3"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionAPNortheast1 credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    AWSCognito *syncClient = [AWSCognito defaultCognito];
    
    // Create a record in a dataset and synchronize with the server
    AWSCognitoDataset *dataset = [syncClient openOrCreateDataset:@"myDataset"];
    [dataset setString:@"myValue" forKey:@"myKey"];
    [[dataset synchronize] continueWithBlock:^id(AWSTask *task) {
        // Your handler code here
        return nil;
    }];
    self.notificationCount = 0;
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    
    
    //Flurry analytics
    [Flurry startSession:@"FG7S2SBZG6WNKCKVF6Z6"];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    NSLog(@"%@",userInfo);
    self.notificationCount++;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PushNotification" object:nil];
    }
    
    else if([UIApplication sharedApplication].applicationState==UIApplicationStateActive){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PushNotification" object:nil];
    }
    
    //When the app is in the background
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PushNotification" object:nil];
        
    }//End background
    
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings // NS_AVAILABLE_IOS(8_0);
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    
    NSString * token = [NSString stringWithFormat:@"%@", deviceToken];
    //Format token as you need:
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    NSLog(@"deviceToken: %@", token);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    AWSSNS *sns = [AWSSNS defaultSNS];
    AWSSNSCreatePlatformEndpointInput *request = [AWSSNSCreatePlatformEndpointInput new];
    request.token = token;
    request.platformApplicationArn = SNSPlatformApplicationArn;
    [[sns createPlatformEndpoint:request] continueWithBlock:^id(AWSTask *task) {
        if (task.error != nil) {
            NSLog(@"Error: %@",task.error);
        } else {
            AWSSNSCreateEndpointResponse *createEndPointResponse = task.result;
            NSLog(@"endpointArn: %@",createEndPointResponse);
            [[NSUserDefaults standardUserDefaults] setObject:createEndPointResponse.endpointArn forKey:@"endpointArn"];
            [defaults setObject:createEndPointResponse.endpointArn forKey:@"devicetoken"];
            [defaults synchronize];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSString *user_id = [defaults objectForKey:@"user_id"];
            if(user_id)
            {
                User * user_info = [User new];
                user_info.user_id = user_id;
                user_info.user_name = [defaults objectForKey:@"user_name"];
                user_info.device_token=createEndPointResponse.endpointArn;
                AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
                updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorAppendSet;
                AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
                [[dynamoDBObjectMapper save:user_info configuration:updateMapperConfig]
                 continueWithBlock:^id(AWSTask *task) {
                     
                     if (task.result) {
                         NSLog(@"Push notification registered");
                     }
                     return nil;
                 }];
            }
        }
        
        return nil;
    }];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



+ (UIImage *)imageFromColor:(UIColor *)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContext(size);
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
    // Draw your image
    [image drawInRect:rect];
    // Get the image, here setting the UIImageView image
    image = UIGraphicsGetImageFromCurrentImageContext();
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    return image;
}

-(void) loadData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    [[dynamoDBObjectMapper load:[User class] hashKey:user_id rangeKey:nil]
     continueWithBlock:^id(AWSTask *task) {
         if (task.result) {
             User *user=task.result;
             
             [self.userArray setObject:user forKey:user.user_id];
             if([user.user_id isEqualToString:user_id])
             {
                 self.followingArray=user.followings;
                 self.followersArray=user.followers;
             }
         }
         return nil;
     }];
}

+(BOOL) isFollowing:(User*) user
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    for(NSDictionary * iterator in user.followers)
    {
        NSString * target=[iterator objectForKey:@"id"];
        if([user_id isEqualToString:target])
            return YES;
    }
    return NO;
}

+(BOOL) isFollowed:(User*) user
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    for(NSDictionary * iterator in user.followings)
    {
        NSString * target=[iterator objectForKey:@"id"];
        if([user_id isEqualToString:target])
            return YES;
    }
    return NO;
}


-(void) send_notification:(User*)user message:(NSString*)message
{
    
    NSString * device_id = user.device_token;
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionAPNortheast1
                                                          identityPoolId:@"ap-northeast-1:709bfbb9-9e4d-4ebc-9e98-253f29e9a4d3"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionAPNortheast1 credentialsProvider:credentialsProvider];
    
    AWSSNS *snsClient = [[AWSSNS alloc] initWithConfiguration:configuration];
    AWSSNSPublishInput *pr = [[AWSSNSPublishInput alloc] init];
    pr.targetArn= device_id;
    
    pr.message = message;
    
    [[snsClient publish:pr] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"Error publishing message: %@", task.error);
            return nil;
        }
        
        NSLog(@"Published: %@", task.result);
        return task;
    }];
    
}

@end
