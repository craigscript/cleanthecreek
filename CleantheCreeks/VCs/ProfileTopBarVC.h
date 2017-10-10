//
//  ProfileTopBarVC.h
//  Clean the Creek
//
//  Created by a on 2/24/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileTopBarVCDelegate <NSObject>

- (void)leftBtnTopBarTapped:(UIButton*)sender topBar:(id)topBar;

- (void)rightBtnTopBarTapped:(UIButton*)sender topBar:(id)topBar;

@end


@interface ProfileTopBarVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblTopBarTitle;

@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;

@property (nonatomic, weak) id<ProfileTopBarVCDelegate> delegate;

- (void)setHeaderStyle:(BOOL)leftBtnHidden title:(NSString*)title rightBtnHidden:(BOOL)rightBtnHidden;
@end
