#import "IntroView.h"
#import <QuartzCore/QuartzCore.h>

@implementation IntroView

- (id)initWithFrame:(CGRect)frame model:(IntroModel*)model
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *imgLogo=[UIImage imageNamed:@"SliderLogoSmall"];
        UIImageView *imageHolder = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,imgLogo.size.width, imgLogo.size.height)];
        imageHolder.image=imgLogo;
        [imageHolder setCenter:CGPointMake(frame.size.width/2, frame.size.height*0.2)];
        [self addSubview:imageHolder];
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setText:model.titleText];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:24]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel sizeToFit];
        [titleLabel setCenter:CGPointMake(frame.size.width/2, imageHolder.frame.origin.y+imageHolder.frame.size.height+20)];
        [self addSubview:titleLabel];
        
        UILabel *descriptionLabel = [[UILabel alloc] init];
        [descriptionLabel setText:model.descriptionText];
        [descriptionLabel setFont:[UIFont systemFontOfSize:20]];
        [descriptionLabel setTextColor:[UIColor whiteColor]];
        [descriptionLabel setNumberOfLines:3];
        [descriptionLabel setBackgroundColor:[UIColor clearColor]];
        [descriptionLabel setTextAlignment:NSTextAlignmentCenter];
        
        CGSize s = [descriptionLabel.text sizeWithFont:descriptionLabel.font constrainedToSize:CGSizeMake(frame.size.width-40, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        
        //three lines height
        CGSize three = [@"1 \n 2 \n 3" sizeWithFont:descriptionLabel.font constrainedToSize:CGSizeMake(frame.size.width-40, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        
        descriptionLabel.frame = CGRectMake((self.frame.size.width-s.width)/2, titleLabel.frame.origin.y+titleLabel.frame.size.height+20,s.width, MIN(s.height, three.height));
        
        [self addSubview:descriptionLabel];
        
        _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,0,0)];
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton setTitle:@"SIGN IN WITH FACEBOOK" forState:UIControlStateNormal];
        [_loginButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        _loginButton.backgroundColor = [UIColor colorWithRed:(1/255.0) green:(122/255.0) blue:(255/255.0) alpha:1.0];
        _loginButton.layer.cornerRadius = 4.0f;
        _loginButton.frame = CGRectMake(0, 0, self.frame.size.width*0.8, self.frame.size.width*0.15);
        [_loginButton setCenter:CGPointMake(self.frame.size.width/2,self.frame.size.height/23*21-_loginButton.frame.size.height/2)];
        [self addSubview:_loginButton];
        
    }
    return self;
}
@end
