//
//  NSQSession.h
//  NSQSession
//
//  Created by Hager Hu on 7/22/14.
//  Copyright (c) 2014 TravelCircle. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSQMessage;

typedef void(^MessageHandler)(NSQMessage *message, NSError *error);


extern NSString *const kIdentifyClientId;
extern NSString *const kIdentifyFeatureNegotiation;
extern NSString *const kIdentifyHeartbeatInterval;


@interface NSQSession : NSObject

@property (nonatomic, readonly) NSDictionary *identify;

@property (nonatomic, readonly) NSString *topic;
@property (nonatomic, readonly) NSString *channel;

@property (nonatomic, copy) MessageHandler messageHandler;


+ (instancetype)sessionSubscribeTopic:(NSString *)topic andChannel:(NSString *)channel withIdentify:(NSDictionary *)identify;


- (BOOL)isConnected;

- (BOOL)connectToHost:(NSString *)host onPort:(UInt16)port error:(NSError **)error;

- (void)closeConnection;

@end
