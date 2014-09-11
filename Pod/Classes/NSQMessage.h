//
//  NSQMessage.h
//  iCircle
//
//  Created by Hager Hu on 7/25/14.
//  Copyright (c) 2014 TravelCircle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSQMessage : NSObject

@property (nonatomic, readonly) NSDate *timeStamp;

@property (nonatomic, readonly) NSString *messageId;

@property (nonatomic, readonly) UInt16 attempts;

@property (nonatomic, readonly) NSString *messageBody;


+ (instancetype)messageWithData:(NSData *)data;

@end
