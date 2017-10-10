#import <UIKit/UIKit.h>
#import "IntroModel.h"

@interface IntroView : UIView
- (id)initWithFrame:(CGRect)frame model:(IntroModel*)model;
@property(strong,nonatomic)UIButton *loginButton;
@end
