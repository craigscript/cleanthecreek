//
//  Activity.h
//  Clean the Creek
//
//  Created by Kimura Eiji on 03/03/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#ifndef Activity_h
#define Activity_h
#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>
#import "Location.h"
@interface Activity :NSObject

@property (nonatomic, strong) NSString * activity_id;
@property (nonatomic) double activity_time;

@property (nonatomic, strong) NSString * activity_type;
@property (nonatomic, strong) Location * activity_location;

@property(nonatomic) long kudo_count;
@property(nonatomic) bool kudo_assigned;
@end
#endif /* Activity_h */
