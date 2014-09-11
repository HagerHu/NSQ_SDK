//
//  NSQCommand.h
//  iCircle
//
//  Created by Hager Hu on 9/11/14.
//  Copyright (c) 2014 TravelCircle. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NSQCommandType) {
    NSQCommandTypeIDENTIFIER,
    NSQCommandTypeIDENTIFY,
    NSQCommandTypeSUB,
    NSQCommandTypePUB,
    NSQCommandTypeMPUB,
    NSQCommandTypeRDY,
    NSQCommandTypeFIN,
    NSQCommandTypeREQ,
    NSQCommandTypeTOUCH,
    NSQCommandTypeCLS,
    NSQCommandTypeNOP,
    NSQCommandTypeAUTH,
};


@interface NSQCommand : NSObject

+ (NSData *)commandIdentifyWithParameters:(NSDictionary *)parameters;

+ (NSData *)commandSubscribeTopic:(NSString *)topic andChannel:(NSString *)channel;

+ (NSData *)commandFinishMessage:(NSString *)messageId;

+ (NSData *)commandReadyWithCount:(NSUInteger)count;

+ (NSData *)commandIdentifier;

+ (NSData *)commandNOP;
+ (NSData *)commandClose;

@end
