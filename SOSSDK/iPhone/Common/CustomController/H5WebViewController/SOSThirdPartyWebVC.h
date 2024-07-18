//
//  SOSThirdPartyWebVC.h
//  Onstar
//
//  Created by Coir on 2019/9/10.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSThirdPartyWebVC : UIViewController

@property (strong, nonatomic) WKWebView *wkWebView;

- (id)initWithUrl:(NSString *)url;

- (void)loadURL:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
