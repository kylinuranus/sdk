//
//  SOSBuyPackageVC.m
//  Onstar
//
//  Created by Coir on 7/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSBuyPackageVC.h"
#import "SOSPackageHeader.h"
#import "SOSOrderHistoryVC.h"
#import "SOSBuyPackageChildVC.h"
#import "SOSAvailablePackageCell.h"
#import "SOSPayViewController.h"
#import "CustomPresentAnimationCotroller.h"
#import "PurchaseProxy.h"
#import "PurchaseModel.h"
#import "RMStore.h"
#import "SOSIAPGuideView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LBSConsigneeVC.h"
#import "LBSConfirmOrderVC.h"
#import "LBSOrderRecordListVC.h"

#if __has_include("SOSSDK.h")

#import <SOSSDK/SOSPay.h>

#endif


@interface SOSBuyPackageVC ()    <UITableViewDelegate, UITableViewDataSource, LLSegmentBarVCDelegate, UIViewControllerTransitioningDelegate, ProxyListener, payProtocol, SKStoreProductViewControllerDelegate>  {
    
    __weak IBOutlet UIView *changePackageBGView;
    __weak IBOutlet UIButton *buyPackageButton;
    __weak IBOutlet UIButton *changePackageButton;
    /** 展示当前选中套餐包名 */
    __weak IBOutlet UILabel *currentSelectedLabel;
    
    __weak IBOutlet UIImageView *arrowFlagImgView;
    /** 展示当前可用包的 TableView */
    __weak IBOutlet UITableView *availablePackageTableView;
    
    NSMutableArray <SOSBuyPackageChildVC *> *childVCArray;
    
    NSMutableDictionary *sourcePackageDic;
    NSMutableSet *degreeDicSet;
    
    BOOL hasShowBannerWeb;
    
    PayChannel selectedChannel;
    BOOL needRePay;
    BOOL needShowHistory;
    NSString *payError;
    UIView *paySuccessVbgView;
    
}

@property (nonatomic, strong) NSMutableArray <NSDictionary *> *degreeDicArray;
@property (nonatomic, strong) NNBanner *bannerInfo;
@property (nonatomic, assign) NSInteger selectSegmentIndex;
@property (nonatomic, assign) NSInteger packageFinishCount;

@property (nonatomic, strong) NSDictionary *consigneeDict;

@end

@implementation SOSBuyPackageVC

- (NSInteger)selectSegmentIndex    {
    return self.segmentVC.segmentBar.selectIndex;
}

- (void)setSelectSegmentIndex:(NSInteger)selectSegmentIndex     {
    self.segmentVC.segmentBar.selectIndex = selectSegmentIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSelf];
    [self initData];
    
}

- (void)refreshBanner	{
    if ([self.view isShowingOnKeyWindow]) 	[Util showHUD];
    __weak __typeof(self) weakSelf = self;
    [OthersUtil getBannerByCategory:BANNER_IAP SuccessHandle:^(NSArray *banners) {
        dispatch_async(dispatch_get_main_queue(), ^{
             if ([weakSelf.view isShowingOnKeyWindow])     [Util dismissHUD];
            if (banners.count) {
                weakSelf.bannerInfo = banners.firstObject;
                SOSIAPGuideView *guideView = [SOSIAPGuideView quickInit];
                [guideView.imageView sd_setImageWithURL:[NSURL URLWithString:weakSelf.bannerInfo.imgUrl] placeholderImage:[UIImage imageNamed:@"iapGuidePlaceholder"]];
                [guideView showInView:weakSelf.navigationController.view imgTapBlock:^{
                    [weakSelf showIapBannerWeb];
                }];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf showIapBannerWeb];
                    [guideView dismiss];
                });
            }
            
        });
        
    } failureHandler:^(NSString *responseStr, NSError *error) {
        if ([weakSelf.view isShowingOnKeyWindow])     [Util dismissHUD];
    }];
}

- (void)showIapBannerWeb {
    if (!hasShowBannerWeb) {
        CustomNavigationController * pushedCon =[SOSUtil bannerClickShowController:self.bannerInfo];
        if (pushedCon) {
            hasShowBannerWeb = YES;
            [SOSDaapManager sendActionInfo:discountpopwindow];
            [SOS_ONSTAR_WINDOW.rootViewController presentViewController:pushedCon animated:YES completion:^{
                
            }];
        }
    }
}

- (void)configSelf      {
    self.title = @"购买安吉星套餐";
    __weak __typeof(self) weakSelf = self;
    [self setLeftBarButtonItemWithTitle:@"取消" AndActionBlock:^(id item) {
        [Util dismissHUD];
        [SOSDaapManager sendActionInfo:servicepackage_purchase_cancel];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    [self setRightBarButtonItemWithTitle:@"订单记录" AndActionBlock:^(id item) {
        __strong typeof(weakSelf) self = weakSelf;
        [Util dismissHUD];
        if (SOS_ONSTAR_PRODUCT) {
            LBSOrderRecordListVC *vc = [[LBSOrderRecordListVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
//            SOSOrderHistoryVC *vc = [SOSOrderHistoryVC new];
//            /** 根据用户当前选择的套餐类型,进入对应的订单记录页面 */
//            if (weakSelf.degreeDicArray.count && (weakSelf.selectSegmentIndex == weakSelf.degreeDicArray.count - 1)) {
//                vc.vcType = HistoryVCType_4GPackage;
//            }   else    vc.vcType = HistoryVCType_Package;
//            [SOSDaapManager sendActionInfo:purchase_purchaserecord];
//            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
#if __has_include("SOSSDK.h")
        else {
            [weakSelf showOrderHistory];
        }
#endif
    }];
    
    self.segmentVC.delegate = self;

    [self.view insertSubview:self.segmentVC.view belowSubview:buyPackageButton];
    
    degreeDicSet = [NSMutableSet set];
    childVCArray = [NSMutableArray array];
    self.degreeDicArray = [NSMutableArray array];
    sourcePackageDic = [NSMutableDictionary dictionary];
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    tableHeaderView.backgroundColor = [UIColor whiteColor];
    availablePackageTableView.tableHeaderView = tableHeaderView;
    availablePackageTableView.tableFooterView = [UIView new];
    [availablePackageTableView registerNib:[UINib nibWithNibName:@"SOSAvailablePackageCell" bundle:nil] forCellReuseIdentifier:@"SOSAvailablePackageCell"];
}

- (void)setUpChildVC   {
    [childVCArray removeAllObjects];
    NSMutableArray *titleArray = [NSMutableArray array];
    if (self.degreeDicArray.count) {
        for (NSDictionary *degreeDic in self.degreeDicArray) {
            [titleArray addObject:degreeDic.allValues[0]];
        }
    }
    
    for (int i = 0; i < titleArray.count; i++) {
        SOSBuyPackageChildVC *childVC = [SOSBuyPackageChildVC new];
        childVC.packageType = PackageType_Core;
        [childVCArray addObject:childVC];
    }
    [self setUpWithItems:titleArray childVCs:childVCArray];
    
    
    NSString *lastTitleString = titleArray.lastObject;
    if ([lastTitleString containsString:@"4G"]) {
        childVCArray.lastObject.packageType = PackageType_4G;
        /** 从4G套餐页面进入 */
        if (self.selectPackageType == PackageType_4G && self.degreeDicArray.count) {
            self.selectSegmentIndex = self.degreeDicArray.count - 1;
        }
        
        //取出最后一个Button
        UIButton *lastButton = self.segmentVC.segmentBar.itemBtns.lastObject;
        //得到两种状态的富文本Title
        NSMutableAttributedString *normalTitle = [SOSUtilConfig setLabelAttributedText:@"互联" AttachmentWithView:[UIImage imageNamed:@"套餐_icon_me_package_4G_cold_gray_unselected_25x25"] ImageOffset:CGRectMake(0, 0, 0, 0) withImagePosition:LEFT_POSITION];
        NSMutableAttributedString *selectedTitle = [SOSUtilConfig setLabelAttributedText:@"互联" AttachmentWithView:[UIImage imageNamed:@"套餐_icon_me_package_4G_passion_blue_selected_25x25"] ImageOffset:CGRectMake(0, 0, 0, 0) withImagePosition:LEFT_POSITION];
        [selectedTitle addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"59708A"] range:NSMakeRange(selectedTitle.length - 2, 2)];
        //设置特殊Title
        [lastButton setAttributedTitle:normalTitle forState:UIControlStateNormal];
        [lastButton setAttributedTitle:selectedTitle forState:UIControlStateSelected];
    }
}

- (void)initData    {
    [Util showHUD];
    [self getPackageList];
    [self requestLBSConsignee];
}
#pragma mark - HTTP
#pragma mark 查询收货人信息
- (void)requestLBSConsignee {
    NSString *finalURL = [NSString stringWithFormat:@"%@%@", BASE_URL, SOS_Order_LBS_Consignee_URL];
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:finalURL params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
        NSLog(@"---returnData：%@",returnData);
        self.consigneeDict = [Util dictionaryWithJsonString:returnData];
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"APPLICANT":@"ONSTAR_IOS"}];
    [sosOperation start];
}
- (void)getPackageList {
    self.packageFinishCount = 0;
    __weak __typeof(self) weakSelf = self;
    [self getPackageWithType:PackageType_4G successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [weakSelf handleRequestsWithReturnData:responseStr AndPackageType:PackageType_4G];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [weakSelf handleRequestsWithReturnData:nil AndPackageType:PackageType_4G];
    }];
    [self getPackageWithType:PackageType_Core successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [weakSelf handleRequestsWithReturnData:responseStr AndPackageType:PackageType_Core];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [weakSelf handleRequestsWithReturnData:nil AndPackageType:PackageType_Core];
    }];
}

- (void)getPackageWithType:(PackageType)type successBlock:(SOSSuccessBlock)successBlock failureBlock:(SOSFailureBlock)failureBlock		{
    NSString *url = @"";
    if (type == PackageType_Core)		url = [BASE_URL stringByAppendingString:NEW_PURCHASE_PACKAGE_CORE];
    else								url = [BASE_URL stringByAppendingString:NEW_PURCHASE_PACKAGE_DATA];
    NSString *finalURL = [NSString stringWithFormat:@"%@?vin=%@",url,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:finalURL params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
        if (successBlock)	successBlock(operation, returnData);

    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failureBlock)	failureBlock(statusCode, responseStr, error);
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"APPLICANT":@"ONSTAR_IOS"}];
    [sosOperation start];
}

- (void)handleRequestsWithReturnData:(NSString *)returnData AndPackageType:(PackageType)type    {
    self.packageFinishCount ++;
    [self handleReturnData:returnData AndPackageType:type];
    if (self.packageFinishCount >= 2) {
        [Util dismissHUD];
#ifndef SOSSDK_SDK
        [self refreshBanner];
#endif
    }
}

- (void)handleReturnData:(NSString *)returnData AndPackageType:(PackageType)type    {
    if (!returnData.length)		return;
    NSArray *dataDicArray = [Util arrayWithJsonString:returnData];
    [dataDicArray enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
        PackageInfos *package = [PackageInfos mj_objectWithKeyValues:dic];
        
        /** 整理标签 */
        [degreeDicSet addObject:@{package.degreeCode: package.degreeDesc}];
        
        /** 添加数据源字典 */
        NSMutableArray *packageArray = sourcePackageDic[package.degreeDesc];
        if (packageArray.count) {
            [packageArray addObject:package];
        }   else    {
            NSMutableArray *tempPackageArray = [NSMutableArray arrayWithObject:package];
            sourcePackageDic[package.degreeDesc] = tempPackageArray;
        }
    }];
    
    if (self.packageFinishCount >= 2) 	{
        [self.degreeDicArray addObjectsFromArray:degreeDicSet.allObjects];
        [self.degreeDicArray sortUsingComparator:^NSComparisonResult(NSDictionary *dic1, NSDictionary *dic2) {
            return [dic1.allKeys[0] intValue] > [dic2.allKeys[0] intValue];
        }];
        [self refreshChildVCShouldRebuildChildVC:YES];
    }
}

- (void)refreshChildVCShouldRebuildChildVC:(BOOL)shouldRebuild  {
    if (!self.degreeDicArray.count)      return;
    /** 获取当前选中的 Package */
    NSArray *selectPackageArray  = [self getSelectPackageArray];
    
    if (selectPackageArray.count) {
        PackageInfos *selectPackage = selectPackageArray[0];
        dispatch_async(dispatch_get_main_queue(), ^{
            /** 刷新 Child VC */
            if (shouldRebuild)  [self setUpChildVC];
            buyPackageButton.hidden = NO;
            arrowFlagImgView.hidden = NO;
            changePackageButton.hidden = NO;
            currentSelectedLabel.hidden = NO;
            childVCArray[self.selectSegmentIndex].selectedPackage = selectPackage;
            if ([selectPackage.packageType isEqualToString:@"CORE"]) {
                self.selectPackageType = PackageType_Core;
            }else {
                self.selectPackageType = PackageType_4G;
            }
            /** 更新当前页面视图 */
            currentSelectedLabel.text = selectPackage.packageName;
            if (changePackageBGView.hidden == NO) {
                [availablePackageTableView reloadData];
            }
        });
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Act
#pragma mark 购买套餐-立即购买
- (IBAction)buyPackageButtonTapped {
    if( [Util show23gPackageDialog]){//是2g3g用户弹完提示框,流程就结束了
        return;
    }
    if (childVCArray.count == 0) {
        return;
    }
    [SOSDaapManager sendActionInfo:purchase_Purchasenow];
    PackageInfos *info = childVCArray[self.selectSegmentIndex].selectedPackage;
    [PurchaseModel sharedInstance].selectPackageInfo = info;
    [[PurchaseModel sharedInstance] setSelectedPackageId:info.packageId];
    [[PurchaseModel sharedInstance] setSelectedPackageDiscountAmount:info.discountAmount];
    [[PurchaseModel sharedInstance] setPurchaseType:(PurchaseType)self.selectPackageType];
    if ([info.isLBSPackage integerValue] == 1) { // 如果是LBS套餐就走LBS
        if (self.consigneeDict.count > 0) { // 有lbs收货人信息
            PackageInfos *package = [PurchaseModel sharedInstance].selectPackageInfo;
            package.deliveryName = self.consigneeDict[@"deliveryName"];
            package.deliveryPhone = self.consigneeDict[@"deliveryPhone"];
            package.deliveryAddr = self.consigneeDict[@"deliveryAddr"];
            LBSConfirmOrderVC *vc = [[LBSConfirmOrderVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }else {// 没有lbs收货人信息
            LBSConsigneeVC *vc = [[LBSConsigneeVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else { // 如果不是LBS套餐就走之前的逻辑
        SOSPayViewController * payController = [[SOSPayViewController alloc] initWithPackage:info];
        payController.payDelegate = self;
        payController.modalPresentationStyle = UIModalPresentationCustom;
        payController.transitioningDelegate = self;
        [self presentViewController:payController animated:YES completion:^{
            payController.view.superview.backgroundColor = [UIColor clearColor];
        }];
    }
}

/** 更换当前所选套餐 */
- (IBAction)changePackageButtonTapped {
    [self showChangePackageView:changePackageBGView.hidden];
}
- (void)showChangePackageView:(BOOL)show     {
    if (show) {
        changePackageBGView.hidden = NO;
        [availablePackageTableView reloadData];
    }   else    {
        changePackageBGView.hidden = YES;
    }
}

- (NSArray *)getSelectPackageArray  {
    NSDictionary *selectDegreeDic = self.degreeDicArray[self.selectSegmentIndex];
    NSArray *selectPackageArray = sourcePackageDic[selectDegreeDic.allValues[0]];
    return selectPackageArray.count ? selectPackageArray : @[];
}

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    if (!self.degreeDicArray.count)  return 0;
    return [self getSelectPackageArray].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath      {
    NSArray *selectPackageArray  = [self getSelectPackageArray];
    SOSAvailablePackageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SOSAvailablePackageCell"];
    cell.package = selectPackageArray[indexPath.row];
    cell.selectFlag = [cell.package.packageName isEqualToString:currentSelectedLabel.text];
    [cell setCornerRidusWithIndexPath:indexPath AndPackageCount:selectPackageArray.count];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath     {
    [self showChangePackageView:NO];
    SOSAvailablePackageCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    childVCArray[self.selectSegmentIndex].selectedPackage = cell.package;
    currentSelectedLabel.text = cell.package.packageName;
}

#pragma mark - Child VC Delegate
- (void)segmentBar:(LLSegmentBar *)segmentBar didSelectIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex  {
    NSString *reportIDString = nil;
    switch (toIndex) {
        case 0:
            reportIDString = purchase_hotsale;
            break;
        case 1:
            reportIDString = purchase_oneyear;
            break;
        case 2:
            reportIDString = purchase_twoyears;
            break;
        case 3:
            reportIDString = purchase_data;
            break;
        default:
            break;
    }
    [SOSDaapManager sendActionInfo:reportIDString];
    if (fromIndex == toIndex)   return;
    [self refreshChildVCShouldRebuildChildVC:NO];
}

#pragma mark -UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    CustomPresentAnimationCotroller *presentAnimation = [CustomPresentAnimationCotroller new];
    presentAnimation.dismiss = NO;
    presentAnimation.originFrame = CGRectMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds), 0, 0);
    return presentAnimation;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    
    CustomPresentAnimationCotroller *presentAnimation = [CustomPresentAnimationCotroller new];
    presentAnimation.dismiss = YES;
    presentAnimation.originFrame = CGRectMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds), 0, 0);
    return presentAnimation;
}



- (void)payClick:(PayChannel)currentChannel		{
//    selectedChannel = currentChannel;
#if __has_include("SOSSDK.h")
    if ([SOSPay gotoStore]) {
        [self openAppWithIdentifier:@"333206289"];
        return;
    }
#endif
    [[LoadingView sharedInstance] startIn:KEY_WINDOW];
    [[PurchaseProxy sharedInstance] addListener:self];
    //创建订单,获取orderid
    [[PurchaseProxy sharedInstance] createOrder];
}

#pragma mark - Proxy Delegate 支付step2 = 根据返回orderID获取服务端分配的支付参数
- (void)payOrderProxyDidFinishRequest:(BOOL)success withObject:(id)object     {
    [[PurchaseProxy sharedInstance] removeListener:self];
    NSDictionary *createOrderResDic = [PurchaseModel sharedInstance].createOrderResDic;
    if (createOrderResDic.count) {
        [self payWithcreateOrderResDic:createOrderResDic];
    }	else	{
        [[LoadingView sharedInstance] stop];
        [Util showAlertWithTitle:nil message:object completeBlock:nil];
    }
}

- (void)payWithcreateOrderResDic:(NSDictionary *)createOrderResDic	{
    if (SOS_ONSTAR_PRODUCT) {
        //支付
        NSString *packageId = createOrderResDic[@"productNumber"];
        packageId = [self packageId4G:packageId];
        [RMStore defaultStore].purchasePayType = RMStorePurchasePayNone;
        [[RMStore defaultStore] requestProducts:[NSSet setWithObject:packageId] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
            NSLog(@"获取商品成功");
            [self handlePayResWithProductNum:createOrderResDic[@"productNumber"]];
        } failure:^(NSError *error) {
            NSLog(@"获取商品失败");
            [[LoadingView sharedInstance] stop];
            [Util showAlertWithTitle:nil message:error.localizedDescription completeBlock:nil];
        }];
    }
#if __has_include("SOSSDK.h")
    else {
        [SOSPay payWithcreateOrderResDic:createOrderResDic target:self];
    }
#endif
}


- (void)openAppWithIdentifier:(NSString *)appId {
    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
    storeProductVC.delegate = self;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:appId forKey:SKStoreProductParameterITunesItemIdentifier];
    [storeProductVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
        if (result) {
            [self presentViewController:storeProductVC animated:YES completion:nil];
        }
        
    }];
}

#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}
  
- (NSString *)packageId4G:(NSString *)pgid {
    NSArray *pgIds = @[@"7000031",
                       @"7000028",
                       @"7000030",
                       @"7000032",
                       @"7000029"];
    if ([pgIds containsObject:pgid]) {
        pgid = [NSString stringWithFormat:@"ID%@",pgid];
    }
    pgid = [NSString stringWithFormat:@"%@%@",SOSSDK_VERSION_PREFIX,pgid];
    return pgid;
}

- (void)handlePayResWithProductNum:(NSString *)productNum		{
    [[RMStore defaultStore] addPayment:[self packageId4G:productNum] user:[CustomerInfo sharedInstance].userBasicInfo.idpUserId transactionIdentify:[PurchaseModel sharedInstance].createOrderResDic[@"buyOrderId"] success:^(SKPaymentTransaction *transaction) {
        [[LoadingView sharedInstance] stop];
        [Util showAlertWithTitle:nil message:@"您已成功购买安吉星套餐" completeBlock:nil];
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        [[LoadingView sharedInstance] stop];
        [Util showAlertWithTitle:nil message:error.localizedDescription completeBlock:nil];
    }];
}


#if __has_include("SOSSDK.h")
#pragma oneapp 支付宝
#pragma mark 支付成功
- (void)observePayResponse:(NSNotification *)notification     {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observePayFinished) name:SOSPayFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[notification name] object:nil];
    
    if ([[notification name] isEqualToString:SOSpaySuccessNotification]) {
        needRePay = NO;
        [[LoadingView sharedInstance] startIn:self.view];
        [self performSelectorInBackground:@selector(queryStatus) withObject:nil];
        
    }     else    {
        if ([[notification name] isEqualToString:SOSpayFailNotification]) {
            needRePay = YES;
            payError = [SOSPay payErrorMsg];
            [[NSNotificationCenter defaultCenter] postNotificationName:SOSPayFinishNotification object:nil];
            
        }
    }
}

- (void)queryStatus     {
    NSInteger gapTime = 0;
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    while (1) {
        gapTime = gapTime + 2;
        NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - startTime;
        NSLog(@"---------------%d", duration);
        if (duration + gapTime >= 30)    {
            payError = @"您的支付异常，请联系400-820-1188。";
            break;
        }
        // 同步请求拉取订单状态
        [[PurchaseProxy sharedInstance] queryOrderStatusWithOrderID:[PurchaseModel sharedInstance].createOrderResDic[@"buyOrderId"]];
        NSString *statusString = [PurchaseModel sharedInstance].queryOrderStatusResponse.status;
        if ([PurchaseModel sharedInstance].queryOrderStatusResponse && [statusString isKindOfClass:[NSString class]]) {
            if ([statusString.uppercaseString isEqualToString:@"PAID"] || [statusString.uppercaseString isEqualToString:@"COMPLETED"]) {
                payError = nil;
                break;
            }
        }
        [NSThread sleepForTimeInterval:gapTime];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SOSPayFinishNotification object:nil];
}

- (void)observePayFinished     {
    dispatch_async(dispatch_get_main_queue(), ^{
            [[LoadingView sharedInstance] stop];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:SOSPayFinishNotification object:nil];
            
            if (payError.length > 0) {
                [Util showAlertWithTitle:nil message:payError completeBlock:^(NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        
                        if (!needRePay) {
                            [self showOrderHistory];
                        } else {
                            [[LoadingView sharedInstance] stop];
                        }
                    }
                }];
                
            } else {
                
                    [self paySuccessV];
                
                
            }
        });
}


- (void)showOrderHistory     {    [paySuccessVbgView removeFromSuperview];
    
    LBSOrderRecordListVC *vc = [[LBSOrderRecordListVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
//    SOSOrderHistoryVC *vc = [SOSOrderHistoryVC new];
//    /** 根据用户当前选择的套餐类型,进入对应的订单记录页面 */
//    if (_degreeDicArray.count && (self.selectSegmentIndex == _degreeDicArray.count - 1)) {
//        vc.vcType = HistoryVCType_4GPackage;
//    }   else    vc.vcType = HistoryVCType_Package;
//    [SOSDaapManager sendActionInfo:purchase_purchaserecord];
//    [self.navigationController pushViewController:vc animated:YES];
}

//支付成功UI
- (void)paySuccessV     {
    
    paySuccessVbgView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    paySuccessVbgView.backgroundColor = [UIColor whiteColor];
    int imgW = SCALE_WIDTH(110);
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-imgW)/2, 40, imgW, imgW)];
    imgV.image = [UIImage imageNamed:@"paySuccess"];//              @"noDataAmount"];
    [paySuccessVbgView addSubview:imgV];
    
    int lbW = SCALE_WIDTH(300);
    UILabel *sucLB = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-lbW)/2, 180, lbW, 40)];
    sucLB.text = @"付款成功";
    sucLB.font = [UIFont systemFontOfSize:24];
    sucLB.textAlignment = NSTextAlignmentCenter;
    sucLB.textColor = [UIColor darkGrayColor];
    [paySuccessVbgView addSubview:sucLB];
    
    UILabel *buyLB = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-lbW)/2, 225, lbW, 40)];
    buyLB.text = @"您已经成功购买安吉星套餐！";
    buyLB.font = [UIFont systemFontOfSize:16];
    buyLB.textAlignment = NSTextAlignmentCenter;
    buyLB.textColor = [UIColor darkGrayColor];
    [paySuccessVbgView addSubview:buyLB];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 300, SCREEN_WIDTH-40, 50)];
    [btn setTitle:@"完成" forState:0];
    btn.layer.cornerRadius = 3;
    btn.layer.masksToBounds = YES;
    btn.backgroundColor = [UIColor colorWithHexString:@"0e5fce"];
    [paySuccessVbgView addSubview:btn];
    [btn addTarget:self action:@selector(showOrderHistory) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[UIColor whiteColor] forState:0];
    
    [self.view addSubview:paySuccessVbgView];
}

#endif


- (void)dealloc	{
    [Util dismissHUD];
    NSLog(@"SOSBuyPackgeVc dealloc");
}

@end
