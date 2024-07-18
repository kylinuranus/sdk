//
//  NavigateShareTool.m
//  Onstar
//
//  Created by Coir on 16/3/28.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "WXApi.h"
#import "WeiXinManager.h"
#import "NavigateShareTool.h"
#import "AppDelegate_iPhone+SOSService.h"
#import "SOSShareView.h"
#import "SOSPhotoLibrary.h"
#ifndef SOSSDK_SDK
#import "SOSIMApiObject.h"
#import "SOSIMApi.h"
#endif
@interface NavigateShareTool    ()   {
    
    SOSPOI *poi;
    WeiXinMessageInfo *_messageInfo;
    WeiXinMessageInfo *wxMessageInfo;
    
    BOOL isFootPrintMode;
//    BOOL isDriveScore;
}

@end

@implementation NavigateShareTool

#define ALERT_NEED_ENSURE_DELETE	3
#define TAG_IS_CADILLAC             4
#define TAG_IS_CADILLAC_ODD         5

#define BUTTON_INDEX_SMS            3
#define BUTTON_INDEX_SINAWEIBO      2
#define BUTTON_INDEX_WEIXIN_FRIEND  0
#define BUTTON_INDEX_WEIXIN_MOMENTS 1

+ (NavigateShareTool *)sharedInstance    {
    static NavigateShareTool *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [[self alloc] init];
    });
    return sharedOBJ;
}

- (void)shareWithImg:(UIImage *)img andFunIDArray:(NSArray <NSString *> *)funIDArray	{
    self.shareCancelDaapID = nil;
    self.shareToChatDaapID = nil;
    self.shareToMomentsDaapID = nil;
    if (img) {
        wxMessageInfo = [[WeiXinMessageInfo alloc] init];
        wxMessageInfo.media = [Util compressedImageFiles:img imageKB:10000];
        if (funIDArray.count == 3) {
            wxMessageInfo.shareWechatRecordFunctionID = funIDArray[0];
            wxMessageInfo.shareMomentsRecordFunctionID = funIDArray[1];
            wxMessageInfo.shareCancelRecordFunctionID = funIDArray[2];
        }
        [self shareWithWeiXinMessageInfo:wxMessageInfo];
    }
}

- (void)shareWithImg:(UIImage *)img	{
    [self shareWithImg:img andFunIDArray:nil];
}



#pragma mark 分享位置点击
- (void)shareWithPOI:(SOSPOI *)sharePoi {
    isFootPrintMode = NO;
    poi = sharePoi;
    
    self.shareCancelDaapID = nil;
    self.shareToChatDaapID = nil;
    self.shareToMomentsDaapID = nil;
    [self showShareAlertControllerWithNewUI];
}

- (void)shareWithNewUIWithPOI:(SOSPOI *)sharePoi    {
    isFootPrintMode = NO;
    poi = sharePoi;
    
    self.shareCancelDaapID = nil;
    self.shareToChatDaapID = nil;
    self.shareToMomentsDaapID = nil;
    [self showShareAlertControllerWithNewUI];
}

- (void)showShareAlertControllerWithNewUI {
    SOSFlexibleAlertController *actionSheet;
    SOSSocialContactShareView *view = [SOSSocialContactShareView viewFromXib];
    view.shareChannels = @[  @{ @"icon":@"wxfrend",
                                @"title":@"微信朋友圈" },
                             @{ @"icon":@"Icon／34x34／icon_share_weixin_34x34",
                                @"title":@"微信好友" } ];
    actionSheet = [SOSFlexibleAlertController alertControllerWithImage:nil title:nil message:nil customView:view preferredStyle:SOSAlertControllerStyleActionSheet];
    
    __weak __typeof(self) weakSelf = self;
    view.shareTapBlock = ^(NSInteger index) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        UIViewController *topVC = SOS_APP_DELEGATE.fetchMainNavigationController.topViewController;
        if (index == 0) {
            if (weakSelf.shareToMomentsDaapID)    [SOSDaapManager sendActionInfo:weakSelf.shareToMomentsDaapID];
            if (poi.sosPoiType == POI_TYPE_LBS) {
                [SOSDaapManager sendActionInfo:LBS_list_deviceinfo_sharelocation_moments];
            }    else    {
                if (isFootPrintMode) {
                    [SOSDaapManager sendActionInfo:Footprints_share_moments];
                }   else    {
                    [SOSDaapManager sendActionInfo:Map_POIdetail_sharePOI_moments];
                }
            }
            if (poi.sosPoiType == POI_TYPE_MIRROR) 	[SOSDaapManager sendActionInfo:Rearview_device_locationshare_towechatmoments];
            
            [weakSelf shareToWXSession];
        }    else if (index == 1) {
            if (weakSelf.shareToChatDaapID)    [SOSDaapManager sendActionInfo:weakSelf.shareToChatDaapID];
            if (poi.sosPoiType == POI_TYPE_LBS) {
                [SOSDaapManager sendActionInfo:LBS_list_deviceinfo_sharelocation_wechat];
            }    else    {
                if (isFootPrintMode) {
                    [SOSDaapManager sendActionInfo:Footprints_share_wechat];
                }   else    {
                    [SOSDaapManager sendActionInfo:Map_POIdetail_sharePOI_wechat];
                }
            }
            if (poi.sosPoiType == POI_TYPE_MIRROR) {
                [SOSDaapManager sendActionInfo:Rearview_device_locationshare_towechatfriend];
            }
            [weakSelf shareToWeChat];
        }
//        [topVC dismissViewControllerAnimated:YES completion:nil];
    };
    
    SOSAlertAction *cancelAction = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
        if (self.shareCancelDaapID)    [SOSDaapManager sendActionInfo:self.shareCancelDaapID];
        if (poi.sosPoiType == POI_TYPE_LBS) {
            [SOSDaapManager sendActionInfo:LBS_list_deviceinfo_sharelocation_cancel];
        }    else    {
            if (isFootPrintMode) {
                [SOSDaapManager sendActionInfo:Footprints_share_cancel];
            }   else    {
                [SOSDaapManager sendActionInfo:Map_POIdetail_sharePOI_cancel];
            }
        }
        if (poi.sosPoiType == POI_TYPE_MIRROR) {
            [SOSDaapManager sendActionInfo:Rearview_device_locationshare_cancel];
        }
        
    }];
    [actionSheet addActions:@[cancelAction]];
    [actionSheet show];
}

- (void)shareToWeChat   {
    [self shareToWeixinScene:WXSceneSession];
}

- (void)shareToWXSession    {
    [self shareToWeixinScene:WXSceneTimeline];
}

#pragma mark 微信分享点击
- (void)shareToWeixinScene:(enum WXScene)scene  {
    // 如果没有安装微信 ,去APP Store 下载 微信
    if (![[WeiXinManager shareInstance] isWXAppInstalled]) {
        [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:@"https://itunes.apple.com/us/app/wechat/id414478124?mt=8"]];
        return;
    }
    
    if (poi) {
        wxMessageInfo = [[WeiXinMessageInfo alloc] init];
        // set poi info to weixin message info.
        //        if (poi.sosPoiType == POI_TYPE_CURRENT_LOCATION || poi.sosPoiType == POI_TYPE_VEHICLE_LOCATION) {
        //            //        [wxMessageInfo setPoiName:NSLocalizedString(@"ShareDestination", nil)];
        //            [wxMessageInfo setPoiName:poi.name];
        //            [wxMessageInfo setAddress:poi.address];
        //        } else {
        [wxMessageInfo setPoiName:poi.name];
        [wxMessageInfo setAddress:poi.address];
        //        }
        
        [wxMessageInfo setLatitude:NONil(poi.y)];
        [wxMessageInfo setLongitude:poi.x];
        
        [wxMessageInfo setAroundDescription:poi.address];
        [wxMessageInfo setCategory:[CustomerInfo sharedInstance].aroundSearchCategory];
        [wxMessageInfo setProvince:poi.province];
        [wxMessageInfo setCity:poi.city];
        [wxMessageInfo setPhoneNumber:poi.tel.length ? poi.tel : @""];
        //set weixin show message
        wxMessageInfo.messageDescription = [NSString stringWithFormat:@"%@\n%@",wxMessageInfo.address, wxMessageInfo.phoneNumber];
        wxMessageInfo.messageThumbImage = [UIImage imageNamed:@"Share_POI_APP_Icon"];
        NSMutableString *url;
        if (poi.sosPoiType == POI_TYPE_MIRROR) {
            url = [NSMutableString stringWithString:SHARE_TO_WEIXIN_RVM_URL];
        }	else	{
            url = [NSMutableString stringWithString:SHARE_TO_WEIXIN_URL];
        }
        [url appendFormat:@"&latitude=%@",wxMessageInfo.latitude];
        [url appendFormat:@"&longitude=%@",wxMessageInfo.longitude];
        [url appendFormat:@"&poiName=%@",wxMessageInfo.poiName];
        if ([Util isNotEmptyString:wxMessageInfo.address]) {
            [url appendFormat:@"&address=%@",wxMessageInfo.address];
        }
        if ([Util isNotEmptyString:wxMessageInfo.phoneNumber]) {
            [url appendFormat:@"&phoneNumber=%@",wxMessageInfo.phoneNumber];
        }
        if ([Util isNotEmptyString:wxMessageInfo.city]) {
            [url appendFormat:@"&city=%@",wxMessageInfo.city];
        }
        if (poi.sosPoiType == POI_TYPE_VEHICLE_LOCATION)    {
            [url appendFormat:@"&nickName=%@", NONil([CustomerInfo sharedInstance].tokenBasicInfo.nickName)];
            wxMessageInfo.messageTitle = [NSString stringWithFormat:@"车辆位置分享（%@）", wxMessageInfo.poiName] ;
        }	else	{
            wxMessageInfo.messageTitle = [NSString stringWithFormat:@"位置分享（%@）", wxMessageInfo.poiName];
        }
        wxMessageInfo.messageWebpageUrl = url;
    }
    wxMessageInfo.scene = scene;
    [[WeiXinManager shareInstance] shareWebPageContent:wxMessageInfo];
}

- (void)showAlertMessage:(NSString *)errorMsg{
    if(![NSThread mainThread])  {
        [self performSelectorOnMainThread:_cmd withObject:errorMsg waitUntilDone:NO];
    }
    [Util showAlertWithTitle:nil message:errorMsg completeBlock:nil];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex     {
    switch (buttonIndex) {
        case BUTTON_INDEX_SMS:
            //            [self shareMessageRequest];
            break;
        case BUTTON_INDEX_SINAWEIBO:
            [self showShareWeiboPage];
            break;
        case BUTTON_INDEX_WEIXIN_FRIEND:
            [self shareToWeixinScene:WXSceneSession];
            break;
        case BUTTON_INDEX_WEIXIN_MOMENTS:
            [self shareToWeixinScene:WXSceneTimeline];
            break;
        default:
            break;
    }
}

#pragma mark Share to SinaWeibo
- (void)showShareWeiboPage     {
    ////[[SOSReportService shareInstance] recordActionWithFunctionID:REPORT_SHARE_TO_WEIBO];
}

- (void)dismissShareWeiboModelView  {
    //    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissShareWeiboModelView:(NSDictionary *)data     {
}

- (void)sinaweiboManagerDidLogIn     {
    
}

#pragma mark - ShareUrl
- (void)shareWithWeiXinMessageInfo:(WeiXinMessageInfo *)messageInfo     {
    @weakify(self)
    _messageInfo = messageInfo;
        SOSFlexibleAlertController *actionSheet;
        NSMutableArray * menu = [NSMutableArray array];
        [menu addObject: @{ @"icon":@"Icon／34x34／icon_share_weixin_34x34",
                                    @"title":@"微信好友",@"functionID":NONil(self.shareToMomentsDaapID) ,@"event":@"shareWchat"}];
        [menu addObject: @{ @"icon":@"wxfrend",
                                    @"title":@"微信朋友圈",@"functionID":NONil(self.shareToChatDaapID) ,@"event":@"shareWchatMoments"}];
     
         
        SOSShareView *view = [[SOSShareView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100) andSource:menu];
        actionSheet = [SOSFlexibleAlertController alertControllerWithImage:nil title:nil message:nil customView:view preferredStyle:SOSAlertControllerStyleActionSheet];
        
        view.shareTapCallback = ^(NSDictionary * _Nonnull clickItem) {
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
            @strongify(self);
            if ([(NSString *)[clickItem objectForKey:@"functionId"] isNotBlank])
                [SOSDaapManager sendActionInfo:[clickItem objectForKey:@"functionId"]];
                        
            if ([self isClickWechat:clickItem]) {
                [self shareToWeixinSceneWeiXinMessageInfo:WXSceneSession messageInfo:messageInfo];
                
            }
            if ([self isClickWchatMoments:clickItem]) {
                [self shareToWeixinSceneWeiXinMessageInfo:WXSceneTimeline messageInfo:messageInfo];
                
            }
        };
        
        SOSAlertAction *cancelAction = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
                NSString *shareCancelRecordFunctionID = _messageInfo.shareCancelRecordFunctionID;
                @strongify(self)
                if (!IsStrEmpty(shareCancelRecordFunctionID)) {
                    [SOSDaapManager sendActionInfo:shareCancelRecordFunctionID];
                    [SOSDaapManager sendActionInfo:self->_messageInfo.shareCancelRecordFunctionID];
                }
                if (self.shareCancelDaapID)    [SOSDaapManager sendActionInfo:self.shareCancelDaapID];
            }];
        [actionSheet addActions:@[cancelAction]];
        [actionSheet show];
}

- (void)shareToWeChatWeiXinMessageInfo  {
    if (!IsStrEmpty(_messageInfo.shareWechatRecordFunctionID)) {
        [SOSDaapManager sendActionInfo:_messageInfo.shareWechatRecordFunctionID];
    }
//    if (isDriveScore) {
//        [SOSDaapManager sendActionInfo:RECENT_TRAVEL_TRAVEL_RECORDS_SHARE_WECHAT_FRIENDS];
//    }
    [self shareToWeixinSceneWeiXinMessageInfo:WXSceneSession];
}

- (void)shareToWXSessionWeiXinMessageInfo   {
    if (!IsStrEmpty(_messageInfo.shareMomentsRecordFunctionID)) {
        [SOSDaapManager sendActionInfo:_messageInfo.shareMomentsRecordFunctionID];
    }
//    if (isDriveScore) {
//        [SOSDaapManager sendActionInfo:RECENT_TRAVEL_TRAVEL_RECORDS_SHARE_WECHAT_MOMENTS];
//    }
    
    [self shareToWeixinSceneWeiXinMessageInfo:WXSceneTimeline];
}

#pragma mark 微信分享点击
- (void)shareToWeixinSceneWeiXinMessageInfo:(enum WXScene)scene     {
    [self shareToWeixinSceneWeiXinMessageInfo:scene messageInfo:_messageInfo];
}

- (void)shareToWeixinSceneWeiXinMessageInfo:(int)scene  messageInfo:(WeiXinMessageInfo *)wxMessageInfo   {
    // 如果没有安装微信 ,去APP Store 下载 微信
    if (![[WeiXinManager shareInstance] isWXAppInstalled]) {
        [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:@"https://itunes.apple.com/us/app/wechat/id414478124?mt=8"]];
        return;
    }
    
    WeiXinMessageInfo *messageInfo = [[WeiXinMessageInfo alloc] init];
    //set weixin show message
    messageInfo.messageTitle = wxMessageInfo.messageTitle;
    messageInfo.messageDescription = wxMessageInfo.messageDescription;
    messageInfo.messageWebpageUrl = wxMessageInfo.messageWebpageUrl;
    messageInfo.messageThumbImage = wxMessageInfo.messageThumbImage;
    messageInfo.media = wxMessageInfo.media;
    messageInfo.scene = scene;
    [[WeiXinManager shareInstance] shareWebPageContent:messageInfo];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//3.event固定类型：
//interface IShareType {
//    String SHARE_WECHAT = "shareWchat";
//    String SHARE_WECHAT_MOMENTS = "shareWchatMoments";
//    String SHARE_ONSTAR_MOMENTS = "shareOnStarMoments";
//    String SHARE_SAVE_PIC = "shareSavePic";
//    String SHARE_CANCEL = "cancelshare";
//}
//
//Dic 示例
//@{@"title":shareTitle,@"desc":shareMsg,@"thumbimageurl":shareImg,@"shareurl":shareUrl,@"menu":@[@{@"event":@"shareWchat",@"functionId":[weakSelf.currentPage isEqualToString:@"driveScore"] ? RECENT_TRAVEL_TRAVEL_RECORDS_SHARE_WECHAT_FRIENDS : @""},@{@"event":@"shareWchatMoments",@"functionId":[weakSelf.currentPage isEqualToString:@"driveScore"] ? RECENT_TRAVEL_TRAVEL_RECORDS_SHARE_WECHAT_MOMENTS : @""}]}
//

////////////////////////////////////////////目前支持4个
- (void)showShareAlertControllerWithShareSource:(NSDictionary *)shareSource screencutShareView:(nullable UIScrollView*)rt {
    @weakify(self);
    SOSFlexibleAlertController *actionSheet;
    NSArray *menuSoure = [shareSource objectForKey:@"menu"];
    NSMutableArray * menu = [NSMutableArray array];
    [menuSoure enumerateObjectsUsingBlock:^(NSDictionary  * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self isClickWechat:obj]) {
            [menu addObject: @{ @"icon":@"Icon／34x34／icon_share_weixin_34x34",
                                @"title":@"微信好友",@"functionID":[obj objectForKey:@"functionId"],@"event":[obj objectForKey:@"event"]}];
        }
        if ([self isClickWchatMoments:obj]) {
            [menu addObject: @{ @"icon":@"wxfrend",
                                @"title":@"微信朋友圈",@"functionID":[obj objectForKey:@"functionId"],@"event":[obj objectForKey:@"event"]}];
        }
#ifndef SOSSDK_SDK
        
        if ([self isClickOnStarMoments:obj]) {
            [menu addObject:  @{ @"icon":@"onstarFrends",
                                 @"title":@"星友圈好友",@"functionID":[obj objectForKey:@"functionId"],@"event":[obj objectForKey:@"event"]}];
        }
#endif
        if ([self isClickSavePic:obj]) {
            [menu addObject:  @{ @"icon":@"share_save_Photo", @"title":@"保存图片",@"functionID":[obj objectForKey:@"functionId"] ,@"event":[obj objectForKey:@"event"]}];
        }
    }];
    SOSShareView *view = [[SOSShareView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100) andSource:menu];
    actionSheet = [SOSFlexibleAlertController alertControllerWithImage:nil title:nil message:nil customView:view preferredStyle:SOSAlertControllerStyleActionSheet];
    
    view.shareTapCallback = ^(NSDictionary * _Nonnull clickItem) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        @strongify(self);
        if ([(NSString *)[clickItem objectForKey:@"functionId"] isNotBlank])
            [SOSDaapManager sendActionInfo:[clickItem objectForKey:@"functionId"]];
        
        UIViewController *topVC = SOS_APP_DELEGATE.fetchMainNavigationController.topViewController;
        
        if ([self isClickWechat:clickItem]) {
            WeiXinMessageInfo *messageInfo = [self makeWeixinShareInfoWithDic:shareSource screencutView:nil];
            
            [self shareToWeixinSceneWeiXinMessageInfo:WXSceneSession messageInfo:messageInfo];
            
        }
        if ([self isClickWchatMoments:clickItem]) {
            WeiXinMessageInfo *messageInfo = [self makeWeixinShareInfoWithDic:shareSource screencutView:nil];
            
            [self shareToWeixinSceneWeiXinMessageInfo:WXSceneTimeline messageInfo:messageInfo];
            
        }
#ifndef SOSSDK_SDK
        if ([self isClickOnStarMoments:clickItem]) {
            [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:topVC andTobePushViewCtr:nil completion:^(BOOL finished) {
                SOSIMMediaMessage *media = [SOSIMMediaMessage new];
                media.title = [shareSource objectForKey:@"title"];
                media.des = [shareSource objectForKey:@"desc"];
                
                SendMessageToSOSIMReq *imReq = [[SendMessageToSOSIMReq alloc] init];
                imReq.messageType = SOSIMMessageTypeText;
                imReq.bText = YES;
                imReq.text = [[shareSource objectForKey:@"shareurl"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                imReq.message = media;
                imReq.fromNav = [SOS_APP_DELEGATE fetchMainNavigationController];
                [SOSIMApi sendReq:imReq];
            }];
        }
#endif
        if ([self isClickSavePic:clickItem]) {
            if (rt) {
                //重新设置回原frame
                UIImage *sendImage =  [self screenCutImageWithScrollView:rt];
                [rt.superview layoutIfNeeded];
                
                [SOSPhotoLibrary saveImage:sendImage assetCollectionName:nil callback:^(BOOL success) {
//                    if (success)     [Util toastWithMessage:@"图片成功保存至'安吉星'相册"];
                }];
            }
            
        }
//        [topVC dismissViewControllerAnimated:YES completion:nil];
    };
    
    SOSAlertAction *cancelAction = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
        if (self.shareCancelDaapID)    [SOSDaapManager sendActionInfo:self.shareCancelDaapID];
        if (poi.sosPoiType == POI_TYPE_LBS) {
            [SOSDaapManager sendActionInfo:LBS_list_deviceinfo_sharelocation_cancel];
        }    else    {
            if (isFootPrintMode) {
                [SOSDaapManager sendActionInfo:Footprints_share_cancel];
            }   else    {
                [SOSDaapManager sendActionInfo:Map_POIdetail_sharePOI_cancel];
            }
        }
        if (poi.sosPoiType == POI_TYPE_MIRROR) {
            [SOSDaapManager sendActionInfo:Rearview_device_locationshare_cancel];
        }
        
    }];
    [actionSheet addActions:@[cancelAction]];
    [actionSheet show];
}
-(UIImage *)screenCutImageWithScrollView:(UIScrollView *)rt{
    rt.frame=rt.superview.frame;
    CGRect frm=rt.frame;
    //webview的scrollerView有64的偏移
    frm.size.height=rt.contentSize.height + IOS7_NAVIGATION_BAR_HEIGHT;
    rt.frame=frm;
    [rt.superview layoutIfNeeded];
    //截屏
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(SCREEN_WIDTH,SCREEN_HEIGHT -IOS7_NAVIGATION_BAR_HEIGHT), YES, 0);     //设置截屏大小
    [rt.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = viewImage.CGImage;
    UIImage *sendImage = [[UIImage alloc] initWithCGImage:imageRef];
    return sendImage;
}
-(WeiXinMessageInfo*)makeWeixinShareInfoWithDic:(NSDictionary *)shareSource screencutView:(UIScrollView *)rt {
    WeiXinMessageInfo *messageInfo = [[WeiXinMessageInfo alloc] init];
    //set weixin show message
    messageInfo.messageTitle = [shareSource objectForKey:@"title"];
    messageInfo.messageDescription = [shareSource objectForKey:@"desc"];
    messageInfo.messageWebpageUrl = [shareSource objectForKey:@"shareurl"];
    if ([(NSString *)[shareSource objectForKey:@"thumbimageurl"] containsString:@"http"]) {
        //net
        messageInfo.messageThumbImage =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[shareSource objectForKey:@"thumbimageurl"]]]];
        
    }else{
        //local
        messageInfo.messageThumbImage =[UIImage imageNamed:[shareSource objectForKey:@"thumbimageurl"]];
        
    }
    if (rt) {
        //截屏分享
        UIImage *sendImage = [self screenCutImageWithScrollView:rt];
        messageInfo.media =  sendImage;
    }
    if (wxMessageInfo) {
        messageInfo.media = wxMessageInfo.media;
    }
    return messageInfo;
}
-(BOOL)isClickWechat:(NSDictionary *)item{
    return  [[item objectForKey:@"event"] isEqualToString:@"shareWchat"];
}
-(BOOL)isClickWchatMoments:(NSDictionary *)item{
    return  [[item objectForKey:@"event"] isEqualToString:@"shareWchatMoments"];
}
-(BOOL)isClickOnStarMoments:(NSDictionary *)item{
    return  [[item objectForKey:@"event"] isEqualToString:@"shareOnStarMoments"];
}
-(BOOL)isClickSavePic:(NSDictionary *)item{
    return  [[item objectForKey:@"event"] isEqualToString:@"shareSavePic"];
}

@end
