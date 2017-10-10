//
//  TermsVC.m
//  CTC
//
//  Created by Andy on 2016-06-15.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "TermsVC.h"

@interface TermsVC ()

@end

@implementation TermsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"eula" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL: [[NSBundle mainBundle] bundleURL]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)acceptClicked:(UIButton *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"true" forKey:@"termsAccepted"];
    
    [defaults synchronize];

    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
