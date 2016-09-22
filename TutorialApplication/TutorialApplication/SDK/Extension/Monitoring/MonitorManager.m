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

#define PINGKEY				@"Ping"
#define NETWORKKEY			@"Network"
#define SETTINGKEY			@"Setting"

#define STORAGEMONITORINGKEY		@"FlieralSTORAGEMonitoringKey"

@interface MonitorManager () <GBPingDelegate>
{
	NSUInteger totalNumberOfPackets;
	NSUInteger numberOfPacketLosts;

	double averageRTT;
}

@property (nullable, nonatomic, strong) GBPing *ping;
@property (nonnull, nonatomic, strong) __block NSDictionary *pingDict;
@property (nonnull, nonatomic, strong) __block NSDictionary *networkDict;
@property (nonnull, nonatomic, strong) __block NSDictionary *settingDict;

@property (nonatomic) BOOL pingReady;
@property (nonatomic) BOOL networkReady;
@property (nonatomic) BOOL settingReady;

@end

@implementation MonitorManager

#pragma mark - Ping Issue

- (void)startPinging
{
	_pingDict = [NSDictionary dictionary];
	
	_ping = [[GBPing alloc] init];
	_ping.host = @"8.8.8.8";
	_ping.delegate = self;
	_ping.timeout = 1.0;
	_ping.pingPeriod = 0.5;
	
	totalNumberOfPackets = 0;
	numberOfPacketLosts	 = 0;
	averageRTT			 = 0;
	
	_pingReady = false;
	_settingReady = false;
	_networkReady = false;
}

#pragma mark - Delegate

- (void)monitoringCompleteObject
{
	if (_pingReady && _settingReady && _networkReady)
	{
		NSDictionary *dict = [NSDictionary dictionary];
		NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
		
		[dict setValue:_pingDict forKey:PINGKEY];
		[dict setValue:_networkDict forKey:NETWORKKEY];
		[dict setValue:_settingDict forKey:SETTINGKEY];
		
		[ud setObject:dict forKey:STORAGEMONITORINGKEY];
		[ud synchronize];
		
		[_delegate monitoringCompleteObject:dict];
	}
}

#pragma mark - User Setting

- (void)getUserSetting
{
	_settingReady = true;
	[self monitoringCompleteObject];
}

#pragma mark - Network Setting

- (void)getNetworkSetting
{
	[APIManager getUserSettingFromIPAPISuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
		
		_networkReady = true;
		_networkDict = (NSDictionary *)responseObject;
		[_delegate networkResponse:_networkDict];
		
		[self monitoringCompleteObject];
		
	} failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
		
	}];
}

#pragma mark - Ping & Delegate

- (void)getPingSetting
{
	[self.ping setupWithBlock:^(BOOL success, NSError *error)
	 {
		 if (success)
		 {
			 //start pinging
			 [self.ping startPinging];
			 
			 //stop it after 5 seconds
			 [NSTimer scheduledTimerWithTimeInterval:3 repeats:NO block:^(NSTimer * _Nonnull timer)
			  {
				  [self.ping stop];
				  self.ping = nil;
				  
				  NSInteger packetLost = ((float)(numberOfPacketLosts / totalNumberOfPackets) * 100);
				  NSInteger packetRTT  = averageRTT * 1000;
				  
				  [_pingDict setValue:[NSString stringWithFormat:@"%li", (long)packetLost] forKey:PACKETLOSTKEY];
				  [_pingDict setValue:[NSString stringWithFormat:@"%li", (long)packetRTT] forKey:PACKETRTTKEY];
				  
				  [_delegate monitorResponse:_pingDict];
				  
				  _pingReady = true;
				  [self monitoringCompleteObject];
			  }];
		 }
		 else
		 {
			 NSLog(@"failed to start");
		 }
	 }];
}

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
	totalNumberOfPackets ++;
}

-(void)ping:(GBPing *)pinger didTimeoutWithSummary:(GBPingSummary *)summary
{
	numberOfPacketLosts ++;
}

@end
