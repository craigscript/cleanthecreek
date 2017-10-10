//
//  FollowVC.m
//  Clean the Creek
//
//  Created by Kimura Eiji on 04/03/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "FollowVC.h"
#import "KudosCell.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

#import "User.h"
#import "Location.h"
#import "ProfileVC.h"
@interface FollowVC()
@property (nonatomic,strong) UIRefreshControl * refreshControl;
@property(nonatomic) int mode;
@end

@implementation FollowVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Following"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.followSegment setSelectedSegmentIndex:self.displayIndex];
    self.appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    [self.profileTopBar setHeaderStyle:NO title:self.profile_user.user_name rightBtnHidden:YES];
    [self.tabBarController.tabBar setHidden:YES];
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.followTable addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    
    self.current_user_id = [self.defaults objectForKey:@"user_id"];
    [self.refreshControl beginRefreshing];
    self.profileTopBar.rightBtn.enabled = NO;
    [self loadData];
}

-(void)loadData
{
    self.displayArray = [[NSMutableArray alloc]init];
    self.imageArray = [[NSMutableDictionary alloc]init];
    NSString * user_id=self.current_user_id;
    if(self.profile_user)
        user_id=self.profile_user.user_id;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    [[dynamoDBObjectMapper scan:[User class] expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.result) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             for (User *user in paginatedOutput.items)
             {
                 [self.appDelegate.userArray setObject:user forKey:user.user_id];
                 
                 if([user.user_id isEqualToString:user_id])
                 {
                     self.followerArray=user.followers;
                     self.followingArray=user.followings;
                     
                 }
                 
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 if(self.displayIndex == 0)
                     self.displayArray = self.followingArray;
                 
                 else if(self.displayIndex == 1)
                     self.displayArray = self.followerArray;
                 [self.followTable reloadData];
                 [self.refreshControl endRefreshing];
                 
             });
         }
         return nil;
     }];
    
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.displayArray count];
}

-(void) showProfile:(id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    self.selectedImgIndex = gesture.view.tag;
    NSLog(@"%ld",self.selectedImgIndex);
    if([self.displayArray count]>0)
    {
        NSDictionary * user = [self.displayArray objectAtIndex:self.selectedImgIndex];
        NSString * user_id = [user objectForKey:@"id"];
        if(![user_id isEqualToString:_profile_user.user_id])
        {
            [self performSegueWithIdentifier:@"showProfileFromFollow" sender:self];
        }
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if([self.displayArray count]>0)
    {
        NSDictionary * user = [self.displayArray objectAtIndex:self.selectedImgIndex];
        NSString * user_id = [user objectForKey:@"id"];
        
        if([segue.identifier isEqualToString:@"showProfileFromFollow"])
        {
            ProfileVC * vc=(ProfileVC*)segue.destinationViewController;
            vc.profile_user_id = user_id;
            vc.mode = YES;
            self.appDelegate.shouldRefreshProfile = YES;
        }
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITapGestureRecognizer *followTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showProfile:)];
    followTap.numberOfTapsRequired=1;
    
    UITapGestureRecognizer *followTap2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showProfile:)];
    followTap2.numberOfTapsRequired=1;
    
    KudosCell* cell = (KudosCell*)[tableView dequeueReusableCellWithIdentifier:@"KudosCell"];
    NSDictionary * current_user=[self.displayArray objectAtIndex:indexPath.row];
    NSDictionary * user_id=[current_user objectForKey:@"id"];
    User * user=[self.appDelegate.userArray objectForKey:user_id];
    
    [cell.user_photo setImage:[self.imageArray objectForKey:user.user_id]];
    
    if([self.imageArray objectForKey:user.user_id]!=nil)
    {
        [cell.user_photo setImage: [self.imageArray objectForKey:user.user_id]];
    }
    else
    {
        NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", user.user_id];
        if([user.has_photo isEqualToString:@"yes"])
            userImageURL = [NSString stringWithFormat:@"https://s3-ap-northeast-1.amazonaws.com/cleanthecreeks/%@", user.user_id];
        NSURL *url = [NSURL URLWithString:userImageURL];
        
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        {
                            [self.imageArray setObject:image forKey:user.user_id];
                            
                        }
                        if(cell)
                            [cell.user_photo setImage: image];
                    });
                }
            }
        }];
        [task resume];
    }
    
    cell.likeButton.hidden = [user.user_id isEqualToString:self.current_user_id];
    [cell.user_name setText:user.user_name];
    [cell.user_location setText:[NSString stringWithFormat:@"%@, %@, %@", user.location, user.state, user.country]];
    cell.likeButton.tag = indexPath.row;
    [cell.likeButton addTarget:self action:@selector(likeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.likeButton setImage:[UIImage imageNamed:@"btnKudoSelect"] forState:UIControlStateNormal];
    [cell.likeButton setImage:[UIImage imageNamed:@"btnKudoUnselect"] forState:UIControlStateSelected];
    
    [cell.user_photo addGestureRecognizer:followTap];
    cell.user_photo.userInteractionEnabled = YES;
    
    [cell.user_name addGestureRecognizer:followTap2];
    cell.user_name.userInteractionEnabled = YES;
    
    cell.user_photo.tag = indexPath.row;
    cell.user_name.tag = indexPath.row;
    if([AppDelegate isFollowing:user])
        cell.likeButton.selected = YES;
    else
        cell.likeButton.selected =NO;
    if(!cell){
        cell = nil;
    }
    return cell;
}

- (void)likeBtnClicked:(UIButton*)sender
{
    if([self.displayArray count]==0)
        return;
    if(sender.tag > [self.displayArray count] -1)
        return;
    NSDictionary * target_user=[self.displayArray objectAtIndex:sender.tag];
    NSString * target_id=[target_user objectForKey:@"id"];
    User * targetuser=[self.appDelegate.userArray objectForKey:target_id];
    User * currentuser=[self.appDelegate.userArray objectForKey:self.current_user_id];
    
    NSMutableArray * followerArray=[[NSMutableArray alloc] init]; //Add current user to the follower list of the user on the table
    NSMutableArray * followingArray=[[NSMutableArray alloc] init];
    if(targetuser.followers!=nil)
        followerArray=targetuser.followers;
    
    if(currentuser.followings!=nil)
        followingArray=currentuser.followings;
    
    NSMutableDictionary *followerItem=[[NSMutableDictionary alloc]init];
    [followerItem setObject:self.current_user_id forKey:@"id"];
    double date =[[NSDate date]timeIntervalSince1970];
    NSNumber *dateObj = [[NSNumber alloc] initWithDouble:date];
    //NSString *dateString=[NSString stringWithFormat:@"%f",date];
    [followerItem setObject:dateObj forKey:@"time"];
    
    NSMutableDictionary *followingItem=[[NSMutableDictionary alloc]init];
    [followingItem setObject:target_id forKey:@"id"];
    [followingItem setObject:dateObj forKey:@"time"];
    
    bool selected=!sender.selected;
    
    //Updating current user followings
    
    if(followingArray!=nil)
    {
        NSMutableArray * removeArray=[[NSMutableArray alloc]init];
        for(NSDictionary *following in followingArray)
        {
            if([[following objectForKey:@"id"] isEqualToString:target_id])
            {
                [removeArray addObject:following];
                
            }
        }
        [followingArray removeObjectsInArray:removeArray];
    }
    if(selected)
    {
        [followingArray addObject:followingItem];
        
    }
    
    if([followingArray count]!=0)
        currentuser.followings = [[NSMutableArray alloc] initWithArray:followingArray];
    else
        currentuser.followings=nil;
    sender.enabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
    updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorUpdate;
    
    [[dynamoDBObjectMapper save:currentuser configuration:updateMapperConfig]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.result) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 //Updating target using followers
                 if(![target_id isEqual:self.current_user_id])
                 {
                     if(followerArray!=nil)
                     {
                         NSMutableArray * removeArray=[[NSMutableArray alloc]init];
                         for(NSDictionary *follower in followerArray)
                         {
                             if([[follower objectForKey:@"id"] isEqualToString:self.current_user_id])
                             {
                                 [removeArray addObject:follower];
                             }
                         }
                         [followerArray removeObjectsInArray:removeArray];
                     }
                     if(selected)
                         [followerArray addObject:followerItem];
                     if([followerArray count]!=0)
                         targetuser.followers = [[NSMutableArray alloc] initWithArray:followerArray];
                     else
                         targetuser.followers = nil;
                     
                     [[dynamoDBObjectMapper save:targetuser configuration:updateMapperConfig]
                      continueWithBlock:^id(AWSTask *task) {
                          if (task.result) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  
                                  sender.selected=!sender.selected;
                                  sender.enabled=YES;
                                  
                                  [self loadData];
                              });
                              
                          }
                          
                          return nil;
                      }];
                     
                 }
             });
         }
         
         return nil;
     }];
    
}

- (IBAction)followingChange:(id)sender {
    self.displayIndex= self.followSegment.selectedSegmentIndex;
    if(self.followSegment.selectedSegmentIndex==0)
        self.displayArray=self.followingArray;
    else
        self.displayArray=self.followerArray;
    [self.followTable reloadData];
}

- (void)leftBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    [self dismissVC];
}

- (void)rightBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    
}

@end
