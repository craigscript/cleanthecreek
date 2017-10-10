//
//  FullScreen.h
//  CTC
//
//  Created by Song on 5/23/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
@interface FullScreen : BaseVC
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)close:(id)sender;

@property(nonatomic, strong) UIImage * img;
@end
