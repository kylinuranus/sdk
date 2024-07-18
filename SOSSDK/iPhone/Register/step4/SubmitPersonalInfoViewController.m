//
//  SubmitPersonalInfoViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/8/21.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SubmitPersonalInfoViewController.h"
#import "SOSRegisterTextField.h"
#import "SOSRegisterInformation.h"
#import "AccountTypeTableViewController.h"
#import "RegisterUtil.h"
#import "InputGovidViewController.h"
#import "SelectProvinceViewController.h"
#import "SOSEditUserInfoViewController.h"
#import "SOSNStytleEditInfoViewController.h"
#import "NSString+JWT.h"
#import "InputPinCodeView.h"
#import "SOSCustomAlertView.h"
#import "SOSVerifyMAMobileViewController.h"
#import "RegisterUtil.h"
#import "SOSInsuranceViewController.h"
#import "SOSSelectDealerVC.h"
#import "SOSWebViewController.h"
#import "LoadingView.h"
#import "SOSExpandableTextView.h"
#import "SOSRemoteTool.h"
#import "SOSPhoneBindController.h"

@interface SubmitPersonalInfoViewController ()<UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource>
{
    SOSPersonInfoItem *itemAccountType;
    SOSPersonInfoItem * itemGovid;
//    SOSPersonInfoItem *itemCompany;
    SOSPersonInfoItem *itemFirstName;
    SOSPersonInfoItem *itemLastName;
    SOSPersonInfoItem *itemMobile;
    SOSPersonInfoItem *itemEmail;
    SOSPersonInfoItem *itemGender;
    SOSPersonInfoItem* itemProvince;
    SOSPersonInfoItem * itemCity;
    SOSPersonInfoItem * itemPostcode;
    SOSPersonInfoItem * itemAddress;
    
    SOSPersonInfoItem * itemMobilePassword;//gsp 强升后删除
    
    SOSPersonInfoItem * itemPincode;
    SOSPersonInfoItem * itemSaleDealer;
    SOSPersonInfoItem * itemPreferDealer;

    SOSClientAcronymTransverter* tAccountType;
    SOSClientAcronymTransverter* tGender;
    SOSClientAcronymTransverter* tSaleDealer;
    
    BOOL isCompanyNameFieldVisiable; //公司名称输入框是否可见
    NSMutableArray * bbwcQuestionRecordArray;
    NSString * saleDealerName;    //售车经销商名称
    NSString * preferDealerName;  //首选经销商名称
    BOOL QAAlertShow;   //非必填时是否提示过
    BOOL PinAlertShow;
}
@property (weak, nonatomic) IBOutlet UITableView * infoTableView;
@property (weak, nonatomic) IBOutlet UILabel     * vinLabel;
@property(strong,nonatomic) NSMutableArray       * itemArray;
@property(strong,nonatomic) NSArray              * bbwcQuestionArray;
@property (weak, nonatomic) IBOutlet UIButton    * submitButton;
@property(nonatomic,strong) NSArray     * provinceList;
@property(nonatomic,strong) NSArray     * cityList;
@property(nonatomic,strong) SOSEnrollGaaInformation * userScanInfo; //当使用扫描的身份证注册时候，如果身份证信息不在gaa中，就使用扫描出的信息注册

@end

//NSString * const subCellID = @"PersonalInfoViewCell";
@implementation SubmitPersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"SOSPersonalInformationTableViewCell" bundle:nil] forCellReuseIdentifier:@"PersonalInfoViewCell"];
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        self.title = @"添加车辆";
    }
    else
    {
        self.title = NSLocalizedString(@"MyPInfo", nil);
    }
    
    self.vinLabel.text = [self.vinLabel.text stringByAppendingString:NONil([SOSRegisterInformation sharedRegisterInfoSingleton].vin).uppercaseString];
    [self queryBBWCQuestion];
    bbwcQuestionRecordArray = [NSMutableArray array];
    [SOSDaapManager sendActionInfo:Register_4step_open];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}
- (void)queryIsUserRegisterMA
{
    /****step1 使用当前身份证,先check该身份证是否在系统中有对应信息**********/
    SOSWeakSelf(weakSelf);
    if (self.queryUserInfoPara) {
        [RegisterUtil checkSubscriberByGovid:[self.queryUserInfoPara mj_JSONString] successHandler:^(NSString *responseStr) {
            SOSRegisterCheckResponseWrapper * userInfo =[SOSRegisterCheckResponseWrapper mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
            /****step 2 如果用户信息存在*****/
            if (userInfo.enrollInfo)
            {
                //有携带gaa用户信息并且省份代码存在，需要映射出用户城市
                if (userInfo.enrollInfo.province.isNotBlank) {
                    [OthersUtil getCityInfoByProvince:userInfo.enrollInfo.province successHandler:^(NSArray *responsePro) {
                        [Util hideLoadView];
                        weakSelf.cityList = responsePro;
                        dispatch_async_on_main_queue(^(){
                            weakSelf.checkedUserInfo = userInfo.enrollInfo;
                            [weakSelf customizationView];
                        });
                        
                    } failureHandler:^(NSString *responseStr, NSError *error) {
                        [Util hideLoadView];
                        dispatch_async_on_main_queue(^(){
                            weakSelf.checkedUserInfo = userInfo.enrollInfo;
                            [weakSelf customizationView];
                        });
                    }];
                }
                else
                {
                    [Util hideLoadView];
                    dispatch_async_on_main_queue(^(){
                        weakSelf.checkedUserInfo = userInfo.enrollInfo;
                        [weakSelf customizationView];
                    });
                    
                }
            }
            else
            {
                /****step 2 用户信息不存在*****/
                [Util hideLoadView];
                dispatch_async_on_main_queue(^(){
                    [weakSelf customizationView];
                });
            }
            
        } failureHandler:^(NSString *responseStr, NSError *error) {
            [Util hideLoadView];
            [self handleQueryMAFail:responseStr];
        }];
        
    }
    else
    {
        if (self.submitUserDraftPara) {
            [RegisterUtil checkSubscriberByGovid:[self.submitUserDraftPara mj_JSONString] successHandler:^(NSString *responseStr) {
                    [Util hideLoadView];
                
            } failureHandler:^(NSString *responseStr, NSError *error) {
                [Util hideLoadView];
            }];
        }
        else
        {
            [Util hideLoadView];
        }
    }
}

- (void)handleQueryMAFail:(NSString *)fail
{
    SOSWeakSelf(weakSelf);
    if ([SOSUtil isOperationResponseAlreadyRegister:[Util dictionaryWithJsonString:fail]]) {
        {
            //首选清除govid以及checkedUserInfo
//            [SOSRegisterInformation sharedRegisterInfoSingleton].inputGovid = nil;
            weakSelf.checkedUserInfo = nil;
            weakSelf.scanInfo = nil;
            [weakSelf customizationView];
            SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"证件号码已注册手机应用" detailText:@"系统检测当前证件已注册过手机应用\n您可选择登录手机应用再添加车辆或更改证件号码" cancelButtonTitle:@"更改证件号码" otherButtonTitles:@[@"登录手机应用"] canTapBackgroundHide:NO];
            [alert setButtonMode:SOSAlertButtonModelVertical];
            [alert setButtonClickHandle:^(NSInteger buttonIndex){
                if (buttonIndex == 0) {
                    //更换身份证
                    [SOSDaapManager sendActionInfo:register_3step_notification_Idexist_change];
                    InputGovidViewController * inputGovid = [[InputGovidViewController alloc] initWithNibName:@"InputGovidViewController" bundle:nil];
                    if ([SOSRegisterInformation sharedRegisterInfoSingleton].inputGovid) {
                        inputGovid.changeGovid = [SOSRegisterInformation sharedRegisterInfoSingleton].inputGovid;
                    }
                    [inputGovid setFillBlock:^(NSString * govid,SOSEnrollGaaInformation * subscriberInfo,NSString *errorStr){
                        dispatch_async_on_main_queue(^(){
                            if (subscriberInfo) {
                                //有携带gaa信息
                                weakSelf.checkedUserInfo = subscriberInfo;
                                [weakSelf customizationView];
                            }
                            else
                            {
                                if (errorStr) {
                                    //有报错
                                    [self handleQueryMAFail:errorStr];
                                }
                                else
                                {
                                    //未查询到信息
                                    itemGovid.itemResult = govid;
                                    itemGovid.itemPlaceholder = [govid govidStringInterceptionHide];
                                    [weakSelf.infoTableView reloadData];
                                }
                            }
                        });
                        
                    }] ;
                    [self.navigationController pushViewController:inputGovid animated:YES];
                }
                else
                {
                    //登录
                     [SOSDaapManager sendActionInfo:register_3step_notification_Idexist_login];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
                [weakSelf customizationView];
            });
        }
    }
    else
    {
        [Util showAlertWithTitle:nil message:fail completeBlock:nil];
    }
}
- (void)customizationView
{
    [self initBarButtonItem];
    [self generateTableItem];
    [self.infoTableView reloadData];
}
- (void)initBarButtonItem
{
    if (self.checkedUserInfo != nil) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"编辑", nil)style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
    }
}
#pragma mark -  当前界面dissmiss
- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 检查pin码
/// 未登录验证pin码逻辑
- (void)checkPINNonLogin	{
    [[SOSRemoteTool sharedInstance] checkPINCodeWithIdpid:self.checkedUserInfo.accountID Success:^{
        [self infoTableEditable];
    }];
    [SOSDaapManager sendActionInfo:register_notification_servicepin_confirm];
}

/// 登录后验证pin码逻辑
- (void)checkPINLoginState		{
    [[SOSRemoteTool sharedInstance] checkPINCodeSuccess:^{
        [self infoTableEditable];
    }];
    [SOSDaapManager sendActionInfo:register_notification_servicepin_confirm];
}

- (void)edit	{
    
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        //如果是添加车辆，验证pin码按照登录后验证pin码策略
        if ([CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId.isNotBlank) {
            //如果用户是subscriber，验证pin码按照登录后验证接口
            [self checkPINLoginState];
        }	else	{
            //如果用户是Visitor，验证pin码按照idpid验证
            [self checkPINNonLogin];
        }
    }	else	{
        //如果是enroll，调用msp验证pin码接口
        [self checkPINNonLogin];
        [SOSDaapManager sendActionInfo:register_4step_personalinfo_edit];
    }
}

- (void)infoTableEditable	{
    self.navigationItem.rightBarButtonItem = nil;
    [itemProvince    setAccessoryVisiable:YES];
    [itemEmail       setAccessoryVisiable:YES];
    [itemCity        setAccessoryVisiable:YES];
    [itemGender      setAccessoryVisiable:YES];
//    if (!SOS_APP_DELEGATE.isgsp) {
//       [itemMobilePassword      setAccessoryVisiable:YES];
//    }
    [itemPincode      setAccessoryVisiable:YES];
    [itemSaleDealer      setAccessoryVisiable:YES];
    [itemPreferDealer      setAccessoryVisiable:YES];

    SOSRegisterTextField * fnameField = [self generateFirstNameField];
    fnameField.text = self.checkedUserInfo.firstName;
    [itemFirstName setRightFieldView:fnameField];
    
    SOSRegisterTextField * lnameField = [self generateLastNameField];
    lnameField.text = self.checkedUserInfo.lastName;
    [itemLastName setRightFieldView:lnameField];
    
    SOSExpandableTextView * addressField = [self generateAddressField];
    addressField.text = [self.checkedUserInfo.address addressStringInterceptionHide];
    addressField.realText = self.checkedUserInfo.address;
    [itemAddress setRightFieldView:addressField];
    
//    SOSRegisterTextField * cityField = [[SOSRegisterTextField alloc] init];
//    cityField.text = self.checkedUserInfo.city;
//    [itemCity setRightFieldView:cityField];
    
    SOSRegisterTextField * zipField = [self generateZipField];
    zipField.text = self.checkedUserInfo.postcode;
    [itemPostcode setRightFieldView:zipField];
    
    //密保问题可修改
    NSArray * questionItemArray = [_itemArray objectAtIndex:4];
    [questionItemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ((SOSRegisterTextField *)[(SOSPersonInfoItem * )obj rightFieldView]).enabled = YES;
    }];
    
  /***商业用车***/
//    SOSRegisterTextField * companyField = [self generateCompanyField];
//    companyField.text = self.checkedUserInfo.companyName;
//    [itemCompany setRightFieldView:companyField];
    [self.infoTableView reloadData];
}
#pragma mark - 输入姓
- (SOSRegisterTextField *)generateFirstNameField
{
    SOSRegisterTextField * fnameField = [[SOSRegisterTextField alloc] init];
    [fnameField addTextInputPredicate];
    fnameField.placeholder = @"请输入姓";
//    fnameField.delegate = self;
    fnameField.maxInputLength = 16;
    [[fnameField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {

    }];
    return fnameField;
}
#pragma mark - 输入名
- (SOSRegisterTextField *)generateLastNameField
{
    SOSRegisterTextField * lastNameField = [[SOSRegisterTextField alloc] init];
    [lastNameField addTextInputPredicate];
    lastNameField.placeholder = @"请输入名";
//    lastNameField.delegate = self;
    lastNameField.maxInputLength = 16;
    [[lastNameField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        
    }];

    return lastNameField;
}
#pragma mark - 输入地址
- (SOSExpandableTextView *)generateAddressField
{
    SOSExpandableTextView * addressField = [[SOSExpandableTextView alloc] init];
    addressField.font = [UIFont systemFontOfSize:16.0f];
    addressField.textColor =  [SOSUtil onstarTextFontColor];
    addressField.placeholder = @"请输入详细地址";
    
    addressField.maxInputLength = 26;
    return addressField;
}
#pragma mark - 输入邮编
- (SOSRegisterTextField *)generateZipField
{
    SOSRegisterTextField * zipField = [[SOSRegisterTextField alloc] init];
    [zipField addTextInputPredicate];
    zipField.placeholder = @"请输入6位邮政编码";
    zipField.delegate = self;
    zipField.maxInputLength = 6;
    return zipField;
}
//#pragma mark - 输入公司名称
//- (SOSRegisterTextField *)generateCompanyField
//{
//    SOSRegisterTextField * companyField = [[SOSRegisterTextField alloc] init];
//    if (self.checkedUserInfo) {
//        companyField.text = self.checkedUserInfo.companyName;
//    }
//    [companyField addTextInputPredicate];
//    companyField.placeholder = @"请输入公司名称";
//    companyField.delegate = self;
//    companyField.maxInputLength = 60;
//    return companyField;
//}
#pragma mark - 生成table填充项
- (void)generateTableItem
{
    if (_itemArray) {
        _itemArray = nil;
    }
    NSMutableArray * count = [NSMutableArray array];
    BOOL isUserInfoExist = (self.checkedUserInfo != nil);
    NSString * value1 = isUserInfoExist?self.checkedUserInfo.accountType:@"1";
    tAccountType = [[SOSClientAcronymTransverter alloc] init];
    tAccountType.clientShow =[Util serverSubstituteToZhcn:value1 comparisonTable:@"VehicleType"];
    tAccountType.serverSubstitute = value1;
    itemAccountType = [[SOSPersonInfoItem alloc] initWithItemDesc:@"账户类型" itemResult:tAccountType.serverSubstitute itemIndex:1 isNecessary:YES rightArrowVisiable:!isUserInfoExist];
    itemAccountType.itemPlaceholder =tAccountType.clientShow;
    itemAccountType.enrollKey = @"accountType";
    [count addObject:itemAccountType];
    
//    if ([value1 isEqualToString:@"2"]) {
//        //商业用车显示公司名
//        NSString * valueComName = self.checkedUserInfo.companyName;
//        itemCompany = [[SOSPersonInfoItem alloc] initWithItemDesc:@"公司名称" itemResult:valueComName itemIndex:111 isNecessary:YES rightArrowVisiable:NO];
//        itemCompany.itemPlaceholder = valueComName;
//        itemCompany.enrollKey = @"companyName";
//        isCompanyNameFieldVisiable = YES;
//        [count addObject:itemCompany];
//    }
    
    NSString * valueGovid = isUserInfoExist? self.checkedUserInfo.inputGovid:[SOSRegisterInformation sharedRegisterInfoSingleton].inputGovid?[SOSRegisterInformation sharedRegisterInfoSingleton].inputGovid:nil;
    NSString * valueGovidShow = isUserInfoExist? self.checkedUserInfo.inputGovid:[SOSRegisterInformation sharedRegisterInfoSingleton].inputGovid?[SOSRegisterInformation sharedRegisterInfoSingleton].inputGovid:@"请输入证件号";
    itemGovid = [[SOSPersonInfoItem alloc] initWithItemDesc:@"证件号码" itemResult:valueGovid itemIndex:2 isNecessary:YES rightArrowVisiable:!isUserInfoExist];
    if ([valueGovidShow hasPrefix:@"请输入"]) {
        itemGovid.itemPlaceholder = valueGovidShow;
    }
    else
    {
        itemGovid.itemPlaceholder = [valueGovidShow govidStringInterceptionHide];
    }
    itemGovid.enrollKey = @"inputGovid";
    [count addObject:itemGovid];
    
    //使用身份证扫码的信息
    BOOL hasScanValue = (self.scanInfo.firstNameValue != nil);
    
    NSString * value3 = isUserInfoExist? self.checkedUserInfo.firstName:(hasScanValue?[self.scanInfo.firstNameValue stringSepFirstName]:nil);
    itemFirstName = [[SOSPersonInfoItem alloc] initWithItemDesc:@"姓" itemResult:value3 itemIndex:3 isNecessary:YES rightArrowVisiable:NO];
    itemFirstName.itemPlaceholder = value3;
    itemFirstName.enrollKey = @"firstName";
    if (!isUserInfoExist) {
        SOSRegisterTextField * fField = [self generateFirstNameField];
        if (hasScanValue) {
            fField.text = value3;
        }
        [itemFirstName setRightFieldView:fField];
    }
     [count addObject:itemFirstName];
    
    NSString * value4 = isUserInfoExist? self.checkedUserInfo.lastName:(hasScanValue?[self.scanInfo.firstNameValue stringSepLastName]:nil);
    itemLastName = [[SOSPersonInfoItem alloc] initWithItemDesc:@"名" itemResult:value4 itemIndex:4 isNecessary:YES rightArrowVisiable:NO];
    itemLastName.itemPlaceholder = value4;
    itemLastName.enrollKey = @"lastName";
    if (!isUserInfoExist ) {
        SOSRegisterTextField * lField = [self generateLastNameField];
        if (hasScanValue) {
            lField.text = value4;
        }
        [itemLastName setRightFieldView:lField];
    }
    [count addObject:itemLastName];
    
    NSString * value5 = isUserInfoExist? self.checkedUserInfo.gender?self.checkedUserInfo.gender:@"请选择性别":@"请选择性别";
    NSString * value55 = isUserInfoExist? self.checkedUserInfo.gender:nil;
    tGender = [[SOSClientAcronymTransverter alloc] init];
    tGender.clientShow =isUserInfoExist?[Util serverSubstituteToZhcn:value5 comparisonTable:@"Gender"]:value5;
    tGender.serverSubstitute = value55;
    if (!isUserInfoExist) {
        if (hasScanValue ) {
            //如果是身份证扫描的性别
            tGender.clientShow = self.scanInfo.genderValue;
            tGender.serverSubstitute =  [Util ClientShowToserverSubstitute:self.scanInfo.genderValue comparisonTable:@"Gender"];
        }
    }
    itemGender = [[SOSPersonInfoItem alloc] initWithItemDesc:@"性别" itemResult:tGender.serverSubstitute itemIndex:5 isNecessary:NO rightArrowVisiable:!isUserInfoExist];
    itemGender.itemPlaceholder = tGender.clientShow;
    itemGender.enrollKey = @"gender";
    [count addObject:itemGender];
    
    NSString * valuePro = isUserInfoExist? self.checkedUserInfo.province:nil;
    NSString * valueProShow = isUserInfoExist? [Util acronymToZhcn:valuePro compareList:self.provinceList]:@"请选择";
//    tProvince = [[SOSClientAcronymTransverter alloc] init];
//    tProvince.clientShow =isUserInfoExist?[Util acronymToZhcn:value6 compareList:self.provinceList]:@"请选择";
//    tProvince.serverSubstitute = value66;
    itemProvince = [[SOSPersonInfoItem alloc] initWithItemDesc:@"省/直辖市/自治区" itemResult:valuePro itemIndex:6 isNecessary:YES rightArrowVisiable:!isUserInfoExist];
    itemProvince.itemPlaceholder = valueProShow;
    itemProvince.enrollKey = @"province";
    
    NSString * valueCity = isUserInfoExist? self.checkedUserInfo.city:nil;
    NSString * valueCityShow =  isUserInfoExist?[Util acronymToZhcn:valueCity compareList:self.cityList]:@"请选择";
//    tCity = [[SOSClientAcronymTransverter alloc] init];
//    tCity.clientShow =isUserInfoExist?[Util acronymToZhcn:value7 compareList:self.cityList]:@"请选择";
//    tCity.serverSubstitute = value77;
    itemCity = [[SOSPersonInfoItem alloc] initWithItemDesc:@"城市/地区" itemResult:valueCity itemIndex:7 isNecessary:YES rightArrowVisiable:!isUserInfoExist];
    itemCity.itemPlaceholder = valueCityShow;
    itemCity.enrollKey = @"city";

    NSString * value8 = isUserInfoExist? self.checkedUserInfo.address.isNotBlank?[NONil(self.checkedUserInfo.address) addressStringInterceptionHide]:@"请输入详细地址" :(hasScanValue?[self.scanInfo.addressValue addressStringInterceptionHide]:nil);
    NSString * value88 = isUserInfoExist? NONil(self.checkedUserInfo.address):(hasScanValue?self.scanInfo.addressValue:nil);
    itemAddress = [[SOSPersonInfoItem alloc] initWithItemDesc:@"地址" itemResult:value88 itemIndex:8 isNecessary:YES rightArrowVisiable:!isUserInfoExist];
    itemAddress.itemPlaceholder = value8;
    itemAddress.enrollKey = @"address";
    if (!isUserInfoExist) {
        SOSExpandableTextView * adField = [self generateAddressField];
        if (hasScanValue) {
            adField.text = value8;
            adField.realText = value88;
        }
        [itemAddress setRightFieldView:adField];
    }
    
    NSString * value9 = isUserInfoExist? self.checkedUserInfo.postcode.isNotBlank?self.checkedUserInfo.postcode:@"请输入6位邮政编码":nil;
    itemPostcode = [[SOSPersonInfoItem alloc] initWithItemDesc:@"邮政编码" itemResult:value9 itemIndex:9 isNecessary:NO rightArrowVisiable:!isUserInfoExist];
    itemPostcode.itemPlaceholder = value9;
    itemPostcode.enrollKey = @"postcode";
    if (!isUserInfoExist) {
        [itemPostcode setRightFieldView:[self generateZipField]];
    }
    NSArray * province = [NSArray arrayWithObjects:itemProvince,itemCity,itemAddress,itemPostcode,nil];
    
    NSString * value10;
        if (!self.checkedUserInfo) {
            value10 =[SOSRegisterInformation sharedRegisterInfoSingleton].mobilePhoneNumer;
        }
        else
        {
            value10 =self.checkedUserInfo.mobile.isNotBlank?self.checkedUserInfo.mobile:[SOSRegisterInformation sharedRegisterInfoSingleton].mobilePhoneNumer;
        }
    itemMobile = [[SOSPersonInfoItem alloc] initWithItemDesc:@"手机号" itemResult:value10 itemIndex:10 isNecessary:YES rightArrowVisiable:NO];
    itemMobile.itemPlaceholder =value10?[value10 stringInterceptionHide]:@"请输入手机号";
    itemMobile.enrollKey = @"mobile";
    
//    if (!SOS_APP_DELEGATE.isgsp) {
//            itemMobilePassword = [[SOSPersonInfoItem alloc] initWithItemDesc:@"手机应用登录密码" itemResult:nil itemIndex:11 isNecessary:YES rightArrowVisiable:!isUserInfoExist];
//            itemMobilePassword.itemPlaceholder = @"请设置密码";
//            itemMobilePassword.enrollKey = @"password";
//    }

    
    //邮箱
    NSString * defaultEmail;
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        if ([CustomerInfo sharedInstance].userBasicInfo.idmUser.emailAddress.isNotBlank) {
            defaultEmail = [CustomerInfo sharedInstance].userBasicInfo.idmUser.emailAddress;
        }
    }
    //如果gaa存在，使用gaa的，如果是visitor使用email登录的，使用登录的邮箱
    NSString * valueEmailShow = isUserInfoExist? (self.checkedUserInfo.email.isNotBlank?[self.checkedUserInfo.email stringEmailInterceptionHide]:@"请输入邮箱"):(defaultEmail?defaultEmail:@"请输入邮箱");
    
    NSString * valueEmailSend = isUserInfoExist? self.checkedUserInfo.email:(defaultEmail?defaultEmail:nil);
    itemEmail  = [[SOSPersonInfoItem alloc] initWithItemDesc:@"邮箱" itemResult:valueEmailSend itemIndex:12 isNecessary:NO rightArrowVisiable:!isUserInfoExist];
    itemEmail.itemPlaceholder = [valueEmailShow stringEmailInterceptionHide];
    itemEmail.enrollKey = @"email";
    
    NSArray * phone;
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        //添加车辆操作无需设置登录密码
        phone = [NSArray arrayWithObjects:itemMobile,itemEmail,nil];
    }
    else
    {
//        if (!SOS_APP_DELEGATE.isgsp) {
//            phone = [NSArray arrayWithObjects:itemMobile,itemMobilePassword,itemEmail,nil];
//        }else{
            phone = [NSArray arrayWithObjects:itemMobile,itemEmail,nil];
//        }
    }
//    if (isUserInfoExist) {
//        NSString * valueDealer = isUserInfoExist?(self.checkedUserInfo.saleDealerName.isNotBlank?self.checkedUserInfo.saleDealerName:@"请选择经销商"):@"请选择经销商";
//        NSString * valueDealer2 = isUserInfoExist? self.checkedUserInfo.saleDealer:nil;
    
    
    //车辆控制密码
    itemPincode  = [[SOSPersonInfoItem alloc] initWithItemDesc:@"车辆控制密码" itemResult:nil itemIndex:15 isNecessary:[self checkPinQaNecessary] rightArrowVisiable:!isUserInfoExist];
    itemPincode.itemPlaceholder = @"请设置密码";
    itemPincode.enrollKey = @"pin";
    NSArray * vehiclepwd = [NSArray arrayWithObjects:itemPincode,nil];
    
    //密保问题
    NSMutableArray * quesArr = [NSMutableArray array];
    if (_bbwcQuestionArray) {
        int i = 1;
        for (NNBBWCQuestion *question in _bbwcQuestionArray) {
            SOSPersonInfoItem * itemQuestion = [[SOSPersonInfoItem alloc] initWithItemDesc:[NSString stringWithFormat:@"问题%@",@(i)] itemResult:nil itemIndex:16 isNecessary:[self checkPinQaNecessary] rightArrowVisiable:YES];
            SOSRegisterTextField * questionField = [[SOSRegisterTextField alloc] init];
            [questionField addTextInputPredicate];
            questionField.placeholder = question.title;
            questionField.enabled = !isUserInfoExist;
            [itemQuestion setRightFieldView:questionField];
            [questionField addBlockForControlEvents:UIControlEventEditingDidEnd block:^(id  _Nonnull sender) {
                if (!QAAlertShow) {
                    QAAlertShow = YES;
                    [self showAlert];
                }
                
            }];
            [quesArr addObject:itemQuestion];
            [bbwcQuestionRecordArray addObject:question];
            i++;
        }
    }
    
    
        itemSaleDealer  = [[SOSPersonInfoItem alloc] initWithItemDesc:@"售车经销商" itemResult:nil itemIndex:13 isNecessary:YES rightArrowVisiable:!isUserInfoExist];
        itemSaleDealer.itemPlaceholder = @"请选择经销商";
        itemSaleDealer.enrollKey = @"saleDealer";
    
        itemPreferDealer  = [[SOSPersonInfoItem alloc] initWithItemDesc:@"首选经销商" itemResult:nil itemIndex:14 isNecessary:YES rightArrowVisiable:!isUserInfoExist];
        itemPreferDealer.itemPlaceholder = @"请选择经销商";
        itemPreferDealer.enrollKey = @"preferDealerCode";
    
        NSArray * dealer;
        dealer = [NSArray arrayWithObjects:itemSaleDealer,itemPreferDealer,nil];
    
    _itemArray = [NSMutableArray arrayWithObjects:count,province,phone, vehiclepwd, dealer, nil];  //隐藏安全问题
//    _itemArray = [NSMutableArray arrayWithObjects:count,province,phone, vehiclepwd, quesArr.copy, dealer, nil];
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
    return 20.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSArray *sectionArray = _itemArray[section];
    SOSPersonInfoItem *item = sectionArray.firstObject;
    if (item.itemIndex == 13) {
        return 30;
    }
    return 10;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *sectionArray = _itemArray[section];
    SOSPersonInfoItem *item = sectionArray.firstObject;
    if (!item.enrollKey) {
        return @"密保问题";
    }
    return nil;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSArray *sectionArray = _itemArray[section];
    SOSPersonInfoItem *item = sectionArray.firstObject;
    if (item.itemIndex == 13) {
        return @"首选经销商建议您选择方便前往的经销商门店";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *footerView = (UITableViewHeaderFooterView *)view;
    footerView.textLabel.font = [UIFont systemFontOfSize:14];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.textLabel.font = [UIFont systemFontOfSize:14];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//
//    return 10.0f;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SOSPersonalInformationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonalInfoViewCell"];
    [cell configCellData:_itemArray[indexPath.section][indexPath.row]];
    return cell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SOSPersonInfoItem * item = [_itemArray objectAtIndex:indexPath.section][indexPath.row];
    switch (item.itemIndex) {
        case 1:
        {
            if (item.accessoryVisiable) {
                //选择用车类型
                SOSClientAcronymTransverterCollection * coll = [[SOSClientAcronymTransverterCollection alloc] init];
                coll.transArr = [SOSClientAcronymTransverter mj_objectArrayWithKeyValuesArray:[Util vehicleTypeInfoArray]];
                AccountTypeTableViewController * type = [[AccountTypeTableViewController alloc] initWithSource:coll dataSourceType:SourceTypeVehicleType];
                SOSWeakSelf(weakSelf);
                type.backRecordFunctionID = changeaccounttype_back;
                [type setSelectBlock:^(SOSClientAcronymTransverter * selectValue){
                    tAccountType = selectValue;
                    itemAccountType.itemResult = selectValue.serverSubstitute;
                    SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                    itemAccountType.itemPlaceholder = selectValue.clientShow;
                    [cell updateCellValue:selectValue.clientShow];
                    if ([selectValue.serverSubstitute isEqualToString:@"1"]) {
                        //个人用车
                        [SOSDaapManager sendActionInfo:changeaccounttype_personal_confirm];
                    }else
                    {
                        //公司用车
                        [SOSDaapManager sendActionInfo:changeaccounttype_business_confirm];
                    }
                    /***商业用车***/
//                    if ([selectValue.clientShow isEqualToString:@"商业用车"]) {
//                        if (!isCompanyNameFieldVisiable) {
//                            [weakSelf.infoTableView beginUpdates];
//                            itemCompany = [[SOSPersonInfoItem alloc] initWithItemDesc:@"公司名称" itemResult:nil itemIndex:111 isNecessary:YES rightArrowVisiable:NO];
//                            itemCompany.itemPlaceholder = nil;
//                            itemCompany.enrollKey = @"companyName";
//                            SOSRegisterTextField * addressField = [[SOSRegisterTextField alloc] init];
//                            addressField.placeholder = @"请输入公司名称";
//                            [itemCompany setRightFieldView:addressField];
//                            [(NSMutableArray *)[_itemArray objectAtIndex:indexPath.section] insertObject:itemCompany atIndex:indexPath.row +1];
//                            [weakSelf.infoTableView insertRow:indexPath.row +1 inSection:indexPath.section withRowAnimation:UITableViewRowAnimationRight];
//                            [weakSelf.infoTableView endUpdates];
//                            isCompanyNameFieldVisiable = YES;
//                        }
//                    }
//                    else
//                    {
//                        if (isCompanyNameFieldVisiable) {
//                            [weakSelf.infoTableView beginUpdates];
//                            [[_itemArray objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row +1];
//                            [weakSelf.infoTableView deleteRow:indexPath.row +1 inSection:indexPath.section withRowAnimation:UITableViewRowAnimationLeft];
//                            [weakSelf.infoTableView endUpdates];
//                            isCompanyNameFieldVisiable = NO;
//                        }
//                    }
                }];
                [self.navigationController pushViewController:type animated:YES];
            }
        }
            break;
        case 2:
        {
            if (item.accessoryVisiable) {
                //身份证
                InputGovidViewController * inputGovid = [[InputGovidViewController alloc] initWithNibName:@"InputGovidViewController" bundle:nil];
                if ([item itemResult]) {
                    inputGovid.changeGovid = [item itemResult];
                }
                
                SOSWeakSelf(weakSelf);
                [inputGovid setFillBlock:^(NSString * govid,SOSEnrollGaaInformation * subscriberInfo,NSString * errorStr){
                    dispatch_async_on_main_queue(^(){
                        if (subscriberInfo) {
                            if (subscriberInfo.province.isNotBlank) {
                                //查询城市信息
                                [OthersUtil getCityInfoByProvince:subscriberInfo.province successHandler:^(NSArray *responsePro) {
                                    [Util hideLoadView];
                                    weakSelf.cityList = responsePro;
                                    dispatch_async_on_main_queue(^(){
                                        weakSelf.checkedUserInfo = subscriberInfo;
                                        [weakSelf customizationView];
                                    });
                                    
                                } failureHandler:^(NSString *responseStr, NSError *error) {
                                    [Util hideLoadView];
                                    dispatch_async_on_main_queue(^(){
                                        weakSelf.checkedUserInfo = subscriberInfo;
                                        [weakSelf customizationView];
                                    });
                                }];
                            }
                            else
                            {
                                [Util hideLoadView];
                                dispatch_async_on_main_queue(^(){
                                    weakSelf.checkedUserInfo = subscriberInfo;
                                    [weakSelf customizationView];
                                });
                            }
                        }
                        else
                        {
                            if (errorStr) {
                                //有报错
                                [self handleQueryMAFail:errorStr];
                            }
                            else
                            {
                                item.itemResult = govid ;
                                item.itemPlaceholder = govid;
                                SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                                [cell updateCellValue:[govid govidStringInterceptionHide]];
                            }
                        }
                    });
                    
                }] ;
                [self.navigationController pushViewController:inputGovid animated:YES];
            }
        }
            break;
        case 5:
        {
            if (item.accessoryVisiable) {
                //选择性别
                SOSClientAcronymTransverterCollection * coll = [[SOSClientAcronymTransverterCollection alloc] init];
                coll.transArr = [SOSClientAcronymTransverter mj_objectArrayWithKeyValuesArray:[Util genderInfoArray]];
                AccountTypeTableViewController * type = [[AccountTypeTableViewController alloc] initWithSource:coll dataSourceType:SourceTypeGender];
                SOSWeakSelf(weakSelf);
                type.backRecordFunctionID = changegender_back;
                [type setSelectBlock:^(SOSClientAcronymTransverter * selectValue){
                    SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                    tGender=selectValue;
                    itemGender.itemResult = selectValue.serverSubstitute;
                    item.itemPlaceholder = selectValue.clientShow;
                    [cell updateCellValue:selectValue.clientShow];
                    if ([itemGender.itemResult isEqualToString:@"F"]) {
                        [SOSDaapManager sendActionInfo:changegender_female_confirm];
                    }
                    else
                    {
                        [SOSDaapManager sendActionInfo:changegender_male_confirm];
                    }
                }];
                [self.navigationController pushViewController:type animated:YES];
            }
        }
            break;
        case 6:
        {
            if (item.accessoryVisiable) {
                //选择省份
                SelectProvinceViewController * slPro = [[SelectProvinceViewController alloc] initWithNibName:@"SelectProvinceViewController" bundle:nil];
                slPro.proList = self.provinceList;
                SOSWeakSelf(weakSelf);
                [slPro setSelectBlock:^(SOSClientAcronymTransverter * province){
                    SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                    itemProvince.itemResult = province.serverSubstitute;
                    itemProvince.itemPlaceholder = province.clientShow;
                    [cell updateCellValue:province.clientShow];
                    //清除界面上显示的城市
                    if (itemCity.isValidateValue) {
                        itemCity.itemPlaceholder = @"请选择";
                        itemCity.itemResult = nil;
                        [self.infoTableView reloadData];
                    }
                    
                }];
                [self.navigationController pushViewController:slPro animated:YES];
            }
        }
            break;
        case 7:
        {
            if (item.accessoryVisiable) {
            if ([itemProvince isValidateValue]) {
                //选择城市
                SelectProvinceViewController * slCity = [[SelectProvinceViewController alloc] initWithNibName:@"SelectProvinceViewController" bundle:nil];
            
                slCity.selectPro = itemProvince.itemResult;
                SOSPersonInfoItem * itemPro = _itemArray[indexPath.section][indexPath.row -1];

                if ([itemPro.itemPlaceholder isNotBlank]){
                    slCity.proTitle = itemPro.itemPlaceholder;
                }
                slCity.backRecordFunctionID = register_city_back;
                SOSWeakSelf(weakSelf);
                [slCity setSelectBlock:^(SOSClientAcronymTransverter * city){
                    SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                    itemCity.itemResult = city.serverSubstitute;
                    itemCity.itemPlaceholder = city.clientShow;
                    [cell updateCellValue:city.clientShow];
                }];
                [self.navigationController pushViewController:slCity animated:YES];
            }
            else
            {
                [Util toastWithMessage:@"请先选择省份"];
            }
            }
        }
            break;
        case 10:
        {
            if (item.accessoryVisiable) {
                
            SOSWeakSelf(weakSelf);
            //设置手机号
            SOSEditUserInfoViewController * editUser = [[SOSEditUserInfoViewController alloc] initWithNibName:@"SOSEditUserInfoViewController" bundle:nil];
            editUser.editType =SOSEditUserInfoTypePhone;
            editUser.backRecordFunctionID = changemobileNo_back;
            if (item.itemResult) {
                editUser.originLabelString = item.itemResult;
            }
//            SOSWeakSelf(weakSelf);
            [editUser setFixOkBlock:^(NSString * text){
                item.itemResult = text;
                SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                item.itemPlaceholder = [text stringInterceptionHide];
                [cell updateCellValue:text];
                [SOSDaapManager sendActionInfo:changemobileNo_confirm];
            }];
            [self.navigationController pushViewController:editUser animated:YES];
            }
        }
            break;
        case 11:
        {
            if (item.accessoryVisiable) {
            //设置MA登录密码
            SOSEditUserInfoViewController * editUser = [[SOSEditUserInfoViewController alloc] initWithNibName:@"SOSEditUserInfoViewController" bundle:nil];
            editUser.editType =SOSEditUserInfoTypeMAPassword;
            editUser.backRecordFunctionID =changeapploginpassword_back;
            SOSWeakSelf(weakSelf);
            [editUser setFixOkBlock:^(NSString * text){
                item.itemResult = text;
                SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                item.itemPlaceholder = @"******";
                [cell updateCellValue:@"******"];
                [SOSDaapManager sendActionInfo:changeapploginpassword_confim];
            }];
            [self.navigationController pushViewController:editUser animated:YES];
            }
        }
            break;
        case 12:
        {
            if (item.accessoryVisiable) {
                //设置邮箱
                SOSEditUserInfoViewController * editUser = [[SOSEditUserInfoViewController alloc] initWithNibName:@"SOSEditUserInfoViewController" bundle:nil];
                if (item.itemResult) {
                    editUser.editType =SOSEditUserInfoTypeMail;
                    editUser.originLabelString = item.itemResult;
                }
                else
                {
                    editUser.editType =SOSEditUserInfoTypeMailAdd;
                }
                editUser.backRecordFunctionID = changeemail_back;
                SOSWeakSelf(weakSelf);
                [editUser setFixOkBlock:^(NSString * text){
                    item.itemResult = text;
                    SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                    item.itemPlaceholder = text;
                    [cell updateCellValue:text];
                    [SOSDaapManager sendActionInfo:changeemail_confirm];
                }];
                [self.navigationController pushViewController:editUser animated:YES];
            }
            
        }
            break;
            case 13:
            case 14:
        {
            if (item.accessoryVisiable) {
            //售车经销商
            SOSWeakSelf(weakSelf);
            SOSSelectDealerVC *dealerVC = [SOSSelectDealerVC new];
            dealerVC.isForRegisterOrAddVehicle = YES;
            dealerVC.q_subscriberId = self.checkedUserInfo.subscriberId;
            dealerVC.q_accountId = self.checkedUserInfo.accountID;
            NSString * vin;
//            if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
//               //用户输入的vin
                if ([SOSRegisterInformation sharedRegisterInfoSingleton].vin) {
                  vin = [SOSRegisterInformation sharedRegisterInfoSingleton].vin;
                }
                else
                {
                  vin = self.checkedUserInfo.vin;
                }
//            }
//            else
//            {
//                //如果是注册,如果gaa有用户信息
//                if (self.checkedUserInfo.vin && self.checkedUserInfo.vin.isNotBlank) {
//                    vin = self.checkedUserInfo.vin;
//                }
//                else
//                {
//                    vin = [SOSRegisterInformation sharedRegisterInfoSingleton].vin;
//                }
//            }
            dealerVC.q_vin = vin;
//            dealerVC.q_brand = self.checkedUserInfo.brand;
            dealerVC.currentQueryType = item.itemIndex==13?querySalerDealer:queryPreferDealer;
            dealerVC.backRecordFunctionID = choosedealer_back;
            dealerVC.selectDealerBlock = ^(id dealerModel) {
                SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                if (item.itemIndex==13) {
                    //售车
                    item.itemResult = [(NNDealers*)dealerModel dealersid];
                    saleDealerName = [(NNDealers*)dealerModel dealerName];
                }else {
                    if ([(NNDealers*)dealerModel dealersid].isNotBlank) {
                        //首选
                        item.itemResult = [(NNDealers*)dealerModel dealersid];
                        preferDealerName = [(NNDealers*)dealerModel dealerName];
                    }else{
                        [Util toastWithMessage:@"经销商不可用,请更换"];
                    }
                }
                item.itemPlaceholder = [(NNDealers*)dealerModel dealerName];
                
                [cell updateCellValue:item.itemPlaceholder];
                [SOSDaapManager sendActionInfo:choosedealer_confirm];
            };
            [SOSDaapManager sendActionInfo:item.itemIndex==13?Register_Prfdealer:Register_Selldealer];
            [self.navigationController pushViewController:dealerVC animated:YES];
            }
        }
            break;
        case 15:
        {
            if (item.accessoryVisiable) {
            //车辆控制码(PIN)
            SOSNStytleEditInfoViewController * editUser = [[SOSNStytleEditInfoViewController alloc] initWithNibName:@"SOSNStytleEditInfoViewController" bundle:nil];
            editUser.editType =SOSEditUserInfoTypeCarControlPassword;
            editUser.govid = itemGovid.personInfoValue;
            editUser.backRecordFunctionID =changecontrolpin_back;
            SOSWeakSelf(weakSelf);
            [editUser setFixOkBlock:^(NSString * text){
                item.itemResult = text;
                SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                item.itemPlaceholder = @"******";
                [cell updateCellValue:@"******"];
                [SOSDaapManager sendActionInfo:changecontrolpin_submit];
                if (!PinAlertShow) {
                    PinAlertShow = YES;
                    [self showAlert];
                }
                
            }];
            [self.navigationController pushViewController:editUser animated:YES];
            }
        }
            break;
        case 18:
        {
            //保险公司
            SOSInsuranceViewController *insuranceVC = [[SOSInsuranceViewController alloc] initWithNibName:@"SOSInsuranceViewController" bundle:nil];
            insuranceVC.pageType = SOSInsuranceVCPageType_BBWC;
            SOSWeakSelf(weakSelf);
            insuranceVC.selectInsurenceBlock = ^(NSString * insurance) {
                SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                item.itemResult = insurance;
                [cell updateCellValue:insurance];
                [self.navigationController popViewControllerAnimated:YES];
            };
            [self.navigationController pushViewController:insuranceVC animated:YES];
        }
            break;
        default:
            break;
    }
}
#pragma mark - UITextField Protocol
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    if ([textField respondsToSelector:@selector(realText)]) {
//        textField.text = [textField performSelector:@selector(realText)];
//    }
//}
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    if ([textField respondsToSelector:@selector(realText)]) {
//        [textField performSelector:@selector(setRealText:) withObject:textField.text] ;
//        textField.text = [textField.text addressStringInterceptionHide];
//    }
//}
- (BOOL)textField:(SOSRegisterTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString *newValue = [textField.text mutableCopy];
    [newValue replaceCharactersInRange:range withString:string];
    if (textField.maxInputLength != 0 && [newValue length]<= textField.maxInputLength) {
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - 查询bbwc安全问题
- (void)queryBBWCQuestion
{
    [Util showLoadingView];
    //第一步:查询bbwc安全问题
    @weakify(self);
    [OthersUtil queryBBWCQuestionByGovid:[CustomerInfo sharedInstance].govid successHandler:^(NSArray *questions) {
        @strongify(self);
        if (questions) {
//            _bbwcQuestionArray = questions;
            _bbwcQuestionArray = @[];    //安全问题不再显示
            //首先查询省份信息
            [OthersUtil getProvinceInfosuccessHandler:^(NSArray *responsePro) {
                if (responsePro) {
                    self.provinceList = responsePro;
                    [self queryIsUserRegisterMA];
                }
                dispatch_async_on_main_queue(^{
                        [self customizationView];
                    });
                
            } failureHandler:^(NSString *responseStr, NSError *error) {
                [Util hideLoadView];
            }];

        }else {
            [Util hideLoadView];
            dispatch_async_on_main_queue(^(){
                [Util toastWithMessage:@"获取安全问题失败,操作中止!"];
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
        
        
    } failureHandler:^(NSString *responseStr, NNError *error) {
        [Util hideLoadView];
        dispatch_async_on_main_queue(^(){
            [Util toastWithMessage:@"获取安全问题失败,操作中止!"];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}


#pragma mark - 提交注册信息
- (IBAction)submitInfo:(id)sender
{
    [self.view endEditing:YES];
    SOSRegisterSubmitWrapper * scr = [[SOSRegisterSubmitWrapper alloc] init];
    scr.enrollInfo = [[SOSUserBaseInformation alloc] init];
    scr.bbwcDTO = [[SOSBBWCSubmitWrapper alloc] init];
    scr.enrollInfo.vin = [SOSRegisterInformation sharedRegisterInfoSingleton].vin;
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        //添加车辆操作，需要确定用户是Visitor升级车主还是subscriber添加车辆
        if ([CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId != nil) {
            scr.enrollInfo.scanIssue = @"subscriber";
        }
        else
        {
            scr.enrollInfo.scanIssue = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
        }
    }
    else
    {
        [SOSDaapManager sendActionInfo:register_4step_personalinfo_submit];
    }
     NSInteger questionIndex = 0;
    for (NSArray * itemArr in _itemArray) {
        for (SOSPersonInfoItem * item in itemArr) {
            if (item.isNecessities) {
                //检查必填项是否填写
                if ([item personInfoValue] == nil || ![item personInfoValue].isNotBlank) {
                    [self toastMustFillPrompt];
                    return;
                }
            }
            if (item.enrollKey && ![item.enrollKey isEqualToString:@"pin"]) {
                [scr.enrollInfo setValue:[item personInfoValue] forKey:item.enrollKey];
            }else {
                if (item.enrollKey) {
                    [scr.bbwcDTO setValue:[item personInfoValue] forKey:item.enrollKey];
                    continue;
                }
                //密保问题,没有enrollkey
                if (![item personInfoValue].length) {
                    questionIndex ++;
                    continue;
                }
                NNBBWCQuestion * sourceQuestion = [bbwcQuestionRecordArray objectAtIndex:questionIndex];
                [sourceQuestion setAnswer:[item personInfoValue]];
                if (!scr.bbwcDTO.questions) {
                    scr.bbwcDTO.questions = [NSMutableArray array];
                }
                [scr.bbwcDTO.questions addObject:sourceQuestion];
                questionIndex ++;
            }
        }
    }
    
    //出于账户安全，请将两个安全问题一并填写完整，感谢您的配合
    if (scr.bbwcDTO.questions.count && scr.bbwcDTO.questions.count < _bbwcQuestionArray.count) {
        //QA不能只填一部分,要么全填要么不填
        [Util toastWithMessage:@"出于账户安全，请将两个安全问题一并填写完整，感谢您的配合"];
        return;
    }
    
    //页面是提交注册信息使用
    if (self.checkedUserInfo) {
        //检查前面输入手机号与存在的gaa手机号不同要确认，加入gaa没有手机号，继续注册流程
        if ([self.checkedUserInfo.mobile stringByTrim].isNotBlank &&![[[SOSRegisterInformation sharedRegisterInfoSingleton].mobilePhoneNumer stringByTrim] isEqualToString:[self.checkedUserInfo.mobile stringByTrim] ]) {
            SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"提示" detailText:NSLocalizedString(@"您提供的手机号码\n与安吉星系统中登记的不一致,\n您需要将手机号码更新为系统中的手机号\n并重新验证手机号", nil) cancelButtonTitle:@"取消" otherButtonTitles:@[@"重新验证"]];
            [alert setButtonMode:SOSAlertButtonModelVertical];
            [alert setButtonClickHandle:^(NSInteger index){
                if (index == 1) {
                    SOSVerifyMAMobileViewController * verifyMobile = [[SOSVerifyMAMobileViewController alloc] initWithNibName:@"SOSVerifyMAMobileViewController" bundle:nil];
                    verifyMobile.gaaMobile = self.checkedUserInfo.mobile;
                    [verifyMobile setVerifyBlock:^(BOOL verifySuccess){
                        if (verifySuccess) {
                            [self sendRegisterRequest:scr];
                        }
                    }];
                    dispatch_async_on_main_queue(^(){
                        [self.navigationController pushViewController:verifyMobile animated:YES];
                    });
                    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
                        [SOSDaapManager sendActionInfo:AddCar_step3mobile_disconsensus_remodify];
                        
                    }else{
                        [SOSDaapManager sendActionInfo:onstarpersonalinfor_notification_phonenotmatch_reverify];
                    }
                }
                else
                {
                    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
                        [SOSDaapManager sendActionInfo:AddCar_step3mobile_disconsensus_cancelmodify];
                        
                    }else{
                        [SOSDaapManager sendActionInfo:onstarpersonalinfor_notification_phonenotmatch_cancel];
                    }
                    
                }
            }];
            [alert show];
        }
        else
        {
            [self sendRegisterRequest:scr];
        }
    }
    else
    {
        [self sendRegisterRequest:scr];
    }
    
}
// 发送注册请求
- (void)sendRegisterRequest:(SOSRegisterSubmitWrapper *)para
{
    [Util showLoadingView];
    
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        [RegisterUtil registSubscriberByEnrollInfo:[para mj_JSONString] successHandler:^(NSString *responseStr) {
            if ([SOSUtil isOperationResponseSuccess:[Util dictionaryWithJsonString:responseStr]])
            {
                [Util hideLoadView];
                dispatch_async_on_main_queue(^(){
                    SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"恭喜您" detailText:NSLocalizedString(@"Register_Add_vehicle", nil) cancelButtonTitle:nil otherButtonTitles:@[@"知道了"]];
                    [alert setButtonMode:SOSAlertButtonModelHorizontal];
                    [alert setButtonClickHandle:^(NSInteger index){
                        //如果是Visitor添加车辆，则退出登录,返回首页
                        if ([SOSCheckRoleUtil isVisitor]) {
                            [self.navigationController  popToRootViewControllerAnimated:YES];
                            [[LoginManage sharedInstance] doLogout];
                        }
                        else
                        {
                            [self.navigationController  popToRootViewControllerAnimated:YES];
                        }

                    }];
                    [alert show];
                });
            }
            
        } failureHandler:^(NSString *responseStr, NSError *error) {
            [Util hideLoadView];
            [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        }];
    }
    else
    {
        @weakify(self);
        [RegisterUtil registSubscriberByEnrollInfo:[para mj_JSONString] successHandler:^(NSString *responseStr) {
            if ([SOSUtil isOperationResponseSuccess:[Util dictionaryWithJsonString:responseStr]])
            {
                [Util hideLoadView];
                [SOSDaapManager sendActionInfo:Register_4step_submit_success];
                dispatch_async_on_main_queue(^(){
                    @strongify(self);
                    SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"恭喜您!" detailText:NSLocalizedString(@"Register_MA_Success", nil) cancelButtonTitle:nil otherButtonTitles:@[@"知道了"]];
                    [alert setButtonMode:SOSAlertButtonModelHorizontal];
                    [alert setButtonClickHandle:^(NSInteger index){
                        [SOSDaapManager sendActionInfo:register_notification_finish_Login];
                        [self.navigationController  dismissViewControllerAnimated:YES completion:^{
                             [self.navigationController popToRootViewControllerAnimated:NO];
                        }];
                    }];
                    [alert show];
                });
            }
            
        } failureHandler:^(NSString *responseStr, NSError *error) {
            [Util hideLoadView];
            [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        }];
        
    }

}
- (void)synUserMobile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * user = [itemMobile personInfoValue];
    if ([Util isValidatePhone:user]) {
        UserDefaults_Set_Object([user stringInterceptionHide], NN_MASK_USERNAME);
    }
    else
    {
        if ([Util isValidateEmail:user]) {
            UserDefaults_Set_Object([user stringEmailInterceptionHide], NN_MASK_USERNAME);
        }
        else
        {
            UserDefaults_Set_Object([user maskedUserName], NN_MASK_USERNAME);
        }
    }
    [defaults setObject:user forKey:NN_CURRENT_USERNAME];
    [defaults setObject:user forKey:NN_TEMP_USERNAME];
    [defaults synchronize];
}
#pragma mark -  提示必填项
- (void)toastMustFillPrompt
{
    [Util toastWithMessage:[NSString stringWithFormat:@"您的必填信息未填写完整，请核对后再提交"]];
}

//pin QA是否必填
- (BOOL)checkPinQaNecessary {
    
    if ([SOSRegisterInformation sharedRegisterInfoSingleton].registerWay == SOSRegisterWayAddVehicle) {
        //添加车辆操作，需要确定用户是Visitor升级车主还是subscriber添加车辆
        if ([CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId != nil) {
            //subcriber
            return false;
        }
        else
        {
            //访客
            if (self.checkedUserInfo) {
                //gaa中有信息
                return false;
            }else {
                return true;
            }
        }
    }
    else
    {
        //新车新用户
        if (self.checkedUserInfo) {
            //gaa中有信息
            return false;
        }else {
            return true;
        }
    }
    
    return false;
    
    
    
//    if ([CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId.isNotBlank) {
//        return false;
//    }
//    return true;
}

- (void)showAlert {
    if (![self checkPinQaNecessary]) {
        [SOSUtil showCustomAlertWithTitle:@"提示"
                                  message:@"车辆的个人信息已设置,\n若重置将同步信息到名下所有车辆。"
                            completeBlock:^(NSInteger buttonIndex) {
                                
                            }];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
