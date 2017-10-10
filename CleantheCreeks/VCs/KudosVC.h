//
//  KudosVC.h
//  Clean the Creek
//
//  Created by a on 2/22/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "Location.h"
#import "User.h"
#import "AppDelegate.h"

@interface KudosVC : BaseVC<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *kudoTable;
@property(strong,nonatomic) Location * location;
@property(strong, nonatomic) NSMutableDictionary *imageArray,*kudoAssignedArray;
@property(strong, nonatomic) NSMutableArray *userArray;
@property (strong,nonatomic) AppDelegate * appDelegate;


@end
