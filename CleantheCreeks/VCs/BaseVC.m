//
//  BaseVC.m
//  Clean the Creek
//
//  Created by a on 2/24/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "BaseVC.h"

@implementation BaseVC

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier  isEqual: @"ProfileTopBarVC"]){
        self.profileTopBar = (ProfileTopBarVC*)segue.destinationViewController;
        self.profileTopBar.delegate = self;
    }
}

- (void) viewDidLoad
{
    [self setNeedsStatusBarAppearanceUpdate];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)dismissVC{
    NSLog(@"%@",self.navigationController.viewControllers);
    if (self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) networkError
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please check your network or server connection." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void) commentError
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"The comment text cannot be empty." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma ProfileTopBarVCDelegate Implementation
- (NSString*) generateUserName:(NSString *)userName
{
    NSString * nickname;
    nickname = [userName stringByReplacingOccurrencesOfString:@" " withString:@""];
    nickname = [nickname lowercaseString];
    return nickname;
}

- (void)leftBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    
}

- (void)rightBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    
}

@end
