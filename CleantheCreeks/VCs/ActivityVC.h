#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "Location.h"
#import <AWSS3/AWSS3.h>
#import "AppDelegate.h"
#import "ActivityPhotoDetailsVC.h"

@interface ActivityVC : BaseVC<UITableViewDataSource, UITableViewDelegate, KudoDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tv;
@property (strong,nonatomic) AWSDynamoDBObjectMapper *dynamoDBObjectMapper;
@property (strong,nonatomic) NSMutableArray * activityArray;
@property (strong,nonatomic) NSMutableDictionary * imageArray;
@property (strong,nonatomic) AppDelegate * appDelegate;
@property(nonatomic) long displayItemCount;

@property (strong, nonatomic) Location * selectedLocation;
@property(strong,nonatomic)NSString *current_user;
@property(nonatomic)NSInteger selectedIndex;
@property(nonatomic) long selectedImgIndex;
@property(strong, nonatomic)NSMutableArray * indexPathArray;

-(void) updateCell;

- (NSMutableAttributedString *)generateString:(NSString*)name content:(NSString*)content location:(NSString*) location;
@end
