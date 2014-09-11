//
//  NSQFrame.m
//  iCircle
//
//  Created by Hager Hu on 7/25/14.
//  Copyright (c) 2014 TravelCircle. All rights reserved.
//

#import "NSQFrame.h"


NSString *FRAME_HEARTBEAT_STRING = @"_heartbeat_";


static NSString *const FRAME_ERROR_INVALID = @"E_INVALID";
static NSString *const FRAME_ERROR_BAD_BODY = @"E_BAD_BODY";

static NSString *const FRAME_ERROR_BAD_TOPIC = @"E_BAD_TOPIC";
static NSString *const FRAME_ERROR_BAD_CHANNEL = @"E_BAD_CHANNEL";

static NSString *const FRAME_ERROR_BAD_MESSAGE = @"E_BAD_MESSAGE";
static NSString *const FRAME_ERROR_PUB_FAILED = @"E_PUB_FAILED";

static NSString *const FRAME_ERROR_MPUB_FAILED = @"E_MPUB_FAILED";

static NSString *const FRAME_ERROR_FIN_FAILED = @"E_FIN_FAILED";

static NSString *const FRAME_ERROR_REQ_FAILED = @"E_REQ_FAILED";

static NSString *const FRAME_ERROR_TOUCH_FAILED = @"E_TOUCH_FAILED";

static NSString *const FRAME_ERROR_AUTH_FAILED = @"E_AUTH_FAILED";
static NSString *const FRAME_ERROR_UNAUTHORIZED = @"E_UNAUTHORIZED";


@interface NSQFrame ()

@property (nonatomic, strong, readwrite) NSData *data;


@property (nonatomic, assign, readwrite) int32_t dataSize;

@property (nonatomic, assign, readwrite) NSQFrameType frameType;

@property (nonatomic, strong, readwrite) NSData *frameData;

@property (nonatomic, strong, readwrite) NSString *responseString;

@end



@implementation NSQFrame

+ (instancetype)frameWithData:(NSData *)data {
    return [[[self class] alloc] initWithData:data];
}


#pragma mark -
#pragma mark Initializing Object

- (id)initWithData:(NSData *)data {
    if (self = [super init]) {
        self.data = data;
        
        self.frameType = NSQFrameTypeUnknown;
    }
    
    return self;
}


#pragma mark -
#pragma mark Overriding property method implementation

- (NSQFrameType)frameType {
    if (_frameType == NSQFrameTypeUnknown && self.data.length > 8) {
        NSData *frameTypeData = [self.data subdataWithRange:NSMakeRange(4, 4)];
        NSUInteger frameType = [self NSDataToNSUInteger:frameTypeData];
        
        _frameType = frameType;
    }
    
    return _frameType;
}


- (NSData *)frameData {
    if (_frameData == nil && self.data.length > 8 && self.dataSize > 4) {
        NSData *frameDataData = [self.data subdataWithRange:NSMakeRange(8, self.dataSize-4)];
        
        _frameData = frameDataData;
    }
    
    if (self.dataSize+4 < self.data.length) {
        
    }
    
    return _frameData;
}


- (int32_t)dataSize {
    if (_dataSize == 0 && self.data.length > 4) {
        NSData *sizeData = [self.data subdataWithRange:NSMakeRange(0, 4)];
        NSUInteger dataSize = [self NSDataToNSUInteger:sizeData];
        
        _dataSize = dataSize;
    }
    
    return _dataSize;
}


- (NSString *)responseString {
    if (_responseString == nil && (self.frameType == NSQFrameTypeResponse || self.frameType == NSQFrameTypeError)) {
        NSString *responseBody = [[NSString alloc] initWithData:self.frameData encoding:NSUTF8StringEncoding];
        
        _responseString = responseBody;
    }
    
    return _responseString;
}


- (NSQErrorCode)errorCode {
    if (self.frameType == NSQFrameTypeError) {
        NSString *response = self.responseString;
        
        if ([response isEqualToString:FRAME_ERROR_INVALID]) {
            return NSQErrorCodeInvalid;
        } else if ([response isEqualToString:FRAME_ERROR_BAD_BODY]) {
            return NSQErrorCodeBadBody;
        } else if ([response isEqualToString:FRAME_ERROR_BAD_TOPIC]) {
            return NSQErrorCodeBadTopic;
        } else if ([response isEqualToString:FRAME_ERROR_BAD_CHANNEL]) {
            return NSQErrorCodeBadChannel;
        } else if ([response isEqualToString:FRAME_ERROR_PUB_FAILED]) {
            return NSQErrorCodePubFailed;
        } else if ([response isEqualToString:FRAME_ERROR_MPUB_FAILED]) {
            return NSQErrorCodeMPubFailed;
        } else if ([response isEqualToString:FRAME_ERROR_BAD_MESSAGE]) {
            return NSQErrorCodeBadMessage;
        } else if ([response isEqualToString:FRAME_ERROR_FIN_FAILED]) {
            return NSQErrorCodeFinFailed;
        } else if ([response isEqualToString:FRAME_ERROR_REQ_FAILED]) {
            return NSQErrorCodeReqFailed;
        } else if ([response isEqualToString:FRAME_ERROR_AUTH_FAILED]) {
            return NSQErrorCodeAuthFailed;
        } else if ([response isEqualToString:FRAME_ERROR_UNAUTHORIZED]) {
            return NSQErrorCodeUnauthorized;
        }
    }
    
    return NSQErrorCodeNone;
}


#pragma mark -
#pragma mark Private method implementation

- (NSUInteger)NSDataToNSUInteger:(NSData *)data {
    NSUInteger index = 0;
    
    Byte byteArray[[data length]];
    [data getBytes:&byteArray];
    
    index += (byteArray[0] << 24) & 0xFF000000;
    index += (byteArray[1] << 16) & 0x00FF0000;
    index += (byteArray[2] << 8) & 0x0000FF00;
    index += byteArray[3] & 0x000000FF;
    
    return index;
}

@end
