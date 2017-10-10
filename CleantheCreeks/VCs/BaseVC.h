//
//  BaseVC.h
//  Clean the Creek
//
//  Created by a on 2/24/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileTopBarVC.h"
#import <Google/Analytics.h>
@interface BaseVC : UIViewController<ProfileTopBarVCDelegate>

@property (nonatomic, weak) ProfileTopBarVC* profileTopBar;
@property (nonatomic,strong) NSUserDefaults * defaults;
- (void)dismissVC;
@property(strong,nonatomic) NSString * current_user_id;

- (void) networkError;
- (void) commentError;
- (NSString*) generateUserName:(NSString *)userName;

@end
