//
//  CHBaseSSOManager.m
//  PictureApp
//
//  Created by yicha on 12/30/15.
//  Copyright © 2015 Chris. All rights reserved.
//

#import "CHBaseSocial.h"
#import "CHSocialContext.h"

@implementation CHBaseSocial

+ (instancetype)sharedSocial
{
  NSLog(@"This is an abstract class, use concrete subclass you need");
  return nil;
}

- (void)loginWithSucess:(CHSocialLoginSuccessHandler)sucess failure:(CHSocialLoginFailureHandler)failure
{
  _successHandler = sucess;
  _failureHandler = failure;
}

- (void)shareObject:(CHShareObject *)object handler:(CHSocialShareHandler)handler
{
  [self setShareHandler:handler];
}

- (void)shareObject:(CHShareObject *)object toPlatform:(NSString *)platform handler:(CHSocialShareHandler)handler
{
  [self setShareHandler:handler];
}

- (void)setShareHandler:(CHSocialShareHandler)handler
{
  _shareHandler = handler;
}

@end