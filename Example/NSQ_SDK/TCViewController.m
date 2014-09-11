//
//  TCViewController.m
//  NSQ_SDK
//
//  Created by Hager Hu on 09/11/2014.
//  Copyright (c) 2014 TravelCircle.in. All rights reserved.
//

#import "TCViewController.h"

#import <NSQ_SDK/NSQ_SDK.h>

static NSString *const kNSQ_HOST = @"127.0.0.1";
static const int kNSQ_HOST_PORT = 4150;


@interface TCViewController ()

@property (nonatomic, strong) NSQSession *session;

@end



@implementation TCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSDictionary *identify = @{kIdentifyClientId: @"1", kIdentifyHeartbeatInterval:@(3000), kIdentifyHeartbeatInterval:@YES};
    self.session = [NSQSession sessionSubscribeTopic:@"test" andChannel:@"nsq_sdk" withIdentify:identify];
    
    self.session.messageHandler = ^(NSQMessage *message, NSError *error) {
        NSLog(@"%s message:%@ body:%@", __FUNCTION__, message, message.messageBody);
    };
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.session && ![self.session isConnected]) {
        NSError *error = nil;
        BOOL connected = [self.session connectToHost:kNSQ_HOST onPort:kNSQ_HOST_PORT error:&error];
        if (error) {
            NSLog(@"%s error:%@", __FUNCTION__, error);
        }
        NSLog(@"%s connected:%d", __FUNCTION__, connected);
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.session && [self.session isConnected]) {
        [self.session closeConnection];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
