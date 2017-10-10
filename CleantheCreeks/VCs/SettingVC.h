//
//  SettingVC.h
//  Clean the Creek
//
//  Created by a on 2/23/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "AppDelegate.h"
#import "User.h"
@interface SettingVC : BaseVC<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *switchComments;
@property (weak, nonatomic) IBOutlet UISwitch *switchKudos;
@property (weak, nonatomic) IBOutlet UISwitch *switchFollows;
@property (weak, nonatomic) IBOutlet UISwitch *switchTag;
@property (weak, nonatomic) IBOutlet UISwitch *switchNewLocation;
- (IBAction)switchCommentUpdate:(id)sender;
- (IBAction)switchKudoUpdated:(id)sender;
- (IBAction)switchFollowUpdate:(id)sender;
- (IBAction)switchTagUpdated:(id)sender;
- (IBAction)switchLocationUpdate:(id)sender;
- (IBAction)measurementUpdate:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UIButton *measurementButton;
- (IBAction)signOut:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *fullName;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *website;
@property (weak, nonatomic) IBOutlet UITextField *bio;
@property(strong,nonatomic) AppDelegate * delegate;
- (IBAction)editPhoto:(UIButton *)sender;
@property(strong, nonatomic) User * current_user;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UIView *privacyPolicyView;
@property (weak, nonatomic) IBOutlet UIView *blockedView;
@property(strong, nonatomic) UIImage * profile_image;
@property (weak, nonatomic) IBOutlet UIView *inviteFB;
@property (nonatomic, assign) id currentResponder;
@end
