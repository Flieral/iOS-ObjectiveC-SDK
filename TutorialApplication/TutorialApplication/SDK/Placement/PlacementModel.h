//
//  PlacementModel.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, Type)
{
	SmallBanner = 1,
	MediumBanner = 2,
	LargeBanner = 3,
	MediumInterstitial = 4,
	LargeInterstitial = 5
	
} type;

@interface PlacementModel : NSObject

@property (nonatomic, strong) NSString  * _Nonnull placementHashID;

@property (nonatomic, strong) UIView	* _Nonnull parentView;
@property (nonatomic, strong) UIWebView * _Nonnull placementView;

@property (nonatomic) Type		placementType;

@property (nonatomic) CGPoint	defaultPosition;
@property (nonatomic) CGPoint	backendPosition;
@property (nonatomic) CGSize	backendSize;

@property (nonatomic, copy, nullable) void (^preLoadBlock)(NSDictionary * _Nonnull details);
@property (nonatomic, copy, nullable) void (^didLoadBlock)(NSDictionary * _Nonnull details);
@property (nonatomic, copy, nullable) void (^failedLoadBlock)(NSDictionary * _Nonnull details);
@property (nonatomic, copy, nullable) void (^willAppearBlock)(NSDictionary * _Nonnull details);
@property (nonatomic, copy, nullable) void (^didAppearBlock)(NSDictionary * _Nonnull details);
@property (nonatomic, copy, nullable) void (^willDisappearBlock)(NSDictionary * _Nonnull details);
@property (nonatomic, copy, nullable) void (^didDisappearBlock)(NSDictionary * _Nonnull details);

- (nullable id)initWithHashID:(nonnull NSString *)hashID;

- (void)setOnlineModeWithContentAtURL:(nonnull NSURL *)url;
- (void)setOfflineModeWithContentAtURL:(nonnull NSURL *)url;

- (nullable UIWebView *)getOnlineModeWithContentAtURL;
- (nullable UIWebView *)getOfflineModeWithContentAtURL;

@end
