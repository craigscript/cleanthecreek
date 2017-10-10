//
//  CleaningDoneCell.h
//  Clean the Creek
//
//  Created by a on 2/22/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityVC.h"
@interface CleaningDoneCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileAvatar;
@property (weak, nonatomic) IBOutlet UILabel *activityHours;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIButton *kudoCounter;
@property (weak, nonatomic) IBOutlet UIButton *giveKudos;
@property (weak, nonatomic) IBOutlet UIButton *btnKudos;
@property (weak, nonatomic) IBOutlet UIButton *btnKudoCount;
@property (weak, nonatomic) ActivityVC * parentVC;

//@property void (^callback)(int, BOOL);

@end
