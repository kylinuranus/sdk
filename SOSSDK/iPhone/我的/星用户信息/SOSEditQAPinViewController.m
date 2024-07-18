//
//  SOSEditQAPinViewController.m
//  Onstar
//
//  Created by onstar on 2017/12/13.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSEditQAPinViewController.h"
#import "SOSPersonalInformationTableViewCell.h"
#import "SOSRegisterTextField.h"
#import "SOSNStytleEditInfoViewController.h"
#import "RegisterUtil.h"
#import "SOSRegisterInformation.h"
#import "SOSCardUtil.h"
#import "SOSCustomAlertView.h"

@interface SOSEditQAPinViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet      UITableView *infoTableView;
@property(strong,nonatomic) NSArray       * itemArray;
@property(strong,nonatomic) NSArray       * bbwcQuestionArray;

@end

@implementation SOSEditQAPinViewController{
//    NSMutableArray * bbwcQuestionRecordArray;

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self configSourceData];
//    [self queryBBWCQuestion];
}

- (void)initUI {
    self.title = @"完善安全信息";
//    bbwcQuestionRecordArray = [NSMutableArray array];
    _infoTableView.dataSource = self;
    _infoTableView.delegate = self ;
    NSString * const cellID = @"PersonalInfoViewCell";
    [_infoTableView registerNib:[UINib nibWithNibName:@"SOSPersonalInformationTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    _infoTableView.backgroundColor = [SOSUtil onstarLightGray];
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 120)];
    UILabel *titleLabel = [UILabel new];
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont systemFontOfSize:16.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [SOSUtil onstarTextFontColor];
    titleLabel.text =@"欢迎您，使用安吉星!\n为了保证您的账户安全\n需要您完善以下信息才能使用安吉星";
    titleLabel.backgroundColor = [UIColor clearColor];
    [tableHeaderView addSubview:titleLabel];
    [titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(tableHeaderView);
    }];
    _infoTableView.tableHeaderView = tableHeaderView ;
    _infoTableView.tableFooterView = [UIView new];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [SOSUtil onstarLightGray];
    
    if (self.dismissComplete) {
        //星用户信息弹出
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_Nav_Back"] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
        
    }else {
        //登录后弹出
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"跳过" style:UIBarButtonItemStylePlain target:self action:@selector(jump)];
    }
}

- (void)configSourceData {
    /****/
    SOSPersonInfoItem * item14 = [[SOSPersonInfoItem alloc] initWithItemDesc:@"车辆控制密码" itemResult:nil itemIndex:15 isNecessary:YES rightArrowVisiable:YES];
    item14.itemPlaceholder = @"请输入密码";
    item14.enrollKey = @"pin";
    NSArray * pin = [NSArray arrayWithObject:item14];
    
//    //密保问题
//    NSMutableArray * quesArr = [NSMutableArray array];
//    if (_bbwcQuestionArray) {
//        int i = 1;
//        for (NNBBWCQuestion *question in _bbwcQuestionArray) {
//            SOSPersonInfoItem * itemQuestion = [[SOSPersonInfoItem alloc] initWithItemDesc:[NSString stringWithFormat:@"问题%@",@(i)] itemResult:nil itemIndex:16 isNecessary:YES rightArrowVisiable:YES];
//            SOSRegisterTextField * questionField = [[SOSRegisterTextField alloc] init];
//            questionField.placeholder = question.title;
//            questionField.text = nil;//[CustomerInfo sharedInstance].bbwcDone ? @"******" : nil;
//            [questionField addTextInputPredicate];
//            [itemQuestion setRightFieldView:questionField];
//            [quesArr addObject:itemQuestion];
//            [bbwcQuestionRecordArray addObject:question];
//            i++;
//        }
//    }
//    _itemArray = @[pin, quesArr];
      _itemArray = @[pin];  //隐藏安全问题

//    _itemArray = @[pin];  隐藏安全问题

}

#pragma mark - 查询bbwc安全问题
//- (void)queryBBWCQuestion
//{
//    [Util showLoadingView];
//    //第一步:查询bbwc安全问题
//    @weakify(self);
//    [OthersUtil queryBBWCQuestionByGovid:[CustomerInfo sharedInstance].govid successHandler:^(NSArray *questions) {
//        [Util hideLoadView];
//        @strongify(self);
//        dispatch_async_on_main_queue(^(){
//            if (questions) {
//                _bbwcQuestionArray = questions;
//                [self configSourceData];
//                [_infoTableView reloadData];
//            }else {
//                [Util toastWithMessage:@"获取安全问题失败,操作中止!"];
//                [self jump];
//            }
//        });
//    } failureHandler:^(NSString *responseStr, NNError *error) {
//        [Util hideLoadView];
//        dispatch_async_on_main_queue(^(){
//            [Util toastWithMessage:@"获取安全问题失败,操作中止!"];
//            [self jump];
//        });
//    }];
//}
//


#pragma mark -  提示必填项
- (void)toastMustFillPrompt
{
    [Util toastWithMessage:[NSString stringWithFormat:@"您的必填信息未填写完整，请核对后再提交"]];
}


//#pragma mark -  跳过

- (void)dismiss {
    [self.navigationController dismissViewControllerAnimated:NO completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SOS_PresentTouchID_Notification object:nil];//弹出touchid
    }];
}

- (void)jump
{
    if (self.dismissComplete) {
        [self.navigationController dismissViewControllerAnimated:NO completion:^{
            self.dismissComplete();
        }];
    }else {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            if (![CustomerInfo sharedInstance].currentVehicle.bbwc) {
                [SOSCardUtil routerToBBwcWithType:@""];
            }else {
                [[NSNotificationCenter defaultCenter] postNotificationName:SOS_PresentTouchID_Notification object:nil];//弹出touchid
            }
        }];
    }
}



- (IBAction)submit:(id)sender {
    
    CustomerInfo *userInfo = [CustomerInfo sharedInstance];
    BOOL bbwcDone = userInfo.currentVehicle.bbwc;
    
    SOSBBWCSubmitWrapper * scr = [[SOSBBWCSubmitWrapper alloc] init];
    scr.bbwcDone = bbwcDone;
//    NSInteger questionIndex = 0;
    for (NSArray * itemArr in _itemArray) {
        for (SOSPersonInfoItem * item in itemArr) {
            //检查必填项是否填写
            if (item.isNecessities) {
                if ([item personInfoValue] == nil || ![item personInfoValue].isNotBlank) {
                    [self toastMustFillPrompt];
                    return;
                }
            }
//            if (item.itemIndex == 15) {
//                NSInteger fromIdx = [CustomerInfo sharedInstance].govid.length - 6;
//                if (fromIdx >= 0) {
//                    NSString *defaultPin = [[CustomerInfo sharedInstance].govid substringFromIndex:fromIdx];
//                    if ([item.personInfoValue isEqualToString:defaultPin]) {
//                        [Util toastWithMessage:@"安全验证升级，请设置其他六位数密码"];
//                        return;
//                    }
//                }
//            }
            

            if (item.enrollKey) {
                [scr setValue:[item personInfoValue] forKey:item.enrollKey];
            }
//            else
//            {
//                //密保问题 没有enrollkey
//                if (![item personInfoValue].length) {
//                    questionIndex ++;
//                    continue;
//                }
//                NNBBWCQuestion * sourceQuestion = [bbwcQuestionRecordArray objectAtIndex:questionIndex];
//                [sourceQuestion setAnswer:[item personInfoValue]];
//                if (!scr.questions) {
//                    scr.questions = [NSMutableArray array];
//                }
//                [scr.questions addObject:sourceQuestion];
//                questionIndex ++;
//            }
        }
    }
//    if (scr.pin.length > 0) {       //此处调用BBWC_Submit接口，无需加密
//        NSString *tempS = scr.pin;
//        scr.pin = [SOSUtil AES128EncryptString:tempS];
//    }
    [Util showLoadingView];
    [RegisterUtil submitBBWCInfoOrOnstarInfo:NO withEnrollInfo:[scr mj_JSONString] successHandler:^(NSString *responseStr) {
        NNBBWCResponse * resp = [NNBBWCResponse mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
            if (resp && resp.vehicleType)
            {
                [Util hideLoadView];
                [Util showAlertWithTitle:@"恭喜您" message:@"您已完成密码设置操作。\n若需要修改其他信息可通过个人信息的星用户信息页面进行修改。" completeBlock:^(NSInteger buttonIndex) {
                    
                        [CustomerInfo sharedInstance].userBasicInfo.subscriber.isDefaultPin = NO;
                        if (![CustomerInfo sharedInstance].currentVehicle.bbwc) {
                            [KEY_WINDOW.rootViewController dismissViewControllerAnimated:NO completion:^{
                                [SOSCardUtil routerToBBwcWithType:resp.vehicleType];
                            }];
                            
                        }	else {
                            [self jump];
                        }
                    
                } cancleButtonTitle:nil otherButtonTitles:@"知道了",nil];
            }
            else
            {
                [Util hideLoadView];
                dispatch_async_on_main_queue(^{
                  [self jump];
                });
            }
    } failureHandler:^(NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
    
}

#pragma mark - tableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _itemArray.count ;
}

     
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)_itemArray[section]).count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 0.0f;
    }
    return 30.0f;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//
//    return 10.0f;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section    {
    if (section == 1) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH - 20, 30)];
        label.text = @"密保问题";
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor colorWithHexString:@"59708A"];
        UIView *headerView = [[UIView alloc] initWithFrame:label.bounds];
        [headerView addSubview:label];
        headerView.backgroundColor = [UIColor clearColor];
        return headerView;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SOSPersonalInformationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonalInfoViewCell"];
    [cell configCellData:_itemArray[indexPath.section][indexPath.row]];
    return cell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SOSPersonInfoItem * item = [_itemArray objectAtIndex:indexPath.section][indexPath.row];
    if (item.itemIndex == 15) {
        //车辆控制码(PIN)
        SOSNStytleEditInfoViewController * editUser = [[SOSNStytleEditInfoViewController alloc] initWithNibName:@"SOSNStytleEditInfoViewController" bundle:nil];
        editUser.editType =SOSEditUserInfoTypeCarControlPassword;
        editUser.govid = [CustomerInfo sharedInstance].govid;
        editUser.backRecordFunctionID =changecontrolpin_back;
        SOSWeakSelf(weakSelf);
        [editUser setFixOkBlock:^(NSString * text){
            item.itemResult = text;
            SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
            item.itemPlaceholder = @"******";
            [cell updateCellValue:@"******"];
            [SOSDaapManager sendActionInfo:changecontrolpin_submit];
        }];
        [self.navigationController pushViewController:editUser animated:YES];
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"SOSEditQAPinViewController dealloc");
    [[LoginManage sharedInstance] nextPopViewAction];
}
@end
