//
//  locationCell.m
//  Clean the Creeks
//
//  Created by Kimura Isoroku on 2/6/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "locationCell.h"

@implementation locationCell

- (void)awakeFromNib {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.view addGestureRecognizer:tap];
}
-(void) didTapOnTableView:(UIGestureRecognizer*) recognizer {
    [self updateBtnsHidden:YES];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)moreBtnTapped:(id)sender {
    [self updateBtnsHidden:NO];
}

- (IBAction)cleanBtnTapped:(id)sender {
    [self updateBtnsHidden:YES];
    
}

- (IBAction)viewBtnTapped:(id)sender {
    [self updateBtnsHidden:YES];
}

- (void)updateBtnsHidden:(BOOL)hidden {
    [self.cleanBtn setHidden:hidden];
    [self.viewBtn setHidden:hidden];
    [UIView animateWithDuration:0.8 animations:^{
        self.cleanBtn.alpha = hidden ? 0 : 1;
        self.viewBtn.alpha = hidden ? 0 : 1;
    }];
}


@end
