//
//  NSQCommand.m
//  iCircle
//
//  Created by Hager Hu on 9/11/14.
//  Copyright (c) 2014 TravelCircle. All rights reserved.
//

#import "NSQCommand.h"

#import <JSONKit-NoWarning/JSONKit.h>


@implementation NSQCommand

+ (NSData *)commandIdentifyWithParameters:(NSDictionary *)parameters {
    NSMutableData *command = [NSMutableData data];
    [command appendData:[@"IDENTIFY\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSUInteger bodyLength = [[parameters JSONString] length];
    [command appendData:[NSQCommand IntToNSData:bodyLength]];
    
    [command appendData:[[parameters JSONString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return command;
}


+ (NSData *)commandSubscribeTopic:(NSString *)topic andChannel:(NSString *)channel {
    NSString *subscribe = [NSString stringWithFormat:@"SUB %@ %@\n", topic, channel];//@"SUB test nsq_to_file\n";
    NSData *data = [subscribe dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
}


+ (NSData *)commandFinishMessage:(NSString *)messageId {
    //FIN <message_id>\n
    NSString *finish = [NSString stringWithFormat:@"FIN %@\n", messageId];
    return [finish dataUsingEncoding:NSUTF8StringEncoding];
}


+ (NSData *)commandReadyWithCount:(NSUInteger)count {
    NSString *ready = [NSString stringWithFormat:@"RDY %lu\n", (unsigned long)count];
    NSData *readyData = [ready dataUsingEncoding:NSUTF8StringEncoding];
    
    return readyData;
}


+ (NSData *)commandIdentifier {
    NSString *magicIdentifier = @"  V2";
    NSData *data = [magicIdentifier dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
}


+ (NSData *)commandNOP {
    NSString *nop = @"NOP\n";
    NSData *data = [nop dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
}


+ (NSData *)commandClose {
    //CLS\n
    NSString *close = @"CLS\n";
    NSData *data = [close dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
}


#pragma mark -
#pragma mark Private method implementation

+ (NSData *)IntToNSData:(NSInteger)data {
    Byte *byteData = (Byte*)malloc(4);
    byteData[3] = data & 0xff;
    byteData[2] = (data & 0xff00) >> 8;
    byteData[1] = (data & 0xff0000) >> 16;
    byteData[0] = (data & 0xff000000) >> 24;
    NSData * result = [NSData dataWithBytes:byteData length:4];
    
    return (NSData*)result;
}

@end
