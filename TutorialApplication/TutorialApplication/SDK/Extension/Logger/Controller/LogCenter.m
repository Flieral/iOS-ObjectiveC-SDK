//
//  LogCenter.m
//  LogCenter
//
//  Created by Alireza Arabi on 6/13/15.
//  Copyright (c) 2015 Alireza Arabi. All rights reserved.
//

#import "LogCenter.h"
#import "LogService.h"

#define LOGSERVICES		@"LogServices"
#define TEMPORALLOGS	@"TemporaryLog"
#define READINGENABLE	@"ReadingIsEnable"

#define ENABLESYSTEM	@"EnableSystem"
#define ENABLELOGGER	@"EnableLogger"
#define LOGGERVERSION	@"LoggerVersion"

#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

@interface LogCenter ()

@end

@implementation LogCenter

#pragma mark - Enable Service

+ (void)SetEnableLogServiceManager:(BOOL)enable {
	
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setBool:enable forKey:ENABLESYSTEM];
	[userDefault synchronize];
	
	[LogCenter SetLoggerVersion:@"1.1.0"];
	
	NSString *loggerStart = [NSString stringWithFormat:@"[LogCenter] START WORKING WITH VERSION %@",[LogCenter LogegrVersion]];
	NSLog(loggerStart);
	
	[LogCenter SetReadingIsEnable:NO];
}

+ (BOOL)ServiceEnable {
	
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	return [userDefault boolForKey:ENABLESYSTEM];
}

#pragma mark - Insert Log

+ (void)NewLogTitle:(NSString *)title LogDescription:(NSString *)description UserInfo:(NSObject *)userInfo {

	if ([LogCenter ServiceEnable]) {

		@try {
			
			NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
			
			LogService *newLog = [[LogService alloc]init];
			[newLog initWithTitle:title eventDescription:description UserInfo:userInfo];
			
			NSData *logEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:newLog];
			
			if ([LogCenter ReadingIsEnable]) {
				
				NSString *logString = [NSString stringWithFormat:@"[READING ENABLE] LOG [%@] %@",[newLog title], [newLog eventDescription]];
				[LogCenter PrintDeveloperLog:logString];
				
				NSMutableArray *logsArray = [NSMutableArray arrayWithArray:[userDefault objectForKey:TEMPORALLOGS]];
				
				[logsArray addObject:logEncodedObject];
				
				[userDefault setObject:logsArray forKey:TEMPORALLOGS];
			}
			else {
				
				NSString *logString = [NSString stringWithFormat:@"[READING DISABLE] LOG [%@] %@",[newLog title], [newLog eventDescription]];
				[LogCenter PrintDeveloperLog:logString];
				
				NSMutableArray *logsArray = [NSMutableArray arrayWithArray:[userDefault objectForKey:LOGSERVICES]];
				
				[logsArray addObject:logEncodedObject];
				
				[userDefault setObject:logsArray forKey:LOGSERVICES];
			}
			
			[userDefault synchronize];
		}
		@catch (NSException *exception) {
			
			NSLog(@"Exception Is: %@",exception);
		}
	} else {
		
		NSLog(@"[LogCenter] SERVICE IS DISABLE!");
	}
}

#pragma mark - Retrive Log

+ (NSArray *)AllLogs {
	
	if ([LogCenter ServiceEnable]) {
		
		NSMutableArray *tempArray = [NSMutableArray array];
		
		NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
		
		NSMutableArray *logsArray = [NSMutableArray array];
		logsArray = [userDefault objectForKey:LOGSERVICES];
		
		for (NSData *dataObject in logsArray) {
			
			LogService *log = [NSKeyedUnarchiver unarchiveObjectWithData:dataObject];
			[tempArray addObject:log];
		}
		
		NSString *numberOfLogs = [NSString stringWithFormat:@"%i",(int)[tempArray count]];
		NSString *Log = [NSString stringWithFormat:@"[Retrive Log] GET [%@] LOG!",numberOfLogs];
		[LogCenter PrintDeveloperLog:Log];
		
		return tempArray;
		
	} else {
		
		NSLog(@"[LogCenter] SERVICE IS DISABLE!");
	}
	return nil;
}

+ (LogService *)LogServiceWithIdentifier:(NSString *)identifier {

	if ([LogCenter ServiceEnable]) {
		
		NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
		
		NSMutableArray *logsArray = [NSMutableArray array];
		logsArray = [userDefault objectForKey:LOGSERVICES];
		
		for (NSData *logData in logsArray) {
			
			LogService *log = [NSKeyedUnarchiver unarchiveObjectWithData:logData];

			if ([[log logServiceID] isEqualToString:identifier]) {

				NSString *Log = [NSString stringWithFormat:@"[Retrive Log] GET LOG [%@]",[log title]];
				[LogCenter PrintDeveloperLog:Log];
				
				return log;
			}
		}
	} else {
		
		NSLog(@"[LogCenter] SERVICE IS DISABLE!");
	}
	return nil;
}

#pragma mark - Remove Log

+ (void)RemoveAllLogs {
	
	if ([LogCenter ServiceEnable]) {
		
		NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
		[userDefault removeObjectForKey:LOGSERVICES];
		[userDefault synchronize];
		
		[LogCenter PrintDeveloperLog:@"[Remove Log] ALL LOGS DELETED!"];

	} else {
		
		NSLog(@"[LogCenter] SERVICE IS DISABLE!");
	}
}

+ (NSArray *)RemoveLogServiceWithIdentifier:(NSString *)identifier {
	
	if ([LogCenter ServiceEnable]) {
		
		@try {
			
			NSString *logTitle = @"";
			
			NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
			
			__strong NSMutableArray *logsArray = [[NSMutableArray alloc]initWithArray:[userDefault objectForKey:LOGSERVICES]];
			
			for (int i = 0; i < [logsArray count]; i++) {
				
				LogService *log = [NSKeyedUnarchiver unarchiveObjectWithData:[logsArray objectAtIndex:i]];
				
				logTitle = [log title];
				
				if ([[log logServiceID] isEqualToString:identifier]) {
					
					[logsArray removeObjectAtIndex:i];
					
					[userDefault setObject:logsArray forKey:LOGSERVICES];
					[userDefault synchronize];
				}
			}
			
			NSString *Log = [NSString stringWithFormat:@"[Remove Log] LOG [%@] DELETED!",logTitle];
			[LogCenter PrintDeveloperLog:Log];
			
			return logsArray;
		}
		@catch (NSException *exception) {

			NSLog(@"Exception Is: %@",exception);
		}
		
	} else {
		
		NSLog(@"[LogCenter] SERVICE IS DISABLE!");
	}
	return nil;
}

#pragma mark - Functional Services

+ (void)MoveTemporaryLogsToLogCenter {
	
	if ([LogCenter ServiceEnable]) {

		NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
		
		NSMutableArray *tempLogs = [userDefault objectForKey:TEMPORALLOGS];
		NSMutableArray *mainLogs = [userDefault objectForKey:LOGSERVICES];
		
		if ([tempLogs count] > 0)
			[mainLogs addObjectsFromArray:tempLogs];
		
		[userDefault removeObjectForKey:TEMPORALLOGS];
		[userDefault setObject:mainLogs forKey:LOGSERVICES];
		[userDefault synchronize];
		
		NSString *Log = [NSString stringWithFormat:@"[Move Log] %i LOG MOVED TO MAIN!",(int)[tempLogs count]];
		[LogCenter PrintDeveloperLog:Log];

	} else {
		
		NSLog(@"[LogCenter] SERVICE IS DISABLE!");
	}
}

#pragma mark - Search Services

+ (NSArray *)SearchLogByTitle:(NSString *)title {
	
	if ([LogCenter ServiceEnable]) {
		
		NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
		
		NSMutableArray *logsArray = [NSMutableArray array];
		NSMutableArray *tempArray = [NSMutableArray array];
		
		logsArray = [userDefault objectForKey:LOGSERVICES];
		
		for (NSData *logData in logsArray) {
			
			LogService *log = [NSKeyedUnarchiver unarchiveObjectWithData:logData];
			
			if ([[log title]hasPrefix:title]) {
				
				[tempArray addObject:log];
			}
		}
		
		NSString *Log = [NSString stringWithFormat:@"[Search Log] %i LOG FOUNDED!",(int)[tempArray count]];
		[LogCenter PrintDeveloperLog:Log];
		
		return tempArray;
	} else {
		
		NSLog(@"[LogCenter] SERVICE IS DISABLE!");
	}
	return nil;
}

+ (NSArray *)SearchLogByMinimumTimeStamp:(NSString *)minTime {
	
	if ([LogCenter ServiceEnable]) {
		
		NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
		
		NSMutableArray *logsArray = [NSMutableArray array];
		NSMutableArray *tempArray = [NSMutableArray array];
		
		logsArray = [userDefault objectForKey:LOGSERVICES];
		
		for (NSData *logData in logsArray) {
			
			LogService *log = [NSKeyedUnarchiver unarchiveObjectWithData:logData];
			
			if ([[log timeInterval] floatValue] <= [minTime floatValue]) {
				
				[tempArray addObject:log];
			}
		}
		
		NSString *Log = [NSString stringWithFormat:@"[Search Log] %i LOG FOUNDED!",(int)[tempArray count]];
		[LogCenter PrintDeveloperLog:Log];
		
		return tempArray;
	} else {
		
		NSLog(@"[LogCenter] SERVICE IS DISABLE!");
	}
	return nil;
}

+ (NSArray *)SearchLogByMaximumTimeStamp:(NSString *)maxTime {
	
	if ([LogCenter ServiceEnable]) {
		
		NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
		
		NSMutableArray *logsArray = [NSMutableArray array];
		NSMutableArray *tempArray = [NSMutableArray array];
		
		logsArray = [userDefault objectForKey:LOGSERVICES];
		
		for (NSData *logData in logsArray) {
			
			LogService *log = [NSKeyedUnarchiver unarchiveObjectWithData:logData];
			
			if ([[log timeInterval] floatValue] >= [maxTime floatValue]) {
				
				[tempArray addObject:log];
			}
		}
		
		NSString *Log = [NSString stringWithFormat:@"[Search Log] %i LOG FOUNDED!",(int)[tempArray count]];
		[LogCenter PrintDeveloperLog:Log];

		return tempArray;
	} else {
		
		NSLog(@"[LogCenter] SERVICE IS DISABLE!");
	}
	return nil;
}

#pragma mark - Reading Enable

+ (void)SetReadingIsEnable:(BOOL)isEnable {

	if ([LogCenter ServiceEnable]) {

		NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
		[userDefault setBool:isEnable forKey:READINGENABLE];
		[userDefault synchronize];
		
		if (!isEnable)
			[LogCenter MoveTemporaryLogsToLogCenter];
	} else {
		
		NSLog(@"[LogCenter] SERVICE IS DISABLE!");
	}
}

+ (BOOL)ReadingIsEnable {
	
	if ([LogCenter ServiceEnable]) {
		
		NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
		return [userDefault boolForKey:READINGENABLE];
	} else {
		
		NSLog(@"[LogCenter] SERVICE IS DISABLE!");
	}
	return false;
}

#pragma mark - Developer Logging

+ (void)SetEnableDeveloperLogs:(BOOL)enable {
	
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setBool:enable forKey:ENABLELOGGER];
	[userDefault synchronize];
}

+ (BOOL)EnableDeveloperLogs {
	
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	return [userDefault boolForKey:ENABLELOGGER];
}

+ (void)PrintDeveloperLog:(NSString *)log {
	
	if ([LogCenter EnableDeveloperLogs])
		NSLog(@"[LogCenter][%f]%@", [[NSDate date] timeIntervalSince1970], log);
}

#pragma mark - Version

+ (void)SetLoggerVersion:(NSString *)version {
	
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setObject:version forKey:LOGGERVERSION];
	[userDefault synchronize];
}

+ (NSString *)LogegrVersion {
	
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	return [userDefault objectForKey:LOGGERVERSION];
}

@end
