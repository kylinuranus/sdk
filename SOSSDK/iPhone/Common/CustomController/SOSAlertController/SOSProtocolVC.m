//
//  SOSLBSProtocolView.m
//  Onstar
//
//  Created by Coir on 2018/12/21.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSProtocolVC.h"

@interface SOSProtocolVC ()

@property (strong, nonatomic) WKWebView *protocolWebView;
@property (assign, nonatomic) SOSAgreementType agreementType;
@property (strong, nonatomic) SOSAgreement *agreement;

@end

@implementation SOSProtocolVC


+ (instancetype)initWithTitle:(NSString *)title AgreementType:(SOSAgreementType)type CompleteHanlder:(void (^)(BOOL agreeStatus))completion		{
    SOSProtocolVC *vc = [SOSProtocolVC initWithTitle:title AgreeTitle:@"同意" CancelTitle:@"再想想" AgreementType:type CompleteHanlder:completion];
    return vc;
}

+ (instancetype)initWithTitle:(NSString *)title AgreeTitle:(NSString *)agreeTItle CancelTitle:(NSString *)cancelTitle AgreementType:(SOSAgreementType)type CompleteHanlder:(void (^)(BOOL agreeStatus))completion 	{
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 260, 300)];
    webView.backgroundColor = [UIColor whiteColor];
    SOSProtocolVC *vc = [SOSProtocolVC alertControllerWithImage:nil title:title message:nil customView:webView preferredStyle:SOSAlertControllerStyleAlert];
    vc.protocolWebView = webView;
    vc.agreementType = type;
    SOSAlertAction *cancelAction = [SOSAlertAction actionWithTitle:cancelTitle style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
        completion(NO);
    }];
    SOSAlertAction *ensureAction = [SOSAlertAction actionWithTitle:agreeTItle style:SOSAlertActionStyleDefault handler:^(SOSAlertAction * _Nonnull action) {
        if (vc.agreement) {
            [SOSAgreement requestSignAgreements:@[vc.agreement] success:^(NSDictionary *response) {
                
            } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                
            }];
        }
        [SOSAgreement localSignAgreement:type];
        completion(YES);
    }];
    [vc addActions:@[cancelAction, ensureAction]];
    return vc;
}

- (void)show	{
    [super show];
    [Util showHUD];
    [SOSAgreement requestAgreementsWithTypes:@[agreementName(self.agreementType)] success:^(NSDictionary *response) {
        [Util dismissHUD];
        NSDictionary *dic = response[agreementName(self.agreementType)];
        self.agreement = [SOSAgreement mj_objectWithKeyValues:dic];
        [self.protocolWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.agreement.url]]];
    } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util dismissHUD];
        [self dismissViewControllerAnimated:NO completion:nil];
        [Util toastWithMessage:@"获取协议内容失败"];
    }];
}

@end
