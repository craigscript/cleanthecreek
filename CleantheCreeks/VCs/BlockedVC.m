//
//  BlockedVC.m
//  CTC
//
//  Created by Andy on 7/1/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "BlockedVC.h"
#import "KudosCell.h"
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "User.h"

@interface BlockedVC()
@property (nonatomic,strong) UIRefreshControl * refreshControl;
@end

@interface BlockedVC ()

@end

@implementation BlockedVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.defaults = [NSUserDefaults standardUserDefaults];
    self.current_user_id = [self.defaults objectForKey:@"user_id"];
    [self.profileTopBar setHeaderStyle:NO title:@"Blocked Users" rightBtnHidden:YES];
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.blockedTable addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(updateData) forControlEvents:UIControlEventValueChanged];
    self.appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateData];
    });
    self.blockedTable.estimatedRowHeight = 76.f;
    self.blockedTable.rowHeight = UITableViewAutomaticDimension;

}

- (void)didReceiveMemoryWarning {
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([self.blockedArray count]>0)
        return [self.blockedArray count];
    else
        return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   User * user = self.blockedArray[indexPath.row];
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Unblock User" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Unblock User" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        NSMutableArray * blockArray=[[NSMutableArray alloc] init];
        if(user.blocked_by!=nil)
            blockArray = user.blocked_by;
        
        if([blockArray containsObject:self.current_user_id])
            [blockArray removeObject:self.current_user_id];
        if([blockArray count]>0)
            user.blocked_by = blockArray;
        else
            user.blocked_by = nil;
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
        updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorUpdate;
        
        [[dynamoDBObjectMapper save:user configuration:updateMapperConfig]
         continueWithBlock:^id(AWSTask *task) {
             if (task.error) {
                 NSLog(@"%@",task.error);
             }
             if (task.exception) {
                 [self networkError];
                 
             }
             if (task.result) {
                 [self updateData];
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
-(void)updateData
{
    
    self.blockedArray = [[NSMutableArray alloc]init];
    self.imageArray = [[NSMutableDictionary alloc]init];

    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    [[dynamoDBObjectMapper scan:[User class] expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.result) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             for (User *user in paginatedOutput.items)
             {
                 [self.appDelegate.userArray setObject:user forKey:user.user_id];
                 
                 if([user.blocked_by containsObject:self.current_user_id])
                 {
                     [self.blockedArray addObject:user];
                     
                     
                 }
                 
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                
                 [self.blockedTable reloadData];
                 [self.refreshControl endRefreshing];
                 
             });
         }
         return nil;
     }];
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger row = indexPath.row;
    KudosCell *cell;
    
    if([self.blockedArray count]>0)
    {
        User * user=[self.blockedArray objectAtIndex:row];
        
        cell = (KudosCell*)[tableView dequeueReusableCellWithIdentifier:@"KudosCell" forIndexPath:indexPath];
        
        NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=100&&height=100", user.user_id];
        
        if([user.has_photo isEqualToString:@"yes"])
            userImageURL = [NSString stringWithFormat:@"https://s3-ap-northeast-1.amazonaws.com/cleanthecreeks/%@", user.user_id];
        NSURL *url = [NSURL URLWithString:userImageURL];
        
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        {
                            
                            if(cell)
                                [cell.user_photo setImage: image];
                        }
                        
                    });
                }
            }
        }];
        [task resume];

        
        [cell.user_photo setImage:[self.imageArray objectForKey:user.user_id]];
        [cell.user_name setText:user.user_name];
        [cell.user_location setText:user.location];
        cell.likeButton.tag=indexPath.row;
    }
    if (cell == nil){
        return [[UITableViewCell alloc] init];
    }
    return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
