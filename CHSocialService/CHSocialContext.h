//
//  CHSocialContext.h
//  PictureApp
//
//  Created by yicha on 12/30/15.
//  Copyright © 2015 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>

@class CHSocialContext;
@class CHShareObject;

// Login type
UIKIT_EXTERN NSString *const kCHSSOTypeWeibo;
UIKIT_EXTERN NSString *const kCHSSOTypeWechat;
UIKIT_EXTERN NSString *const kCHSSOTypeTencent;

// Login Result
UIKIT_EXTERN NSString *const kCHSocialSSOResultCodeSuccuess;
UIKIT_EXTERN NSString *const kCHSocialSSOResultCodeFailNotNetwork;
UIKIT_EXTERN NSString *const kCHSocialSSOResultCodeFailCancel;
UIKIT_EXTERN NSString *const kCHSocialSSOResultCodeFailOther;
UIKIT_EXTERN NSString *const kCHSocialSSOResultCodeLogedOut;

// Share Platform
UIKIT_EXTERN NSString *const kCHSocialShareToQQ;
UIKIT_EXTERN NSString *const kCHSocialShareToQZone;
UIKIT_EXTERN NSString *const kCHSocialShareToWechat;
UIKIT_EXTERN NSString *const kCHSocialShareToComments;
UIKIT_EXTERN NSString *const kCHSocialShareToWeibo;

@protocol CHSocialDelegate <NSObject>

@optional
// SSO
- (void)socialContextLoginSuccess:(CHSocialContext *)context openID:(NSString *)openID accessToken:(NSString *)accessToken;
- (void)socialContextLoginFailed:(CHSocialContext *)context code:(NSString *)code;
- (void)socialContextLogedOut:(CHSocialContext *)context;

// Share
- (void)socialContextSharedSuccess:(CHSocialContext *)context shareObject:(CHShareObject *)object toPlatform:(NSString *)platform;
- (void)socialContextSharedFailure:(CHSocialContext *)context shareObject:(CHShareObject *)object toPlatform:(NSString *)platform;

@end

@interface CHSocialContext : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, weak) id<CHSocialDelegate>delegate;

+ (void)registerApp;
+ (BOOL)handleOpenURL:(NSURL *)url;

+ (instancetype)sharedContext;
- (void)login;
- (void)shareObject:(CHShareObject *)object withIndex:(NSUInteger)index;

@end