//
//  User.h
//  Clean the Creek
//
//  Created by Kimura Eiji on 29/02/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

#ifndef User_h
#define User_h
#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@interface User : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString * nick_name;
@property (nonatomic, strong) NSString *user_name;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSMutableArray *followings;
@property (nonatomic, strong) NSString* device_token;
@property (nonatomic, strong) NSMutableArray *followers;
@property (nonatomic, strong) NSString *website_url;
@property (nonatomic, strong) NSString *tagline;
@property (nonatomic, strong) NSString *user_about;
@property (nonatomic, strong) NSString *is_blocked;
@property (nonatomic, strong) NSString *has_photo;
@property (nonatomic, strong) NSMutableArray *blocked_by;
@property  double latitude;
@property  double longitude;
@end

#endif /* User_h */
