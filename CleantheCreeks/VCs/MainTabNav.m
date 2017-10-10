//
//  MainTabNav.m
//  CleantheCreeks
//
//  Created by Kimura EIJI on 1/28/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "MainTabNav.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
@interface MainTabNav ()<CLLocationManagerDelegate,UINavigationControllerDelegate>

@end
CLLocationManager * locationManager;

@implementation MainTabNav

- (id) init
{
    self = [super init];
    if (!self) return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePushNotification:)
                                                 name:@"PushNotification"
                                               object:nil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePushNotification:)
                                                 name:@"PushNotification"
                                               object:nil];
    self.mainDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    if(!_freshLoad)
    {
        self.selectedIndex=1;
        _freshLoad=YES;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    [[dynamoDBObjectMapper load:[User class] hashKey:user_id rangeKey:nil]
     continueWithBlock:^id(AWSTask *task) {
         if (task.result) {
             User *user=task.result;
             self.current_user = task.result;
             if([user.is_blocked isEqualToString:@"1"])
             {
                 [self blocked];
             }
         }
         return nil;
     }];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
}

- (void) receivePushNotification:(NSNotification *) notification
{
    if(self.mainDelegate.notificationCount > 0)
    {
        NSString * str=[NSString stringWithFormat:@"%ld",(long)self.mainDelegate.notificationCount];
        [[[[self tabBar] items]
          objectAtIndex:2] setBadgeValue:str];
        NSLog(@"received");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if(tabBarController.selectedIndex==0)
    {
        NSLog(@"selected 1st");
        self.selectedViewController=[self.viewControllers objectAtIndex:1];
    }
    
}


- (void) blocked
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:@"You have been blocked from the system." preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
        NSDictionary * dict = [defs dictionaryRepresentation];
        for (id key in dict) {
            [defs removeObjectForKey:key];
        }
        [defs synchronize];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }]];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

@end
