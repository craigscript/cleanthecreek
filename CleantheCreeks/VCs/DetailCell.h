//
//  DetailCell1.h
//  Clean the Creek
//
//  Created by Kimura Isoroku on 2/13/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *locationName1;
@property (weak, nonatomic) IBOutlet UILabel *finderName;

@property (weak, nonatomic) IBOutlet UILabel *cleanerName;
@property (weak, nonatomic) IBOutlet UILabel *cleanedDate;
@property (weak, nonatomic) IBOutlet UILabel *foundDate;

@property (weak, nonatomic) IBOutlet UITextField *commentText;
@property (weak, nonatomic) IBOutlet UIView *cellView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomShadow;


@property (weak, nonatomic) IBOutlet UILabel *locationName2;
@end
