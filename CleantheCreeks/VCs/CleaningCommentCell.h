//
//  CleaningCommentCell.h
//  Clean the Creek
//
//  Created by a on 2/22/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CleaningCommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UILabel *activityHours;


- (void)setValue:(id)delegate avatarImage:(NSString*)avatarImage content:(NSString*)content activityHours:(NSNumber*)hours;
@end
