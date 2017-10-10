//
//  CameraNav.m
//  CTC
//
//  Created by Song on 5/5/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "CameraNav.h"
#import "CameraVC.h"
@interface CameraNav ()

@end

@implementation CameraNav

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController setSelectedIndex:1];
    CameraVC * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraVC"];
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:vc];
    [navC.navigationBar setHidden:YES];
 
    [self presentViewController:navC animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
