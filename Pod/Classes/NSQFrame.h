//
//  NSQFrame.h
//  iCircle
//
//  Created by Hager Hu on 7/25/14.
//  Copyright (c) 2014 TravelCircle. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NSQFrameType) {
    NSQFrameTypeUnknown = NSUIntegerMax,
    NSQFrameTypeResponse = 0,
    NSQFrameTypeError,
    NSQFrameTypeMessage,
};


typedef NS_ENUM(NSUInteger, NSQErrorCode) {
    NSQErrorCodeNone,
    NSQErrorCodeInvalid,
    NSQErrorCodeBadBody,
    NSQErrorCodeBadTopic,
    NSQErrorCodeBadChannel,
    NSQErrorCodeBadMessage,
    NSQErrorCodePubFailed,
    NSQErrorCodeMPubFailed,
    NSQErrorCodeFinFailed,
    NSQErrorCodeReqFailed,
    NSQErrorCodeTouchFailed,
    NSQErrorCodeAuthFailed,
    NSQErrorCodeUnauthorized,
};


extern NSString *FRAME_HEARTBEAT_STRING;


@interface NSQFrame : NSObject

@property (nonatomic, readonly) int32_t dataSize;

@property (nonatomic, readonly) NSQFrameType frameType;

@property (nonatomic, readonly) NSData *frameData;

@property (nonatomic, readonly) NSString *responseString;

@property (nonatomic, readonly) NSQErrorCode errorCode;


+ (instancetype)frameWithData:(NSData *)data;

@end
