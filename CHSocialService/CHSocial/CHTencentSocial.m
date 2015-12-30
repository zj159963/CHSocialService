//
//  CHTencentSocial.m
//  PictureApp
//
//  Created by yicha on 12/30/15.
//  Copyright © 2015 Chris. All rights reserved.
//

#import "CHTencentSocial.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>

@interface CHTencentSocial () <TencentSessionDelegate>

@property (nonatomic, strong) TencentOAuth *oAuth;

@end

@implementation CHTencentSocial

+ (instancetype)sharedSocial
{
  static CHTencentSocial *social = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    social = CHTencentSocial.new;
    social.oAuth = [[TencentOAuth alloc] initWithAppId:@"100424468" andDelegate:social];
  });
  return social;
}

- (void)loginWithSucess:(CHSocialLoginSuccessHandler)sucess failure:(CHSocialLoginFailureHandler)failure
{
  [super loginWithSucess:sucess failure:failure];
  [self.oAuth authorize:@[@"get_user_info"] inSafari:NO];
}

- (void)shareObject:(CHShareObject *)object toPlatform:(NSString *)platform handler:(CHSocialShareHandler)handler
{
  [super shareObject:object toPlatform:platform handler:handler];
  [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL ch_URLWithString:object.previewURL] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
    if (!error && finished) {
      QQApiURLObject *link = [QQApiURLObject objectWithURL:[NSURL ch_URLWithString:object.url] title:object.title description:object.des previewImageData:image.ch_previewData targetContentType:QQApiURLTargetTypeNews];
      SendMessageToQQReq *request = [SendMessageToQQReq reqWithContent:link];
      dispatch_sync(dispatch_get_main_queue(), ^{
        if ([platform isEqualToString:kCHSocialShareToQQ]) {
          _shareHandler(YES);
        } else if ([platform isEqualToString:kCHSocialShareToQZone]) {
          QQApiSendResultCode code = [QQApiInterface SendReqToQZone:request];
          _shareHandler(code == EQQAPISENDSUCESS);
        }
      });
    } else {
      dispatch_sync(dispatch_get_main_queue(), ^{
        _shareHandler(NO);
      });
    }
  }];
}

#pragma mark - Tencent Session Delegate
- (void)tencentDidLogin
{
  _successHandler(self.oAuth.openId, self.oAuth.accessToken);
}

- (void)tencentDidLogout
{
  _failureHandler(kCHSocialSSOResultCodeLogedOut);
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
  NSString *code = cancelled ? kCHSocialSSOResultCodeFailCancel : kCHSocialSSOResultCodeFailOther;
  _failureHandler(code);
}

- (void)tencentDidNotNetWork
{
  _failureHandler(kCHSocialSSOResultCodeFailNotNetwork);
}

@end