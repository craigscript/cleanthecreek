#import "LastPageView.h"
#import <QuartzCore/QuartzCore.h>
@implementation LastPageView

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
        
        descriptionLabel.frame = CGRectMake((self.frame.size.width-s.width)/2, titleLabel.frame.origin.y+titleLabel.frame.size.height+30,s.width, MIN(s.height, three.height));
        [self addSubview:descriptionLabel];
        
        UILabel *orLabel = [[UILabel alloc] init];
        [orLabel setText:@"OR"];
        [orLabel setFont:[UIFont systemFontOfSize:20]];
        [orLabel setTextColor:[UIColor whiteColor]];
        [orLabel setNumberOfLines:1];
        [orLabel setBackgroundColor:[UIColor clearColor]];
        [orLabel setTextAlignment:NSTextAlignmentCenter];
        
        CGSize s2 = [orLabel.text sizeWithFont:orLabel.font constrainedToSize:CGSizeMake(frame.size.width-40, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        
        orLabel.frame = CGRectMake((self.frame.size.width-s2.width)/2, frame.size.height*0.73,s2.width, s2.height);
        [self addSubview:orLabel];
        
        _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,0,0)];
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton setTitle:@"SIGN IN WITH FACEBOOK" forState:UIControlStateNormal];
        [_loginButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        _loginButton.backgroundColor = [UIColor colorWithRed:(1/255.0) green:(122/255.0) blue:(255/255.0) alpha:1.0];
        _loginButton.layer.cornerRadius = 4.0f;
        _loginButton.frame = CGRectMake(0, 0, self.frame.size.width*0.8, self.frame.size.width*0.15);
        [_loginButton setCenter:CGPointMake(self.frame.size.width/2,self.frame.size.height/668*451-_loginButton.frame.size.height/2)];
        [self addSubview:_loginButton];
        _loginButton.tag=20;
        
        
        _mapLabel = [[UIButton alloc] init];
        //[mapLabel setTitle:@"VIEW AROUND ME" forState:UIControlStateNormal];
        [_mapLabel setFont:[UIFont systemFontOfSize:20]];
        [_mapLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:@"VIEW AROUND ME"];
         [commentString setAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]} range:NSMakeRange(0,[commentString length])];
        [_mapLabel setAttributedTitle:commentString forState:UIControlStateNormal];
        _mapLabel.frame=CGRectMake(0, 0, frame.size.width*0.8, frame.size.width*0.15);

        [_mapLabel setCenter:CGPointMake(frame.size.width/2,frame.size.height*0.8)];
        [self addSubview:_mapLabel];
        _mapLabel.tag=15;
    }
    return self;
}

@end
