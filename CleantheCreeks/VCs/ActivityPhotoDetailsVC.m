//
//  ActivityPhotoDetailsVC.m
//  Clean the Creek
//
//  Created by a on 2/22/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "ActivityPhotoDetailsVC.h"
#import "PhotoViewCell.h"
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

#import <AWSS3/AWSS3.h>
#import "DetailCell.h"
#import "LocationPhotoCell.h"
#import "LocationBarCell.h"
#import "CommentCell.h"
#import "User.h"
#import "PhotoDetailsVC.h"
#import "FacebookPostVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ProfileVC.h"
#import "FullScreen.h"
#import "MapVC.h"
#import "TGCameraColor.h"
@implementation ActivityPhotoDetailsVC

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.

- (void)keyboardWasShown:(NSNotification*)aNotification

{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.tv.contentInset = contentInsets;
    self.tv.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    
    // Your app might not need or want this behavior.
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.commentView.frame.origin) ) {
        
        [self.tv scrollRectToVisible:self.commentView.frame animated:YES];
        CGRect commentFrame=self.commentView.frame;
        commentFrame.origin.y-=kbSize.height;
        [self.commentView setFrame:commentFrame];
    }
    NSLog(@"keyboard was showen");
}
// Called when the UIKeyboardWillHideNotification is sent

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tv.contentInset = contentInsets;
    self.tv.scrollIndicatorInsets = contentInsets;
    NSLog(@"keyboard hidden");
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField

{
    [textField resignFirstResponder];
    return YES;
}

-(void)loadData
{
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    [[dynamoDBObjectMapper scan:[User class] expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.result) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             for (User *user in paginatedOutput.items)
             {
                 [self.mainDelegate.userArray setObject:user forKey:user.user_id];
                 
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tv reloadData];
             });
         }
         return nil;
     }];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    self.textComment.delegate=self;
    self.commentVisible = NO;
    [self.commentView setHidden:!self.commentVisible];
    UIColor *tintColor = [UIColor colorWithRed:1/255.0 green:122/255.0 blue:1 alpha:1.0];
    [TGCameraColor setTintColor:tintColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    self.mainDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self loadData];
    [self registerForKeyboardNotifications];
    self.defaults = [NSUserDefaults standardUserDefaults];
    self.current_user_id = [self.defaults objectForKey:@"user_id"];
    UIButton * btnKudo = [self.view viewWithTag:22];
    
    btnKudo.enabled = NO; //disabling the button while finishing the db update
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tv reloadData];
        btnKudo.enabled = YES;
    });
    [self.profileTopBar setHeaderStyle:NO title:self.location.location_name rightBtnHidden:YES];
    // Adding shadows on the comment box
    self.commentView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.commentView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.commentView.layer.shadowRadius = 10.0f;
    self.commentView.layer.shadowOpacity = 0.9f;
}

-(void)dismissKeyboard {
    [self.textComment resignFirstResponder];
    [self.tv reloadData];
    
}

- (void)leftBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    [self dismissVC];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height=0;
    if(indexPath.section==0)
    {
        if(indexPath.row==0)
            height = self.view.frame.size.width*0.5;
        if(indexPath.row==1)
            height = 50.f;
    }
    else if(indexPath.section==1)
    {
        if(indexPath.row==0)
            height=5;
        else if(indexPath.row==3)
        {
            if([self.location.isDirty isEqualToString:@"false"])
                height=self.view.frame.size.height*0.13;
            else
                height=0;
        }
        else if(indexPath.row==2)
        {
            if([self.location.isDirty isEqualToString:@"true"])
                height=self.view.frame.size.height*0.13+2;
            else
                height=self.view.frame.size.height*0.13;
        }
        else
            height=self.view.frame.size.height*0.13;
    }
    else if(indexPath.section==2)
    {
        if(indexPath.row==0)
            height=5;
        else
            height=self.view.frame.size.height*0.13+2;
    }
    
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Activity Photo Details"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if(section == 0)
        count = 2;
    else if(section == 1)
    {
       
        if([self.location.isDirty isEqualToString:@"false"])
            count = 4;
        else
            count = 3;
    }
    else if(section==2)
    {
        if(self.location.comments!=nil)
            count = self.location.comments.count+1;
        else
            count = 1;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section>0)
        return 40.f;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell=[[UITableViewCell alloc]init];
    
    if(indexPath.section==0)
    {
        if(indexPath.row==0)
        {
            cell = (LocationPhotoCell*)[tableView dequeueReusableCellWithIdentifier:@"LocationPhotoCell"];
            
            UITapGestureRecognizer *firstTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFirstPhoto:)];
            firstTap.numberOfTapsRequired=1;
            [((LocationPhotoCell*)cell).firstPhoto addGestureRecognizer:firstTap];
            if(self.beforePhoto)
            {
                ((LocationPhotoCell*)cell).firstPhoto.userInteractionEnabled=YES;
                [((LocationPhotoCell*)cell).firstPhoto setImage:self.beforePhoto];
            }
            else
            {
                NSString *userImageURL = [NSString stringWithFormat:@"https://s3-ap-northeast-1.amazonaws.com/cleanthecreeks/%@%@", self.location.location_id,@"a"];
                NSURL *url = [NSURL URLWithString:userImageURL];
                
                NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (data) {
                        UIImage *image = [UIImage imageWithData:data];
                        if (image) {
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                {
                                    self.beforePhoto = image;
                                    ((LocationPhotoCell*)cell).firstPhoto.userInteractionEnabled=YES;
                                    [((LocationPhotoCell*)cell).firstPhoto setImage:image];
                                    [self.tv reloadData];
                                    
                                }
                                
                            });
                        }
                    }
                }];
                [task resume];
            }
            
            
            if([self.location.isDirty isEqualToString:@"false"])
            {
                if(self.afterPhoto)
                {
                    [((LocationPhotoCell*)cell).secondPhoto setImage:self.afterPhoto];
                    UITapGestureRecognizer *secondTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showSecondPhoto:)];
                    secondTap.numberOfTapsRequired=1;
                    [((LocationPhotoCell*)cell).secondPhoto addGestureRecognizer:secondTap];
                    ((LocationPhotoCell*)cell).secondPhoto.userInteractionEnabled=YES;
                }
                else
                {
                    NSString *userImageURL = [NSString stringWithFormat:@"https://s3-ap-northeast-1.amazonaws.com/cleanthecreeks/%@%@", self.location.location_id,@"b"];
                    NSURL *url = [NSURL URLWithString:userImageURL];
                    
                    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        if (data) {
                            UIImage *image = [UIImage imageWithData:data];
                            if (image) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    {
                                        self.afterPhoto = image;
                                        ((LocationPhotoCell*)cell).secondPhoto.userInteractionEnabled = YES;
                                        [((LocationPhotoCell*)cell).secondPhoto setImage:image];
                                        [self.tv reloadData];
                                        
                                    }
                                    
                                });
                            }
                        }
                    }];
                    [task resume];
                }
            }
            else
            {
                [((LocationPhotoCell*)cell).secondPhoto setImage:[UIImage imageNamed:@"camera"]];
                
                UITapGestureRecognizer *tapClean=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhoto:)];
                tapClean.numberOfTapsRequired=1;
                
                [((LocationPhotoCell*)cell).secondPhoto addGestureRecognizer:tapClean];
                ((LocationPhotoCell*)cell).secondPhoto.userInteractionEnabled=YES;
                
            }
        }
        
        else if(indexPath.row==1)
        {
            
            cell = (LocationBarCell*)[tableView dequeueReusableCellWithIdentifier:@"BarCell"];
            // Adding shadows
            ((LocationBarCell*)cell).barCellView.layer.masksToBounds = NO;
            ((LocationBarCell*)cell).barCellView.layer.shadowColor = [[UIColor blackColor] CGColor] ;
            ((LocationBarCell*)cell).barCellView.layer.shadowOffset = CGSizeMake(0, 1);
            ((LocationBarCell*)cell).barCellView.layer.shadowRadius = 1.0f;
            ((LocationBarCell*)cell).barCellView.layer.shadowOpacity = 0.6f;
            
            
            [((LocationBarCell*)cell).btnComment setImage:[UIImage imageNamed:@"IconQuote"] forState:UIControlStateNormal];
            
            [((LocationBarCell*)cell).btnComment setImage:[UIImage imageNamed:@"IconComment"] forState:UIControlStateSelected];
            ((LocationBarCell*)cell).btnComment.selected = self.commentVisible;
            ((LocationBarCell*)cell).btnLike.tag = 22;
            if([self.location.isDirty isEqualToString:@"false"])
            {
                [((LocationBarCell*)cell).btnLike setImage:[UIImage imageNamed:@"IconKudos4"] forState:UIControlStateNormal];
                [((LocationBarCell*)cell).btnLike setImage:[UIImage imageNamed:@"IconKudos5"] forState:UIControlStateSelected];
                ((LocationBarCell*)cell).btnLike.selected = self.isKudoed;
                [((LocationBarCell*)cell).btnLike addTarget:self action:@selector(kudoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                ((LocationBarCell*)cell).btnLike.hidden = YES;
                ((LocationBarCell*)cell).kudoLeadingConst.constant = 0;
                ((LocationBarCell*)cell).commentLeadingConst.constant = 0;
                
            }
            [((LocationBarCell*)cell).btnComment addTarget:self action:@selector(commentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [((LocationBarCell*)cell).btnReport addTarget:self action:@selector(reportButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    else if(indexPath.section==1)
    {
        
        NSString *user_name = [self.defaults objectForKey:@"user_name"];
        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd, yyyy"];
        
        if(indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"FirstBar"];
        }
        else if(indexPath.row == 1)
        {
            cell = (DetailCell*)[tableView dequeueReusableCellWithIdentifier:@"FirstDetailCell"];
            
            [((DetailCell*)cell).locationName1 setText:self.location.location_name];
            NSString * subLocation = [[NSString alloc]initWithFormat:@"%@, %@, %@", self.location.locality, self.location.state, self.location.country];
            [((DetailCell*)cell).locationName2 setText:subLocation];
            ((DetailCell*)cell).locationName1.userInteractionEnabled = YES;
            ((DetailCell*)cell).locationName2.userInteractionEnabled = YES;
            UITapGestureRecognizer *firstTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showLocation)];
            firstTap.numberOfTapsRequired=1;
            [((DetailCell*)cell).locationName1 addGestureRecognizer:firstTap];
            
            UITapGestureRecognizer *secondTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showLocation)];
            secondTap.numberOfTapsRequired=1;
            [((DetailCell*)cell).locationName2 addGestureRecognizer:secondTap];
            ((DetailCell*)cell).cellView.layer.masksToBounds = NO;
            ((DetailCell*)cell).cellView.layer.shadowColor = [[UIColor blackColor] CGColor] ;
            ((DetailCell*)cell).cellView.layer.shadowOffset = CGSizeMake(0.5, 1);
            //((DetailCell*)cell).cellView.layer.shadowRadius = 1;
            ((DetailCell*)cell).cellView.layer.shadowOpacity = 0.6f;

        }
        else if(indexPath.row == 2)
        {
            cell = (DetailCell*)[tableView dequeueReusableCellWithIdentifier:@"SecondDetailCell"];
            if(self.location!= nil)
                [((DetailCell*)cell).finderName setText:self.location.found_by];
            else
                [((DetailCell*)cell).finderName setText:user_name];
            NSDate* founddate=[[NSDate alloc]initWithTimeIntervalSince1970:self.location.found_date];
            [((DetailCell*)cell).foundDate setText:[dateFormatter stringFromDate:founddate]];
            
            UITapGestureRecognizer *finderNameTap = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(showFinder:)];
            finderNameTap.numberOfTapsRequired=1;
            [((DetailCell*)cell).finderName addGestureRecognizer:finderNameTap];
            [((DetailCell*)cell).finderName setUserInteractionEnabled:YES];
            [((DetailCell*)cell).cleanerName setUserInteractionEnabled:YES];
            ((DetailCell*)cell).cellView.layer.masksToBounds = NO;
            ((DetailCell*)cell).cellView.layer.shadowColor = [[UIColor blackColor] CGColor] ;
            ((DetailCell*)cell).cellView.layer.shadowOffset = CGSizeMake(0.5, 1);
            //((DetailCell*)cell).cellView.layer.shadowRadius = 1;
            ((DetailCell*)cell).cellView.layer.shadowOpacity = 0.6f;
            if([self.location.isDirty isEqualToString:@"true"])
                [((DetailCell*)cell).bottomShadow setConstant:2];
            else if([self.location.isDirty isEqualToString:@"false"])
                [((DetailCell*)cell).bottomShadow setConstant:0];

        }
        else if(indexPath.row==3)
        {
            cell = (DetailCell*)[tableView dequeueReusableCellWithIdentifier:@"ThirdDetailCell"];
            if([self.location.isDirty isEqualToString:@"false"])
                [((DetailCell*)cell).cleanerName setText:self.location.cleaner_name];
            else
                [((DetailCell*)cell).cleanerName setText:user_name];
            NSDate* cleanedDate=[[NSDate alloc]initWithTimeIntervalSince1970:self.location.cleaned_date];
            [((DetailCell*)cell).cleanedDate setText:[dateFormatter stringFromDate:cleanedDate]];
            
            UITapGestureRecognizer *cleanerNameTap = [[UITapGestureRecognizer alloc]
                                                      initWithTarget:self
                                                      action:@selector(showCleaner:)];
            cleanerNameTap.numberOfTapsRequired=1;
            [((DetailCell*)cell).cleanerName addGestureRecognizer:cleanerNameTap];
            [((DetailCell*)cell).cleanerName setUserInteractionEnabled:YES];
            ((DetailCell*)cell).cellView.layer.masksToBounds = NO;
            ((DetailCell*)cell).cellView.layer.shadowColor = [[UIColor blackColor] CGColor] ;
            ((DetailCell*)cell).cellView.layer.shadowOffset = CGSizeMake(0.5, 1);
            //((DetailCell*)cell).cellView.layer.shadowRadius = 1;
            ((DetailCell*)cell).cellView.layer.shadowOpacity = 0.6f;


        }
        
    }
    else if(indexPath.section==2)
    {
        if(indexPath.row==0)
            cell = [tableView dequeueReusableCellWithIdentifier:@"SecondBar"];
        
        else
        {
            if(self.location!=nil)
            {
                if([self.location.comments count]>0)
                {
                    cell = (CommentCell*)[tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
                    NSMutableDictionary *commentItem=[self.location.comments objectAtIndex:indexPath.row-1];
                    User * commentUser = [self.mainDelegate.userArray objectForKey:[commentItem objectForKey:@"id"]];
                    NSString *commentUserName=commentUser.user_name;
                    NSString *commentText = [commentItem objectForKey:@"text"];
                    [((CommentCell*)cell).commentLabel setAttributedText:[self generateCommentString:commentUserName content:commentText]];
                    
                    UITapGestureRecognizer *commentTap = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(showCommenter:)];
                    commentTap.numberOfTapsRequired = 1;
                    [((CommentCell*)cell).commentLabel addGestureRecognizer:commentTap];
                    [((CommentCell*)cell).commentLabel setUserInteractionEnabled:YES];
                    ((CommentCell*)cell).commentLabel.tag =indexPath.row-1;
                    ((CommentCell*)cell).cellView.layer.masksToBounds = NO;
                    ((CommentCell*)cell).cellView.layer.shadowColor = [[UIColor blackColor] CGColor] ;
                    ((CommentCell*)cell).cellView.layer.shadowOffset = CGSizeMake(0.5, 1);
                    //((DetailCell*)cell).cellView.layer.shadowRadius = 1;
                    ((CommentCell*)cell).cellView.layer.shadowOpacity = 0.6f;
                    
                    if(indexPath.row==self.location.comments.count)
                        [((CommentCell*)cell).bottomShadow setConstant:-6];
                    else
                        [((CommentCell*)cell).bottomShadow setConstant:-8];
                }
            }
            
        }
        
    }
    [[cell contentView] setFrame:[cell bounds]];
    [[cell contentView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    return cell;
}

-(void)showFirstPhoto:(id)sender
{
    self.imgToShow = self.beforePhoto;
    [self performSegueWithIdentifier:@"showFullScreen" sender:self];
}

-(void)showSecondPhoto:(id)sender
{
    self.imgToShow = self.afterPhoto;
    [self performSegueWithIdentifier:@"showFullScreen" sender:self];
}

-(void)showLocation
{
    MapVC * vc= [self.storyboard instantiateViewControllerWithIdentifier:@"MapView"];
    vc.currentLocation = self.location;
    vc.currentImage = [PhotoDetailsVC scaleImage:self.beforePhoto toSize:CGSizeMake(320.0,320.0)];
    
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)showCleaner:(id)sender
{
    if([self.defaults objectForKey:@"user_id"])
    {
        self.selected_user = self.location.cleaner_id;
        [self showProfileWithValidation];
    }
    else
    {
        [self fbLogin];
    }
}

-(void)showFinder:(id)sender
{
    if([self.defaults objectForKey:@"user_id"])
    {
        self.selected_user = self.location.founder_id;
        [self showProfileWithValidation];
    }
    else
    {
        [self fbLogin];
    }
}

-(void) showProfileWithValidation
{
//    User * current_user = [self.mainDelegate.userArray objectForKey:[self.defaults objectForKey:@"user_id"]];
//    if(![current_user.blocked_by containsObject:self.selected_user])
        [self performSegueWithIdentifier:@"showProfileFromDetails" sender:self];
//    else
//        NSLog(@"blocked");
}

-(void)showCommenter:(id)sender
{
    if([self.defaults objectForKey:@"user_id"])
    {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
        NSMutableDictionary *commentItem=[self.location.comments objectAtIndex:gesture.view.tag];
        self.selected_user = [commentItem objectForKey:@"id"];
        [self showProfileWithValidation];
    }
    else
    {
        [self fbLogin];
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* title;
    if(section == 1)
        title = @"Details";
    else if(section == 2)
        title = @"Timeline";
    return title;
}

-(void) kudoButtonClicked:(UIButton*)sender
{
    sender.selected=!sender.selected;
    
    NSMutableArray * kudoArray=[[NSMutableArray alloc] init];
    if(self.location.kudos!=nil)
        kudoArray=self.location.kudos;
    NSMutableDictionary *kudoItem=[[NSMutableDictionary alloc]init];
    [kudoItem setObject:self.current_user_id forKey:@"id"];
    double date =[[NSDate date]timeIntervalSince1970];
    NSString *dateString=[NSString stringWithFormat:@"%f",date];
    [kudoItem setObject:dateString forKey:@"time"];
    
    if(kudoArray!=nil)
    {
        NSMutableArray *removeArray=[[NSMutableArray alloc]init];
        for(NSDictionary *kudo_gaver in kudoArray)
        {
            if([[kudo_gaver objectForKey:@"id"] isEqualToString:self.current_user_id])
            {
                [removeArray addObject:kudo_gaver];
                
            }
        }
        [kudoArray removeObjectsInArray:removeArray];
    }
    if(sender.selected)
        [kudoArray addObject:kudoItem];
    if([kudoArray count]!=0)
        self.location.kudos=[[NSMutableArray alloc] initWithArray:kudoArray];
    else
        self.location.kudos=nil;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
    updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorUpdate;
    
    [[dynamoDBObjectMapper save:self.location configuration:updateMapperConfig]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             self.isKudoed = sender.selected;
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tv reloadData];
             });
             
             if(sender.selected)
             {
                 User * user=[self.mainDelegate.userArray objectForKey:self.location.cleaner_id];
                 NSString * user_name = [self.defaults objectForKey:@"user_name"];
                 NSString * attributedString=[NSString stringWithFormat:@"%@ gave you kudos", user_name];
                 
                 [self.mainDelegate send_notification:user message:attributedString];
                 NSLog(@"assigned");
             }
             else
                 NSLog(@"unassigned");
             
         }
         return nil;
     }];
}

-(void)commentButtonClicked:(UIButton*) sender
{
    self.defaults = [NSUserDefaults standardUserDefaults];
    if([self.defaults objectForKey:@"user_id"])
    {
        self.commentVisible = !self.commentVisible;
        [self.commentView setHidden:!self.commentVisible];
        [self.textComment becomeFirstResponder];
        sender.selected = self.commentVisible;
    }
    else
        [self fbLogin];
}

-(void)reportButtonClicked:(UIButton*) sender
{
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Title" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Invite friends" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
        content.appLinkURL = [NSURL URLWithString:@"https://fb.me/1619190835060094"];
        //optionally set previewImageURL
        content.appInvitePreviewImageURL = [NSURL URLWithString:@"http://cleanthecreek.com/fb-invite.jpg"];
        // Present the dialog. Assumes self is a view controller
        // which implements the protocol `FBSDKAppInviteDialogDelegate`.
        [FBSDKAppInviteDialog showFromViewController:self
                                         withContent:content
                                            delegate:nil];

    }]];

    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Report abuse" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
            mailCont.mailComposeDelegate = self;
            NSString * title = [NSString stringWithFormat:@"%@ has uploaded irrelevant photos.",self.location.found_by];
            [mailCont setSubject:title];
            [mailCont setToRecipients:[NSArray arrayWithObject:@"abuse@cleanthecreek.com"]];
            NSString * message=[NSString stringWithFormat:@"%@ with id %@ has uploaded irrelevant photos on %@, %@, %@",self.location.found_by, self.location.founder_id, self.location.location_name, self.location.state, self.location.country];
            [mailCont setMessageBody:message isHTML:NO];
            
            [self presentViewController:mailCont animated:YES completion:nil];
        }
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)closeBtnClicked:(id)sender {
    self.commentVisible=NO;
    [self.commentView setHidden:YES];
    [self dismissKeyboard];
    [self.tv reloadData];
}

- (IBAction)sendButtonClicked:(id)sender {
    if([self.textComment.text length]>0)
    {
        self.commentVisible = NO;
        [self.commentView setHidden:YES];
        
        NSMutableArray * commentArray=[[NSMutableArray alloc] init];
        if(self.location.comments!=nil)
            commentArray=self.location.comments;
        NSMutableDictionary *commentItem=[[NSMutableDictionary alloc]init];
        
        [commentItem setObject:self.current_user_id forKey:@"id"];
        [commentItem setObject:self.textComment.text forKey:@"text"];
        double date =[[NSDate date]timeIntervalSince1970];
        NSString *dateString=[NSString stringWithFormat:@"%f",date];
        [commentItem setObject:dateString forKey:@"time"];
        
        
        [commentArray addObject:commentItem];
        
        self.location.comments=[[NSMutableArray alloc] initWithArray:commentArray];
        
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
        updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorUpdate;
        [self.textComment resignFirstResponder];
        [[dynamoDBObjectMapper save:self.location configuration:updateMapperConfig]
         continueWithBlock:^id(AWSTask *task) {
             if (task.error) {
                 [self networkError];
             }
             if (task.exception) {
                 [self networkError];
             }
             if (task.result) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.textComment setText:@""];
                     [self generateNotification:self.location.cleaner_id mode:@"comment"];
                     [self.tv reloadData];
                     CGPoint bottomOffset = CGPointMake(0,  self.tv.contentInset.bottom + self.tv.contentSize.height - self.tv.bounds.size.height);
                     if(bottomOffset.y > 0)
                      [self.tv setContentOffset:bottomOffset animated:YES];
                     NSLog(@"Updated Comment");
                 });
             }
             return nil;
         }];
    }
    else
    {
        [self commentError];
    }
    
}

-(void) generateNotification:(NSString*) target_id mode:(NSString*) mode
{
    self.defaults=[NSUserDefaults standardUserDefaults];
    NSString *user_name = [self.defaults objectForKey:@"user_name"];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    NSString * attributedString;
    if([mode isEqualToString:@"comment"])
        attributedString=[NSString stringWithFormat:@"%@ commented on your clean up location", user_name];
    else if([mode isEqualToString:@"clean"])
        attributedString=[NSString stringWithFormat:@"%@ commented on your clean up location", user_name];
    
    [[dynamoDBObjectMapper load:[User class] hashKey:target_id rangeKey:nil]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.result) {
             User * user=task.result;
             
             if(user.device_token)
             {
                 [self.mainDelegate send_notification:user message:attributedString];
             }
             
         }
         return nil;
     }];
}

-(void) takePhoto:(id)sender
{
    self.defaults = [NSUserDefaults standardUserDefaults];
    if([self.defaults objectForKey:@"user_id"])
    {
//        UIImagePickerController *picker=[[UIImagePickerController alloc] init];
//        picker.allowsEditing = YES;
//        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]==NO)
//        {
//            picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
//        }
//        else
//        {
//            picker.sourceType=UIImagePickerControllerSourceTypeCamera;
//            picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
//        }
//        picker.delegate = self;
//        [self presentViewController:picker animated:YES completion:nil];
        TGCameraNavigationController *navigationController =
        [TGCameraNavigationController newWithCameraDelegate:self];
        
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    else
        [self fbLogin];
   
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([self.textComment.text length] > 255)
        return NO;
    else
        return YES;
}

- (void)cameraDidTakePhoto:(UIImage *)image
{
    NSLog(@"Photo taken");
    UIImage * photo=[[UIImage alloc]init];
    photo = image;
    
    self.afterPhoto=photo;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self cleanLocation];
    });
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void) fbLogin
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sign in with Facebook" message:@"In order to take a photo or commment you must be signed in to your facebook account." preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login
         logInWithReadPermissions: @[@"public_profile",@"email"]
         fromViewController:self
         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
             if (error) {
                 NSLog(@"Process error");
             } else if (result.isCancelled) {
                 NSLog(@"Cancelled");
             }
             else
             {
                 
                 NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
                 [parameters setValue:@"id,name,location,about" forKey:@"fields"];
                 [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
                  startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                      
                      if (!error) {
                          [self.tabBarController.tabBar setHidden:NO];
                          NSLog(@"fetched user:%@  and Email : %@", result,result[@"email"]);
                          NSUserDefaults *loginInfo = [NSUserDefaults standardUserDefaults];
                          NSString *fbUsername = [[result valueForKey:@"link"] lastPathComponent];
                          [loginInfo setObject:fbUsername forKey:@"username"];
                          [loginInfo setObject:result[@"id"] forKey:@"user_id"];
                          [loginInfo setObject:result[@"name"] forKey:@"user_name"];
                          [loginInfo setObject:result[@"location"] forKey:@"user_location"];
                          [loginInfo setObject:result[@"about"] forKey:@"user_about"];
                          [loginInfo synchronize];
                          User * user_info = [User new];
                          user_info.user_id = result[@"id"];
                          user_info.user_name = result[@"name"];
                          user_info.device_token = [loginInfo objectForKey:@"devicetoken"];

                          user_info.user_about=[loginInfo objectForKey:@"user_about"];
                          
                          AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
                          updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorAppendSet;
                          AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
                          [[dynamoDBObjectMapper save:user_info configuration:updateMapperConfig]
                           continueWithBlock:^id(AWSTask *task) {
                               
                               if (task.result) {
                                   dispatch_async(dispatch_get_main_queue(), ^ {
                                       [self dismissVC];
                                   });
                               }
                               return nil;
                           }];
                      }
                  }];
             }
         }];
        
    }]];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self presentViewController:alertController animated:YES completion:nil];
    });
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    self.defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [self.defaults objectForKey:@"user_id"];
    if(indexPath.section ==2 && indexPath.row>0)
    {
        
        NSDictionary * commentItem = [self.location.comments objectAtIndex:indexPath.row-1];
        if([[commentItem objectForKey:@"id"] isEqualToString:user_id])
            return YES;
        else
            return NO;
    }
    else
        return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            if(self.location.comments!=nil)
            {
                
                [self.location.comments removeObjectAtIndex:indexPath.row-1];
                
            }
            if([self.location.comments count]==0)
                self.location.comments = nil;
            [tableView reloadData];
            AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
            AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
            updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorUpdate;
            
            [[dynamoDBObjectMapper save:self.location configuration:updateMapperConfig]
             continueWithBlock:^id(AWSTask *task) {
                 
                 if (task.result) {
                     [tableView reloadData];
                 }
                 
                 return nil;
             }];
        });
    }
}

- (void)cameraDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) cleanLocation
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_name = [defaults objectForKey:@"user_name"];
    NSString *user_id = [defaults objectForKey:@"user_id"];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    
    
    self.location.isDirty=@"false";
    self.location.cleaner_id=user_id;
    self.location.cleaner_name=user_name;
    self.location.cleaned_date=[[NSDate date] timeIntervalSince1970];
    
    //Updating the database
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    [[dynamoDBObjectMapper save:self.location]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             //Do something with the result.
         }
         return nil;
     }];
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *cleanPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@b.jpg", self.location.location_id]];
    UIImage* cimage2 = [PhotoDetailsVC scaleImage:self.afterPhoto toSize:CGSizeMake(320.0,320.0)];
    [UIImageJPEGRepresentation(cimage2,0.8) writeToFile:cleanPath atomically:YES];
    NSURL* cleanURL = [NSURL fileURLWithPath:cleanPath];
    AWSS3TransferManagerUploadRequest *seconduploadRequest = [AWSS3TransferManagerUploadRequest new];
    seconduploadRequest.bucket = @"cleanthecreeks";
    seconduploadRequest.contentType = @"image/jpg";
    seconduploadRequest.body = cleanURL;
    
    seconduploadRequest.key = [NSString stringWithFormat:@"%f,%fb",
                               self.location.latitude, self.location.longitude];
    [[transferManager upload:seconduploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        break;
                        
                    default:
                    {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Server Error" message:@"Please try again later." preferredStyle:UIAlertControllerStyleAlert];
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            [self presentViewController:alertController animated:YES completion:nil];
                        });
                        break;
                    }
                }
            } else {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Server Error" message:@"Please try again later." preferredStyle:UIAlertControllerStyleAlert];
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [self presentViewController:alertController animated:YES completion:nil];
                });
                
            }
        }
        
        if (task.result) {
            NSLog(@"cleaned photo uploaded");
            [self performSegueWithIdentifier:@"cleanFromView" sender:self];
            [self generateNotification:YES];
        }
        return nil;
    }];
    
    
}

-(void) generateNotification:(bool)mode
{
    self.defaults=[NSUserDefaults standardUserDefaults];
    NSString *user_name = [self.defaults objectForKey:@"user_name"];
    NSString *current_user_id = [self.defaults objectForKey:@"user_id"];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    NSString * attributedString;
    if(!mode)
    {
        attributedString=[NSString stringWithFormat:@"%@ found a new dirty spot %@", user_name, self.location.location_name];
        
    }
    else
    {
        attributedString=[NSString stringWithFormat:@"%@ has cleaned %@", user_name, self.location.location_name];
        
    }
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    [[dynamoDBObjectMapper scan:[User class] expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.result) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             for(User * user in paginatedOutput.items)
             {
                 if(user.device_token)
                 {
                     CLLocation* userLocation=[[CLLocation alloc]initWithLatitude:user.latitude longitude:user.longitude];
                     CLLocationDistance distance=[userLocation distanceFromLocation:self.location];
                     distance=distance/1000.0;
                     if(distance<100.0 || [AppDelegate isFollowed:user] || [self.location.found_by isEqualToString:current_user_id])
                         [self.mainDelegate send_notification:user message:attributedString];
                 }
             }
         }
         return nil;
     }];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    FacebookPostVC* vc = (FacebookPostVC*)segue.destinationViewController;
    
    if([segue.identifier isEqualToString:@"cleanFromView"])
    {
        vc.firstPhoto=[[UIImage alloc]init];
        vc.firstPhoto=[PhotoDetailsVC scaleImage:self.beforePhoto toSize:CGSizeMake(320.0,320.0)];
        vc.secondPhoto=[[UIImage alloc]init];
        vc.secondPhoto=[PhotoDetailsVC scaleImage:self.afterPhoto toSize:CGSizeMake(320.0,320.0)];
        vc.cleaned=YES;
        vc.locationID = self.location.location_id;
    }
    else if([segue.identifier isEqualToString:@"showProfileFromDetails"])
    {
        if(self.selected_user)
        {
            ProfileVC * vc=(ProfileVC*)segue.destinationViewController;
            
            vc.profile_user_id = self.selected_user;
            vc.mode = YES;
            self.mainDelegate.shouldRefreshProfile = YES;
        }
    }
    else if([segue.identifier isEqualToString:@"showFullScreen"])
    {
        FullScreen * vc=(FullScreen*)segue.destinationViewController;
        vc.img = self.imgToShow;
        
    }
    
}

- (NSMutableAttributedString *)generateCommentString:(NSString*)name content:(NSString*)content
{
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@""];
    UIColor * color1 = [UIColor colorWithRed:(1/255.0) green:(122/255.0) blue:(255/255.0) alpha:1.0];
    UIColor * color2= [UIColor colorWithRed:(51/255.0) green:(51/255.0) blue:(51/255.0) alpha:1.0];
    
    NSDictionary * attributes1 = [NSDictionary dictionaryWithObject:color1 forKey:NSForegroundColorAttributeName];
    
    NSDictionary * attributes2 = [NSDictionary dictionaryWithObject:color2 forKey:NSForegroundColorAttributeName];
    if(name!=nil)
    {
        NSAttributedString * nameStr = [[NSAttributedString alloc] initWithString:name attributes:attributes1];
        [string appendAttributedString:nameStr];
        
    }
    NSAttributedString * space = [[NSAttributedString alloc] initWithString:@" " attributes:attributes2];
    [string appendAttributedString:space];
    if(content!=nil)
    {
        NSAttributedString * middleStr = [[NSAttributedString alloc] initWithString:content attributes:attributes2];
        [string appendAttributedString:middleStr];
    }
    
    return string;
}
@end
