//
//  SOSBleUserShareListViewController.m
//  Onstar
//
//  Created by onstar on 2018/7/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleUserShareListViewController.h"
#import "SOSBleUserShareCell.h"
#import "SOSBleUserCarListViewController.h"
#import "SOSBleNetwork.h"
#import <BlePatacSDK/BlueToothManager.h>
#import <RMUniversalAlert/RMUniversalAlert.h>
#import "SOSBleUtil.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "SOSCustomAlertView.h"

@interface SOSBleUserShareListViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,DZNEmptyDataSetDelegate,DZNEmptyDataSetSource>

@property (nonatomic,strong) UICollectionView *collectionView;

@end

@implementation SOSBleUserShareListViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

    //该方法也可以设置itemSize
    layout.itemSize =CGSizeMake(self.view.width, self.view.height);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    //2.初始化collectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [self.view addSubview:self.collectionView];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SOSBleUserShareCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    //4.设置代理
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.emptyDataSetSource = self;
    self.collectionView.emptyDataSetDelegate = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSourceData:(NSArray *)sourceData {
    _sourceData = sourceData;
    [self.collectionView reloadData];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sourceData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SOSBleUserShareCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    SOSAuthorDetail *entity = self.sourceData[indexPath.row];
    cell.authorEntity = entity;
    cell.operationButtonTapBlock = ^{
        NSMutableArray *titles = @[].mutableCopy;
        if (entity.mobilePhone.isNotBlank) {
            [titles addObject:[NSString stringWithFormat:@"呼叫 %@",[SOSBleUtil formatPhone:entity.mobilePhone]]];
        }
        [titles addObject:@"放弃共享"];
        [RMUniversalAlert showActionSheetInViewController:self withTitle:nil message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:titles popoverPresentationControllerBlock:nil tapBlock:^(RMUniversalAlert * _Nonnull alert, NSInteger buttonIndex) {
            if (buttonIndex == alert.cancelButtonIndex+2 && titles.count == 2) {
                [SOSUtil callPhoneNumber:entity.mobilePhone];
                if ([entity.authorizationType isEqualToString:@"TEMP"]) {
                    [SOSDaapManager sendActionInfo:ReceivedCarsharing_TempCarsharing_Call];
                }else {
                    [SOSDaapManager sendActionInfo:ReceivedCarsharing_PermCarsharing_Call];
                }
                
            }else if (buttonIndex == alert.cancelButtonIndex+3 || (buttonIndex == alert.cancelButtonIndex+2 && titles.count == 1)) {
                SOSCustomAlertView *alert = [[SOSCustomAlertView alloc] initWithTitle:@"提示" detailText:@"您确定要放弃当前的共享吗?" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"]];
                alert.pageModel = SOSAlertViewModelContent;
                alert.buttonMode = SOSAlertButtonModelHorizontal;
                alert.backgroundModel = SOSAlertBackGroundModelStreak;
                @weakify(self)
                alert.buttonClickHandle = ^(NSInteger clickIndex) {
                    @strongify(self)
                    if (clickIndex == 1) {
                        [self userGiveUpShareWithAuthorInfo:entity];
                    }
                };
                [alert show];
                
                if ([entity.authorizationType isEqualToString:@"TEMP"]) {
                    [SOSDaapManager sendActionInfo:ReceivedCarsharing_TempCarsharing_Giveup];
                }else {
                    [SOSDaapManager sendActionInfo:ReceivedCarsharing_PermCarsharing_Giveup];
                }
                
            }
        }];
    };
    return cell;
}

#pragma mark --Action
- (void)downloadKeyWithAuthorInfo:(SOSAuthorDetail *)authorInfo
                         complete:(void(^)(void))complete {
    if (!complete) {
        if ([authorInfo.authorizationType isEqualToString:@"TEMP"]) {
            [SOSDaapManager sendActionInfo:ReceivedCarsharing_TempCarsharing_Loadkey];
        }else {
            [SOSDaapManager sendActionInfo:ReceivedCarsharing_PermCarsharing_Loadkey];
        }
    }else {
        if ([authorInfo.authorizationType isEqualToString:@"TEMP"]) {
            [SOSDaapManager sendActionInfo:ReceivedCarsharing_TempCarsharing_Load_Conectkey];
        }else {
            [SOSDaapManager sendActionInfo:ReceivedCarsharing_PermCarsharing_Load_Conectkey];
        }
    }
    
    
    [SOSBleNetwork bleUserDownloadKeysWithParams:@{
                                                   @"authorizationId":authorInfo.authorizationId?:@"",
                                                   @"idpUserId":[CustomerInfo sharedInstance].userBasicInfo.idpUserId?:@"",
                                                   @"vin":authorInfo.vin,
                                                   @"duid":[[BlueToothManager sharedInstance] getPHoneUUID]
                                                   }
                                         success:^(id JSONDict) {
                                             
                                             if ([JSONDict[@"message"] isEqualToString:@"success"]) {
                                                 NSDictionary *dic = JSONDict[@"resultData"];
                                                 if ([dic isKindOfClass:[NSDictionary class]]) {
                                                     SOSVKeys *key = [SOSVKeys mj_objectWithKeyValues:dic];
                                                     !complete?:complete();
                                                     //下载钥匙
                                                     [SOSBleUtil saveKeysWithVKeys:key authorInfo:authorInfo];
                                                     //刷新
                                                     [self callSuperRefresh];
                                                 }
                                             }else {
                                                 [Util toastWithMessage:JSONDict[@"message"]];
                                             }                                             
                                         } Failed:^(NSString *responseStr, NSError *error) {
        
    
                                         }];
}

- (void)userGiveUpShareWithAuthorInfo:(SOSAuthorDetail *)authorInfo {
    NSDictionary *dic = @{@"idpUserId":[CustomerInfo sharedInstance].userBasicInfo.idpUserId?:@"",
                          @"authorizationId":authorInfo.authorizationId,
                          @"authorizationStatus":@"CANCELLED"
                          };
    
    [SOSBleNetwork bleUserAuthorizationsParams:dic method:@"PUT" success:^(SOSAuthorInfo *authorInfo) {
        if ([authorInfo.statusCode isEqualToString:@"0000"]) {
            //刷新
            [self callSuperRefresh];
        }else {
            [Util toastWithMessage:authorInfo.message];
        }
    } Failed:^(NSString *responseStr, NSError *error) {
        
    }];
}


- (UIViewController *)pageContainerViewController {
    return self.parentViewController.parentViewController;
}

- (void)callSuperRefresh
{
    UIViewController *vc =  [self pageContainerViewController];
    if ([vc respondsToSelector:@selector(request)]) {
        [vc performSelector:@selector(request)];
    }
}


- (void)routerToBlePage:(SOSAuthorDetail *)authorInfo {
    if (authorInfo) {
        if ([authorInfo.authorizationType isEqualToString:@"TEMP"]) {
            [SOSDaapManager sendActionInfo:ReceivedCarsharing_TempCarsharing_Conectkey];
        }else {
            [SOSDaapManager sendActionInfo:ReceivedCarsharing_PermCarsharing_Conectkey];
        }
    }
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[SOSBleUserCarListViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    SOSBleUserCarListViewController *blePage = [SOSBleUserCarListViewController new];
    [self.navigationController pushViewController:blePage animated:YES];
}

- (void)downloadKeyThenToBlePageWithAuthorInfo:(SOSAuthorDetail *)authorInfo {

    [self downloadKeyWithAuthorInfo:authorInfo complete:^{
        [self routerToBlePage:nil];
    }];
}


#pragma mark - DZNEmptyDataSetSource Methods

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];

    if ( [AFNetworkReachabilityManager sharedManager].reachable) {
        text = @"没有车辆";
    }else {
        text = @"没有网络连接";
    }
    font = [UIFont systemFontOfSize:16];
    textColor =   [UIColor colorWithHexString:@"b9b9b9"] ;
    
    
    
    if (!text) {
        return nil;
    }
    
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    if ( [AFNetworkReachabilityManager sharedManager].reachable) {
        text = @"其他车主共享给你的车辆会显示在这里";
    }else {
        text = @"";
    }
    
    font = [UIFont systemFontOfSize:16];
    textColor =   [UIColor colorWithHexString:@"b9b9b9"] ;

    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    if (paragraph) [attributes setObject:paragraph forKey:NSParagraphStyleAttributeName];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    
    return attributedString;
}



- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [AFNetworkReachabilityManager sharedManager].reachable?[UIImage imageNamed:@"pic_list_nocar_70x70"]:[UIImage imageNamed:@"pic_satellite-dish_70x70"];
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
{
    return 20;
}


- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -50.0;
}
@end
