#import "ProfileVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "User.h"
#import "Location.h"
#import "ProfileViewCell.h"
#import "FollowVC.h"
#import "AppDelegate.h"
#import <UIScrollView+InfiniteScroll.h>
#import "CustomInfiniteIndicator.h"
#import "ActivityPhotoDetailsVC.h"
#import "SettingVC.h"

@interface ProfileVC()
@property (nonatomic,strong) UIRefreshControl * refreshControl;
@property (nonatomic,strong) CustomInfiniteIndicator *infiniteIndicator;
@end
@implementation ProfileVC

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:self.mode];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Profile"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    [self.refreshControl beginRefreshing];
    
    [self updateData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.defaults = [NSUserDefaults standardUserDefaults];
    self.locationArray=[[NSMutableArray alloc]init];
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.current_user_id=[self.defaults objectForKey:@"user_id"];
    [self.profileTable addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(updateData) forControlEvents:UIControlEventValueChanged];
    self.appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.displayItemCount = 3;
    
    self.profileTable.estimatedRowHeight = 323.f;
    self.profileTable.rowHeight = UITableViewAutomaticDimension;
    
    self.profileTable.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    self.infiniteIndicator = [[CustomInfiniteIndicator alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    self.profileTable.infiniteScrollIndicatorView = self.infiniteIndicator;
    
    [self.profileTable addInfiniteScrollWithHandler:^(UITableView* tableView) {
        self.displayItemCount += 5;
        self.displayItemCount = MIN(self.locationArray.count,self.displayItemCount);
        [self.infiniteIndicator startAnimating];
        [tableView reloadData];
        [tableView finishInfiniteScroll];
    }];
    [self.profileTopBar setHeaderStyle:!self.mode title:@"" rightBtnHidden:NO];
    if(self.mode)
    {
        [self.profileTopBar.rightBtn setImage:[UIImage imageNamed:@"ItemMore2"] forState:UIControlStateNormal];
        if([self.profile_user_id  isEqualToString: self.current_user_id])
        {
            self.profileTopBar.rightBtn.hidden=YES;
            self.profileTopBar.rightBtn.enabled=NO;
        }
    }
    
    
}

-(void) updateData
{
    self.kudoCount=0;
    if(!self.mode)
    {
        self.profile_user_id=self.current_user_id;
    }
    self.kudoArray=[[NSMutableDictionary alloc]init];
    [self.firstArray removeAllObjects];
    [self.secondArray removeAllObjects];
    self.firstArray=[[NSMutableDictionary alloc] init];
    self.secondArray=[[NSMutableDictionary alloc] init];
    self.dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    self.locationArray=[[NSMutableArray alloc]init];
    [[self.dynamoDBObjectMapper load:[User class] hashKey:self.profile_user_id rangeKey:nil]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.error) {
             [self networkError];
             [self.refreshControl endRefreshing];
         }
         if (task.exception) {
             [self networkError];
             [self.refreshControl endRefreshing];
         }
         if (task.result) {
             self.profile_user=task.result;
             
             [self.profileTopBar.lblTopBarTitle setText:self.profile_user.nick_name];
             AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
             scanExpression.filterExpression = @"cleaner_id = :val";
             scanExpression.expressionAttributeValues = @{@":val":self.profile_user.user_id};
             [[self.dynamoDBObjectMapper scan:[Location class]
                                   expression:scanExpression]
              continueWithBlock:^id(AWSTask *task) {
                  if (task.result) {
                      AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                      self.formattedCleansCount = [NSString stringWithFormat:@"%lu",(unsigned long)paginatedOutput.items.count];
                      for (Location *location in paginatedOutput.items)
                      {
                          if([location.isDirty isEqualToString:@"false"]) //cleaned
                          {
                              //Counting item count
                              [self.locationArray addObject:location];
                              //Adding total kudo count
                              self.kudoCount+=location.kudos.count;
                              if(location.kudos!=nil)
                              {
                                  for(NSDictionary *kudo_gaver in location.kudos)
                                  {
                                      if([[kudo_gaver objectForKey:@"id"] isEqualToString:self.current_user_id])
                                      {
                                          [self.kudoArray setObject:@"true" forKey:location.location_id];
                                          break;
                                      }
                                  }
                              }
                              
                          }
                          
                      }
                      self.displayItemCount = MIN(self.locationArray.count,self.displayItemCount);
                      dispatch_async(dispatch_get_main_queue(), ^{
                          if([self.locationArray count]>0)
                              self.locationArray = (NSMutableArray*)[self.locationArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                                  double first = ((Location*)a).cleaned_date;
                                  double second = ((Location*)b).cleaned_date;
                                  return first<second;
                              }];
                          
                          [self.profileTable reloadData];
                          [self.refreshControl endRefreshing];
                          
                      });
                  }
                  
                  return nil;
              }];
             AWSDynamoDBScanExpression *scanExpression2 = [AWSDynamoDBScanExpression new];
             
             scanExpression2.filterExpression = @"founder_id = :val";
             scanExpression2.expressionAttributeValues = @{@":val":self.profile_user.user_id};
             [[self.dynamoDBObjectMapper scan:[Location class]
                                   expression:scanExpression2]
              continueWithBlock:^id(AWSTask *task) {
                  
                  if (task.result) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                          self.formattedFindsCount = [NSString stringWithFormat:@"%lu",(unsigned long)paginatedOutput.items.count];
                          
                          [self.profileTable reloadData];
                      });
                  }
                  return nil;
              }];
             if(self.profile_user.followings)
                 self.appDelegate.followingArray=self.profile_user.followings;
             if(self.profile_user.followers)
                 self.appDelegate.followersArray=self.profile_user.followers;
             self.luser_location=[NSString stringWithFormat:@"%@, %@, %@",self.profile_user.location,self.profile_user.state,self.profile_user.country];
             
         }
         return nil;
     }];
    
}

-(void) updateCell
{
    self.kudoArray=[[NSMutableDictionary alloc]init];
    self.locationArray = [[NSMutableArray alloc]init];
    self.kudoCount=0;
    self.dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.filterExpression = @"cleaner_id = :val";
    scanExpression.expressionAttributeValues = @{@":val":self.profile_user.user_id};
    [[self.dynamoDBObjectMapper scan:[Location class]
                          expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.result) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             
             for (Location *location in paginatedOutput.items)
             {
                 if([location.isDirty isEqualToString:@"false"]) //cleaned
                 {
                     //Counting item count
                     [self.locationArray addObject:location];
                     
                     //Adding total kudo count
                     self.kudoCount+=location.kudos.count;
                     if(location.kudos!=nil)
                     {
                         for(NSDictionary *kudo_gaver in location.kudos)
                         {
                             if([[kudo_gaver objectForKey:@"id"] isEqualToString:self.current_user_id])
                             {
                                 [self.kudoArray setObject:@"true" forKey:location.location_id];
                                 break;
                             }
                         }
                     }
                 }
                 
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 if([self.locationArray count]>0)
                     self.locationArray = (NSMutableArray*)[self.locationArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                         double first = ((Location*)a).cleaned_date;
                         double second = ((Location*)b).cleaned_date;
                         return first<second;
                     }];
                 
                 [self.profileTable reloadData];
                 [self.refreshControl endRefreshing];
                 
             });
         }
         
         return nil;
     }];
    
}

-(void)followClicked:(UIButton*)sender
{
    
    NSString *user= [self.defaults objectForKey:@"user_id"];
    User * currentuser=[self.appDelegate.userArray objectForKey:user];
    
    NSString * target_id=self.profile_user.user_id;
    User * targetuser=self.profile_user;
    
    NSMutableArray * followerArray=[[NSMutableArray alloc] init]; //Add current user to the follower list of the user on the table
    NSMutableArray * followingArray=[[NSMutableArray alloc] init];
    if(targetuser.followers!=nil)
        followerArray=targetuser.followers;
    
    if(currentuser.followings!=nil)
        followingArray=currentuser.followings;
    
    NSMutableDictionary *followerItem=[[NSMutableDictionary alloc]init];
    [followerItem setObject:user forKey:@"id"];
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
        if([followingArray count]>0)
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
         if (task.error) {
             [self networkError];
         }
         if (task.exception) {
             [self networkError];
             
         }
         if (task.result) {
             //Updating target using followers
             if(![target_id isEqual:user])
             {
                 if(followerArray!=nil)
                 {
                     NSMutableArray * removeArray=[[NSMutableArray alloc]init];
                     for(NSDictionary *follower in followerArray)
                     {
                         if([[follower objectForKey:@"id"] isEqualToString:user])
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
                              sender.selected = !sender.selected;
                              sender.enabled = YES;
                              [self.profileTable reloadData];
                              if(selected)
                                  [self generateNotification:target_id];
                          });
                      }
                      
                      return nil;
                  }];
             }
             
         }
         
         return nil;
     }];
    
}

-(void) generateNotification:(NSString*) target_id
{
    self.defaults=[NSUserDefaults standardUserDefaults];
    NSString *user_name = [self.defaults objectForKey:@"user_name"];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    NSString * attributedString;
    
    attributedString=[NSString stringWithFormat:@"%@ started following you", user_name];
    
    [[dynamoDBObjectMapper load:[User class] hashKey:target_id rangeKey:nil]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.result) {
             User * user=task.result;
             
             if(user.device_token)
             {
                 if([AppDelegate isFollowing:user])
                     [self.appDelegate send_notification:user message:attributedString];
             }
             
         }
         return nil;
     }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount=0;
    if(section==0)
        rowCount=1;
    else if(section==1)
        rowCount=1;
    else if(section==2)
    {
        if([self.locationArray count]>0)
            rowCount=self.displayItemCount;
        else
            rowCount=0;
    }
    
    return rowCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount=3;
    NSString *user= [self.defaults objectForKey:@"user_id"];
    User * currentuser=[self.appDelegate.userArray objectForKey:user];
    if([currentuser.blocked_by containsObject:self.profile_user.user_id])
        sectionCount = 2;
    return sectionCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ProfileViewCell * cell=nil;
    if(indexPath.section==0)
    {
        if(indexPath.row==0)
        {
            if(self.profile_user)
            {
                cell = (ProfileViewCell*)[tableView dequeueReusableCellWithIdentifier:@"profileViewCell"];
                [cell.btnFollow addTarget:self action:@selector(followClicked:) forControlEvents:UIControlEventTouchUpInside];
                NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=100&&height=100", self.profile_user.user_id];
                
                if([self.profile_user.has_photo isEqualToString:@"yes"])
                    userImageURL = [NSString stringWithFormat:@"https://s3-ap-northeast-1.amazonaws.com/cleanthecreeks/%@", self.profile_user.user_id];
                NSURL *url = [NSURL URLWithString:userImageURL];
                
                NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (data) {
                        UIImage *image = [UIImage imageWithData:data];
                        if (image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                {
                                    self.profileImage = image;
                                    if(cell)
                                        [cell.userPhoto setImage: image];
                                }
                                
                            });
                        }
                    }
                }];
                [task resume];
                
                [cell.user_name setText:self.profile_user.user_name ];
                //[cell.user_quotes setText:self.profile_user.user_about];
                [cell.user_location setText:self.luser_location];
                [cell.user_tagline setText:self.profile_user.tagline];
                [cell.website_url setText:self.profile_user.website_url];
                
                
                //Removed email
                //[cell.user_email setText:self.profile_user.user_email];
                UITapGestureRecognizer *followingTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFollowing)];
                followingTap.numberOfTapsRequired=1;
                
                UITapGestureRecognizer *followersTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFollower)];
                followersTap.numberOfTapsRequired=1;
                
                UITapGestureRecognizer *webTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showWebsite)];
                webTap.numberOfTapsRequired=1;
                
                [cell.user_following addGestureRecognizer:followingTap];
                [cell.followingLabel addGestureRecognizer:followingTap];
                [cell.user_follows addGestureRecognizer:followersTap];
                [cell.followersLabel addGestureRecognizer:followersTap];
                [cell.website_url addGestureRecognizer:webTap];
                cell.btnFollow.hidden = [self.profile_user.user_id  isEqualToString: self.current_user_id];
                [cell.btnFollow setImage:[UIImage imageNamed:@"btnKudoSelect"] forState:UIControlStateNormal];
                [cell.btnFollow setImage:[UIImage imageNamed:@"btnKudoUnselect"] forState:UIControlStateSelected];
                
                if([AppDelegate isFollowing:self.profile_user])
                    cell.btnFollow.selected = YES;
                else
                    cell.btnFollow.selected = NO;
                if(self.appDelegate.followingArray!=nil)
                    [cell.user_following setText:[NSString stringWithFormat:@"%lu",(unsigned long)[self.profile_user.followings count]]];
                if(self.appDelegate.followersArray!=nil)
                    [cell.user_follows setText:[NSString stringWithFormat:@"%lu",(unsigned long)[self.profile_user.followers count]]];
            }
        }
    }
    
    else if(indexPath.section==1)
    {
        if(indexPath.row==0)
        {
            if(self.profile_user)
            {
                cell = (ProfileViewCell*)[tableView dequeueReusableCellWithIdentifier:@"kudoCell"];
                [cell.user_cleans setTitle:self.formattedCleansCount forState:UIControlStateNormal];
                [cell.user_spotsfound setTitle:self.formattedFindsCount forState:UIControlStateNormal];
                [cell.user_kudos setTitle:[NSString stringWithFormat:@"%lu", (long)self.kudoCount] forState:UIControlStateNormal];
                
                cell.layer.masksToBounds = NO;
                cell.layer.shadowColor = [[UIColor blackColor] CGColor] ;
                cell.layer.shadowOffset = CGSizeMake(0, 1);
                cell.layer.shadowRadius = 1.0f;
                cell.layer.shadowOpacity = 0.6f;

            }
        }
        
    }
    else if(indexPath.section>1)
    {
        if([self.locationArray count] > 0)
        {
            if([self.locationArray objectAtIndex:indexPath.row])
            {
                cell = (ProfileViewCell*)[tableView dequeueReusableCellWithIdentifier:@"activityCell"];
                cell.parentVC = self;
                Location * location=[self.locationArray objectAtIndex:indexPath.row];
                NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@""];
                UIColor * color1 = [UIColor blackColor];
                UIColor * color2= [UIColor colorWithRed:(145/255.0) green:(145/255.0) blue:(145/255.0) alpha:1.0];
                
                UIFont *font1 = [UIFont fontWithName:@"Lato-Bold" size:15.0];
                NSDictionary *fontAttr1 = [NSDictionary dictionaryWithObject:font1 forKey:NSFontAttributeName];
                NSDictionary * attributes1 = [NSDictionary dictionaryWithObject:color1 forKey:NSForegroundColorAttributeName];
                                NSDictionary * attributes2 = [NSDictionary dictionaryWithObject:color2 forKey:NSForegroundColorAttributeName];
                NSAttributedString * nameStr;
                if(self.profile_user.user_name!=nil)
                {
                    nameStr = [[NSAttributedString alloc] initWithString:self.profile_user.user_name attributes:attributes1];
                    
                    [string appendAttributedString:nameStr];
                
                }
                [string addAttributes:fontAttr1 range:NSMakeRange(0,[nameStr length])];
                NSAttributedString * middleStr = [[NSAttributedString alloc] initWithString:@" finished cleaning " attributes:attributes2];
                [string appendAttributedString:middleStr];
                NSAttributedString * locationStr;
                if(location.location_name!=nil)
                {
                    locationStr = [[NSAttributedString alloc] initWithString:location.location_name attributes:attributes1];
                    
                    [string appendAttributedString:locationStr];
                }
                [string addAttributes:fontAttr1 range:NSMakeRange([nameStr length]+[middleStr length],[locationStr length])];
                [cell.comment setAttributedText:string];
                [cell.location setText: location.location_name];
                NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MMM dd, yyyy"];
                [cell.btnKudo setImage:[UIImage imageNamed:@"IconKudos2"] forState:UIControlStateNormal];
                [cell.btnKudo setImage:[UIImage imageNamed:@"IconKudos3"] forState:UIControlStateSelected];
                
                if([[self.kudoArray objectForKey:location.location_id] isEqualToString:@"true"])
                {
                    cell.btnKudo.selected=YES;
                }
                else
                    cell.btnKudo.selected=NO;
                cell.btnKudo.tag=indexPath.row;
                [cell.date setText:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:location.cleaned_date]]];
                [cell.kudoCount setText:[[NSString alloc]initWithFormat:@"%ld",(long)location.kudos.count]];
                cell.beforePhoto.tag = indexPath.row;
                cell.afterPhoto.tag = indexPath.row;
                [cell.beforePhoto setImage:[UIImage imageNamed:@"EmptyPhoto"]];
                
                [cell.afterPhoto setImage:[UIImage imageNamed:@"EmptyPhoto"]];
                
                if([self.firstArray objectForKey:location.location_id])
                    [cell.beforePhoto setImage:[self.firstArray objectForKey:location.location_id]];
                else
                {
                    
                    NSString *userImageURL = [NSString stringWithFormat:@"https://s3-ap-northeast-1.amazonaws.com/cleanthecreeks/%@%@", location.location_id,@"a"];
                    NSURL *url = [NSURL URLWithString:userImageURL];
                    
                    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        if (data) {
                            UIImage *image = [UIImage imageWithData:data];
                            if (image) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    {
                                        
                                        if(cell)
                                            [cell.beforePhoto setImage: image];
                                        [self.firstArray setObject:image forKey:location.location_id];
                                        
                                    }
                                    
                                });
                            }
                            else{
                                NSLog(@"else");
                            }
                        }
                    }];
                    [task resume];
                }
                if([self.secondArray objectForKey:location.location_id])
                    [cell.afterPhoto setImage:[self.secondArray objectForKey:location.location_id]];
                else
                {
                    NSString *userImageURL = [NSString stringWithFormat:@"https://s3-ap-northeast-1.amazonaws.com/cleanthecreeks/%@%@", location.location_id,@"b"];
                    NSURL *url = [NSURL URLWithString:userImageURL];
                    
                    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        if (data) {
                            UIImage *image = [UIImage imageWithData:data];
                            if (image) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    {
                                        if(cell)
                                            [cell.afterPhoto setImage: image];
                                        
                                        [self.secondArray setObject:image forKey:location.location_id];
                                        
                                    }
                                    
                                });
                            }
                            else{
                                NSLog(@"else");
                            }
                        }
                    }];
                    [task resume];
                }
                UITapGestureRecognizer *locationTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showLocation:)];
                locationTap.numberOfTapsRequired=1;
                
                UITapGestureRecognizer *locationTap2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showLocation:)];
                locationTap2.numberOfTapsRequired=1;
                [cell.beforePhoto setUserInteractionEnabled:YES];
                [cell.afterPhoto setUserInteractionEnabled:YES];
                
                [cell.beforePhoto addGestureRecognizer:locationTap];
                [cell.afterPhoto addGestureRecognizer:locationTap2];
                
                //Adding shadows
                
                ((ProfileViewCell*)cell).cellView.layer.masksToBounds = NO;
                ((ProfileViewCell*)cell).cellView.layer.shadowColor = [[UIColor blackColor] CGColor] ;
                ((ProfileViewCell*)cell).cellView.layer.shadowOffset = CGSizeMake(0, 1);
                ((ProfileViewCell*)cell).cellView.layer.shadowRadius = 1.0f;
                ((ProfileViewCell*)cell).cellView.layer.shadowOpacity = 0.6f;
            }
        }
        
    }
    if(!cell){
        cell=[[UITableViewCell alloc]init];
        cell.backgroundColor=[UIColor colorWithRed:238.0 green:238.0 blue:238.0 alpha:1];
    }
    return cell;
}

-(void) showWebsite
{
    NSURL *url = [NSURL URLWithString:self.profile_user.website_url];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Invalid url" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void) showLocation:(id) sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    self.selectedIndex = gesture.view.tag;
    [self performSegueWithIdentifier:@"showLocationFromProfile" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma ProfileTopBarVCDelegate Implementation

- (void)leftBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    [self dismissVC];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)rightBtnTopBarTapped:(UIButton *)sender topBar:(id)topBar{
    self.defaults = [NSUserDefaults standardUserDefaults];
    NSString *user= [self.defaults objectForKey:@"user_id"];
    User * currentuser=[self.appDelegate.userArray objectForKey:self.profile_user_id];
    NSString * title = @"Block User";
    if([currentuser.blocked_by containsObject:user])
        title = @"Unblock User";
    //Add current user to the follower list of the user on the table
    if(!self.mode)
        [self performSegueWithIdentifier:@"ProfileVC2SettingVC" sender:nil];
    else
    {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            // Cancel button tappped.
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            NSMutableArray * blockArray=[[NSMutableArray alloc] init];
            if(currentuser.blocked_by!=nil)
                blockArray = currentuser.blocked_by;
            
            if(![blockArray containsObject:user])
                [blockArray addObject:user];
            else
                [blockArray removeObject:user];
            if([blockArray count]>0)
                currentuser.blocked_by = blockArray;
            else
                currentuser.blocked_by = nil;
            AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
            AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
            updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorUpdate;
            
            [[dynamoDBObjectMapper save:currentuser configuration:updateMapperConfig]
             continueWithBlock:^id(AWSTask *task) {
                 if (task.error) {
                     NSLog(@"%@",task.error);
                 }
                 if (task.exception) {
                     [self networkError];
                     
                 }
                 if (task.result) {
                     
                     //Updating target using followers
                 }
                 
                 return nil;
             }];
            
            // Distructive button tapped.
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }]];
        
        // Present action sheet.
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

-(void)showFollowing
{
    [self performSegueWithIdentifier:@"showFollowing" sender:self];
}

-(void)showFollower
{
    [self performSegueWithIdentifier:@"showFollowers" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if([segue.identifier isEqual:@"showFollowing"])
    {
        FollowVC *followVC=(FollowVC*)segue.destinationViewController;
        if(self.profile_user)
            
            followVC.profile_user = self.profile_user;
        followVC.displayIndex=0;
        
        [followVC.followSegment setSelectedSegmentIndex:0];
    }
    else if([segue.identifier isEqual:@"showFollowers"])
    {
        FollowVC *followVC=(FollowVC*)segue.destinationViewController;
        if(self.profile_user)
            
            followVC.profile_user = self.profile_user;
        followVC.displayIndex=1;
        [followVC.followSegment setSelectedSegmentIndex:1];
    }
    else if([segue.identifier isEqual:@"showLocationFromProfile"])
    {
        ActivityPhotoDetailsVC *vc=(ActivityPhotoDetailsVC*)segue.destinationViewController;
        vc.location = [self.locationArray objectAtIndex:self.selectedIndex];
        vc.beforePhoto = [self.firstArray objectForKey:vc.location.location_id];
        vc.afterPhoto = [self.secondArray objectForKey:vc.location.location_id];
        vc.isKudoed = [[self.kudoArray objectForKey:vc.location.location_id] isEqualToString:@"true"];
        
        vc.cleaned = YES;
        vc.fromLocationView = YES;
        
    }
    else if ([segue.identifier isEqualToString:@"ProfileVC2SettingVC"])
    {
        SettingVC *vc=(SettingVC*)segue.destinationViewController;
        vc.current_user = self.profile_user;
        vc.profile_image = self.profileImage;
    }
}

@end
