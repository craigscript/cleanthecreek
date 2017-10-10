#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface IntroModel : NSObject

@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSString *descriptionText;
@property (nonatomic, strong) UIImage *image;

//@property (nonatomic, strong) SlideVC *delegate;


- (id) initWithTitle:(NSString*)title description:(NSString*)desc image:(NSString*)imageText ToVC:(UIViewController*)vc;

@end
