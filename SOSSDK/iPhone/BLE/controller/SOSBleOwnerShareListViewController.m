//
//  SOSBleOwnerShareListViewController.m
//  Onstar
//
//  Created by onstar on 2018/7/19.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleOwnerShareListViewController.h"
#import "SOSBleOwnerShareCell.h"
#import "SOSBleNetwork.h"
#import "LoadingView.h"
#import "SOSBleQRViewController.h"
#import "SOSBleUtil.h"
#import "UIScrollView+EmptyDataSet.h"
#import "SOSCustomAlertView.h"
#import "SOSBleAppoverViewController.h"
#import "NSDate+DateTools.h"
#import "WeiXinMessageInfo.h"
#import "NavigateShareTool.h"
#import "UITableView+FDTemplateLayoutCell.h"
@interface SOSBleOwnerShareListViewController ()<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@end

@implementation SOSBleOwnerShareListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerNib:[UINib nibWithNibName:@"SOSBleOwnerShareCell" bundle:nil] forCellReuseIdentifier:SOSBleOwnerShareCell.className];
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"E8EBEF"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SOSBleOwnerShareCell *cell = [tableView dequeueReusableCellWithIdentifier:SOSBleOwnerShareCell.className forIndexPath:indexPath];
    SOSAuthorDetail *entity = self.sourceData[indexPath.row];
    [cell setAuthorEntity:entity ownerSharePage:self.fromOwnerShare];
    cell.operationButtonTapBlock = ^{
        BOOL valid = [SOSBleUtil authorValid:entity.authorizationStatus];
        BOOL acceptUser = entity.userId.isNotBlank && entity.mobilePhone.isNotBlank;
        NSMutableArray *titles = @[].mutableCopy;
        NSMutableArray *selectors = @[].mutableCopy;
        NSMutableArray *params = @[].mutableCopy;
        NSMutableArray *daaps = @[].mutableCopy;
        
        if ([entity.authorizationStatus isEqualToString:@"NEW"] && [entity.authorizationType isEqualToString:@"TEMP"]) {
            [titles addObject:@"分享给好友"];
            [selectors addObject:NSStringFromSelector(@selector(toShareWithUrl:))];
            [params addObject:entity.shareUrl?:@""];
            [daaps addObject:@""];
        }
        
        if (acceptUser) {
            [titles addObject:[NSString stringWithFormat:@"呼叫 %@",[SOSBleUtil formatPhone:entity.mobilePhone]]];
            [selectors addObject:NSStringFromSelector(@selector(callWithPhone:))];
            [params addObject:entity.mobilePhone];
            
            if ([entity.authorizationType isEqualToString:@"TEMP"]) {
                [daaps addObject:BLEOwner_PermCarsharing_Call];
            }else {
                [daaps addObject:BLEOwner_PermCarsharing_Call];
            }
        }
        
        if (valid) {
            [titles addObject:@"关闭共享"];
            [selectors addObject:NSStringFromSelector(@selector(closeAuthorWithAuthorId:))];
            [params addObject:entity.authorizationId];
            if ([entity.authorizationType isEqualToString:@"TEMP"]) {
                [daaps addObject:BLEOwner_TempCarsharing_Close];
            }else {
                [daaps addObject:BLEOwner_PermCarsharing_Close];
            }
        }
        

        if (titles.count) {
            
            [RMUniversalAlert showActionSheetInViewController:self withTitle:nil message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:titles popoverPresentationControllerBlock:nil tapBlock:^(RMUniversalAlert * _Nonnull alert, NSInteger buttonIndex) {
                if (buttonIndex >= 2) {
                    if ([self respondsToSelector:NSSelectorFromString(selectors[buttonIndex-2])]) {
                        [self performSelector:NSSelectorFromString(selectors[buttonIndex-2]) withObject:params[buttonIndex-2]];
                        
                    }
                    NSString *daap = daaps[buttonIndex-2];
                    if (daap.isNotBlank) {
                        [SOSDaapManager sendActionInfo:daap];
                    }
                    
                }
                
               
//                if (buttonIndex == alert.cancelButtonIndex + 2) {
//                    //打电话 || 关闭共享
//                    acceptUser?[self callWithPhone:entity.mobilePhone]:[self operationShareWithAuthorId:entity.authorizationId status:@"CLOSED"];;
//                }else if (buttonIndex == alert.cancelButtonIndex + 3) {
//                    //关闭共享
//                    [self closeAuthorWithAuthorId:entity.authorizationId];
//                }
            }];
        }
        
    };
    return cell;
}

- (void)closeAuthorWithAuthorId:(NSString *)authorId {
    SOSCustomAlertView *alert = [[SOSCustomAlertView alloc] initWithTitle:@"提示" detailText:@"您确定要关闭当前的共享吗?" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"]];
    alert.pageModel = SOSAlertViewModelContent;
    alert.buttonMode = SOSAlertButtonModelHorizontal;
    alert.backgroundModel = SOSAlertBackGroundModelStreak;
    @weakify(self)
    alert.buttonClickHandle = ^(NSInteger clickIndex) {
        @strongify(self)
        if (clickIndex == 1) {
            [self operationShareWithAuthorId:authorId status:@"CLOSED"];
        }
    };
    [alert show];
}

- (void)toShareWithUrl:(NSString *)url
{
    WeiXinMessageInfo *messageInfo = [[WeiXinMessageInfo alloc] init];
    messageInfo.messageTitle = @"安吉星@车辆共享";
    messageInfo.messageDescription = @"您收到了一个来自好友的车辆蓝牙操控分享，请点击开启分享之旅。";
#ifdef SOSSDK_SDK
    url = [NSString stringWithFormat:@"%@&sc=%@",url,[SOSSDKKeyUtils bleSchemeUrl]];
#endif
    messageInfo.messageWebpageUrl = url;
    
    messageInfo.messageThumbImage = [UIImage imageNamed:@"pic_IMG_60x60"];
    [[NavigateShareTool sharedInstance] shareWithWeiXinMessageInfo:messageInfo];
}

- (void)callWithPhone:(NSString *)phoneNumber
{
    [SOSUtil callPhoneNumber:phoneNumber];
}

- (void)operationShareWithAuthorId:(NSString *)authorId status:(NSString *)status
{
    [[LoadingView sharedInstance] startIn:[self pageContainerViewController].view];
    [SOSBleNetwork bleOwnerOperateAuthorizationsParams:@{@"authorizationId":authorId,
                                                         @"idpUserId":[CustomerInfo sharedInstance].userBasicInfo.idpUserId?:@"",
                                                         @"authorizationStatus":status,
                                                         }
                                               success:^(SOSAuthorInfo *authorInfo) {
                                                   [Util hideLoadView];
                                                   if ([authorInfo.statusCode isEqualToString:@"0000"]) {
                                                      
                                                       [self callSuperRefresh];
                                                   }else {
                                                       [Util toastWithMessage:authorInfo.message];
                                                   }
                                               }
                                                Failed:^(NSString *responseStr, NSError *error) {
                                                    [Util hideLoadView];
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

- (void)callSuperAddShare
{
    UIViewController *vc =  [self pageContainerViewController];
    if ([vc respondsToSelector:@selector(shareMyCar)]) {
        [vc performSelector:@selector(shareMyCar)];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SOSAuthorDetail *authorInfo = self.sourceData[indexPath.row];

    return [tableView fd_heightForCellWithIdentifier:SOSBleOwnerShareCell.className cacheByKey:authorInfo.authorizationId configuration:^(SOSBleOwnerShareCell *cell) {
        [cell setAuthorEntity:authorInfo ownerSharePage:self.fromOwnerShare];
    }];
}

//出示二维码
- (void)showQrPageWithAuthorInfo:(SOSAuthorDetail *)authorInfo {
    [SOSDaapManager sendActionInfo:BLEOwner_Add_New_PermCarsharing_QR_Show];
    SOSBleQRViewController *qrVc = [[SOSBleQRViewController alloc] initWithNibName:@"SOSBleQRViewController" bundle:nil];
    qrVc.qrUrl = authorInfo.shareUrl;
    [self.navigationController pushViewController:qrVc animated:YES];
}

//批准授权 APPROVED
- (void)ownerAcceptShareWithAuthorInfo:(SOSAuthorDetail *)authorInfo {
    
    if ([authorInfo.authorizationType isEqualToString:@"TEMP"]) {
         [SOSDaapManager sendActionInfo:BLEOwner_TempCarsharing_Confirm];
    }else {
         [SOSDaapManager sendActionInfo:BLEOwner_PermCarsharing_Confirm];
    }
    
    //CR弹出ALERT
    NSNumber *dateNum = UserDefaults_Get_Object(@"bleAcceptRemindKey");
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateNum.doubleValue];
    if (![[date dateByAddingDays:7] isEarlierThan:[NSDate date]]) {
//    if (![[date dateByAddingMinutes:5] isEarlierThan:[NSDate date]]) {
        [self operationShareWithAuthorId:authorInfo.authorizationId status:@"APPROVED"];
        return;
    }
    SOSBleAppoverViewController *vc = [[SOSBleAppoverViewController alloc] initWithNibName:@"SOSBleAppoverViewController" bundle:nil];
    @weakify(self)
    vc.acceptBlock = ^{
        @strongify(self)
        [self operationShareWithAuthorId:authorInfo.authorizationId status:@"APPROVED"];
    };
    vc.phone = authorInfo.mobilePhone;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:vc animated:NO completion:nil];
}


#pragma mark - DZNEmptyDataSetSource Methods

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    
    if (self.isHistory) {
        text = @"暂无数据";
    }else {
        text = @"没有共享给好友";
    }
//    font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
    font = [UIFont systemFontOfSize:16];
    textColor =   [UIColor colorWithHexString:@"b9b9b9"] ;

    
    
    if (!text) {
        return nil;
    }
    
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}


- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"pic_list_nocar_70x70"];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    if (self.isHistory) {
        return nil;
    }
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    

    text = @"添加新共享";
//    font = [UIFont boldSystemFontOfSize:16.0];
    font = [UIFont systemFontOfSize:16];
    textColor = [UIColor whiteColor];
    
    
    if (!text) {
        return nil;
    }
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}


- (UIImage *)buttonBackgroundImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    if (self.isHistory) {
        return nil;
    }
    UIImage *image = [[UIImage imageWithColor:[UIColor colorWithHexString:@"107fe0"] size:CGSizeMake(kScreenWidth, 50)] imageByRoundCornerRadius:5];
    UIEdgeInsets capInsets = UIEdgeInsetsZero;
    UIEdgeInsets rectInsets = UIEdgeInsetsZero;
    rectInsets = UIEdgeInsetsMake(-0, -30, 0, -30);
    return [[image resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch] imageWithAlignmentRectInsets:rectInsets];
}



- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
{
    return 20;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button
{
    [self callSuperAddShare];
}

@end
