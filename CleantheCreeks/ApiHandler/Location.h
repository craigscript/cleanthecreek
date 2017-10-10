//
//  Location.h
//  CleantheCreeks
//
//  Created by Kimura Isoroku on 2/3/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#ifndef Location_h
#define Location_h

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@interface Location : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *location_id;
@property (nonatomic, strong) NSString *location_name;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *founder_id;
@property (nonatomic, strong) NSString *found_by;
@property double found_date;
@property (nonatomic, strong) NSString *cleaner_id;
@property (nonatomic, strong) NSString *cleaner_name;
@property double cleaned_date;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *locality;
@property (nonatomic, strong) NSString *isDirty;
@property (nonatomic, strong) NSMutableArray *kudos;
@property  double latitude;
@property  double longitude;

@end
#endif /* Location_h */
