//
//  MonitorManager.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/21/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "MonitorManager.h"
#import "GBPing.h"
#import "APIManager.h"

#define PACKETLOSTKEY		@"PacketLost"
#define PACKETRTTKEY		@"PacketRTT"

#define PINGKEY				@"PingStorageKey"

@interface MonitorManager () <GBPingDelegate>
{
	NSUInteger totalNumberOfPackets;
	NSUInteger numberOfPacketLosts;

	double averageRTT;
}

@property (nullable, nonatomic, strong) GBPing *ping;
@property (nullable, nonatomic, strong) __block NSDictionary *pingDict;

@property (nonatomic) BOOL pingReady;

@end

@implementation MonitorManager

- (nonnull instancetype)init
{
    self = [super init];
    if (self)
    {
        _pingDict = [NSDictionary dictionary];
        
        _ping               = [[GBPing alloc] init];
        _ping.host          = @"8.8.8.8";
        _ping.delegate      = self;
        _ping.timeout       = 1.0;
        _ping.pingPeriod    = 0.5;
        
        [_pingDict setValue:[NSString stringWithFormat:@"%li", (long)0] forKey:PACKETLOSTKEY];
        [_pingDict setValue:[NSString stringWithFormat:@"%li", (long)0] forKey:PACKETRTTKEY];

        [self saveData];
    }
    return self;
}

#pragma mark - Ping Issue

- (void)startPinging
{
    totalNumberOfPackets = 0;
    numberOfPacketLosts	 = 0;
    averageRTT			 = 0;

    _pingReady = false;
    
    [self getPingSetting];
}

#pragma mark - Ping Start

- (void)getPingSetting
{
	[self.ping setupWithBlock:^(BOOL success, NSError *error)
	 {
		 if (success)
		 {
			 [self.ping startPinging];
			 
			 [NSTimer scheduledTimerWithTimeInterval:2 repeats:NO block:^(NSTimer * _Nonnull timer)
			  {
				  [self.ping stop];
				  self.ping = nil;
				  
				  NSInteger packetLost = ((float)(numberOfPacketLosts / totalNumberOfPackets) * 100);
				  NSInteger packetRTT  = averageRTT * 1000;
				  
				  [_pingDict setValue:[NSString stringWithFormat:@"%li", (long)packetLost]  forKey:PACKETLOSTKEY];
				  [_pingDict setValue:[NSString stringWithFormat:@"%li", (long)packetRTT]   forKey:PACKETRTTKEY];
				  
                  [self saveData];
                  
				  [_delegate monitorResponse:_pingDict];
				  
				  _pingReady = true;
			  }];
		 }
		 else
		 {
			 NSLog(@"Failed to Start: %@", error);
		 }
	 }];
}

- (void)saveData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:_pingDict forKey:PINGKEY];
    [ud synchronize];
}

#pragma mark - Ping Delegate

-(void)ping:(GBPing *)pinger didReceiveReplyWithSummary:(GBPingSummary *)summary
{
	if (averageRTT == 0)
		averageRTT = summary.rtt;
	else
		averageRTT =  ((averageRTT * (totalNumberOfPackets - 1)) + summary.rtt) / totalNumberOfPackets;
}

-(void)ping:(GBPing *)pinger didReceiveUnexpectedReplyWithSummary:(GBPingSummary *)summary
{
	if (averageRTT == 0)
		averageRTT = 5;
	else
		averageRTT =  ((averageRTT * (totalNumberOfPackets - 1)) + 5) / totalNumberOfPackets;
}

-(void)ping:(GBPing *)pinger didSendPingWithSummary:(GBPingSummary *)summary
{
	totalNumberOfPackets++;
}

-(void)ping:(GBPing *)pinger didTimeoutWithSummary:(GBPingSummary *)summary
{
	numberOfPacketLosts++;
}

#pragma mark - Monitor Setting

- (nullable NSDictionary *)getMonitorSetting
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud objectForKey:PINGKEY];
}

@end
