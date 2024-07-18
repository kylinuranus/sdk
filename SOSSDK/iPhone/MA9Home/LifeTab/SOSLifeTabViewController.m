//
//  SOSLifeTabViewController.m
//  Onstar
//
//  Created by Onstar on 2018/11/17.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSLifeTabViewController.h"
#import "SOSLifeThirdFuncsHelper.h"
#import "SOSLifeWebViewController.h"

#import "SOSQuickStartEditorViewController.h"
#import "SOSLifeJumpHelper.h"
#if __has_include("SOSSDK.h")
#import "SOSSDK.h"
#else
#import "SOSIMNotificationCenter.h"
#import <NIMSDK/NIMSDK.h>
#import "SOSIMLoginManager.h"
#endif

@interface SOSLifeTabViewController ()<SOSLifeWebViewControllerDelegate, SOSQuickStarteditCompleteDelegate>
@property (strong, nonatomic) NSArray<NNBanner *> *totalThirdFuncs;
@property (strong, nonatomic) NSMutableArray<NNBanner *> *thirdFuncs;
@property (strong, nonatomic) SOSLifeWebViewController *webViewController;
@property (assign, nonatomic) BOOL needClearChelunRecord;//清楚车辆违章查询历史

@end

@implementation SOSLifeTabViewController

- (void)initData {
    _thirdFuncs = @[].mutableCopy;
    _totalThirdFuncs = @[];
}

- (void)initView {
#if SOSSDK_SDK
    self.fd_prefersNavigationBarHidden = NO;
    self.navigationItem.title = @"安吉星";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[[UIImage imageNamed:@"common_Nav_Back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    button.size = CGSizeMake(30, 44);
    [button addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        [SOSSDK sos_dismissOnstarModule];
    }];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
#else
    self.fd_prefersNavigationBarHidden = YES;
#endif
    NSString *url = SOSLifeHomeURL;
#if TEST || DEBUG
    //测试环境没有开启https服务
    url = [url stringByReplacingOccurrencesOfString:@"https" withString:@"http"];
#endif
    _webViewController = [[SOSLifeWebViewController alloc] initWithUrl:url];
    _webViewController.delegate = self;
    [self addChildViewController:_webViewController];
    [_webViewController didMoveToParentViewController:self];
    [self.view addSubview:_webViewController.view];
    [_webViewController.view mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];
    __weak __typeof(self)weakSelf = self;
    _webViewController.editFuncs = ^{
        [weakSelf editFuncs];
    };
    
    if (@available(iOS 11.0, *)) {
        [_webViewController.webView.wkWebView.scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }


}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
    [self addObserver];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)addObserver {
    __weak __typeof(self)weakSelf = self;
    [RACObserve([LoginManage sharedInstance] , loginState) subscribeNext:^(NSNumber *state) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (state.integerValue == LOGIN_STATE_NON || state.integerValue == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS) {
                [weakSelf cookTotalFuncs];
            }
    #ifndef SOSSDK_SDK
            if (state.integerValue == LOGIN_STATE_NON) {
                if (weakSelf.needClearChelunRecord) {
                    [[CLQuery sharedInstance] deleteAllCar];
                    weakSelf.needClearChelunRecord = NO;
                }

            }
            if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady] && ![SOSCheckRoleUtil isVisitor]) {
                [[SOSIMNotificationCenter sharedCenter] addDelegate:weakSelf];
                [weakSelf sendUnreadNumToHTML];
            }
            if (state.integerValue == LOGIN_STATE_NON) {
                [[SOSIMNotificationCenter sharedCenter] removeDelegate:weakSelf];
            }
    #endif
        });
       
    }];
}


#pragma mark - http request

- (void)requestThirdFunctions:(void (^)(NSArray<NNBanner *> * _Nullable totalFuncs, NSError * _Nullable error))finished {
    [OthersUtil getBannerByCategory:@"MA90_LIFE" SuccessHandle:^(NSArray<NNBanner *> *response) {
        _totalThirdFuncs = response.copy;
        finished ? finished(_totalThirdFuncs, nil) : nil;
        
    } failureHandler:^(NSString *responseStr, NSError *error) {
        finished ? finished(nil, error) : nil;

    }];
}

#pragma mark - life web view controller delegate
- (void)lifeWebViewControllerDidFinishLoadingURL:(NSURL *)URL {
    __weak __typeof(self)weakSelf = self;
    if (_totalThirdFuncs.count <= 0) {
        [self requestThirdFunctions:^(NSArray<NNBanner *> * _Nullable totalFuncs, NSError * _Nullable error) {
            if (!error) {
                [weakSelf cookTotalFuncs];
            }
        }];
    }else {
        [self sendThirdFuncsToHTML];
    }
    [self sendUnreadNumToHTML];

}

- (void)lifeWebViewControllerDidFailToLoadURL:(NSURL *)URL {
    
}

#pragma mark - SOSIMNotificationCenterDelegate
- (void)didMessageUnreadNumChanged:(NSUInteger)unreadNum {
    [self sendUnreadNumToHTML];
}

#pragma mark - SOSQuickStarteditCompleteDelegate
- (void)editCompleteWithSelectQS:(NSMutableArray *)selectqsArray andAllqsArray:(NSMutableArray *)allqsArray {
    _thirdFuncs = selectqsArray;
    [[SOSLifeThirdFuncsHelper sharedInstance] saveThirdFuncs:selectqsArray];
    [self sendThirdFuncsToHTML];
}

#pragma mark - private

- (void)cookTotalFuncs {
    _thirdFuncs = [[SOSLifeThirdFuncsHelper sharedInstance] filterWithServerResponse:_totalThirdFuncs].mutableCopy;
    [self sendThirdFuncsToHTML];
}

- (void)sendThirdFuncsToHTML {
//    if (_thirdFuncs.count <= 0) {
//        return;
//    }
    NSString *param = [_thirdFuncs modelToJSONString];
    [self.webViewController sendThirdFuncsToHTML:param];
}

- (void)sendUnreadNumToHTML {
#ifndef SOSSDK_SDK
    if (![SOSIMLoginManager sharedManager].isLogin) {
        return;
    }
    [self.webViewController sendUnreadNumToHTML:[SOSIMNotificationCenter sharedCenter].unreadCount];
#endif
}

- (void)editFuncs {
//    if (_thirdFuncs.count <= 0) {
//        return;
//    }
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:self withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        SOSQuickStartEditorViewController *vc = [[SOSQuickStartEditorViewController alloc] initWithSelectqsArray:_thirdFuncs.mutableCopy allqsArray:@[[SOSLifeThirdFuncsHelper sharedInstance].filterdTotalFuncs.mutableCopy].mutableCopy groupNameArray:@[@"其他"] needUniqueCheck:YES];
        vc.navigationItem.title = @"实用功能";
        vc.minKeepNumber = 3;
        vc.maxKeepNumber = 7;
        vc.delegate = self;
        vc.cellClickBlock = ^(id<SOSQSModelProtol> _Nonnull modelItem) {
            //这里MJExtension似乎有bug,转换para会丢失中文内容
            NNBanner *banner = (NNBanner *)modelItem;
            NSString *key = banner.title;
            NSLog(@"goto  %@", key);
            SOSLifeJumpHelper *helper = [[SOSLifeJumpHelper alloc] initWithFromViewController:self];
            [helper jumpTo:key para:banner];
        };
        
        //埋点
        vc.backFunctionID = UF_BACK;
        vc.editFunctionID = UF_CHANGE;
        vc.saveFunctionID = UF_CHANGESAVE;
        vc.cancelFunctionID = UF_CHANGECANCEL;
        
        [self.navigationController pushViewController:vc animated:YES];
    }];

}


- (void)dealloc {
    NSLog(@"%@ has dealloc", self.className);
}
-(void)initSDK{
#ifndef SOSSDK_SDK
    self.needClearChelunRecord = YES;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        NSString * key ;
//        #if DEBUG || TEST
//        key = @"TYCqAahzdLtceXaxPb8gyst62cXYSk9l";
//        #else
            key = @"TYZOlKz87aGDetB1mQVpL3yJfTBiAITu";
//        #endif
        [[CLQuery sharedInstance] setupWithDelegate:self appId:@"1" key:@"cwz.api.cwz_token" secret:key debug:NO];

    });
#endif
}
#pragma mark--CLQ Delegate
- (void)openWithLink:(NSString *)link{
    SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:link];
    [self.navigationController pushViewController:webVC animated:YES];

}
//- (NSString *)getUserGdCityCode{
//    NSLog(@"getUserGdCityCode");
//    return @"021";
//}
@end
