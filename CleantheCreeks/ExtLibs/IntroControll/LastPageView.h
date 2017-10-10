#import <UIKit/UIKit.h>
#import "IntroModel.h"

@interface LastPageView : UIView
- (id)initWithFrame:(CGRect)frame model:(IntroModel*)model;
@property(nonatomic,strong) UIButton* mapLabel;
@property(strong,nonatomic)UIButton *loginButton;
@end
