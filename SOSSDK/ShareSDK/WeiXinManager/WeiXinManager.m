//
//  WeiXinManager.m
//  HappyNewYear
//
//  Created by Onstar on 3/7/13.
//  Copyright (c) 2013 Onstar. All rights reserved.
//

#import "WeiXinManager.h"
#import "Util.h"
#import "WeiXinMessageInfo.h"
#import "SOSSDKKeyUtils.h"

// 微信注册ID
//#define kWeiXinAppID @"wx3e8fc25aedec08b6"


@implementation WeiXinManager

@synthesize scenceFrind,scenceFrinds;
@synthesize fromWeixin;

- (BOOL)isWXAppInstalled     {
    return [WXApi isWXAppInstalled];
}

- (void)sendWeiXinImage:(UIImage *)image Message:(NSString *)message Scence:(int)scence     {
    if (!self.fromWeixin) {
        [self requestWeiXinImage:image Message:message Scence:scence];
    } else {
        [self respWeiXinImage:image Message:message];
    }
    // reset send falg to true
    self.fromWeixin = NO;
}

- (void)requestWeiXinImage:(UIImage *)image Message:(NSString *)message Scence:(int)scence     {
    WXMediaMessage *wxMessage = [WXMediaMessage message];
    [wxMessage setTitle:message];
    [wxMessage setThumbImage:[Util zoomImage:image WithScale:5]];
    
    WXImageObject *imageObject = [WXImageObject object];
    imageObject.imageData = UIImagePNGRepresentation(image);
    
    wxMessage.mediaObject = imageObject;
    
    SendMessageToWXReq *wxRequest = [[SendMessageToWXReq alloc] init];
    wxRequest.bText = NO;
    wxRequest.message = wxMessage;
    wxRequest.scene = scence;
    
    [WXApi sendReq:wxRequest completion:nil];
}

- (void)respWeiXinImage:(UIImage *)image Message:(NSString *)messageStr     {
    
    WXMediaMessage *wxMessage = [WXMediaMessage message];
    [wxMessage setTitle:messageStr];
    [wxMessage setThumbImage:[Util zoomImage:image WithScale:5]];
    
    WXImageObject *imageObject = [WXImageObject object];
    imageObject.imageData = UIImagePNGRepresentation(image);
    
    wxMessage.mediaObject = imageObject;

    GetMessageFromWXResp* resp = [[GetMessageFromWXResp alloc] init];
    resp.message = wxMessage;
    resp.bText = NO;
    
    [WXApi sendResp:resp completion:nil];
}
///

#define BUFFER_SIZE 1024 * 100
- (void)sendAppContentTitle:(NSString *)title Message:(NSString *)messageStr ThumbImage:(UIImage *)thumb Scence:(int)scence     {
    // 发送内容给微信
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = messageStr;
    [message setThumbImage:thumb];
    
    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo = @"onstar";
    ext.url = @"https://itunes.apple.com/cn/app/an-ji-xing/id437190725?l=en&mt=8";

    Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
    memset(pBuffer, 0, BUFFER_SIZE);
    NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
    free(pBuffer);

    ext.fileData = data;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scence;
    
    [WXApi sendReq:req completion:nil];
}

- (void)RespAppContent     {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"这是App消息";
    message.description = @"你看不懂啊， 看不懂啊， 看不懂！";
    [message setThumbImage:[UIImage imageNamed:@"res2.jpg"]];
    
    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo = @"<xml>test</xml>";
    
    Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
    memset(pBuffer, 0, BUFFER_SIZE);
    NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
    free(pBuffer);
    
    ext.fileData = data;
    
    message.mediaObject = ext;
    
    GetMessageFromWXResp* resp = [[GetMessageFromWXResp alloc] init];
    resp.message = message;
    resp.bText = NO;
    
//    [WXApi sendResp:resp];
    [WXApi sendResp:resp completion:nil];
    

}

#pragma mark - registerAPP
- (void)registerApp     {
    dispatch_async_on_main_queue(^{
  
        BOOL registerStatus = [WXApi registerApp:kWeiXinAppID universalLink:[SOSSDKKeyUtils universalLink]];
        NSLog(@"注册微信 version:%@,%@",[WXApi getApiVersion],registerStatus?@"成功":@"失败");
    });
}

#pragma mark - web page content
- (void)shareWebPageContent:(WeiXinMessageInfo *)messageInfo     {
    if (self.fromWeixin) {
        [self respWebPageContent:messageInfo];
    } else {
        if (messageInfo.media != nil) {
            [self sendWebImageContent:messageInfo];
        }
        else
        {
            [self sendWebPageContent:messageInfo];
        }
    }
    // reset flag the way communicate with weixin
    self.fromWeixin = NO;
}
//分享链接
/*! @brief 发送请求到微信,等待微信返回onResp
 *
 * 函数调用后，会切换到微信的界面。第三方应用程序等待微信返回onResp。微信在异步处理完成后一定会调用onResp。可能发送的请求有
 * SendMessageToWXReq、SendAuthReq等。
 * @param req 具体的发送请求，在调用函数后，请自己释放。
 * 
 */
- (void)sendWebPageContent:(WeiXinMessageInfo *)messageInfo     {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = messageInfo.messageTitle;
    message.description = messageInfo.messageDescription;
    [message setThumbImage:messageInfo.messageThumbImage];
    WXWebpageObject *webContent = [WXWebpageObject object];
    NSLog(@"URL : %@",messageInfo.messageWebpageUrl);
    webContent.webpageUrl = messageInfo.messageWebpageUrl;
    //@"http://192.168.0.11/destination.html?latitude=31.232817&longitude=121.476059";//latitude=31.232817&longitude=121.476059&poiName=肯德基(和平店)&address=西藏中路290号&phoneNumber=021-33041267";//messageInfo.messageWebpageUrl;
    
    message.mediaObject = webContent;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = messageInfo.scene;
    [WXApi sendReq:req completion:nil];
}
//分享图片
- (void)sendWebImageContent:(WeiXinMessageInfo *)messageInfo     {
    WXMediaMessage *message =  [WXMediaMessage message];
    message.title = messageInfo.messageTitle;
    
    message.description = messageInfo.messageDescription;
    [message setThumbImage:messageInfo.messageThumbImage];
    WXImageObject * imageOb = [WXImageObject object];
    imageOb.imageData =messageInfo.media;
    message.mediaObject = imageOb;

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = messageInfo.scene;
    [WXApi sendReq:req completion:nil];
}

/*! @brief 收到微信onReq的请求，发送对应的应答给微信，并切换到微信界面
 *
 * 函数调用后，会切换到微信的界面。第三方应用程序收到微信onReq的请求，异步处理该请求，完成后必须调用该函数。可能发送的相应有
 * GetMessageFromWXResp、ShowMessageFromWXResp等。
 * @param resp 具体的应答内容，调用函数后，请自己释放
 */
- (void)respWebPageContent:(WeiXinMessageInfo *)messageInfo     {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = messageInfo.messageTitle;
    message.description = messageInfo.messageDescription;
    messageInfo.messageThumbImage = messageInfo.messageThumbImage;
    WXWebpageObject *webContent = [WXWebpageObject object];
    webContent.webpageUrl = messageInfo.messageWebpageUrl;
    message.mediaObject = webContent;
    GetMessageFromWXResp  *resp = [[GetMessageFromWXResp alloc] init];
    resp.bText = NO;
    resp.message = message;
    [WXApi sendResp:resp completion:nil];
}

#pragma mark - singleton
static WeiXinManager *wxManager = nil;
+ (WeiXinManager *)shareInstance     {
    @synchronized(self){
        if (wxManager == nil) {
            wxManager = [[self alloc] init];
        }
    }
    return wxManager;
}

- (id)init     {
    self = [super init];
    scenceFrind = WXSceneSession;
    scenceFrinds = WXSceneTimeline;
    self.fromWeixin = NO;
    return self;
}

+ (id)allocWithZone:(NSZone *)zone     {
    @synchronized(self)	{
        if (wxManager == nil) {
            wxManager = [super allocWithZone:zone];
             return wxManager;
        }
    }
    return nil;
}


@end
