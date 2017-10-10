//
//  User.m
//  Clean the Creek
//
//  Created by Kimura Eiji on 29/02/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>
#import "User.h"

@implementation User

+ (NSString *)dynamoDBTableName {
    return @"User";
}

+ (NSString *)hashKeyAttribute {
    return @"user_id";
}

@end