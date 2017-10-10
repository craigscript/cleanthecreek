    //
//  BlockedVC.h
//  CTC
//
//  Created by Andy on 7/1/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "BaseVC.h"
#import "AppDelegate.h"
@interface BlockedVC : BaseVC<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *blockedTable;
@property(strong,nonatomic) NSMutableArray *blockedArray;
@property(strong,nonatomic) NSMutableDictionary *imageArray;
@property (strong, nonatomic) AppDelegate * appDelegate;

@end
