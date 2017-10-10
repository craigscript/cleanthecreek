//
//  Location.m
//  CleantheCreeks
//
//  Created by Kimura Isoroku on 2/3/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "Location.h"

@implementation Location

+ (NSString *)dynamoDBTableName {
    return @"Location";
}

+ (NSString *)hashKeyAttribute {
    return @"location_id";
}

@end
