//
//  SOSNickNameViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/9/15.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSNickNameViewController.h"
#import "AccountInfoUtil.h"
@interface SOSNickNameViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet SOSRegisterTextField *nickNameField;
@property (copy, nonatomic) NSString *lastTextContent;
@end

@implementation SOSNickNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"昵称";
//    self.navigationController.//navigationBar.translucent = NO;
    self.view.backgroundColor = [SOSUtil onstarLightGray];
//    [self.nickNameField addTarget:self action:@selector(textLengthChange:) forControlEvents:UIControlEventEditingChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.nickNameField];
    _nickNameField.delegate = self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    NSUInteger bytes = self.nickNameField.text.cStringLength;
    if (bytes > 18 && ![string isEqualToString:@""] && ![string isEqualToString:@"\n"]) {
        return NO;
    }
    return YES;
}


- (void)textFieldDidChange:(NSNotification *)note{
    
    //获取文本框内容的字节数
    NSUInteger bytes = self.nickNameField.text.cStringLength;
    NSLog(@"字节数   %@", @(bytes));
    //设置不能超过18个字节，因为不能有半个汉字，所以以字符串长度为单位。
    if (bytes > 18)
    {
        //超出字节数，还是原来的内容
        self.nickNameField.text = self.lastTextContent;
    }
    else
    {
        self.lastTextContent = self.nickNameField.text;
    }

}

//更新nickname
- (IBAction)updateNickName:(id)sender{
    [self.view endEditing:YES];
    if (![self inputChineseOrLettersNumberslimit:self.nickNameField.text]) {
        [Util toastWithMessage:@"您输入的内容包含非法字符，请输入中文或英文字母重试"];
        return;
    }
    if ([[CustomerInfo sharedInstance].tokenBasicInfo.nickName isEqualToString:self.nickNameField.text]) {
        [Util toastWithMessage:@"您的昵称已存在，请重新输入"];
        return;
    }
    
    [Util showLoadingView];
    [AccountInfoUtil updateUserNickName:self.nickNameField.text successBlock:^(NNRegisterResponse *response) {
        [Util hideLoadView];
        [Util toastWithMessage:@"更改昵称成功"];
        [CustomerInfo sharedInstance].tokenBasicInfo.nickName = self.nickNameField.text;
        [[LoginManage sharedInstance] saveTokenOnstarAccount:[[CustomerInfo sharedInstance].tokenBasicInfo mj_JSONString]];
        self->_updateBlock(self.nickNameField.text);
        [self.navigationController popViewControllerAnimated:YES];
        
        
    } failedBlock:^{
        [Util hideLoadView];
    }];
}
- (BOOL)inputChineseOrLettersNumberslimit:(NSString*)string{
    NSString *regex = @"^[a-zA-Z0-9_\u4e00-\u9fa5]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL  inputString = [predicate evaluateWithObject:string];
    return inputString;
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
