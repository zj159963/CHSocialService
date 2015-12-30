//
//  CHBaseSSOManager.h
//  PictureApp
//
//  Created by yicha on 12/30/15.
//  Copyright © 2015 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "CHShareObject.h"

@class CHSocialContext;

typedef void(^CHSocialLoginSuccessHandler)(NSString *openID, NSString *accessToken);
typedef void(^CHSocialLoginFailureHandler)(NSString *code);

typedef void(^CHSocialShareHandler)(BOOL sucess);

@interface CHBaseSocial : NSObject {
  CHSocialLoginSuccessHandler _successHandler;
  CHSocialLoginFailureHandler _failureHandler;
  CHSocialShareHandler _shareHandler;
}

+ (instancetype)sharedSocial;
- (void)loginWithSucess:(CHSocialLoginSuccessHandler)sucess failure:(CHSocialLoginFailureHandler)failure;
- (void)shareObject:(CHShareObject *)object toPlatform:(NSString *)platform handler:(CHSocialShareHandler)handler;

@end