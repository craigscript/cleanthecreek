#import <UIKit/UIKit.h>
#import "IntroControll.h"
#import "BaseVC.h"
#import "AppDelegate.h"
@interface SlideVC : BaseVC<LastPageShowDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)acceptClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *popView;
@property (nonatomic) bool aroundView;
@property (nonatomic,strong) AppDelegate *mainDelegate;
@end
