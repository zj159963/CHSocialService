//
//  CHWeiboSSOManager.m
//  PictureApp
//
//  Created by yicha on 12/30/15.
//  Copyright © 2015 Chris. All rights reserved.
//

#import "CHWeiboSocial.h"
#import "WeiboSDK.h"

@interface CHWeiboSocial ()

@property (nonatomic, strong) WBAuthorizeRequest *request;

@end

@implementation CHWeiboSocial

+ (instancetype)sharedSocial
{
  static CHWeiboSocial *social = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    social = CHWeiboSocial.new;
    social.request = [WBAuthorizeRequest request];
    social.request.redirectURI = @"http://sns.whalecloud.com/sina2/callback";
    social.request.scope = @"all";
  });
  return social;
}

- (void)loginWithSucess:(CHSocialLoginSuccessHandler)sucess failure:(CHSocialLoginFailureHandler)failure
{
  [super loginWithSucess:sucess failure:failure];
  [WeiboSDK sendRequest:self.request];
}

- (void)shareObject:(CHShareObject *)object toPlatform:(NSString *)platform handler:(CHSocialShareHandler)handler
{
  [super shareObject:object toPlatform:platform handler:handler];
  [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL ch_URLWithString:object.previewURL] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
    if (!error && finished) {
      WBMessageObject *message = [WBMessageObject message];
      message.text = [NSString stringWithFormat:@"我分享了“交点”APP的图片 %@", object.url];
      WBImageObject *imageObject = [WBImageObject object];
      imageObject.imageData = image.ch_shareToWeibo;
      message.imageObject = imageObject;
      WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
      [WeiboSDK sendRequest:request];
    } else {
      dispatch_sync(dispatch_get_main_queue(), ^{
        _shareHandler(NO);
      });
    }
  }];
}

#pragma mark WeiboSDK Delegate
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
  if ([response isKindOfClass:WBAuthorizeResponse.class])
  {
    WBAuthorizeResponse *auth = (WBAuthorizeResponse *)response;
    if (auth.statusCode == WeiboSDKResponseStatusCodeSuccess) {
      _successHandler(auth.userID, auth.accessToken);
    }
    else if (auth.statusCode == WeiboSDKResponseStatusCodeUserCancel)
    {
      _failureHandler(kCHSocialSSOResultCodeFailCancel);
    }
    else
    {
      _failureHandler(kCHSocialSSOResultCodeFailOther);
    }
  }
  else if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
  {
    _shareHandler(response.statusCode == WeiboSDKResponseStatusCodeSuccess);
  }
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {}

@end