//
//  ProfileTopBarVC.m
//  Clean the Creek
//
//  Created by a on 2/24/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "ProfileTopBarVC.h"

@implementation ProfileTopBarVC

- (void)setHeaderStyle:(BOOL)leftBtnHidden title:(NSString*)title rightBtnHidden:(BOOL)rightBtnHidden{
    self.leftBtn.hidden = leftBtnHidden;
    self.rightBtn.hidden = rightBtnHidden;
    self.lblTopBarTitle.text = title;
}

- (IBAction)rightBtnTapped:(id)sender {
    if (self.delegate){
        [self.delegate rightBtnTopBarTapped:sender topBar:self];
    }
}

- (IBAction)leftBtnTapped:(id)sender {
    if (self.delegate){
        [self.delegate leftBtnTopBarTapped:sender topBar:self];
    }
}

@end
