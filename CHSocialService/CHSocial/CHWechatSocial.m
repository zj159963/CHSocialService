//
//  CHWechatSSOManager.m
//  PictureApp
//
//  Created by yicha on 12/30/15.
//  Copyright © 2015 Chris. All rights reserved.
//

#import "CHWechatSocial.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "NSURL+CHHelper.h"

static NSString *const kURLWechatUserInfo = @"https://api.weixin.qq.com/sns/oauth2/access_token?";

@interface CHWechatSocial ()

@property (nonatomic, strong) SendAuthReq *request;

@end

@implementation CHWechatSocial

+ (instancetype)sharedSocial
{
  static CHWechatSocial *social = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    social = CHWechatSocial.new;
    social.request = SendAuthReq.new;
    social.request.scope = @"snsapi_userinfo";
    social.request.state = @"com.yicha.photo";
  });
  return social;
}


- (void)loginWithSucess:(CHSocialLoginSuccessHandler)sucess failure:(CHSocialLoginFailureHandler)failure
{
  [super loginWithSucess:sucess failure:failure];
  [WXApi sendReq:self.request];
}

- (void)shareObject:(CHShareObject *)object toPlatform:(NSString *)platform handler:(CHSocialShareHandler)handler
{
  [super shareObject:object toPlatform:platform handler:handler];
  [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL ch_URLWithString:object.previewURL] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
    if (!error && finished) {
      WXWebpageObject *webpage = [WXWebpageObject object];
      webpage.webpageUrl = object.url;
      WXMediaMessage *message = [WXMediaMessage message];
      message.mediaObject = webpage;
      message.thumbData = image.ch_previewData;
      SendMessageToWXReq *request = [[SendMessageToWXReq alloc] init];
      request.message = message;
      if (platform == kCHSocialShareToWechat) {
        request.scene = WXSceneSession;
        message.title = object.title;
        message.description = object.des;
      } else {
        request.scene = WXSceneTimeline;
        message.title = [NSString stringWithFormat:@"%@ %@", object.title, object.des];
      }
      [WXApi sendReq:request];
    } else {
      dispatch_sync(dispatch_get_main_queue(), ^{
        _shareHandler(NO);
      });
    }
  }];
}

- (void)onResp:(BaseResp *)resp
{
  if ([resp isKindOfClass:SendAuthResp.class])
  {
    SendAuthResp *auth = (SendAuthResp *)resp;
    if (auth.errCode == 0) {
      NSDictionary *param = @{@"appid":@"wxdc1e388c3822c80b",
                              @"secret":@"a393c1527aaccb95f3a4c88d6d1455f6",
                              @"code":auth.code,
                              @"grant_type":@"authorization_code"};
      AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
      manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", nil];
      [manager GET:kURLWechatUserInfo parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        _successHandler(responseObject[@"openid"], responseObject[@"access_token"]);
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        _failureHandler(kCHSocialSSOResultCodeFailNotNetwork);
      }];
    }
    else if (auth.errCode == -2)
    {
      _failureHandler(kCHSocialSSOResultCodeFailCancel);
    }
    else
    {
      _failureHandler(kCHSocialSSOResultCodeFailOther);
    }
  }
  else if ([resp isKindOfClass:SendMessageToWXResp.class])
  {
    _shareHandler(resp.errCode == 0);
  }
}

@end