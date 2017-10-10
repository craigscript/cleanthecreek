#import "SlideVC.h"
#import "LocationVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "User.h"
#import "LocationVC.h"
#import <Google/Analytics.h>

@implementation SlideVC
UIImage *firstPicture;
UIImage *secondPicture;
UIButton *loginButton;
- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    return self;
}

- (void) loadView {
    [super loadView];
    
    IntroModel *model1 = [[IntroModel alloc] initWithTitle:@"CLEAN THE CREEK" description:@"Leave it Cleaner than you found it. " image:@"back1.jpg" ToVC:self];
    IntroModel *model2 = [[IntroModel alloc] initWithTitle:@"CLEAN THE CREEK" description:@"Tag dirty locations where you live in a fun social network." image:@"back2.jpg" ToVC:self];
    IntroModel *model3 = [[IntroModel alloc] initWithTitle:@"CLEAN THE CREEK" description:@"Join forces or go in solo to create a cleaner environment." image:@"back3.jpg" ToVC:self];
    IntroModel *model4 = [[IntroModel alloc] initWithTitle:@"CLEAN THE CREEK" description:@"Post your kudos to facebook" image:@"back4.jpg" ToVC:self];
    IntroModel *model5 = [[IntroModel alloc] initWithTitle:@"CLEAN THE CREEK" description:@"Show your facebook friends\nyour good deeds." image:@"back1.jpg" ToVC:self];
    IntroControll *control=[[IntroControll alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) pages:@[model1, model2, model3,model4,model5]];
       self.view =control;
    control.delegate=self;
    
    UITapGestureRecognizer *dtapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapLabelClicked)];
    dtapGestureRecognize.delegate = self;
    dtapGestureRecognize.numberOfTapsRequired = 1;
    UIButton *mapButton=[self.view viewWithTag:15];
    [mapButton addGestureRecognizer:dtapGestureRecognize];

    for(int i=0;i<5;i++)
    {
        UITapGestureRecognizer *fbGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginButtonClicked)];
        fbGestureRecognize.delegate = self;
        fbGestureRecognize.numberOfTapsRequired = 1;
        UIButton *fbButton=[self.view viewWithTag:i+16];
        [fbButton addGestureRecognizer:fbGestureRecognize];
    }
}

-(void) mapLabelClicked
{
    [self performSegueWithIdentifier:@"Slide2MainTabNav" sender:self];
}

- (void)viewDidLoad
{
//    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
//    NSString * termsAccepted = [defaults objectForKey:@"termsAccepted"];
//    if(!termsAccepted)
//    {
//        UIViewController *tncView = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsVC"];
//        [tncView setModalInPopover:YES];
//        [tncView setModalPresentationStyle:UIModalPresentationPopover];
//        [self presentViewController:tncView animated:YES completion:NULL];
//
//    }
    [super viewDidLoad];
    self.mainDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self.mainDelegate loadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)moveToMainNav {
    [self performSegueWithIdentifier:@"Slide2MainTabNav" sender:self];
}


-(void)loginButtonClicked
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile",@"email",@"user_friends"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else
         {
             NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
             [parameters setValue:@"id,name,email,location,about" forKey:@"fields"];
             [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
              startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                      [self moveToMainNav];
                  if (!error) {
                     
                      NSLog(@"fetched user:%@  and Email : %@", result,result[@"email"]);
                      NSUserDefaults *loginInfo = [NSUserDefaults standardUserDefaults];
                      NSString *fbUsername = [[result valueForKey:@"link"] lastPathComponent];
                      [loginInfo setObject:fbUsername forKey:@"username"];
                      [loginInfo setObject:result[@"id"] forKey:@"user_id"];
                      [loginInfo setObject:result[@"name"] forKey:@"user_name"];
                      [loginInfo setObject:result[@"email"] forKey:@"user_email"];
                      [loginInfo setObject:result[@"location"] forKey:@"user_location"];
                      [loginInfo setObject:result[@"about"] forKey:@"user_about"];
                      // Storing FB token
                      NSString *access_token=[FBSDKAccessToken currentAccessToken].tokenString;
                      [loginInfo setObject:access_token forKey:@"fb_token"];
                
                      [loginInfo synchronize];
                      User * user_info = [User new];
                      user_info.user_id = result[@"id"];
                      user_info.user_name = result[@"name"];
                      user_info.device_token = [loginInfo objectForKey:@"devicetoken"];
                      user_info.user_about = [loginInfo objectForKey:@"user_about"];
                      
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
                               NSMutableArray * userNameArray = [[NSMutableArray alloc]init];
                               NSMutableArray * user_array= [NSMutableArray arrayWithObjects:self.mainDelegate.userArray, nil];
                               for(User* user in user_array)
                               {
                                   if(user.nick_name)
                                       [userNameArray addObject:user.nick_name];
                               }
                               
                               int i=1;
                               NSString * nickName = [self generateUserName:user_info.user_name];
                               while([userNameArray containsObject:nickName])
                               {
                                   nickName = [NSString stringWithFormat:@"%@%d",[self generateUserName:user_info.user_name],i];
                                   i++;
                               }
                               user_info.nick_name = nickName;
                               AWSDynamoDBObjectMapperConfiguration *updateMapperConfig = [AWSDynamoDBObjectMapperConfiguration new];
                               updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorAppendSet;
                               AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
                               [[dynamoDBObjectMapper save:user_info configuration:updateMapperConfig]
                                continueWithBlock:^id(AWSTask *task) {
                                    if (task.error) {
                                        NSLog(@"The request failed. Error: [%@]", task.error);
                                    }
                                    if (task.exception) {
                                        NSLog(@"The request failed. Exception: [%@]", task.exception);
                                    }
                                    if (task.result) {
                                        NSLog(@"new user is registered");
                                    }
                                    return nil;
                                }];

                           }
                           return nil;
                       }];
                      


                  }
              }];
             
            
             
         }
     }];
}

-(void) lastPage:(bool)show
{
    if(show)
        [loginButton setCenter:CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height/67*42-loginButton.frame.size.height/2)];
    else
        [loginButton setCenter:CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height/23*21-loginButton.frame.size.height/2)];
        
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Home Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void) loadData
{
    
}
@end
