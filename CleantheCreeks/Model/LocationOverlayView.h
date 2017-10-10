//
//  LocationOverlayView.h
//  Clean the Creek
//
//  Created by Kimura Isoroku on 2/20/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface LocationOverlayView : MKAnnotationView
@property (nonatomic, weak) UILabel *label;
- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;
@end
