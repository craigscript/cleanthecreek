//
//  LocationOverlayView.m
//  Clean the Creek
//
//  Created by Kimura Isoroku on 2/20/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import "LocationOverlayView.h"
#import "LocationAnnotation.h"
#import "AppDelegate.h"
#import "PhotoDetailsVC.h"

@interface LocationOverlayView ()
@property (nonatomic) CGFloat width;
@end

@implementation LocationOverlayView
- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:9];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor colorWithRed:0.0 green:120/255.0 blue:252/255.0 alpha:1.0];

        [self addSubview:label];
        self.label = label;
        
        [self adjustLabelWidth:annotation];
        
        self.opaque = false;
        self.centerOffset = CGPointMake(0, -11);
    }
    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    [self adjustLabelWidth:annotation];
}

- (void)adjustLabelWidth:(id<MKAnnotation>)annotation {
    NSString *title;
    
    if ([annotation respondsToSelector:@selector(title)] && self.label) {
        title = [annotation title];
        NSDictionary *attributes = @{ NSFontAttributeName : self.label.font };
        CGSize size = [title sizeWithAttributes:attributes];
        self.width = MAX(size.width + 6, 22);
    }
    else {
        self.width = 0;
    }
    if(title)
    {
        self.label.frame = CGRectMake(50 - self.width/2, -8, self.width, 16);
        self.label.layer.masksToBounds = YES;
        self.label.layer.cornerRadius = 8;
    }
    else
    {
        self.label.frame = CGRectMake(0,0,0,0);
    }
    self.label.text = title;
    self.frame = CGRectMake(self.frame.origin.x, 0, 50, 50);
    
}

- (void)drawRect:(CGRect)rect {

}

@end
