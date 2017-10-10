//
//  KudosCell.h
//  Clean the Creek
//
//  Created by a on 2/22/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KudosCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *user_photo;
@property (weak, nonatomic) IBOutlet UILabel *user_name;
@property (weak, nonatomic) IBOutlet UILabel *user_location;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

@end
