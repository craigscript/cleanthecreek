//
//  ProfileViewCell.h
//  Clean the Creek
//
//  Created by Kimura Eiji on 01/03/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "ProfileVC.h"
#import <AWSS3/AWSS3.h>
@interface ProfileViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *beforePhoto;
@property (weak, nonatomic) IBOutlet UIImageView *afterPhoto;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *kudoCount;
@property (weak, nonatomic) IBOutlet UILabel *comment;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;
@property (weak, nonatomic) IBOutlet UILabel *user_follows;
@property (weak, nonatomic) IBOutlet UILabel *user_following;
@property (weak, nonatomic) IBOutlet UILabel *user_name;
@property (weak, nonatomic) IBOutlet UILabel *user_quotes;
@property (weak, nonatomic) IBOutlet UILabel *user_email;
@property (weak, nonatomic) IBOutlet UILabel *user_location;
@property (weak, nonatomic) IBOutlet UIButton *user_cleans;
@property (weak, nonatomic) IBOutlet UIButton *user_spotsfound;
@property (weak, nonatomic) IBOutlet UIButton *user_kudos;
@property (weak, nonatomic) IBOutlet UILabel *followingLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnFollow;
@property (weak, nonatomic) IBOutlet UIButton *btnKudo;
- (IBAction)kudoClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *user_tagline;
@property (weak, nonatomic) IBOutlet UILabel *website_url;
@property (weak, nonatomic) IBOutlet UIView *cellView;

@property (strong, nonatomic) ProfileVC * parentVC;
@end
