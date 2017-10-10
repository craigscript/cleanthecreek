#import "IntroModel.h"

@implementation IntroModel

@synthesize titleText;
@synthesize descriptionText;
@synthesize image;

- (id) initWithTitle:(NSString*)title description:(NSString*)desc image:(NSString*)imageText ToVC:(UIViewController*)vc{
    self = [super init];
    if(self != nil) {
  //      self.delegate = (SlideVC*)vc;
        titleText = title;
        descriptionText = desc;
        image = [UIImage imageNamed:imageText];
    }
    return self;
}

@end
