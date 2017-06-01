//
//  NSQueue.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "NSQueue.h"

#define QUEUECONTENTKEY		@"FlieralQueueContentKey"
#define QUEUECAPACITYKEY	@"FlieralQueueCapacityKey"
#define QUEUECACHEPOLICYKEY	@"FlieralQueueCachePolicyKey"

@interface NSQueue()

@property (nonatomic, strong) NSMutableArray  * data;
@property (nonatomic, strong) NSString        * identifier;

@property (nonatomic) NSInteger     capacity;
@property (nonatomic) BOOL          useCachePolicy;

@end

@implementation NSQueue

#pragma mark - Placement Life Cycle

- (nullable instancetype)init
{
	self = [super init];
	if (self)
	{
		
	}
	return self;
}

- (nullable instancetype)initWithIdentifier:(nonnull NSString *)identifier Capacity:(NSInteger)capacity
{
	if (self = [super init])
	{
		_useCachePolicy = false;
		_identifier     = identifier;
		_capacity       = capacity;
		_data           = [NSMutableArray arrayWithCapacity:capacity];
	}
	return self;
}

#pragma mark - Queue Setting

- (void)useAutomaticCachePolicyInOperations
{
	_useCachePolicy = true;
}

- (void)saveQueueContent
{
	NSString *key1 = [NSString stringWithFormat:@"%@:%@", QUEUECONTENTKEY, _identifier];
	NSString *key2 = [NSString stringWithFormat:@"%@:%@", QUEUECAPACITYKEY, _identifier];
	NSString *key3 = [NSString stringWithFormat:@"%@:%@", QUEUECACHEPOLICYKEY, _identifier];
	
    NSData *encodedObject   = [NSKeyedArchiver  archivedDataWithRootObject:_data];
	NSUserDefaults *ud      = [NSUserDefaults   standardUserDefaults];
    
	[ud setObject:encodedObject     forKey:key1];
	[ud setInteger:_capacity        forKey:key2];
	[ud setBool:_useCachePolicy     forKey:key3];
    
	[ud synchronize];
}

- (void)loadQueueContentForPlacementIdentifier:(nonnull NSString *)identifier
{
	NSString *key1 = [NSString stringWithFormat:@"%@:%@", QUEUECONTENTKEY,      _identifier];
	NSString *key2 = [NSString stringWithFormat:@"%@:%@", QUEUECAPACITYKEY,     _identifier];
	NSString *key3 = [NSString stringWithFormat:@"%@:%@", QUEUECACHEPOLICYKEY,  _identifier];
	
	NSUserDefaults *ud  = [NSUserDefaults standardUserDefaults];
	_identifier         = identifier;
    _capacity           = [ud integerForKey:key2];
    _useCachePolicy     = [ud boolForKey:key3];
    
    NSData *encodedObject = [ud objectForKey:key1];
    _data = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
}

#pragma mark - Queue Operation

- (void)enqueue:(nonnull id)anObject
{
	if (_data.count < _capacity)
		[self.data addObject:anObject];
	
	if (_useCachePolicy)
		[self saveQueueContent];
}

- (nullable id)dequeue
{
	id headObject;
	if (_data.count > 0)
	{
		headObject = [self.data objectAtIndex:0];
		if (headObject != nil)
		{
			[self.data removeObjectAtIndex:0];
		}
	}

	if (_useCachePolicy)
		[self saveQueueContent];

	return headObject;
}

- (nullable id)peekObjectAtIndex:(NSInteger)index
{
	id object;
	if (_data.count > 0 && index < _data.count)
		object = [self.data objectAtIndex:index];

	return object;
}

- (void)clearingQueue
{
    [self.data removeAllObjects];

    if (_useCachePolicy)
        [self saveQueueContent];

}

#pragma mark - Queue Statuses

- (int)currentEmptySpaces
{
    return (int) _capacity - (int) _data.count;
}

- (BOOL)checkForEmptySpace
{
    if (_capacity - _data.count > 0)
        return true;
    return false;
}

@end
