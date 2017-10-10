//
//  ProfileViewCell.m
//  Clean the Creek
//
//  Created by Kimura Eiji on 01/03/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "ProfileViewCell.h"
#import "User.h"
#import "Location.h"
#import "Activity.h"
@implementation ProfileViewCell

- (IBAction)kudoClicked:(id)sender {
    if(self.parentVC.locationArray.count==0)
        return;
    UIButton * senderButton=(UIButton*)sender;
    bool selected=!senderButton.selected;
    Location * location=[self.parentVC.locationArray objectAtIndex:[sender tag]];
   
    NSMutableArray * kudoArray=[[NSMutableArray alloc] init];
    if(location.kudos!=nil)
        kudoArray = location.kudos;
    NSMutableDictionary *kudoItem = [[NSMutableDictionary alloc]init];
    [kudoItem setObject:self.parentVC.current_user_id forKey:@"id"];
    double date =[[NSDate date]timeIntervalSince1970];
    NSString *dateString=[NSString stringWithFormat:@"%f",date];
    [kudoItem setObject:dateString forKey:@"time"];
    if(kudoArray!=nil)
    {
        NSMutableArray *removeArray = [[NSMutableArray alloc]init];
        for(NSDictionary *kudo_gaver in kudoArray)
        {
            if([[kudo_gaver objectForKey:@"id"] isEqualToString:self.parentVC.current_user_id])
            {
                [removeArray addObject:kudo_gaver];
            }
        }
        [kudoArray removeObjectsInArray:removeArray];
    }
    if(selected)
        [kudoArray addObject:kudoItem];
    if([kudoArray count]!=0)
        location.kudos = [[NSMutableArray alloc] initWithArray:kudoArray];
    else
        location.kudos = nil;
    senderButton.enabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
    updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorUpdate;
    
    [[dynamoDBObjectMapper save:location configuration:updateMapperConfig]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.parentVC updateCell];
             });
             NSString * user_name = [self.parentVC.defaults objectForKey:@"user_name"];
             NSString * attributedString=[NSString stringWithFormat:@"%@ gave you kudos", user_name];
             User * user=[self.parentVC.appDelegate.userArray objectForKey:location.cleaner_id];
             if(selected)
                 [self.parentVC.appDelegate send_notification:user message:attributedString];
             
             senderButton.enabled=YES;
             
         }
         
         return nil;
     }];

}
@end
