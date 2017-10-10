//
//  FacebookPostVC.h
//  Clean the Creek
//
//  Created by Kimura Isoroku on 2/18/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "BaseVC.h"
@interface FacebookPostVC : BaseVC<UITabBarControllerDelegate>
@property (strong, nonatomic) UIImage * firstPhoto;
@property (strong, nonatomic) UIImage * secondPhoto;
@property (strong, nonatomic) UIImage * postImage;
@property (weak, nonatomic) IBOutlet UIImageView *fbImage;
@property (weak, nonatomic) IBOutlet UIImageView *user_photo;
@property (weak, nonatomic) IBOutlet UILabel *user_name;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UIButton *btnPost;

@property (weak, nonatomic) IBOutlet UIImageView *fbTopImage;
- (IBAction)skip:(id)sender;
@property(strong,nonatomic)SLComposeViewController *mySLComposerSheet;
@property(nonatomic)bool cleaned;
@property(nonatomic, strong) NSString * locationID;
@end
