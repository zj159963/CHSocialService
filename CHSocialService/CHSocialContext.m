//
//  CHSocialContext.m
//  PictureApp
//
//  Created by yicha on 12/30/15.
//  Copyright © 2015 Chris. All rights reserved.
//

#import "CHSocialContext.h"
#import "CHBaseSocial.h"
#import "CHWeiboSocial.h"
#import "CHWechatSocial.h"
#import "CHTencentSocial.h"

NSString *const kCHSSOTypeWeibo = @"X_wb";
NSString *const kCHSSOTypeWechat = @"weixin";
NSString *const kCHSSOTypeTencent = @"qq";

NSString *const kCHSocialSSOResultCodeSuccuess = @"kCHSocialSSOResultCodeSuccuess";
NSString *const kCHSocialSSOResultCodeFailNotNetwork = @"kCHSocialSSOResultCodeFailNotNetwork";
NSString *const kCHSocialSSOResultCodeFailCancel = @"kCHSocialSSOResultCodeFailCancel";
NSString *const kCHSocialSSOResultCodeFailOther = @"kCHSocialSSOResultCodeFailOther";
NSString *const kCHSocialSSOResultCodeLogedOut = @"kCHSocialSSOResultCodeLogedOut";

NSString *const kCHSocialShareToQQ = @"kCHSocialShareToQQ";
NSString *const kCHSocialShareToQZone = @"kCHSocialShareToQZone";
NSString *const kCHSocialShareToWechat = @"kCHSocialShareToWechat";
NSString *const kCHSocialShareToComments = @"kCHSocialShareToComments";
NSString *const kCHSocialShareToWeibo = @"kCHSocialShareToWeibo";

static NSString *const kURLWechatUserInfo = @"https://api.weixin.qq.com/sns/oauth2/access_token?";

@interface CHSocialContext ()

@property (nonatomic, strong) CHBaseSocial *social;

@end

@implementation CHSocialContext

+ (void)registerApp
{
  [WeiboSDK enableDebugMode:YES];
  [WeiboSDK registerApp:@"3921700954"];
  [WXApi registerApp:@"wxdc1e388c3822c80b"];
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
  if ([url.absoluteString containsString:@"tencent100424468"]) {
    return [TencentOAuth HandleOpenURL:url];
  }
  if ([url.absoluteString containsString:@"wb3921700954"]) {
    return [WeiboSDK handleOpenURL:url delegate:CHWeiboSocial.sharedSocial];
  }
  if ([url.absoluteString containsString:@"wxdc1e388c3822c80b"]) {
    return [WXApi handleOpenURL:url delegate:CHWechatSocial.sharedSocial];
  }
  return YES;
}

// Singleton
+ (instancetype)sharedContext
{
  static CHSocialContext *context = nil;
  static dispatch_once_t onceToken = 0;
  dispatch_once(&onceToken, ^{
    context = CHSocialContext.new;
  });
  return context;
}

#pragma mark - Initializers
- (instancetype)initWithDelegate:(id<CHSocialDelegate>)delegate
{
  self = [super init];
  if (self) {
    _delegate = delegate;
  }
  return self;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _social = CHBaseSocial.new;
  }
  return self;
}

#pragma mark - Setters
- (void)setType:(NSString *)type
{
  if ([type isEqualToString:kCHSSOTypeTencent]) {
    self.social = CHTencentSocial.sharedSocial;
  } else if ([type isEqualToString:kCHSSOTypeWechat]) {
    self.social = CHWechatSocial.sharedSocial;
  } else if ([type isEqualToString:kCHSSOTypeWeibo]) {
    self.social = CHWeiboSocial.sharedSocial;
  } else {
    NSAssert(YES, @"%s, Unsupported type. Use kCHSSOTypeWeibo or kCHSSOTypeWechat or kCHSSOTypeTencent", __func__);
  }
  _type = type;
}

#pragma mark - Service
- (void)login
{
  [self.social loginWithSucess:^(NSString *openID, NSString *accessToken) {
    [NSObject ch_target:self.delegate performSelector:@selector(socialContextLoginSuccess:openID:accessToken:) withObjects:@[self, openID, accessToken]];
  } failure:^(NSString *code) {
    [NSObject ch_target:self.delegate performSelector:@selector(socialContextLoginFailed:code:) withObjects:@[self, code]];
  }];
}

- (void)shareObject:(CHShareObject *)object withIndex:(NSUInteger)index
{
  NSString *platform = nil;
  switch (index) {
    case 0: {
      platform = kCHSocialShareToWeibo;
      self.type = kCHSSOTypeWeibo;
      break;
    }
    case 1: {
      platform = kCHSocialShareToComments;
      self.type = kCHSSOTypeWechat;
      break;
    }
    case 2: {
      platform = kCHSocialShareToQZone;
      self.type = kCHSSOTypeTencent;
      break;
    }
    case 3: {
      platform = kCHSocialShareToWechat;
      self.type = kCHSSOTypeWechat;
      break;
    }
    case 4: {
      platform = kCHSocialShareToQQ;
      self.type = kCHSSOTypeTencent;
      break;
    }
    default:
      break;
  }
  __strong typeof(object) strongObject = object;
  [self.social shareObject:strongObject toPlatform:platform handler:^(BOOL sucess) {
    if (sucess) {
      [NSObject ch_target:self.delegate performSelector:@selector(socialContextSharedSuccess:shareObject:toPlatform:) withObjects:@[self, object, platform]];
    } else {
      [NSObject ch_target:self.delegate performSelector:@selector(socialContextSharedFailure:shareObject:toPlatform:) withObjects:@[self, object, platform]];
    }
  }];
}

@end