//
//  TermsVC.h
//  CTC
//
//  Created by Andy on 2016-06-15.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TermsVC : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)acceptClicked:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *popView;

@end
