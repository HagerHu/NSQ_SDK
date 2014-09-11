//
//  NSQMessage.m
//  iCircle
//
//  Created by Hager Hu on 7/25/14.
//  Copyright (c) 2014 TravelCircle. All rights reserved.
//

#import "NSQMessage.h"


@interface NSQMessage ()

@property (nonatomic, strong, readwrite) NSData *data;


@property (nonatomic, readwrite, strong) NSDate *timeStamp;

@property (nonatomic, readwrite, strong) NSString *messageId;

@property (nonatomic, readwrite, assign) UInt16 attempts;

@property (nonatomic, readwrite, strong) NSString *messageBody;

@end


@implementation NSQMessage

+ (instancetype)messageWithData:(NSData *)data {
    return [[[self class] alloc] initWithData:data];
}


#pragma mark -
#pragma mark Initialization

- (id)initWithData:(NSData *)data {
    if (self = [super init]) {
        self.data = data;
    }
    
    return self;
}


#pragma mark -
#pragma mark Customizing property method implementation

- (NSDate *)timeStamp {
    if (_timeStamp == nil && self.data.length > 8) {
        NSData *nanoSecondData = [self.data subdataWithRange:NSMakeRange(0, 8)];
        long long nanoSecond = [self NSDataToLongLong:nanoSecondData];
        NSDate *messageTime = [NSDate dateWithTimeIntervalSince1970:(nanoSecond/(1000*1000*1000))];
        
        _timeStamp = messageTime;
    }
    
    return _timeStamp;
}


- (UInt16)attempts {
    if (_attempts == 0 && self.data.length > 10) {
        NSData *attemptsData = [self.data subdataWithRange:NSMakeRange(8, 2)];
        UInt16 attempts = [self NSDataToUInt16:attemptsData];
        
        _attempts = attempts;
    }
    
    return _attempts;
}


- (NSString *)messageId {
    if (_messageId == nil && self.data.length > 26) {
        NSData *messageIdData = [self.data subdataWithRange:NSMakeRange(10, 16)];
        NSString *messageId = [[NSString alloc] initWithData:messageIdData encoding:NSUTF8StringEncoding];
        
        _messageId = messageId;
    }
    
    return _messageId;
}


- (NSString *)messageBody {
    if (_messageBody == nil && self.data.length > 26) {
        NSData *bodyData = [self.data subdataWithRange:NSMakeRange(26, [self.data length]-26)];
        NSString *messageBody = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
        
        _messageBody = messageBody;
    }
    
    return _messageBody;
}


#pragma mark -
#pragma mark Private method implemenation

- (int64_t)NSDataToLongLong:(NSData *)data {
    int64_t index = 0;
    
    Byte byteArray[[data length]];
    [data getBytes:&byteArray];
    
    index += ((((int64_t)byteArray[0]) << 56) & 0xFF00000000000000);
    index += ((((int64_t)byteArray[1]) << 48) & 0x00FF000000000000);
    index += ((((int64_t)byteArray[2]) << 40) & 0x0000FF0000000000);
    index += ((((int64_t)byteArray[3]) << 32) & 0x000000FF00000000);
    index += ((((int64_t)byteArray[4]) << 24) & 0x00000000FF000000);
    index += ((((int64_t)byteArray[5]) << 16) & 0x0000000000FF0000);
    index += ((((int64_t)byteArray[6]) << 8) & 0x000000000000FF00);
    index += byteArray[7] & 0x00000000000000FF;
    
    return index;
}


- (UInt16)NSDataToUInt16:(NSData *)data {
    UInt16 index = 0;
    
    Byte byteArray[[data length]];
    [data getBytes:&byteArray];
    
    index += byteArray[0] & 0xFF00;
    index += byteArray[1] & 0x00FF;
    
    return index;
}

@end
