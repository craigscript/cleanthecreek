//
//  SettingVC.m
//  Clean the Creek
//
//  Created by a on 2/23/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "SettingVC.h"
#import "SlideVC.h"
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

#import <AWSS3/AWSS3.h>
#import "PhotoDetailsVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
@implementation SettingVC
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Settings"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.defaults=[NSUserDefaults standardUserDefaults];
    [self.profileTopBar setHeaderStyle:NO title:@"SETTINGS" rightBtnHidden:NO];
    [self.profileTopBar.rightBtn setTitle:@"Save" forState:UIControlStateNormal];
    [self.profileTopBar.rightBtn setImage:nil forState:UIControlStateNormal];
    NSUserDefaults *settingInfo=[NSUserDefaults standardUserDefaults];
    
    NSString *commentStatus = [settingInfo objectForKey:@"switchComment"];
    if(commentStatus!=nil)
        [self.switchComments setOn:[commentStatus isEqualToString:@"YES"]];
    
    NSString *kudoStatus = [settingInfo objectForKey:@"switchKudo"];
    if(kudoStatus!=nil)
        [self.switchKudos setOn:[kudoStatus isEqualToString:@"YES"]];
    
    NSString *followStatus = [settingInfo objectForKey:@"switchFollow"];
    if(followStatus!=nil)
        [self.switchFollows setOn:[followStatus isEqualToString:@"YES"]];
    
    NSString *tagStatus = [settingInfo objectForKey:@"switchTag"];
    if(tagStatus!=nil)
        [self.switchTag setOn:[tagStatus isEqualToString:@"YES"]];
    
    NSString *locationStatus = [settingInfo objectForKey:@"switchLocation"];
    if(locationStatus!=nil)
        [self.switchNewLocation setOn:[locationStatus isEqualToString:@"YES"]];
    
    NSString *measurement = [settingInfo objectForKey:@"measurement"];
    if(measurement!=nil)
    {
        if([measurement isEqualToString:@"miles"])
            [self.measurementButton setTitle:@"Miles" forState:UIControlStateNormal];
        else
            [self.measurementButton setTitle:@"Metric" forState:UIControlStateNormal];
        
    }
    self.imgAvatar.layer.cornerRadius = 30.0f;
    self.imgAvatar.layer.masksToBounds = YES;
    [self.tabBarController.tabBar setHidden:YES];
    self.delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self.delegate loadData];
    self.current_user_id = [settingInfo objectForKey:@"user_id"];
    
    [self.fullName setText:[settingInfo objectForKey:@"user_name"]];
    [self.userName setText:self.current_user.nick_name];
    [self.website setText:self.current_user.website_url];
    [self.bio setText:self.current_user.tagline];
    self.fullName.delegate=self;
    self.userName.delegate=self;
    self.website.delegate=self;
    self.bio.delegate=self;
   
    if([self.current_user.has_photo isEqualToString:@"yes"])
        [self.photo setImage:self.profile_image];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *privacyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(privacyTapped:)];
    [privacyTap setNumberOfTapsRequired:1];
    [self.privacyPolicyView addGestureRecognizer:privacyTap];
    
    UITapGestureRecognizer *blockedTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blockedTapped:)];
    [blockedTap setNumberOfTapsRequired:1];
    [self.blockedView addGestureRecognizer:blockedTap];
    
    UITapGestureRecognizer *inviteTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inviteTapped:)];
    [inviteTap setNumberOfTapsRequired:1];
    [self.inviteFB addGestureRecognizer:inviteTap];
}

- (void)resignOnTap:(id)iSender {
    [self.fullName resignFirstResponder];
    [self.userName resignFirstResponder];
    [self.website resignFirstResponder];
    [self.bio resignFirstResponder];
    
}

- (void)blockedTapped:(id)iSender {
    [self performSegueWithIdentifier:@"showBlockedUsers" sender:self];
}

- (void)inviteTapped:(id)iSender {
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://fb.me/1619190835060094"];
    //optionally set previewImageURL
    content.appInvitePreviewImageURL = [NSURL URLWithString:@"http://cleanthecreek.com/fb-invite.jpg"];
    // Present the dialog. Assumes self is a view controller
    // which implements the protocol `FBSDKAppInviteDialogDelegate`.
    [FBSDKAppInviteDialog showFromViewController:self
                                     withContent:content
                                        delegate:nil];
}

- (void)privacyTapped:(id)iSender {
    NSURL *url = [NSURL URLWithString:@"https://www.iubenda.com/privacy-policy/7811463"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    
   
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField

{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma ProfileTopBarVCDelegate Implementation

- (void)leftBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    [self dismissVC];
}

- (void)rightBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    if(self.self.fullName.text.length>0)
        self.current_user.user_name = self.fullName.text;
    if(self.self.userName.text.length>0)
        self.current_user.nick_name = self.userName.text;
    if(self.website.text.length>0)
        self.current_user.website_url = self.website.text;
    if(self.bio.text.length>0)
        self.current_user.tagline = self.bio.text;
    if(self.profile_image)
        self.current_user.has_photo = @"yes";
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
    updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorUpdate;
    
    [[dynamoDBObjectMapper save:self.current_user configuration:updateMapperConfig]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"%@",task.error);
         }
         if (task.exception) {
             NSLog(@"%@",task.error);
             
         }
         if (task.result) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                 
                 NSString *photoPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", self.current_user.user_id]];
                 UIImage* uploadImage = [PhotoDetailsVC scaleImage:self.profile_image toSize:CGSizeMake(320.0,320.0)];
                 [UIImageJPEGRepresentation(uploadImage,0.8) writeToFile:photoPath atomically:YES];
                 NSURL* cleanURL = [NSURL fileURLWithPath:photoPath];
                 AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
                 AWSS3TransferManagerUploadRequest *seconduploadRequest = [AWSS3TransferManagerUploadRequest new];
                 seconduploadRequest.bucket = @"cleanthecreeks";
                 seconduploadRequest.contentType = @"image/jpg";
                 seconduploadRequest.body = cleanURL;
                 
                 seconduploadRequest.key = [NSString stringWithFormat:@"%@",
                                            self.current_user.user_id];
                 [[transferManager upload:seconduploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
                     if (task.error) {
                         if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                             switch (task.error.code) {
                                 case AWSS3TransferManagerErrorCancelled:
                                 case AWSS3TransferManagerErrorPaused:
                                     break;
                                     
                                 default:
                                 {
                                     [self networkError];
                                     break;
                                 }
                             }
                         } else {
                             [self networkError];
                         }
                     }
                     
                     if (task.result) {
                         NSLog(@"cleaned photo uploaded");
                         
                         [self dismissVC];
                         
                     }
                     return nil;
                 }];

                 
             });
             
         }
         
         return nil;
     }];
    
}

- (IBAction)switchCommentUpdate:(id)sender {
    BOOL value=((UISwitch*)sender).isOn;
    [self.defaults setObject:(value)? @"YES":@"NO" forKey:@"switchComment"];
    [self.defaults synchronize];
}

- (IBAction)switchKudoUpdated:(id)sender {
    BOOL value=((UISwitch*)sender).isOn;
    [self.defaults setObject:(value)? @"YES":@"NO" forKey:@"switchKudo"];
    [self.defaults synchronize];
}

- (IBAction)switchFollowUpdate:(id)sender {
    
    BOOL value=((UISwitch*)sender).isOn;
    [self.defaults setObject:(value)? @"YES":@"NO" forKey:@"switchFollow"];
    [self.defaults synchronize];
}

- (IBAction)switchTagUpdated:(id)sender {
    
    BOOL value=((UISwitch*)sender).isOn;
    [self.defaults setObject:(value)? @"YES":@"NO" forKey:@"switchTag"];
    [self.defaults synchronize];
    
}

- (IBAction)switchLocationUpdate:(id)sender {
    
    BOOL value=((UISwitch*)sender).isOn;
    [self.defaults setObject:(value)? @"YES":@"NO" forKey:@"switchLocation"];
    [self.defaults synchronize];
}

- (IBAction)measurementUpdate:(id)sender {
    
    NSString *measurement = [self.measurementButton titleForState:UIControlStateNormal];
    if([measurement isEqualToString:@"Metric"])
    {
        [self.defaults setObject:@"miles" forKey:@"measurement"];
        [self.measurementButton setTitle:@"Miles" forState:UIControlStateNormal];
    }
    else
    {
        [self.defaults setObject:@"KM" forKey:@"measurement"];
        [self.measurementButton setTitle:@"Metric" forState:UIControlStateNormal];
    }
}

- (IBAction)signOut:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sign Out" message:@"Are you sure to sign out?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
        NSDictionary * dict = [defs dictionaryRepresentation];
        for (id key in dict) {
            [defs removeObjectForKey:key];
        }
        [defs synchronize];
        
        SlideVC * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SlideVC"];
        
        UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:vc];
        [navC.navigationBar setHidden:YES];
        
        [self presentViewController:navC animated:YES completion:nil];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self presentViewController:alertController animated:YES completion:nil];
    });
}
- (IBAction)editPhoto:(UIButton *)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Update Photo" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take a Photo" style:UIPreviewActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIImagePickerController *picker=[[UIImagePickerController alloc] init];
        picker.allowsEditing = YES;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]==YES)
        {
            picker.sourceType=UIImagePickerControllerSourceTypeCamera;
        }
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"From Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *picker=[[UIImagePickerController alloc] init];
        picker.allowsEditing = YES;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]==NO)
        {
            picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        }
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }]];
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    self.profile_image = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
    [self.photo setImage:_profile_image];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
