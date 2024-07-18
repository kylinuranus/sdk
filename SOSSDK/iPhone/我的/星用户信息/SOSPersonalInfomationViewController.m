//
//  SOSPersonalInfomationViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/8/3.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "LoadingView.h"
#import "RegisterUtil.h"
#import "SOSSelectDealerVC.h"
#import "InputPinCodeView.h"
#import "SOSRegisterTextField.h"
#import "SOSLoginUserDbService.h"
#import "SOSRegisterInformation.h"
#import "InputGovidViewController.h"
#import "SOSInsuranceViewController.h"
#import "SelectProvinceViewController.h"
#import "AppDelegate_iPhone+SOSService.h"
#import "SOSEditUserInfoViewController.h"
#import "SOSNStytleEditInfoViewController.h"
#import "AccountTypeTableViewController.h"
#import "SOSPersonalInfomationViewController.h"
#import "SOSProvinceService.h"
#import "SOSVerifyPersonInfoView.h"
#import "SOSRemoteTool.h"
#import "SOSPhoneBindController.h"
#import "AccountInfoUtil.h"

//NSString * const SOSPersonalInfomationViewControllerDealloc = @"SOSPersonalInfomationViewControllerDealloc";

@interface SOSPersonalInfomationViewController ()   <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    SOSPersonInfoItem *itemAccountType;
    SOSPersonInfoItem * itemGovid;
    //    SOSPersonInfoItem *itemCompany;
    SOSPersonInfoItem *itemFirstName;
    SOSPersonInfoItem *itemLastName;
    SOSPersonInfoItem *itemGender;
    SOSPersonInfoItem* itemMobile;
    SOSPersonInfoItem* itemEmail;
    SOSPersonInfoItem* itemProvince;
    SOSPersonInfoItem * itemCity;
    SOSPersonInfoItem * itemPostcode;
    SOSPersonInfoItem * itemAddress;
    
    SOSClientAcronymTransverter* tAccountType;
    SOSClientAcronymTransverter* tGender;
    //    SOSClientAcronymTransverter* tProvince;
    //    SOSClientAcronymTransverter* tCity;
    SOSClientAcronymTransverter* tSaleDealer;
    
    SOSProvinceService *  provinceService;
    
    BOOL isCompanyNameFieldVisiable;
    NSMutableArray * bbwcQuestionRecordArray;
    
    BOOL isPINCodeChecked;
    
    BOOL QAAlertShow;   //非必填时是否提示过
    BOOL PinAlertShow;
    BOOL isDefaultPin; //是否是默认pin码
    
    NSString * secretTicket; //修改pin码需要验证的令牌
}
@property(nonatomic,strong)UITableView * infoTableView;
@property(nonatomic,strong)NSMutableArray * itemArray;
@property(nonatomic,strong)NSArray * bbwcQuestionArray;
@property(nonatomic,strong)SOSEnrollGaaInformation *checkedUserInfo;
@property(nonatomic,assign)CurrentUserRoleType roleType;
@end
NSString * const cellID = @"PersonalInfoViewCell";
@implementation SOSPersonalInfomationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *topBkView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    topBkView.font = [UIFont systemFontOfSize:18.0f];
    topBkView.textColor = [SOSUtil onstarLightViewControllerTitleColor];
    topBkView.text = NSLocalizedString(@"星用户信息", nil);
    topBkView.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = topBkView;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [SOSUtil onstarLightGray];
    
    if ([SOSCheckRoleUtil isOwner]) {
        self.roleType = RoleTypeOwner;
    }else {
        if ([SOSCheckRoleUtil isDriverOrProxy]) {
            self.roleType = RoleTypeDriverOrProxy;
        }
        else{
            self.roleType = RoleTypeVisitor;
        }
    }
    _infoTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _infoTableView.dataSource = self;
    _infoTableView.delegate = self ;
    [_infoTableView registerNib:[UINib nibWithNibName:@"SOSPersonalInformationTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    [self.view addSubview:self.infoTableView];
    _infoTableView.backgroundColor = [SOSUtil onstarLightGray];
    [_infoTableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];
    
    if (self.roleType == RoleTypeOwner) {
        [self requestData];
    }
    
    [self customizationView];
    bbwcQuestionRecordArray = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated	{
    [super viewWillAppear:animated];
    //增加实名认证入口
//    [AccountInfoUtil cheeckNeedVerifyPersionInfoBlock:^(bool needVerify,NSString *verUrl, NSString *verifyTip) {
        if (self.verifyTip) {
            SOSVerifyPersonInfoView *view = [[NSBundle SOSBundle] loadNibNamed:@"SOSVerifyPersonInfoView" owner:self options:nil][0];
            view.verifyTip = self.verifyTip;
            view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
            view.verifyTip = self.verifyTip;
            view.pageType = SOSVerifyTypeStarInfo;
            self.infoTableView.tableHeaderView = view;
        }else{
            UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
            self.infoTableView.tableHeaderView = view;
        }
//    }];
    
    [self.infoTableView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    if (secretTicket) {
    //        secretTicket = nil;
    //    }
}
#pragma mark -  跳过bbwc
- (void)jump
{
    [SOSDaapManager sendActionInfo:onstaruserinfor_skip];
    [self dismiss:nil];
}
- (void)dismiss:(id)sender
{
    if (sender) {
        [SOSDaapManager sendActionInfo:onstaruserinfor_back];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 查询bbwc安全问题
- (void)requestData {
    [Util showLoadingView];
    
    [self queryBBWCQuestion];
}

- (void)queryBBWCQuestion{
    //第一步:查询bbwc安全问题
    [OthersUtil queryBBWCQuestionByGovid:[CustomerInfo sharedInstance].govid successHandler:^(NSArray *questions) {
        if (questions) {
            _bbwcQuestionArray = @[];     //隐藏安全问题
        }
        SOSRegisterCheckRequestWrapper * reg = [[SOSRegisterCheckRequestWrapper alloc] init];
        reg.enrollInfo = [[SOSRegisterCheckRequest alloc] init];
        reg.enrollInfo.vin = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
        reg.enrollInfo.inputGovid = [CustomerInfo sharedInstance].govid;
        reg.enrollInfo.idpID = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
        //第二步:查询用户信息填充界面
        [OthersUtil queryBBWCInfoByEnrollInfo:[reg mj_JSONString] successHandler:^(NSDictionary *response) {
            SOSRegisterCheckResponseWrapper * userInfo =[SOSRegisterCheckResponseWrapper mj_objectWithKeyValues:response];
            if (userInfo.enrollInfo) {
                self.checkedUserInfo = userInfo.enrollInfo;
            }
            //第三步：查询省份信息
            if (!provinceService) {
                provinceService = [[SOSProvinceService alloc] init];
                [provinceService fetchProvincesComplete:^(NSArray *infoArray) {
                    if (infoArray && userInfo.enrollInfo.province.isNotBlank) {
                        
                        //第四步：查询城市信息
                        [provinceService fetchCityWithProvinceCode:userInfo.enrollInfo.province Complete:^(NSArray *infoArray) {
                            dispatch_async_on_main_queue(^(){
                                [Util hideLoadView];
                                [self customizationView];
                                [self infoTableEditable];
                            });
                        }];
                    }
                    else
                    {
                        [Util hideLoadView];
                        dispatch_async_on_main_queue(^(){
                            [Util hideLoadView];
                            [self customizationView];
                            [self infoTableEditable];
                        });
                    }
                }
                 
                 ];
            }
            else
            {
                [Util hideLoadView];
            }
            
        } failureHandler:^(NSString *responseStr, NNError *error) {
            [Util hideLoadView];
            [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        }];
        
    } failureHandler:^(NSString *responseStr, NNError *error) {
        [Util hideLoadView];
        dispatch_async_on_main_queue(^(){
            [Util toastWithMessage:@"获取安全问题失败,操作中止!"];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}
- (void)customizationView
{
    [self initBarButtonItem];
    [self generateTableItem];
}
- (void)initBarButtonItem
{
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"保存", nil)style:UIBarButtonItemStylePlain target:self action:@selector(saveUser)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_Nav_Back"] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
}

#pragma mark - 检查pin码
- (void)checkPINWithCompleteBlock:(void (^)(void))pinComplete	{
    if (/*![CustomerInfo sharedInstance].bbwcDone*/isDefaultPin || isPINCodeChecked || self.roleType != RoleTypeOwner) {
        pinComplete();
        return;
    }
    
    [[SOSRemoteTool sharedInstance] checkPINCodeSuccess:^{
        isPINCodeChecked = YES;
        pinComplete();
        return;
    }];
    
}

- (void)saveUser {
    [self sendBBWCRequest];
}

#pragma mark - 获取数据后刷新数据源
- (void)infoTableEditable    {
    
    [itemProvince setAccessoryVisiable:YES];
    [itemGender setAccessoryVisiable:YES];
    
    SOSRegisterTextField * fnameField = [self generateFirstNameField];
    //    [fnameField addTextInputPredicate];
    fnameField.text = self.checkedUserInfo.firstName;
    [itemFirstName setRightFieldView:fnameField];
    
    SOSRegisterTextField * lnameField = [self generateLastNameField];
    lnameField.text = self.checkedUserInfo.lastName;
    //    [lnameField addTextInputPredicate];
    [itemLastName setRightFieldView:lnameField];
    
    SOSRegisterAddressTextField * addressField = [self generateAddressField];
    addressField.text = [self.checkedUserInfo.address addressStringInterceptionHide];
    addressField.realText = self.checkedUserInfo.address;
    [itemAddress setRightFieldView:addressField];
    
    //    SOSRegisterTextField * cityField = [[SOSRegisterTextField alloc] init];
    //    cityField.maxInputLength = 40;
    //    [cityField addTextInputPredicate];
    //    cityField.text = self.checkedUserInfo.city;
    //    [itemCity setRightFieldView:cityField];
    //
    SOSRegisterTextField * zipField = [self generateZipField];
    [zipField addTextInputPredicate];
    zipField.text = self.checkedUserInfo.postcode;
    zipField.keyboardType = UIKeyboardTypeNumberPad;
    [itemPostcode setRightFieldView:zipField];
    
    /*  SOSRegisterTextField * companyField = [self generateCompanyField];
     companyField.text = self.checkedUserInfo.companyName;
     [itemCompany setRightFieldView:companyField];   */
    
    [self.infoTableView reloadData];
}
#pragma mark - 输入姓
- (SOSRegisterTextField *)generateFirstNameField
{
    SOSRegisterTextField * fnameField = [[SOSRegisterTextField alloc] init];
    fnameField.placeholder = @"请输入姓";
    [fnameField addTextInputPredicate];
    fnameField.delegate = self;
    fnameField.maxInputLength = 16;
    return fnameField;
}

#pragma mark - 输入名
- (SOSRegisterTextField *)generateLastNameField  {
    SOSRegisterTextField * lastNameField = [[SOSRegisterTextField alloc] init];
    lastNameField.placeholder = @"请输入名";
    [lastNameField addTextInputPredicate];
    lastNameField.delegate = self;
    lastNameField.maxInputLength = 16;
    return lastNameField;
}
#pragma mark - 输入地址
- (SOSRegisterAddressTextField *)generateAddressField   {
    SOSRegisterAddressTextField * addressField = [[SOSRegisterAddressTextField alloc] init];
    addressField.placeholder = @"请输入详细地址";
    [addressField addTextInputPredicate];
    addressField.delegate = self;
    addressField.maxInputLength = 26;
    return addressField;
}
#pragma mark - 输入邮编
- (SOSRegisterTextField *)generateZipField   {
    SOSRegisterTextField * zipField = [[SOSRegisterTextField alloc] init];
    zipField.placeholder = @"请输入6位邮政编码";
    [zipField addTextInputPredicate];
    zipField.delegate = self;
    zipField.keyboardType = UIKeyboardTypeNumberPad;
    zipField.maxInputLength = 6;
    return zipField;
}
//#pragma mark - 输入公司名称
//- (SOSRegisterTextField *)generateCompanyField   {
//    SOSRegisterTextField * companyField = [[SOSRegisterTextField alloc] init];
//    if (self.checkedUserInfo)   companyField.text = self.checkedUserInfo.companyName;
//    companyField.placeholder = @"请输入公司名称";
//    [companyField addTextInputPredicate];
//    companyField.delegate = self;
//    companyField.maxInputLength = 60;
//    return companyField;
//}
#pragma mark - 生成table填充项
- (void)generateTableItem
{
    
    switch (self.roleType) {
        case RoleTypeOwner:
            [self generateOwnerTableItem];
            break;
        case RoleTypeDriverOrProxy:
            [self generateDriverProxyTableItem];
            break;
        default:
            [self generateVisitorTableItem];
            break;
    }
    
}
- (void)generateOwnerTableItem
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
    itemAccountType = [[SOSPersonInfoItem alloc] initWithItemDesc:@"账户类型" itemResult:tAccountType.serverSubstitute itemIndex:1 isNecessary:YES rightArrowVisiable:NO];
    itemAccountType.itemPlaceholder =tAccountType.clientShow;
    itemAccountType.enrollKey = @"accountType";
    [count addObject:itemAccountType];
    
    /*
     if ([value1 isEqualToString:@"2"]) {
     //商业用车显示公司名
     NSString * valueComName = self.checkedUserInfo.companyName;
     itemCompany = [[SOSPersonInfoItem alloc] initWithItemDesc:@"公司名称" itemResult:valueComName itemIndex:111 isNecessary:YES rightArrowVisiable:NO];
     itemCompany.itemPlaceholder = valueComName;
     itemCompany.enrollKey = @"companyName";
     SOSRegisterTextField * companyField = [[SOSRegisterTextField alloc] init];
     if (self.checkedUserInfo) {
     companyField.text = self.checkedUserInfo.companyName;
     }
     companyField.placeholder = @"请输入公司名称";
     isCompanyNameFieldVisiable = YES;
     [itemCompany setRightFieldView:companyField];
     [count addObject:itemCompany];
     }*/
    
    NSString * value2 = isUserInfoExist? self.checkedUserInfo.inputGovid:[SOSRegisterInformation sharedRegisterInfoSingleton].inputGovid?[SOSRegisterInformation sharedRegisterInfoSingleton].inputGovid:nil;
    NSString * value22 = isUserInfoExist? self.checkedUserInfo.inputGovid:[SOSRegisterInformation sharedRegisterInfoSingleton].inputGovid?[SOSRegisterInformation sharedRegisterInfoSingleton].inputGovid:@"请输入证件号";
    itemGovid = [[SOSPersonInfoItem alloc] initWithItemDesc:@"证件号码" itemResult:value2 itemIndex:2 isNecessary:YES rightArrowVisiable:NO];
    itemGovid.itemPlaceholder = [value22 govidStringInterceptionHide];
    itemGovid.enrollKey = @"inputGovid";
    [count addObject:itemGovid];
    
    NSString * value3 = isUserInfoExist? self.checkedUserInfo.firstName:nil;
    itemFirstName = [[SOSPersonInfoItem alloc] initWithItemDesc:@"姓" itemResult:value3 itemIndex:3 isNecessary:YES rightArrowVisiable:!isUserInfoExist];
    itemFirstName.itemPlaceholder = value3;
    itemFirstName.enrollKey = @"firstName";
    if (!isUserInfoExist) {
        [itemFirstName setRightFieldView:[self generateFirstNameField]];
    }
    [count addObject:itemFirstName];
    
    NSString * value4 = isUserInfoExist? self.checkedUserInfo.lastName:nil;
    itemLastName = [[SOSPersonInfoItem alloc] initWithItemDesc:@"名" itemResult:value4 itemIndex:4 isNecessary:YES rightArrowVisiable:!isUserInfoExist];
    itemLastName.itemPlaceholder = value4;
    itemLastName.enrollKey = @"lastName";
    if (!isUserInfoExist ) {
        [itemLastName setRightFieldView:[self generateLastNameField]];
    }
    [count addObject:itemLastName];
    
    NSString * value5 = isUserInfoExist? self.checkedUserInfo.gender:@"请选择性别";
    NSString * value55 = isUserInfoExist? self.checkedUserInfo.gender:nil;
    tGender = [[SOSClientAcronymTransverter alloc] init];
    tGender.clientShow =isUserInfoExist?[Util serverSubstituteToZhcn:value5 comparisonTable:@"Gender"]:value5;
    tGender.serverSubstitute = value5;
    itemGender = [[SOSPersonInfoItem alloc] initWithItemDesc:@"性别" itemResult:value55 itemIndex:5 isNecessary:NO rightArrowVisiable:!isUserInfoExist];
    itemGender.itemPlaceholder = tGender.clientShow;
    itemGender.enrollKey = @"gender";
    [count addObject:itemGender];
    
    NSString * valuePro = isUserInfoExist? self.checkedUserInfo.province:nil;
    NSString * valueProShow = isUserInfoExist? [Util acronymToZhcn:valuePro compareList:provinceService.provinceList]:@"请选择";
    //    tProvince = [[SOSClientAcronymTransverter alloc] init];
    //    tProvince.clientShow =isUserInfoExist?value6 :@"请选择";
    //    tProvince.serverSubstitute = value66;
    [self initProvinceItemWithShowName:valueProShow realValue:valuePro];
    
    
    NSString * valueCity = isUserInfoExist? self.checkedUserInfo.city:nil;
    NSString * valueCityShow = isUserInfoExist?[Util acronymToZhcn:valueCity compareList:provinceService.cityList]:@"请选择";
    [self initCityItemWithShowName:valueCityShow realCityValue:valueCity];
    
    NSString * value8 = isUserInfoExist? self.checkedUserInfo.address:nil;
    itemAddress = [[SOSPersonInfoItem alloc] initWithItemDesc:@"地址" itemResult:value8 itemIndex:8 isNecessary:YES rightArrowVisiable:!isUserInfoExist];
    itemAddress.itemPlaceholder = value8;
    itemAddress.enrollKey = @"address";
    if (!isUserInfoExist ) {
        [itemAddress setRightFieldView:[self generateAddressField]];
    }
    
    NSString * value9 = isUserInfoExist? self.checkedUserInfo.postcode:nil;
    itemPostcode = [[SOSPersonInfoItem alloc] initWithItemDesc:@"邮政编码" itemResult:value9 itemIndex:9 isNecessary:NO rightArrowVisiable:!isUserInfoExist];
    itemPostcode.itemPlaceholder = value9;
    itemPostcode.enrollKey = @"postcode";
    if (!isUserInfoExist) {
        [itemPostcode setRightFieldView:[self generateZipField]];
    }
    NSArray * province = @[itemProvince,itemCity,itemAddress,itemPostcode];
    
    
    NSString * value10;
    value10 =self.checkedUserInfo.mobile;
    itemMobile = [[SOSPersonInfoItem alloc] initWithItemDesc:@"手机号" itemResult:value10 itemIndex:10 isNecessary:YES rightArrowVisiable:YES];
    itemMobile.itemPlaceholder = [value10 stringInterceptionHide] ? :@"请绑定服务手机号";
    itemMobile.enrollKey = @"mobile";
    
    SOSPersonInfoItem * item11 = [[SOSPersonInfoItem alloc] initWithItemDesc:@"手机应用登录密码" itemResult:nil itemIndex:11 isNecessary:YES rightArrowVisiable:YES];
    item11.itemPlaceholder = @"请设置密码";
    item11.enrollKey = @"password";
    
    NSString * valueEmailShow = isUserInfoExist? (self.checkedUserInfo.email.length>0?[self.checkedUserInfo.email stringEmailInterceptionHide]:@"请输入邮箱") : @"请输入邮箱";
    NSString * valueEmailSend = isUserInfoExist? self.checkedUserInfo.email : nil;
    
    itemEmail = [[SOSPersonInfoItem alloc] initWithItemDesc:@"邮箱" itemResult:valueEmailSend itemIndex:12 isNecessary:NO rightArrowVisiable:YES];
    
    itemEmail.itemPlaceholder = valueEmailShow;
    itemEmail.enrollKey = @"email";
    NSArray * phone;
    phone = [NSArray arrayWithObjects:itemMobile,itemEmail,nil];
    NSString * valueDealerSaleName = @"";
    NSString * valueDealerSaleCode = nil;
    if (isUserInfoExist) {
        valueDealerSaleCode = self.checkedUserInfo.saleDealer;
        if (self.checkedUserInfo.saleDealerName.isNotBlank) {
            valueDealerSaleName = self.checkedUserInfo.saleDealerName;
        }
    }
    
    SOSPersonInfoItem * item12 = [[SOSPersonInfoItem alloc] initWithItemDesc:@"售车经销商" itemResult:valueDealerSaleCode itemIndex:13 isNecessary:NO rightArrowVisiable:NO];
    item12.itemPlaceholder = valueDealerSaleName;
    item12.enrollKey = @"saleDealer";
    
    NSArray * dealer;
    NSString * valuePreferDealer = isUserInfoExist?(self.checkedUserInfo.preferDealerName.isNotBlank ?self.checkedUserInfo.preferDealerName:@"请选择经销商"):@"请选择经销商";
    NSString * valuePreferDealer2 = isUserInfoExist? self.checkedUserInfo.preferDealerCode:nil;
    SOSPersonInfoItem * item13 = [[SOSPersonInfoItem alloc] initWithItemDesc:@"首选经销商" itemResult:valuePreferDealer2 itemIndex:14 isNecessary:YES rightArrowVisiable:YES];
    item13.itemPlaceholder = valuePreferDealer;
    item13.enrollKey = @"preferDealerCode";
    dealer = [NSArray arrayWithObjects:item12,item13,nil];
    /****/
    SOSPersonInfoItem * item14 = [[SOSPersonInfoItem alloc] initWithItemDesc:@"车辆控制密码" itemResult:nil itemIndex:15 isNecessary:[self checkPinQaNecessary] rightArrowVisiable:YES];
    item14.itemPlaceholder = !isDefaultPin/* && [CustomerInfo sharedInstance].bbwcDone*/ ? @"******" : @"请输入密码";
    item14.enrollKey = @"pin";
    NSArray * pin = [NSArray arrayWithObject:item14];
    
    /***/
    SOSPersonInfoItem * item17 = [[SOSPersonInfoItem alloc] initWithItemDesc:@"保险公司" itemResult:self.checkedUserInfo.insuranceCompany itemIndex:18 isNecessary:NO rightArrowVisiable:YES];
    item17.itemPlaceholder = self.checkedUserInfo.insuranceCompany.length ?self.checkedUserInfo.insuranceCompany : @"请选择";
    item17.enrollKey = @"insuranceCompany";
    NSMutableArray * insurance = [NSMutableArray arrayWithObjects:item17,nil];
    
    if (/*![CustomerInfo sharedInstance].bbwcDone && */isDefaultPin) {
        NSMutableArray * quesArr = [NSMutableArray array];
        if (_bbwcQuestionArray) {
            int i = 1;
            for (NNBBWCQuestion *question in _bbwcQuestionArray) {
                SOSPersonInfoItem * itemQuestion = [[SOSPersonInfoItem alloc] initWithItemDesc:[NSString stringWithFormat:@"问题%@",@(i)] itemResult:nil itemIndex:16 isNecessary:[self checkPinQaNecessary] rightArrowVisiable:YES];
                SOSRegisterTextField * questionField = [[SOSRegisterTextField alloc] init];
                questionField.placeholder = question.title;
                questionField.text = nil;//[CustomerInfo sharedInstance].bbwcDone ? @"******" : nil;
                [itemQuestion setRightFieldView:questionField];
                [quesArr addObject:itemQuestion];
                [questionField addBlockForControlEvents:UIControlEventEditingDidEnd block:^(id  _Nonnull sender) {
                    if (!QAAlertShow) {
                        QAAlertShow = YES;
                        [self showAlert];
                    }
                    
                }];
                [bbwcQuestionRecordArray addObject:question];
                i++;
            }
        }
        //        NSArray * question = [NSArray arrayWithArray:quesArr];
        //        _itemArray = [NSMutableArray arrayWithObjects:count, province, phone, pin, question, dealer,  insurance, nil];  //隐藏安全问题
        _itemArray = [NSMutableArray arrayWithObjects:count, province, phone, pin, dealer, insurance,nil];
    }   else    {
        _itemArray = [NSMutableArray arrayWithObjects:count, province, phone, pin, dealer, insurance,nil];
    }
}
- (void)generateDriverProxyTableItem
{
    if (_itemArray) {
        _itemArray = nil;
    }
    CustomerInfo *info = [CustomerInfo sharedInstance];
    //第三步：查询省份信息
    if (!provinceService) {
        provinceService = [[SOSProvinceService alloc] init];
        [Util showLoadingView];
        [provinceService fetchProvincesComplete:^(NSArray *infoArray) {
            
            if (infoArray && info.province.isNotBlank) {
                //第四步：查询城市信息
                [provinceService fetchCityWithProvinceCode:info.province Complete:^(NSArray *infoArray) {
                    dispatch_async_on_main_queue(^(){
                        [Util hideLoadView];
                        [self customizationView];
                    });
                }];
            }
            else
            {
                [Util hideLoadView];
            }
        }
         ];
    }
    //省
    NSString * valuePro = info.province.isNotBlank ? [Util acronymToZhcn:info.province compareList:provinceService.provinceList] : @"请选择";
    NSString * valueProSub = info.province.isNotBlank ?info.province:nil;
    [self initProvinceItemWithShowName:valuePro realValue:valueProSub];
    
    //城市
    NSString * valueShowCity = info.city.isNotBlank ? [Util acronymToZhcn:info.city compareList:provinceService.cityList] : @"请选择";
    NSString * value77 = info.city.isNotBlank? info.city:nil;
    [self initCityItemWithShowName:valueShowCity realCityValue:value77];
    
    //地区
    NSString * value8 = info.address1;
    itemAddress = [[SOSPersonInfoItem alloc] initWithItemDesc:@"地址" itemResult:value8 itemIndex:8 isNecessary:YES rightArrowVisiable:YES];
    itemAddress.itemPlaceholder = value8;
    itemAddress.enrollKey = @"address";
    SOSRegisterAddressTextField *addressField = [self generateAddressField];
    addressField.text = value8.length ? [value8 addressStringInterceptionHide] : nil;
    addressField.realText = value8;
    [itemAddress setRightFieldView:addressField];
    
    NSArray * contactArr;
    contactArr = [NSArray arrayWithObjects:itemProvince,itemCity,itemAddress,nil];
    
    ///
    NSString * valueReal;
    NSString * valueShow;
    valueReal = info.userBasicInfo.idmUser.mobilePhoneNumber;
    valueShow = [valueReal stringInterceptionHide];
    
    itemMobile = [[SOSPersonInfoItem alloc] initWithItemDesc:@"手机号" itemResult:valueReal itemIndex:10 isNecessary:YES rightArrowVisiable:YES];
    itemMobile.itemPlaceholder = [Util isNotEmptyString:valueShow] ? valueShow :@"请绑定服务手机号";
    itemMobile.enrollKey = @"mobile";
    
    itemEmail = [[SOSPersonInfoItem alloc] initWithItemDesc:@"邮箱" itemResult:info.userBasicInfo.idmUser.emailAddress itemIndex:12 isNecessary:NO rightArrowVisiable:YES];
    NSString *emailString = info.userBasicInfo.idmUser.emailAddress;
    itemEmail.itemPlaceholder = emailString.length ? [Util maskEmailWithStar:emailString] : @"请输入邮箱";
    itemEmail.enrollKey = @"email";
    NSArray * mobileArr = @[itemMobile, itemEmail];
    
    _itemArray = [NSMutableArray arrayWithArray:@[contactArr,mobileArr]];
    [self.infoTableView reloadData];
}
#pragma mark -item
-(void)initProvinceItemWithShowName:(NSString *)proName realValue:(nullable NSString*)real{
    itemProvince = [[SOSPersonInfoItem alloc] initWithItemDesc:@"省/直辖市/自治区" itemResult:real itemIndex:6 isNecessary:YES rightArrowVisiable:YES];
    itemProvince.itemPlaceholder = proName;
    itemProvince.enrollKey = @"province";
}
-(void)initCityItemWithShowName:(NSString *)cityName realCityValue:(nullable NSString*)realCity{
    itemCity = [[SOSPersonInfoItem alloc] initWithItemDesc:@"城市/地区" itemResult:realCity itemIndex:7 isNecessary:YES rightArrowVisiable:YES];
    itemCity.itemPlaceholder = cityName;
    itemCity.enrollKey = @"city";
}


- (void)generateVisitorTableItem
{
    if (_itemArray) {
        _itemArray = nil;
    }
    CustomerInfo *info = [CustomerInfo sharedInstance];
    NSString * value10;
    value10 = info.userBasicInfo.idmUser.mobilePhoneNumber;
    itemMobile = [[SOSPersonInfoItem alloc] initWithItemDesc:@"手机号" itemResult:value10 itemIndex:10 isNecessary:YES rightArrowVisiable:YES];
    itemMobile.itemPlaceholder =value10.length ? [value10 stringInterceptionHide]:@"请绑定服务手机号";
    itemMobile.enrollKey = @"mobile";
    
    itemEmail = [[SOSPersonInfoItem alloc] initWithItemDesc:@"邮箱" itemResult:info.userBasicInfo.idmUser.emailAddress itemIndex:12 isNecessary:NO rightArrowVisiable:YES];
    NSString *emailString = info.userBasicInfo.idmUser.emailAddress;
    itemEmail.itemPlaceholder = emailString.length ? [Util maskEmailWithStar:emailString] : @"请输入邮箱";
    itemEmail.enrollKey = @"email";
    
    NSArray * count = @[itemMobile, itemEmail];
    
    _itemArray = [NSMutableArray arrayWithArray:@[count]];
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
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    SOSPersonInfoItem *item = [_itemArray[section] firstObject];
    if (item.itemIndex == 13) {
        return 20.0f;
    }
    return 10.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section    {
    
    SOSPersonInfoItem *item = [_itemArray[section] firstObject];
    if (item.itemIndex == 16) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, -10, SCREEN_WIDTH - 20, 30)];
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

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    SOSPersonInfoItem *item = [_itemArray[section] firstObject];
    if (item.itemIndex == 13) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH - 20, 30)];
        label.text = @"首选经销商建议您选择方便前往的经销商门店";
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
    SOSPersonInfoItem * item = _itemArray[indexPath.section][indexPath.row];
    
    if (!item.accessoryVisiable)        return;
    
    switch (item.itemIndex) {
        case 1:
        {
            if (item.accessoryVisiable) {
                //选择用车类型
                SOSClientAcronymTransverterCollection * coll = [[SOSClientAcronymTransverterCollection alloc] init];
                coll.transArr = [SOSClientAcronymTransverter mj_objectArrayWithKeyValuesArray:[Util vehicleTypeInfoArray]];
                AccountTypeTableViewController * type = [[AccountTypeTableViewController alloc] initWithSource:coll dataSourceType:SourceTypeVehicleType];
                SOSWeakSelf(weakSelf);
                [type setSelectBlock:^(SOSClientAcronymTransverter * selectValue){
                    tAccountType = selectValue;
                    itemAccountType.itemResult = selectValue.serverSubstitute;
                    SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                    itemAccountType.itemPlaceholder = selectValue.clientShow;
                    [cell updateCellValue:selectValue.clientShow];
                    /***商业用车delete***/
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (subscriberInfo) {
                            weakSelf.checkedUserInfo = subscriberInfo;
                            [weakSelf customizationView];
                            [weakSelf.infoTableView reloadData];
                        }   else    {
                            if (errorStr) {
                                //有报错
                                //                                [self handleQueryMAFail:errorStr];
                            }   else    {
                                item.itemResult = govid;
                                item.itemPlaceholder = govid;
                                SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                                [cell updateCellValue:govid];
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
                [SOSDaapManager sendActionInfo:Psn_BBWC_gender];
                //选择性别
                SOSClientAcronymTransverterCollection * coll = [[SOSClientAcronymTransverterCollection alloc] init];
                coll.transArr = [SOSClientAcronymTransverter mj_objectArrayWithKeyValuesArray:[Util genderInfoArray]];
                AccountTypeTableViewController * type = [[AccountTypeTableViewController alloc] initWithSource:coll dataSourceType:SourceTypeGender];
                type.backDaapFunctionID = Psn_BBWC_gender_back;
                SOSWeakSelf(weakSelf);
                [type setSelectBlock:^(SOSClientAcronymTransverter * selectValue){
                    if ([selectValue.serverSubstitute isEqualToString:@"F"]) {
                        [SOSDaapManager sendActionInfo:Psn_BBWC_gender_female];
                    }else{
                        [SOSDaapManager sendActionInfo:Psn_BBWC_gender_male];
                    }
                    SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                    tGender=selectValue;
                    itemGender.itemResult = selectValue.serverSubstitute;
                    
                    item.itemPlaceholder = selectValue.clientShow;
                    [cell updateCellValue:selectValue.clientShow];
                }];
                [self.navigationController pushViewController:type animated:YES];
            }
        }
            break;
        case 6:
        {
            if (item.accessoryVisiable) {
                //选择省份
                [SOSDaapManager sendActionInfo:Psn_BBWC_province];
                SelectProvinceViewController * slPro = [[SelectProvinceViewController alloc] initWithNibName:@"SelectProvinceViewController" bundle:nil];
                slPro.proList = provinceService.provinceList;
                SOSWeakSelf(weakSelf);
                [slPro setSelectBlock:^(SOSClientAcronymTransverter * province){
                    SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                    //                    tProvince = province;
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
                if ([itemProvince isValidateValue] && itemProvince.itemPlaceholder.isNotBlank) {
                    //选择城市
                    [SOSDaapManager sendActionInfo:Psn_BBWC_city];
                    
                    SelectProvinceViewController * slCity = [[SelectProvinceViewController alloc] initWithNibName:@"SelectProvinceViewController" bundle:nil];
                    if (itemProvince.itemResult) {
                        slCity.selectPro = itemProvince.itemResult;
                    }else{
                        [Util toastWithMessage:@"请先选择省份"];
                        return;
                    }
                    
                    SOSPersonInfoItem * itemPro = _itemArray[indexPath.section][indexPath.row -1];
                    if ([itemPro.itemPlaceholder isNotBlank] ){
                        slCity.proTitle = itemPro.itemPlaceholder;
                    }
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
                [self checkPINWithCompleteBlock:^{
                    NSLog(@"phone is %@",item.itemResult);
                    SOSWeakSelf(weakSelf);
                    //根据要求IDM部分逻辑先去除
                    //                    if (item.itemResult.length > 0) {   //有手机号，走老的修改手机号逻辑
                    [SOSDaapManager sendActionInfo:Psn_BBWC_mobile];
                    SOSEditUserInfoViewController * editUser = [[SOSEditUserInfoViewController alloc] initWithNibName:@"SOSEditUserInfoViewController" bundle:nil];
                    editUser.editType =SOSEditUserInfoTypePhone;
                    if (item.itemResult) {
                        editUser.originLabelString = item.itemResult;
                    }
                    [editUser setFixOkBlock:^(NSString * text){
                        [SOSDaapManager sendActionInfo:Psn_BBWC_mobile_changesucce];
                        item.itemResult = text;
                        SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                        item.itemPlaceholder = [text stringInterceptionHide];
                        [cell updateCellValue:text];
                    }];
                    [self.navigationController pushViewController:editUser animated:YES];
                    //                    }else  //没有手机号，走IDM账号合并绑定手机逻辑
                    //                    {
                    //                        SOSPhoneBindController *vc = [[SOSPhoneBindController alloc] init];
                    //                        vc.overBlock = ^(NSString * _Nonnull phone) {
                    //                            self.checkedUserInfo.mobile = phone;  //确保点击保存时上传新绑定的手机号
                    //                            item.itemResult = phone;
                    //                            SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                    //                            item.itemPlaceholder = [phone stringInterceptionHide];
                    //                            [cell updateCellValue:phone];
                    //                        };
                    //                        vc.needRelogin = ^{   //如果是合并成功，需要重新登录
                    //                            [self.navigationController dismissViewControllerAnimated:NO completion:nil];
                    //                            if (_backToMain) {
                    //                                _backToMain();
                    //                            }
                    //                        };
                    //                        [self.navigationController pushViewController:vc animated:YES];
                    //
                    //                    }
                    return;
                }];
                
            }
        }
            break;
            
        case 12:
        {
            
            [self checkPINWithCompleteBlock:^{
                //设置邮箱
                [SOSDaapManager sendActionInfo:Psn_BBWC_email];
                
                SOSEditUserInfoViewController * editUser = [[SOSEditUserInfoViewController alloc] initWithNibName:@"SOSEditUserInfoViewController" bundle:nil];
                if (item.itemResult && item.itemResult.isNotBlank) {
                    editUser.editType =SOSEditUserInfoTypeMail;
                    editUser.originLabelString = item.itemResult;
                }
                else
                {
                    editUser.editType =SOSEditUserInfoTypeMailAdd;
                }
                SOSWeakSelf(weakSelf);
                [editUser setFixOkBlock:^(NSString * text){
                    [SOSDaapManager sendActionInfo:Psn_BBWC_mobile_verycode];
                    item.itemResult = text;
                    SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                    item.itemPlaceholder = [text stringEmailInterceptionHide];
                    [cell updateCellValue:[text stringEmailInterceptionHide]];
                }];
                [self.navigationController pushViewController:editUser animated:YES];
            }];
        }
            break;
        case 13:
        {
            //售车经销商
            SOSWeakSelf(weakSelf);
            SOSSelectDealerVC *dealerVC = [SOSSelectDealerVC new];
            dealerVC.q_subscriberId = self.checkedUserInfo.subscriberId;
            dealerVC.q_accountId = self.checkedUserInfo.accountID;
            dealerVC.q_vin = self.checkedUserInfo.vin;
            dealerVC.q_brand = self.checkedUserInfo.brand;
            dealerVC.currentQueryType = querySalerDealer;
            dealerVC.selectDealerBlock = ^(id dealerModel) {
                SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                item.itemResult = [(NNDealers*)dealerModel dealersid];
                item.itemPlaceholder = [(NNDealers*)dealerModel dealerName];
                [cell updateCellValue:item.itemPlaceholder];
            };
            [self.navigationController pushViewController:dealerVC animated:YES];
        }
            break;
        case 14:
        {
            [SOSDaapManager sendActionInfo:Psn_BBWC_preferdealer];
            //首选经销商
            SOSWeakSelf(weakSelf);
            SOSSelectDealerVC *dealerVC = [SOSSelectDealerVC new];
            dealerVC.currentQueryType = queryPreferDealer;
            dealerVC.selectDealerBlock = ^(id dealerModel) {
                if ( [(NNDealers*)dealerModel dealersid].isNotBlank) {
                    SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                    item.itemResult = [(NNDealers*)dealerModel dealersid];
                    item.itemPlaceholder = [(NNDealers*)dealerModel dealerName];
                    [cell updateCellValue:item.itemPlaceholder];
                }else{
                    [Util toastWithMessage:@"经销商不可用,请更换"];
                }
                
            };
            [self.navigationController pushViewController:dealerVC animated:YES];
            
        }
            break;
            
        case 15:
        {
            [SOSDaapManager sendActionInfo:Psn_BBWC_remotectrlsecurcode];
            /** 更改PIN码 */
            @weakify(self);
            [self checkPINWithCompleteBlock:^{
                //R8.4.2因安全增加验证逻辑
                SOSRegisterCheckPINRequest * pinRequest = [[SOSRegisterCheckPINRequest alloc] init];
                pinRequest.accountID = self.checkedUserInfo.accountID;
                //                pinRequest.pin = [LoginManage sharedInstance].pinCode;
                pinRequest.pin = [SOSUtil AES128EncryptString:[LoginManage sharedInstance].pinCode];
                [Util showLoadingView];
                [OthersUtil loadSecretTicket:[pinRequest mj_JSONString] successHandler:^(NSString *ticket) {
                    @strongify(self);
                    [Util hideLoadView];
                    secretTicket = ticket ;
                    SOSNStytleEditInfoViewController * editUser = [[SOSNStytleEditInfoViewController alloc] initWithNibName:@"SOSNStytleEditInfoViewController" bundle:nil];
                    editUser.editType =SOSEditUserInfoTypeCarControlPassword;
                    editUser.govid = [CustomerInfo sharedInstance].govid ;
                    SOSWeakSelf(weakSelf);
                    [editUser setFixOkBlock:^(NSString * text){
                        item.itemResult = text;
                        SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                        item.itemPlaceholder = @"******";
                        [cell updateCellValue:@"******"];
                        
                        [self showAlert];
                    }];
                    [self.navigationController pushViewController:editUser animated:YES];
                } failureHandler:^(NSString *responseStr, NNError *error) {
                    [Util hideLoadView];
                    [Util toastWithMessage:@"验证PIN码失败"];
                }];
                
            }];
        }
            break;
        case 16:    {
            /** 安全问题 */
            
            break;
        }
            
        case 18:
        {
            [SOSDaapManager sendActionInfo:Psn_BBWC_insuranceco];
            //保险公司
            SOSInsuranceViewController *insuranceVC = [[SOSInsuranceViewController alloc] initWithNibName:@"SOSInsuranceViewController" bundle:nil];
            insuranceVC.pageType = SOSInsuranceVCPageType_BBWC;
            SOSWeakSelf(weakSelf);
            insuranceVC.selectInsurenceBlock = ^(NSString * insurance) {
                SOSPersonalInformationTableViewCell *cell = [weakSelf.infoTableView cellForRowAtIndexPath:indexPath];
                item.itemResult = insurance;
                item.itemPlaceholder = insurance;
                [cell updateCellValue:insurance];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            };
            [self.navigationController pushViewController:insuranceVC animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 提交用户更新/BBWC信息
- (void)sendBBWCRequest
{
    [self.view endEditing:YES];
    CustomerInfo *userInfo = [CustomerInfo sharedInstance];
    BOOL bbwcDone = userInfo.currentVehicle.bbwc;
    
    SOSBBWCSubmitWrapper * scr = [[SOSBBWCSubmitWrapper alloc] init];
    switch (self.roleType) {
        case RoleTypeOwner:{
            if (bbwcDone) {
                [SOSDaapManager sendActionInfo:onstaruserinfor_finish];
            }else{
                [SOSDaapManager sendActionInfo:Psn_BBWC_info_save];
            }
            NSInteger questionIndex = 0;
            for (NSArray * itemArr in _itemArray) {
                for (SOSPersonInfoItem * item in itemArr) {
                    //检查必填项是否填写
                    if (item.isNecessities) {
                        if ([item personInfoValue] == nil || ![item personInfoValue].isNotBlank) {
                            ///pin码输入,且已完成BBWC
                            if (!(item.itemIndex == 15 && !isDefaultPin)) {
                                [self toastMustFillPrompt];
                                return;
                            }
                            
                        }
                    }
                    //邮编
                    if (item.itemIndex == 9) {
                        if ([item personInfoValue].isNotBlank) {
                            if (![Util isNumeber:[item personInfoValue]] || [item personInfoValue].length != 6) {
                                [Util toastWithMessage:@"邮编格式错误"];
                                return;
                            }
                        }
                    }
                    
                    if (item.enrollKey) {
                        [scr setValue:[item personInfoValue] forKey:item.enrollKey];
                    }
                    else
                    {
                        //密保问题 没有enrollkey
                        if (![item personInfoValue].length) {
                            questionIndex ++;
                            continue;
                        }
                        NNBBWCQuestion * sourceQuestion = [bbwcQuestionRecordArray objectAtIndex:questionIndex];
                        [sourceQuestion setAnswer:[item personInfoValue]];
                        if (!scr.questions) {
                            scr.questions = [NSMutableArray array];
                        }
                        [scr.questions addObject:sourceQuestion];
                        questionIndex ++;
                    }
                    if (item.itemIndex == 13) {
                        scr.saleDealerName = item.itemPlaceholder;
                    }else if(item.itemIndex == 14){
                        scr.preferDealerName = item.itemPlaceholder;
                    }
                }
            }
            scr.bbwcDone = bbwcDone;
            scr.idpUserId = userInfo.userBasicInfo.idpUserId;
            scr.subscriberId = userInfo.userBasicInfo.subscriber.subscriberId;
            scr.accountID = userInfo.userBasicInfo.currentSuite.account.accountId;
            scr.vin = userInfo.userBasicInfo.currentSuite.vehicle.vin;
            break;
        }
        case RoleTypeDriverOrProxy:
        {
            [SOSDaapManager sendActionInfo:onstaruserinfor_finish];
            bbwcDone = YES; //driver需要调用更新用户信息接口
            scr.idpUserId =  userInfo.userBasicInfo.idpUserId;
            scr.subscriberId = userInfo.userBasicInfo.subscriber.subscriberId;
            scr.accountID = userInfo.userBasicInfo.currentSuite.account.accountId;
            //            scr.vin = userInfo.vin;
            for (NSArray * itemArr in _itemArray) {
                for (SOSPersonInfoItem * item in itemArr) {
                    //检查必填项是否填写
                    if (item.isNecessities) {
                        if ([item personInfoValue] == nil || ![item personInfoValue].isNotBlank) {
                            [self toastMustFillPrompt];
                            return;
                        }
                    }
                    if (item.enrollKey) {
                        [scr setValue:[item personInfoValue] forKey:item.enrollKey];
                    }
                }
            }
            
        }
            break;
        case RoleTypeVisitor:
        {
            [SOSDaapManager sendActionInfo:onstaruserinfor_finish];
            bbwcDone = YES;//访客需要调用更新用户信息接口
            NSString *zipCode = userInfo.zip;
            if (zipCode.length)     scr.postcode = zipCode;
            scr.idpUserId = userInfo.userBasicInfo.idpUserId;
            for (NSArray * itemArr in _itemArray) {
                for (SOSPersonInfoItem * item in itemArr) {
                    if (item.isNecessities) {          //访客必填项未填写也无法保存
                        if ([item personInfoValue] == nil || ![item personInfoValue].isNotBlank) {
                            [self toastMustFillPrompt];
                            return;
                        }
                    }
                    if (item.enrollKey) {
                        [scr setValue:[item personInfoValue] forKey:item.enrollKey];
                    }
                }
            }
            break;
        }
        default:
            break;
    }
    
    if (scr.pin.length > 0) {       //当用户在本界面点击pin码且修改过后，才会有值
        NSString *tempS = scr.pin;
        scr.pin = [SOSUtil AES128EncryptString:tempS];
    }
    scr.username = userInfo.userBasicInfo.idpUserId;   //根据df19906要求，参数新增username字段，值为iDpUserId
    [Util showLoadingView];
    @weakify(self);
    NSString * paraStr = [scr mj_JSONString];
    if (secretTicket) {
        secretTicket = [secretTicket stringByReplacingOccurrencesOfString:@"{" withString:@","];
        paraStr = [paraStr stringByReplacingOccurrencesOfString:@"}" withString:secretTicket];
    }
    
    [RegisterUtil submitBBWCInfoOrOnstarInfo:bbwcDone withEnrollInfo:paraStr successHandler:^(NSString *responseStr) {
        NNBBWCResponse * resp = [NNBBWCResponse mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if (resp && resp.vehicleType && !bbwcDone)
            {
                [Util hideLoadView];
                UINavigationController *personNav =  (UINavigationController *)([SOS_APP_DELEGATE fetchMainNavigationController]);
                //加载bbwc教育页面
                NSString *url = [NSString stringWithFormat:BBWC_EDUCATION,resp.vehicleType];
                
                SOSWebViewController *bbwcEdu = [[SOSWebViewController alloc] initWithUrl:url];
                bbwcEdu.shouldDismiss = YES;
                UINavigationController *bbwcNav = [[UINavigationController alloc] initWithRootViewController:bbwcEdu];
                [self.navigationController dismissViewControllerAnimated:NO completion:^{
                    [personNav presentViewController:bbwcNav animated:YES completion:^{
                        if (self.isInvokeFromLogin) {
                            [personNav popToRootViewControllerAnimated:NO];
                        }
                    }];
                }];
            }
            else
            {
                [Util hideLoadView];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
        });
        
        //同步当前 CustomerInfo 信息
        switch (self.roleType) {
            case RoleTypeOwner:
                if (!bbwcDone) {
                    //更新缓存中 BBWC 状态信息
                    NSString *cachedProfileString = [[SOSLoginUserDbService sharedInstance] searchUserIdToken:[LoginManage sharedInstance].idToken];
                    //                    NNSubscriber *profile = [NNSubscriber mj_objectWithKeyValues:[Util dictionaryWithJsonString:cachedProfileString]];
                    SOSLoginUserDefaultVehicleVO * userBasicInfo = [SOSLoginUserDefaultVehicleVO mj_objectWithKeyValues:[Util dictionaryWithJsonString:cachedProfileString]];
                    userBasicInfo.currentSuite.vehicle.bbwc = YES;
                    //                    NSString *currentAccountID = [userBasicInfo defaultAccountID];
                    //
                    //                    for (NNAccount *account in [profile accounts]) {
                    //                        if ([[account accountID] isEqualToString:currentAccountID]) {
                    //                            // 默认的Account
                    //                            for (NNVehicle *vehicle in [account vehicles]) {
                    //                                if ([[vehicle vin] isEqualToString:[userInfo userBasicInfo].currentSuite.vehicle.vin]) {
                    //                                    vehicle.bbwc = YES;
                    //                                }
                    //                            }
                    //                        }
                    //                    }
                    //                    userInfo.bbwcDone = YES;
                    NSString *newProfileString = [userBasicInfo mj_JSONString];
                    [[SOSLoginUserDbService sharedInstance] updateUserIdToken:[LoginManage sharedInstance].idToken reposeString:newProfileString];
                    
                    userInfo.currentVehicle.bbwc = YES;
                    
                }
                break;
            case RoleTypeDriverOrProxy:
                userInfo.province = [itemProvince personInfoValue];
                userInfo.city = [itemCity personInfoValue];
                userInfo.address1 = [itemAddress personInfoValue];
            case RoleTypeVisitor:
                userInfo.userBasicInfo.idmUser.mobilePhoneNumber = [itemMobile personInfoValue];
                userInfo.userBasicInfo.idmUser.emailAddress = [itemEmail personInfoValue];
                break;
                
            default:
                break;
        }
    } failureHandler:^(NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
}
#pragma mark - UITextField Protocol
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField respondsToSelector:@selector(realText)]) {
        textField.text = [textField performSelector:@selector(realText)];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField respondsToSelector:@selector(realText)]) {
        [textField performSelector:@selector(setRealText:) withObject:textField.text] ;
        textField.text = [textField.text addressStringInterceptionHide];
    }
}
#pragma mark -  提示必填项
- (void)toastMustFillPrompt
{
    [Util toastWithMessage:[NSString stringWithFormat:@"您的必填信息未填写完整，请核对后再提交"]];
}
//pin QA是否必填
- (BOOL)checkPinQaNecessary {
    
    //    if (isDefaultPin) {
    //        return true;
    //    }
    //    if ([CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId.isNotBlank) {
    //        return false;
    //    }
    //只有车主会显示 若显示则必填
    return true;
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
}

- (void)dealloc{
    [SOSDaapManager sendActionInfo:Psn_BBWC_back];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:SOSPersonalInfomationViewControllerDealloc object:@(_isInvokeFromLogin)];
}

@end

