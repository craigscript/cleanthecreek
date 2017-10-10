//
//  FollowVC.h
//  Clean the Creek
//
//  Created by Kimura Eiji on 04/03/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "AppDelegate.h"
@interface FollowVC : BaseVC<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *followSegment;
@property (weak, nonatomic) IBOutlet UITableView *followTable;
@property (strong, nonatomic) NSMutableArray * displayArray;
@property (nonatomic) long displayIndex;
@property (strong, nonatomic) AppDelegate * appDelegate;

@property (strong, nonatomic) User * profile_user;

@property (strong ,nonatomic) NSMutableDictionary* imageArray;
@property (strong, nonatomic) NSMutableArray * userArray,*followerArray,*followingArray;
- (IBAction)followingChange:(id)sender;
@property(nonatomic) long selectedImgIndex;
@end
