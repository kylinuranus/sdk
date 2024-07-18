//
//  ISVINReaderPreViewViewController.h
//  ISVINReaderPreviewSDK
//
//  Created by Simon Liu on 2017/8/3.
//  Copyright © 2017年 xzliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ISOpenSDKFoundation/ISOpenSDKFoundation.h>


typedef void(^ConstructResourcesFinishHandler)(ISOpenSDKStatus status);
typedef void(^DetectCardFinishHandler)(int result, NSArray *borderPointsArray);
typedef void(^RecognizeCardFinishHandler)(NSDictionary *cardInfo);
typedef void(^ISVINReaderRecognizeCardFinishHandler)(NSDictionary *resultInfo);

typedef NS_ENUM(NSUInteger,ISHomeOrientationType)
{
    ISHomeOrientationTypeDown = 1,
    ISHomeOrientationTypeLeft = 2,
    ISHomeOrientationTypeRight = 3,
};


@interface ISVINReaderPreViewViewController : NSObject

+ (ISVINReaderPreViewViewController *)sharedISOpenSDKController;

- (ISOpenSDKCameraViewController *)cameraViewControllerWithAppkey:(NSString *)appKey subAppkey:(NSString *)subAppKey;

- (void)constructResourcesWithAppKey:(NSString *)appKey
                           subAppkey:(NSString *)subAppKey
                       finishHandler:(ConstructResourcesFinishHandler)handler;
/**
 *  VIN识别方法
 *  #param  sampleBuffer： 识别图像数据源
 *  #param  rect： 需要识别的图像位置
 *  #param detectCardFinishHandler 边缘检测的回调Block，result为检测结果，大于0表示检测成功，borderPointsArray为检测出的8个角点数组
 *  #param recognizeFinishHandler  识别成功的回调Block，只有在识别成功时才会回调，cardInfo里面包含了识别结果信息
 */
- (ISOpenSDKStatus)detectCardWithOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
                                           cardRect:(CGRect)rect//rect should be a golden rect for  that are shaped with its proportions
                            detectCardFinishHandler:(DetectCardFinishHandler)detectCardFinishHandler
                         recognizeCardFinishHandler:(ISVINReaderRecognizeCardFinishHandler)recognizeFinishHandler;

/**
 *  VIN识别方法
 *  #param  sampleBuffer： 识别图像数据源
 *  #param  homeOrientationType： 横竖屏切边标识：横竖屏依据Home键方位；ISHomeOrientationTypeDown=Home在下方；ISHomeOrientationTypeLeft=Home在左方；ISHomeOrientationTypRight=Home在右方
 *  #param  rect： 需要识别的图像位置
 *  #param detectCardFinishHandler 边缘检测的回调Block，result为检测结果，大于0表示检测成功，borderPointsArray为检测出的8个角点数组
 *  #param recognizeFinishHandler  识别成功的回调Block，只有在识别成功时才会回调，cardInfo里面包含了识别结果信息
 */
- (ISOpenSDKStatus)detectCardWithOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
                                homeOrientationType:(ISHomeOrientationType)homeOrientationType
                                           cardRect:(CGRect)rect//rect should be a golden rect for  that are shaped with its proportions
                            detectCardFinishHandler:(DetectCardFinishHandler)detectCardFinishHandler
                         recognizeCardFinishHandler:(ISVINReaderRecognizeCardFinishHandler)recognizeFinishHandler;


- (void)destructResources;

- (NSString *)getSDKVersion;

@end
