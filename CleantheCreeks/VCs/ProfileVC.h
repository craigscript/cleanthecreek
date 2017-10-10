#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

#import <AWSS3/AWSS3.h>
#import "AppDelegate.h"
#import "User.h"
@interface ProfileVC : BaseVC<UITableViewDataSource, UITableViewDelegate>

@property (strong,nonatomic) NSMutableArray * locationArray;
@property (weak, nonatomic) IBOutlet UITableView *profileTable;

@property (strong, nonatomic) UIImage * profileImage;
@property (nonatomic) bool mode;
@property (strong,nonatomic) NSString *luser_location,*profile_user_id;

@property (strong,nonatomic) User * profile_user;
@property (strong,nonatomic) NSString *formattedCleansCount;
@property (strong,nonatomic) NSString *formattedFindsCount;
@property (strong,nonatomic) AWSDynamoDBObjectMapper *dynamoDBObjectMapper;
@property  NSInteger kudoCount;
@property (strong,nonatomic) NSMutableDictionary*firstArray, *secondArray;
@property (strong, nonatomic) AppDelegate * appDelegate;
@property (strong, nonatomic) NSMutableArray *followingArray, *followerArray ;
@property(nonatomic) long displayItemCount, selectedIndex;
@property (strong, nonatomic) NSMutableDictionary * kudoArray;
- (void)updateData;
- (void)updateCell;

@end
