//
//  CommentCell.h
//  CTC
//
//  Created by Kimura Eiji on 09/03/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIView *cellView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomShadow;


@end
