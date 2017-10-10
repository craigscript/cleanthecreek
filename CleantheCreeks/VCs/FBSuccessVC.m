//
//  FBSuccessVC.m
//  Clean the Creek
//
//  Created by Kimura Isoroku on 2/22/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "FBSuccessVC.h"
#import "CameraVC.h"
@implementation FBSuccessVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.profileTopBar setHeaderStyle:YES title:@"LOCATION DETAILS" rightBtnHidden:YES];
    
}
- (IBAction)showFBPost:(id)sender {
   // NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSString *user_id = [defaults objectForKey:@"user_id"];
    NSString *fb_base = @"fb://profile/";
    //NSString *fb_url = [fb_base stringByAppendingString:user_id];
    NSURL *url = [NSURL URLWithString:fb_base];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)close:(UIButton *)sender {
    
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Facebook Posting Success"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

@end
