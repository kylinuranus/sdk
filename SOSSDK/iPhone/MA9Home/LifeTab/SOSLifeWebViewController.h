//
//  SOSLifeWebViewController.h
//  Onstar
//
//  Created by TaoLiang on 2019/1/9.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSWebViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SOSLifeWebViewControllerDelegate <NSObject>

@optional
- (void)lifeWebViewControllerDidFinishLoadingURL:(NSURL *)URL;
- (void)lifeWebViewControllerDidFailToLoadURL:(NSURL *)URL;
@end

@interface SOSLifeWebViewController : SOSWebViewController

@property (assign, nonatomic) id<SOSLifeWebViewControllerDelegate> delegate;

- (void)sendThirdFuncsToHTML:(NSString *)funcsJson;
- (void)sendUnreadNumToHTML:(NSInteger)unreadCount;

- (void)reload;

@property(copy, nonatomic) void (^editFuncs)(void);

@end

NS_ASSUME_NONNULL_END
