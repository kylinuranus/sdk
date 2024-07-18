//
//  WeiXinMessageInfo.h
//  Onstar
//
//  Created by Onstar on 13-6-4.
//
//

#import <Foundation/Foundation.h>
@interface WeiXinMessageInfo : NSObject
@property(strong, nonatomic) NSString *messageTitle;
@property(strong, nonatomic) NSString *messageDescription;
@property(strong, nonatomic) UIImage *messageThumbImage;
@property(strong, nonatomic) NSString *messageWebpageUrl;
@property(readwrite, nonatomic)int  scene;
@property(strong, nonatomic) id media;

@property(strong, nonatomic) NSString * poiName;
@property(strong, nonatomic) NSString * latitude;
@property(strong, nonatomic) NSString * longitude;
@property(strong, nonatomic) NSString * address;
@property(strong, nonatomic) NSString * category;
@property(strong, nonatomic) NSString * province;
@property(strong, nonatomic) NSString * city;
@property(strong, nonatomic) NSString * phoneNumber;
@property(strong, nonatomic) NSString * aroundDescription;

@property (copy, nonatomic) NSString *shareClickRecordFunctionID;//点击分享报告ID
@property (copy, nonatomic) NSString *shareCancelRecordFunctionID;//分享取消报告ID
@property (copy, nonatomic) NSString *shareWechatRecordFunctionID;//分享微信报告ID
@property (copy, nonatomic) NSString *shareMomentsRecordFunctionID;//分享朋友圈报告ID
//@property (nonatomic,assign) BOOL isDriveScore;

@end
