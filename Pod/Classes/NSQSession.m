//
//  NSQSession.m
//  NSQSession
//
//  Created by Hager Hu on 7/22/14.
//  Copyright (c) 2014 TravelCircle. All rights reserved.
//

#import "NSQSession.h"

#import <CocoaAsyncSocket/AsyncSocket.h>

#import "NSQFrame.h"
#import "NSQMessage.h"
#import "NSQCommand.h"

static NSString *TCNSQErrorDomain = @"TCNSQErrorDomain";


NSString *const kIdentifyClientId = @"client_id";
NSString *const kIdentifyHostname = @"hostname";
NSString *const kIdentifyFeatureNegotiation = @"feature_negotiation";
NSString *const kIdentifyHeartbeatInterval = @"heartbeat_interval";
NSString *const kIdentifyOutputBufferSize = @"output_buffer_size";
NSString *const kIdentifyOutputBufferTimeout = @"output_buffer_timeout";
NSString *const kIdentifyTLS_V1 = @"tls_v1";
NSString *const kIdentifySnapp = @"snapp";
NSString *const kIdentifyDeflate = @"deflate";
NSString *const kIdentifyDeflateLevel = @"deflate_level";
NSString *const kIdentifySampleRate = @"sample_rate";
NSString *const kIdentifyUserAgent = @"user_agent";
NSString *const kIdentifyMessageTimeout = @"msg_timeout";


#if ENABLE_DDLOG
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif
#endif


@interface NSQSession () <AsyncSocketDelegate>

@property (nonatomic, strong, readwrite) NSDictionary *identify;

@property (nonatomic, strong, readwrite) NSString *topic;
@property (nonatomic, strong, readwrite) NSString *channel;


@property (nonatomic, strong) AsyncSocket *socket;

@property (nonatomic, assign) long tag;
@property (nonatomic, assign) long identifyCommandTag;


@property (nonatomic, assign) NSTimeInterval readTimeout;
@property (nonatomic, assign) NSTimeInterval writeTimeout;

@property (nonatomic, assign) NSUInteger readyCount;

@end



@implementation NSQSession

+ (instancetype)sessionSubscribeTopic:(NSString *)topic andChannel:(NSString *)channel withIdentify:(NSDictionary *)identify {
    NSQSession *client = [[[self class] alloc] init];
    client.identify = identify;
    
    client.topic = topic;
    client.channel = channel;
    
    return client;
}


#pragma mark -
#pragma mark Public method implementation

- (BOOL)isConnected {
    if (self.socket) {
        return [self.socket isConnected];
    }
    
    return NO;
}


- (BOOL)connectToHost:(NSString *)host onPort:(UInt16)port error:(NSError **)error {
    if (self.socket) {
        if ([self.socket isConnected]) {
            return YES;
        }
        
        return [self.socket connectToHost:host onPort:port error:error];
    }
    
    return NO;
}


- (void)closeConnection {
    if (self.socket) {
        [self sendCommand:NSQCommandTypeCLS withData:[NSQCommand commandClose]];
    }
}


#pragma mark -
#pragma mark Initialization

- (id)init {
    if (self = [super init]) {
        self.socket = [[AsyncSocket alloc] initWithDelegate:self];
        
        self.readTimeout = 2000;
        self.writeTimeout = 2000;
        
        self.readyCount = 20;
    }
    
    return self;
}


#pragma mark -
#pragma mark AsyncSocketDelegate method implementation

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
#if ENABLE_DDLOG
    DDLogVerbose(@"%s socket:%@ error:%@", __FUNCTION__, sock, err);
#endif
}


- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
#if ENABLE_DDLOG
    DDLogInfo(@"%s socket:%@", __FUNCTION__, sock);
#endif
}


- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
#if ENABLE_DDLOG
    DDLogVerbose(@"%s socket:%@ newSocket:%@", __FUNCTION__, sock, newSocket);
#endif
}


- (BOOL)onSocketWillConnect:(AsyncSocket *)sock {
#if ENABLE_DDLOG
    DDLogVerbose(@"%s socket:%@", __FUNCTION__, sock);
#endif
    
    return YES;
}


- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
#if ENABLE_DDLOG
    DDLogInfo(@"%s socket:%@ host:%@ port:%d", __FUNCTION__, sock, host, port);
#endif
    
    [self sendCommand:NSQCommandTypeIDENTIFIER withData:[NSQCommand commandIdentifier]];
    
    //NSDictionary *identify = @{@"short_id": @"client1", @"long_id": @"client1.circle.in", @"heartbeat_interval": @(30000), @"feature_negotiation": @YES};
    [self sendCommand:NSQCommandTypeIDENTIFY withData:[NSQCommand commandIdentifyWithParameters:self.identify]];
}


- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
#if ENABLE_DDLOG
    DDLogVerbose(@"%s socket:%@ length:%ld data:%@ tag:%ld", __FUNCTION__, sock, (unsigned long)[data length], data, tag);
#endif
    
    NSData *readData = [data subdataWithRange:NSMakeRange(0, [data length])];
    
    NSQFrame *frame = [NSQFrame frameWithData:readData];
    
#if ENABLE_DDLOG
    DDLogVerbose(@"%s frame:%@ type:%ld size:%d", __FUNCTION__, frame, (unsigned long)frame.frameType, frame.dataSize);
#endif
    
    if (frame.frameType == NSQFrameTypeResponse) {
#if ENABLE_DDLOG
        DDLogVerbose(@"%s frame:%@ type:%lu data:%@ string:%@", __FUNCTION__, frame, frame.frameType, frame.frameData, frame.responseString);
        
        DDLogInfo(@"%s frame:%@ type:%lu string:%@", __FUNCTION__, frame, frame.frameType, frame.responseString);
#endif
        
        if ([frame.responseString isEqualToString:FRAME_HEARTBEAT_STRING]) {
            [self sendCommand:NSQCommandTypeNOP withData:[NSQCommand commandNOP]];
        }
    } else if (frame.frameType == NSQFrameTypeMessage) {
        NSQMessage *message = [NSQMessage messageWithData:frame.frameData];
        
#if ENABLE_DDLOG
        DDLogInfo(@"%s message:%@ id:%@ body:%@", __FUNCTION__, message, message.messageId, message.messageBody);
#endif
        
        [self sendCommand:NSQCommandTypeFIN withData:[NSQCommand commandFinishMessage:message.messageId]];
        
        
        if (self.messageHandler) {
            self.messageHandler(message, nil);
        }
    } else if (frame.frameType == NSQFrameTypeError) {
#if ENABLE_DDLOG
        DDLogVerbose(@"%s frame:%@ data:%@ string:%@", __FUNCTION__, frame, frame.frameData, frame.responseString);
        
        DDLogInfo(@"%s frame:%@ type:%lu data:%@", __FUNCTION__, frame, frame.frameType, frame.responseString);
#endif
        
        NSDictionary *extraInfo = @{@"extraInfo":frame};
        NSError *error = [NSError errorWithDomain:TCNSQErrorDomain code:frame.errorCode userInfo:extraInfo];
        
        if (self.messageHandler) {
            self.messageHandler(nil, error);
        }
    } else {
#if ENABLE_DDLOG
        DDLogVerbose(@"%s response:%@", __FUNCTION__, frame.responseString);
        
        DDLogInfo(@"%s frame:%@ type:%lu string:%@", __FUNCTION__, frame, frame.frameType, frame.responseString);
#endif
        
        NSString *responseString = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
        NSLog(@"%s responseString:%@", __FUNCTION__, responseString);
        
        NSDictionary *extraInfo = @{@"extraInfo":frame};
        NSError *error = [NSError errorWithDomain:TCNSQErrorDomain code:frame.errorCode userInfo:extraInfo];
        
        if (self.messageHandler) {
            self.messageHandler(nil, error);
        }
    }
    
    
    if (tag == self.identifyCommandTag) {
        [self sendCommand:NSQCommandTypeSUB withData:[NSQCommand commandSubscribeTopic:self.topic andChannel:self.channel]];
    } else {
        [self sendCommand:NSQCommandTypeRDY withData:[NSQCommand commandReadyWithCount:self.readyCount]];
    }
}


- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
#if ENABLE_DDLOG
    DDLogVerbose(@"%s socket:%@ partial:%lu tag:%ld", __FUNCTION__, sock, (unsigned long)partialLength, tag);
#endif
}


- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
#if ENABLE_DDLOG
    DDLogVerbose(@"%s socket:%@ tag:%ld", __FUNCTION__, sock, tag);
#endif
}


- (void)onSocket:(AsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
#if ENABLE_DDLOG
    DDLogVerbose(@"%s socket:%@ partial:%lu tag:%ld", __FUNCTION__, sock, (unsigned long)partialLength, tag);
#endif
}


- (NSTimeInterval)onSocket:(AsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
    return self.readTimeout;
}


- (NSTimeInterval)onSocket:(AsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
    return self.writeTimeout;
}


- (void)onSocketDidSecure:(AsyncSocket *)sock {
#if ENABLE_DDLOG
    DDLogVerbose(@"%s socket:%@", __FUNCTION__, sock);
#endif
}


#pragma mark -
#pragma mark Private method implementation

- (void)sendCommand:(NSQCommandType)command withData:(NSData *)data {
    self.tag += 1;
    
    if (command == NSQCommandTypeIDENTIFIER) {
        self.identifyCommandTag = self.tag;
    }
    
    [self.socket writeData:data withTimeout:-1 tag:self.tag];
    [self.socket readDataWithTimeout:-1 tag:self.tag];
    
#if ENABLE_DDLOG
    NSString *commandString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DDLogVerbose(@"%s tag:%ld command:%d string:%@", __FUNCTION__, self.tag, command, commandString);
#endif
}


@end
