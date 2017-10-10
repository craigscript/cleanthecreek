//
//  ActivityPhotoDetailsVC.h
//  Clean the Creek
//
//  Created by a on 2/22/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "Location.h"
#import "CommentView.h"
#import "AppDelegate.h"
#import "TGCameraViewController.h"
@protocol KudoDelegate<NSObject>
@optional
-(void) giveKudoWithLocation:(Location*)location assigned:(bool) assigned;
@end

@interface ActivityPhotoDetailsVC : BaseVC<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate, UIImagePickerControllerDelegate,TGCameraDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tv;
@property (strong, nonatomic) Location * location;
@property (nonatomic) BOOL cleaned,isKudoed;
@property (strong, nonatomic) UIImage * beforePhoto, *afterPhoto;
@property (weak, nonatomic) IBOutlet CommentView *commentView;
@property (weak, nonatomic) IBOutlet UIButton *sendComment;
@property (weak, nonatomic) IBOutlet UIButton *closeComment;

@property (weak, nonatomic) IBOutlet UITextField *textComment;
- (IBAction)closeBtnClicked:(id)sender;
- (IBAction)sendButtonClicked:(id)sender;
@property (nonatomic) bool commentVisible;
@property(nonatomic, retain) id<KudoDelegate> delegate;
@property (strong,nonatomic )AppDelegate * mainDelegate;
@property(nonatomic) bool fromLocationView;
@property(nonatomic, strong) NSString * selected_user;
@property (nonatomic, strong) UIImage * imgToShow;
@end
