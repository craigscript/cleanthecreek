//
//  KudosVC.m
//  Clean the Creek
//
//  Created by a on 2/22/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "KudosVC.h"
#import "KudosCell.h"
#import "AppDelegate.h"
@interface KudosVC()
@property (nonatomic,strong) UIRefreshControl * refreshControl;
@end
@implementation KudosVC

-(void) viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.current_user_id = [defaults objectForKey:@"user_id"];
    [self.profileTopBar setHeaderStyle:NO title:@"KUDOS" rightBtnHidden:YES];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.kudoTable addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(updateData) forControlEvents:UIControlEventValueChanged];
    self.appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    dispatch_async(dispatch_get_main_queue(), ^{
    [self updateData];
    });
    self.kudoTable.estimatedRowHeight = 79.f;
    self.kudoTable.rowHeight = UITableViewAutomaticDimension;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    [self dismissVC];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Kudos"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void)updateData
{
    self.userArray=[[NSMutableArray alloc] init];
    
    for(NSMutableDictionary *kudo in self.location.kudos)
    {
        
        User * user=[self.appDelegate.userArray objectForKey:[kudo objectForKey:@"id"]];
        [self.userArray addObject:user];
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.kudoTable reloadData];
        [self.refreshControl endRefreshing];
        
    });
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.userArray)
    {
        return [self.userArray count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger row = indexPath.row;
    KudosCell *cell;
    
    if([self.userArray count]>0)
    {
        User * user=[self.userArray objectAtIndex:row];
        
        cell = (KudosCell*)[tableView dequeueReusableCellWithIdentifier:@"KudosCell" forIndexPath:indexPath];
        
        [cell.user_photo setImage:[self.imageArray objectForKey:user.user_id]];
        [cell.user_name setText:user.user_name];
        [cell.user_location setText:user.location];
        cell.likeButton.tag=indexPath.row;
        [cell.likeButton setImage:[UIImage imageNamed:@"btnKudoSelect"] forState:UIControlStateNormal];
        [cell.likeButton setImage:[UIImage imageNamed:@"btnKudoUnselect"] forState:UIControlStateSelected];
        [cell.likeButton setSelected:NO];
        if(![user.user_id isEqualToString:self.current_user_id])
        {
            if([AppDelegate isFollowing:user])
                [cell.likeButton setSelected:YES];
            
            
            [cell.likeButton addTarget:self action:@selector(kudoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
            cell.likeButton.hidden=YES;
    }
    if (cell == nil){
        return [[UITableViewCell alloc] init];
    }
    return cell;
}

-(void)kudoButtonClicked:(UIButton*)sender
{
    User * targetuser=[self.userArray objectAtIndex:sender.tag];
    NSString * target_id=targetuser.user_id;
    
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
        currentuser.followings=[[NSMutableArray alloc] initWithArray:followingArray];
    else
        currentuser.followings=nil;
    sender.enabled=NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
    updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorUpdate;
    
    [[dynamoDBObjectMapper save:currentuser configuration:updateMapperConfig]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.result) {
             
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
                     targetuser.followers=[[NSMutableArray alloc] initWithArray:followerArray];
                 else
                     targetuser.followers=nil;
                 
                 
                 [[dynamoDBObjectMapper save:targetuser configuration:updateMapperConfig]
                  continueWithBlock:^id(AWSTask *task) {
                      if (task.result) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [self.appDelegate loadData];
                              [self.kudoTable reloadData];
                              sender.enabled=YES;
                          });
                          
                      }
                      
                      return nil;
                  }];
             }
             
         }
         
         return nil;
     }];
    
    
}

@end
