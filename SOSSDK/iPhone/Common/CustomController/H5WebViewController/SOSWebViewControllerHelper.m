//
//  SOSWebViewControllerHelper.m
//  Onstar
//
//  Created by TaoLiang on 2017/12/13.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSWebViewControllerHelper.h"
#import "LoadingView.h"
#import "SOSCardUtil.h"
#import "ServiceController.h"
#import "SOSTripPOIVC.h"
#import "NavigateSearchVC.h"
#import "SOSNavigateTool.h"
#import "PurchaseModel.h"
#import "CarStatusDetailViewController.h"
#import "SOSMroService.h"
#import "SOSFlexibleAlertController.h"
#import "SOSForumShareView.h"
#import "SOSPhotoLibrary.h"
#import "WeiXinManager.h"
#import "WeiXinMessageInfo.h"
#import "SOSUserLocation.h"
#ifndef SOSSDK_SDK
#import "SOSIMApi.h"
#endif
#import <TZImagePickerController/TZImagePickerController.h>

#import "SOSTripModule.h"
@interface SOSWebViewControllerHelper ()
@property (weak, nonatomic) SOSWebViewController *vc;
@property (strong, nonatomic) NSDictionary *para;

@end

@implementation SOSWebViewControllerHelper

- (instancetype)initWithCustomeH5WebViewController:(SOSWebViewController *)vc {
    self = [super init];
    if (self) {
        _vc = vc;
    }
    return self;
}

-(void)pickPhotos:(NSInteger)maxNum{
    
    SOSWeakSelf(weakSelf);
    [SOSPhotoLibrary getAuthorizationStatusCallback:^(BOOL success) {
        [SOSPhotoLibrary getAVAuthorizationStatusCallback:^(BOOL aVAuthSuccess) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success && aVAuthSuccess) {
                    [weakSelf authedPickPhotos:maxNum];
                }else{
                    [Util showAlertWithTitle:@"无手机相册和拍照权限，请在设置中同意手机相册和拍照权限！" message:nil completeBlock:^(NSInteger buttonIndex) {
                        if(buttonIndex == 0){
                            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] ];
                        }
                    }];
                }
            });
        }];
    }];
}

-(void)authedPickPhotos:(NSInteger)maxNum{
    //todo
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxNum delegate:nil];
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowTakeVideo = NO;
//    [imagePickerVc setPhotoPickerPageUIConfigBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
//        NSLog(@"%@-%@-%@",collectionView,bottomToolBar,previewButton);
//        [previewButton setBackgroundColor:[UIColor redColor] forState:UIControlStateNormal];
//    }];
    //    imagePickerVc.allowPickingOriginalPhoto = self.allowPickingOriginalPhotoSwitch.isOn;
    //    imagePickerVc.allowPickingMultipleVideo = self.allowPickingMuitlpleVideoSwitch.isOn;
    //    imagePickerVc.showSelectedIndex = self.showSelectedIndexSwitch.isOn;
    //    imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    //    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        //        self->_selectedPhotos = [NSMutableArray arrayWithArray:photos];
        //        self->_selectedAssets = [NSMutableArray arrayWithArray:assets];
        //        self->_isSelectOriginalPhoto = isSelectOriginalPhoto;
        //        [self->_collectionView reloadData];
        //        self->_collectionView.contentSize = CGSizeMake(0, ((self->_selectedPhotos.count + 2) / 3 ) * (self->_margin + self->_itemWH));
        NSMutableArray * arr = [NSMutableArray array];
        for (UIImage *img  in photos) {
            
            [arr addObject:@{@"base64File":[[Util compressedImageFiles:img imageKB:400] base64Encoding],@"imgType":@"jpg"}];
        }
        NSString *textJS = [NSString stringWithFormat:@"getImagesCallback('%@')", [arr mj_JSONString]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.vc.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:nil];
            [Util hideLoadView];
        });
    }];
    [imagePickerVc setImagePickerControllerDidCancelHandle:^{
        NSMutableArray * arr = [NSMutableArray array];
       
        NSString *textJS = [NSString stringWithFormat:@"getImagesCallback('%@')", [arr mj_JSONString]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.vc.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:nil];
            [Util hideLoadView];
        });
    }];
    [self.vc presentViewController:imagePickerVc animated:YES completion:nil];
}


- (void)pickPhoto:(NSDictionary *)para {
    NSArray <NSString *> *types = para[@"type"];
    if (types.count > 1) {
        
        SOSWeakSelf(weakSelf);
        [SOSPhotoLibrary getAuthorizationStatusCallback:^(BOOL success) {
            [SOSPhotoLibrary getAVAuthorizationStatusCallback:^(BOOL aVAuthSuccess) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf showPickerPhone:success AVAuth:aVAuthSuccess param:para];
                });
            }];
        }];
        
        
    }else {
        if ([types.firstObject isEqualToString:@"camera"]) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [self presentImagePickerController:UIImagePickerControllerSourceTypeCamera para:para];
                
            }else {
                [Util toastWithMessage:@"抱歉，您的设备不支持拍照"];
            }
        }else {
            [self presentImagePickerController:UIImagePickerControllerSourceTypeSavedPhotosAlbum para:para];
        }
    }
}

-(void)showPickerPhone:(BOOL)isPhotoAuth AVAuth:(BOOL)avAuth param:(NSDictionary *)para{
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"选择图像" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if (isPhotoAuth) {
        UIAlertAction *ac0 = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self presentImagePickerController:UIImagePickerControllerSourceTypeSavedPhotosAlbum para:para];
        }];
        [ac addAction:ac0];
    }
    if (avAuth) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertAction *ac1 = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                dispatch_async_on_main_queue(^{
                    [self presentImagePickerController:UIImagePickerControllerSourceTypeCamera para:para];
                });
            }];
            [ac addAction:ac1];
        }
    }
    if (!isPhotoAuth && !avAuth) {
        
        [Util showAlertWithTitle:@"无手机相册和拍照权限，请在设置中同意手机相册和拍照权限！" message:nil completeBlock:^(NSInteger buttonIndex) {
            if(buttonIndex == 0){
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] ];
            }
        }];
        NSDictionary *responseData = @{@"errCode": @"2", @"errMsg": @"用户取消"};
        NSString *para2 = [responseData toJson];
        NSString *textJS = [NSString stringWithFormat:@"chooseImageCallback('%@', '%@')", para[@"reqid"], para2];
        dispatch_async_on_main_queue(^{
            [self.vc.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:nil];
        });
        return;
    }else if(isPhotoAuth && !avAuth){
        [Util toastWithMessage:@"无手机相册访问权限，请在设置中同意手机相册权限！"];
    }else if(!isPhotoAuth && avAuth){
        [Util toastWithMessage:@"无拍照访问权限，请在设置中同意拍照权限！"];
    }
    UIAlertAction *ac2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSDictionary *responseData = @{@"errCode": @"2", @"errMsg": @"用户取消"};
        NSString *para2 = [responseData toJson];
        NSString *textJS = [NSString stringWithFormat:@"chooseImageCallback('%@', '%@')", para[@"reqid"], para2];
        dispatch_async_on_main_queue(^{
            [self.vc.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:nil];
        });
    }];
    [ac addAction:ac2];
    [self.vc presentViewController:ac animated:YES completion:nil];
}

- (void)presentImagePickerController:(UIImagePickerControllerSourceType)sourceType para:(NSDictionary *)para {
    _para = para;
    // 跳转到相机或相册页面
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;
    [self.vc presentViewController:picker animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        [[LoadingView sharedInstance] startIn:self.vc.view];
        NSString *url = [MA8_1_H5_UPDATEFILE_URL stringByAppendingString:_para[@"funTag"]?:@""];
        NSString *fileName = [NSString stringWithFormat:@"iOS_%@.jpg", @([[NSDate date] timeIntervalSince1970]*1000 * 1000)];
        NSData *data = [Util compressedImageFiles:[info objectForKey:UIImagePickerControllerOriginalImage] imageKB:4000];
//        NSData *data = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 0.8);
//        if (data.length >= 1024 * 1024 * 2) {
//            NSDictionary *responseData = @{@"errCode": @"3", @"errMsg": @"超过2M"};
//            NSString *para2 = [responseData toJson];
//            dispatch_async_on_main_queue(^{
//                NSString *textJS = [NSString stringWithFormat:@"chooseImageCallback('%@', '%@')", _para[@"reqid"], para2];
//                [self.vc.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:nil];
//            });
//            return;
//        }
        SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"image/jpeg"];
        } successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            NSDictionary *dict = [Util dictionaryWithJsonString:responseStr];
            if ([dict[@"errCode"] integerValue] == 0) {
                NSDictionary *reqData = dict[@"reqData"] ? : @{};
                //传递给H5的第二个参数
                NSDictionary *responseData = @{@"errCode": @"0", @"errMsg": @"成功", @"images": @[reqData]};
                NSString *para2 = [responseData toJson];
                NSString *textJS = [NSString stringWithFormat:@"chooseImageCallback('%@', '%@')", _para[@"reqid"], para2];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.vc.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:nil];
                    [Util hideLoadView];
                });
            }
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            NSDictionary *responseData = @{@"errCode": @"1", @"errMsg": responseStr};
            NSString *para2 = [responseData toJson];
            dispatch_async_on_main_queue(^{
                NSString *textJS = [NSString stringWithFormat:@"chooseImageCallback('%@', '%@')", _para[@"reqid"], para2];
                [self.vc.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:nil];
                [Util hideLoadView];
                [Util showAlertWithTitle:nil message:NSLocalizedString(@"Upload_failed", nil) completeBlock:nil];
            });
        }];
        [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [operation setHttpMethod:@"POST"];
        [operation startUploadTask];
    }];
}

//-(void)pickPhotos:(NSInteger)maxNum{
//    //todo
//    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxNum delegate:nil];
//    imagePickerVc.allowPickingGif = NO;
//    imagePickerVc.allowTakeVideo = NO;
////    [imagePickerVc setPhotoPickerPageUIConfigBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
////        NSLog(@"%@-%@-%@",collectionView,bottomToolBar,previewButton);
////        [previewButton setBackgroundColor:[UIColor redColor] forState:UIControlStateNormal];
////    }];
//    //    imagePickerVc.allowPickingOriginalPhoto = self.allowPickingOriginalPhotoSwitch.isOn;
//    //    imagePickerVc.allowPickingMultipleVideo = self.allowPickingMuitlpleVideoSwitch.isOn;
//    //    imagePickerVc.showSelectedIndex = self.showSelectedIndexSwitch.isOn;
//    //    imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
//    //    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
//    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
//        //        self->_selectedPhotos = [NSMutableArray arrayWithArray:photos];
//        //        self->_selectedAssets = [NSMutableArray arrayWithArray:assets];
//        //        self->_isSelectOriginalPhoto = isSelectOriginalPhoto;
//        //        [self->_collectionView reloadData];
//        //        self->_collectionView.contentSize = CGSizeMake(0, ((self->_selectedPhotos.count + 2) / 3 ) * (self->_margin + self->_itemWH));
//        NSMutableArray * arr = [NSMutableArray array];
//        for (UIImage *img  in photos) {
//
//            [arr addObject:@{@"base64File":[[Util compressedImageFiles:img imageKB:400] base64Encoding],@"imgType":@"jpg"}];
//        }
//        NSString *textJS = [NSString stringWithFormat:@"getImagesCallback('%@')", [arr mj_JSONString]];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.vc.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:nil];
//            [Util hideLoadView];
//        });
//    }];
//    [imagePickerVc setImagePickerControllerDidCancelHandle:^{
//        NSMutableArray * arr = [NSMutableArray array];
//
//        NSString *textJS = [NSString stringWithFormat:@"getImagesCallback('%@')", [arr mj_JSONString]];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.vc.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:nil];
//            [Util hideLoadView];
//        });
//    }];
//    [self.vc presentViewController:imagePickerVc animated:YES completion:nil];
//
//}
//- (void)pickPhoto:(NSDictionary *)para {
//    NSArray <NSString *> *types = para[@"type"];
//    if (types.count > 1) {
//        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"选择图像" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//        UIAlertAction *ac0 = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self presentImagePickerController:UIImagePickerControllerSourceTypeSavedPhotosAlbum para:para];
//        }];
//        [ac addAction:ac0];
//        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//            UIAlertAction *ac1 = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                dispatch_async_on_main_queue(^{
//                    [self presentImagePickerController:UIImagePickerControllerSourceTypeCamera para:para];
//                });
//            }];
//            [ac addAction:ac1];
//        }
//        UIAlertAction *ac2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            NSDictionary *responseData = @{@"errCode": @"2", @"errMsg": @"用户取消"};
//            NSString *para2 = [responseData toJson];
//            NSString *textJS = [NSString stringWithFormat:@"chooseImageCallback('%@', '%@')", para[@"reqid"], para2];
//            dispatch_async_on_main_queue(^{
//                [self.vc.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:nil];
//            });
//        }];
//        [ac addAction:ac2];
//        [self.vc presentViewController:ac animated:YES completion:nil];
//    }else {
//        if ([types.firstObject isEqualToString:@"camera"]) {
//            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//                [self presentImagePickerController:UIImagePickerControllerSourceTypeCamera para:para];
//
//            }else {
//                [Util toastWithMessage:@"抱歉，您的设备不支持拍照"];
//            }
//        }else {
//            [self presentImagePickerController:UIImagePickerControllerSourceTypeSavedPhotosAlbum para:para];
//        }
//    }
//}
//
//- (void)presentImagePickerController:(UIImagePickerControllerSourceType)sourceType para:(NSDictionary *)para {
//    _para = para;
//    // 跳转到相机或相册页面
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.sourceType = sourceType;
//    [self.vc presentViewController:picker animated:YES completion:nil];
//
//}
//
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
//    [picker dismissViewControllerAnimated:YES completion:^{
//        [[LoadingView sharedInstance] startIn:self.vc.view];
//        NSString *url = [MA8_1_H5_UPDATEFILE_URL stringByAppendingString:_para[@"funTag"]?:@""];
//        NSString *fileName = [NSString stringWithFormat:@"iOS_%@.jpg", @([[NSDate date] timeIntervalSince1970]*1000 * 1000)];
//        NSData *data = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 0.8);
//        if (data.length >= 1024 * 1024 * 10) {
//            NSDictionary *responseData = @{@"errCode": @"3", @"errMsg": @"超过10M"};
//            NSString *para2 = [responseData toJson];
//            dispatch_async_on_main_queue(^{
//                NSString *textJS = [NSString stringWithFormat:@"chooseImageCallback('%@', '%@')", _para[@"reqid"], para2];
//                [self.vc.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:nil];
//            });
//            return;
//        }
//        SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//            [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"image/jpeg"];
//        } successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//            NSDictionary *dict = [Util dictionaryWithJsonString:responseStr];
//            if ([dict[@"errCode"] integerValue] == 0) {
//                NSDictionary *reqData = dict[@"reqData"] ? : @{};
//                //传递给H5的第二个参数
//                NSDictionary *responseData = @{@"errCode": @"0", @"errMsg": @"成功", @"images": @[reqData]};
//                NSString *para2 = [responseData toJson];
//                NSString *textJS = [NSString stringWithFormat:@"chooseImageCallback('%@', '%@')", _para[@"reqid"], para2];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.vc.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:nil];
//                    [Util hideLoadView];
//                });
//            }
//        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//            NSDictionary *responseData = @{@"errCode": @"1", @"errMsg": responseStr};
//            NSString *para2 = [responseData toJson];
//            dispatch_async_on_main_queue(^{
//                NSString *textJS = [NSString stringWithFormat:@"chooseImageCallback('%@', '%@')", _para[@"reqid"], para2];
//                [self.vc.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:nil];
//                [Util hideLoadView];
//                [Util showAlertWithTitle:nil message:NSLocalizedString(@"Upload_failed", nil) completeBlock:nil];
//            });
//        }];
//        [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
//        [operation setHttpMethod:@"POST"];
//        [operation startUploadTask];
//    }];
//}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        NSDictionary *responseData = @{@"errCode": @"2", @"errMsg": @"用户取消"};
        NSString *para2 = [responseData toJson];
        NSString *textJS = [NSString stringWithFormat:@"chooseImageCallback('%@', '%@')", _para[@"reqid"], para2];
        [self.vc.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:nil];
    }];

}
//    进入刷新车辆数据（cardata）
//    进入车辆定位（location）
//    进入远程遥控（remote）
//    进入兴趣点搜索（navi）
//    进入爱车评估（carevaluation）
//    进入闪灯鸣笛（light）
//    进入电子围栏设置（fence）
//    进入驾驶行为评分（drivingscore）
//    进入车况检测报告（carreport）
//    进入小O对话（littleo）
//    进入智能家居设置（smarthome）
//    进入保养建议（maintenance）
- (void)goFunPage:(NSString *)para {
    if ([para isEqualToString:@"cardata"]) {
        [SOSCardUtil routerToVehicleConditionFromPresentVC:self.vc.navigationController isPresentType:NO];
    }    else if ([para isEqualToString:@"location"]) {
        if (![[ServiceController sharedInstance] canPerformRequest:GET_VEHICLE_LOCATION_REQUEST]) {
            return;
        }
        SOSTripPOIVC *_viewCtrNavigate = [SOSTripPOIVC new];
        _viewCtrNavigate.mapType = MapTypeShowCarLocation;
        [_viewCtrNavigate refreshVehicleLocationButtonTapped];
        [self pushToVC:_viewCtrNavigate];
    }    else if ([para isEqualToString:@"remote"]) {
        [SOSCardUtil routerToRemoteControl:self.vc.navigationController];
    }    else if ([para isEqualToString:@"navi"]) {
        NavigateSearchVC *vc = [NavigateSearchVC new];
        [self pushToVC:vc];
    }    else if ([para isEqualToString:@"carevaluation"]) {
        [SOSCardUtil routerToCarReportH5];
    }    else if ([para isEqualToString:@"light"]) {
        [SOSCardUtil routerToRemoteControl:self.vc.navigationController];
    }    else if ([para isEqualToString:@"fence"]) {
        //[SOSNavigateTool showGeoPageFromVC:self.vc]; 网页去掉跳转电子围栏的入口
    }    else if ([para isEqualToString:@"drivingscore"]) {
        [SOSCardUtil routerToDrivingScoreH5:self.vc.navigationController];
    }    else if ([para isEqualToString:@"carreport"]) {
        [SOSCardUtil routerToVehicleDetectionReport];
    }    else if ([para isEqualToString:@"littleo"]) {
//        [Util toastWithMessage:@"小O正在升级中"];
        [[SOSMroService sharedMroService] startMroService];

    }    else if ([para isEqualToString:@"maintenance"]) {
        CarStatusDetailViewController *statusViewController = [[CarStatusDetailViewController alloc] initWithNibName:@"CarStatusDetailViewController" bundle:nil];
        statusViewController.gasStatus = [SOSVehicleVariousStatus gasStatus];
        statusViewController.oilStatus = [SOSVehicleVariousStatus oilStatus];
        statusViewController.pressureStatus = [SOSVehicleVariousStatus tirePressureStatus];
        statusViewController.mileage = [[CustomerInfo sharedInstance].oDoMeter floatValue];
        statusViewController.batteryStatus = [SOSVehicleVariousStatus batteryStatus];
        [self pushToVC:statusViewController];
    }
//    NSDictionary *responseData = @{@"errCode": @"0", @"errMsg": @"成功"};
//    NSString *jsPara = [responseData toJson];
//    NSString *textJS = [NSString stringWithFormat:@"goFunPage('%@')", jsPara];
//    [self.vc.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:nil];
}

- (void)pushToVC:(__kindof UIViewController *)vc {
    [self.vc.navigationController pushViewController:vc animated:YES];

}

- (void)hideNavBar:(BOOL)hide {
    if (self.vc.navigationController.navigationBar.isHidden != hide) {
        self.vc.fd_prefersNavigationBarHidden = hide;
        [self.vc.navigationController setNavigationBarHidden:hide animated:NO];
//        self.vc.extendedLayoutIncludesOpaqueBars = !hide;
    }
}

- (NSString *)sendVehicleConditionToHTML {
    
    NSDictionary *userInfo = @{
                               @"nickName": [CustomerInfo sharedInstance].tokenBasicInfo.nickName ? : @"",
                               @"idpUserId": [CustomerInfo sharedInstance].userBasicInfo.idpUserId ? : @"",
                               @"avatar": [CustomerInfo sharedInstance].userBasicInfo.preference.avatarUrl ? : @""
                               };
    
    
    
    NSDictionary *vehicleInfo = @{
                                  @"brand": [CustomerInfo sharedInstance].currentVehicle.brand ? : @"",
                                  @"modelDesc": [CustomerInfo sharedInstance].currentVehicle.modelDesc ? : @"",
                                  @"vehicleConditionCategory": @([Util updateVehicleConditionCategory]),
                                  @"vehicleEnergyCategory": [self getVehicleEnergyCategory],
                                  };
    
    
    NSMutableDictionary *dic = @{
                                 @"lastUpdateTime": @([self setupLastUpdateTime]),
                                 @"userInfo": userInfo,
                                 @"vehicleInfo": vehicleInfo,
                                 @"diagnosticResponse": [self setupDiagnosticResponse]
                                 }.mutableCopy;
    
    
    return dic.mj_JSONString;
}
-(void)helperExitMyDonateRefresh{
    [SOSCardUtil shareInstance].myDonateInfo = nil;
}
- (NSNumber *)getVehicleEnergyCategory {
    NSNumber *vehicleEnergyCategory = @0;
    if (Util.vehicleIsMy21) {
        vehicleEnergyCategory = @3;
        return vehicleEnergyCategory;
    }
    if ([Util vehicleIsPHEV]) {
        vehicleEnergyCategory = @1;
    }else if ([Util vehicleIsBEV]) {
        vehicleEnergyCategory = @2;
    }else {
        vehicleEnergyCategory = @0;
    }
    return vehicleEnergyCategory;
}

- (NSArray *)setupDiagnosticResponse {
    NSMutableArray *diagnosticResponse = @[].mutableCopy;
    
    //燃油余量
    if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.fuelTankInfoSupport) {
        NSDictionary *dic = @{
                              @"name": @"FUEL TANK INFO",
                              @"diagnosticElement": @[
                                      @{
                                          @"name": @"FUEL LEVEL",
                                          @"value": [CustomerInfo sharedInstance].fuelLavel
                                          }

                                      ]
                              };
        [diagnosticResponse addObject:dic];
    }
    
    //胎压
    if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.tirePressureSupport) {
        NSDictionary *dic = @{
                              @"name": @"TIRE PRESSURE",
                              @"diagnosticElement": @[
                                      @{
                                          @"name": @"TIRE PRESSURE LF",
                                          @"value": [CustomerInfo sharedInstance].tirePressureLF ? : @"",
                                          @"message": [CustomerInfo sharedInstance].tirePressureLFStatus ? : @""
                                          },
                                      @{
                                          @"name": @"TIRE PRESSURE RF",
                                          @"value": [CustomerInfo sharedInstance].tirePressureRF ? : @"",
                                          @"message": [CustomerInfo sharedInstance].tirePressureRFStatus ? : @""
                                          },
                                      @{
                                          @"name": @"TIRE PRESSURE LR",
                                          @"value": [CustomerInfo sharedInstance].tirePressureLR ? : @"",
                                          @"message": [CustomerInfo sharedInstance].tirePressureLRStatus ? : @""
                                          },
                                      @{
                                          @"name": @"TIRE PRESSURE RR",
                                          @"value": [CustomerInfo sharedInstance].tirePressureRR ? : @"",
                                          @"message": [CustomerInfo sharedInstance].tirePressureRRStatus ? : @""
                                          },
                                      @{
                                          @"name": @"TIRE PRESSURE PLACARD FRONT",
                                          @"value": [CustomerInfo sharedInstance].tirePressurePlacardFront ? : @"",
                                          },
                                      @{
                                          @"name": @"TIRE PRESSURE PLACARD REAR",
                                          @"value": [CustomerInfo sharedInstance].tirePressurePlacardRear ? : @"",
                                          },
                                      ]
                              };
        [diagnosticResponse addObject:dic];

    }
    
    //总里程
    if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.odoMeterSupport) {
        NSDictionary *dic = @{
                              @"name": @"ODOMETER",
                              @"diagnosticElement": @[
                                      @{
                                          @"name": @"ODOMETER",
                                          @"value": [CustomerInfo sharedInstance].oDoMeter ? : @""
                                          }
                                      
                                      ]
                              };
        [diagnosticResponse addObject:dic];

    }
    
    //机油寿命
    if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.oilLifeSupport) {
        NSDictionary *dic = @{
                              @"name": @"OIL LIFE",
                              @"diagnosticElement": @[
                                      @{
                                          @"name": @"OIL LIFE",
                                          @"value": [CustomerInfo sharedInstance].oilLife ? : @""
                                          }
                                      
                                      ]
                              };
        [diagnosticResponse addObject:dic];

    }
    
    if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.evChargeStateSupport) {
        NSDictionary *dic = @{
                              @"name": @"EV CHARGE STATE",
                              @"diagnosticElement": @[
                                      @{
                                          @"name": @"EV CHARGE STATE",
                                          @"value": [CustomerInfo sharedInstance].evChargeState ? : @""
                                          }
                                      
                                      ]
                              };
        [diagnosticResponse addObject:dic];

    }
    
    if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.evBatteryLevelSupport) {
        NSDictionary *dic = @{
                              @"name": @"EV BATTERY LEVEL",
                              @"diagnosticElement": @[
                                      @{
                                          @"name": @"EV BATTERY LEVEL",
                                          @"value": [CustomerInfo sharedInstance].batteryLevel ? : @""
                                          }
                                      
                                      ]
                              };
        [diagnosticResponse addObject:dic];
    }
    
    //电动续航里程  -综合续航里程
    if ([CustomerInfo sharedInstance].evRange) {
        NSDictionary *dic = @{
                              @"name": @"VEHICLE RANGE",
                              @"diagnosticElement": @[
                                      @{
                                          @"name": @"EV RANGE",
                                          @"value": [CustomerInfo sharedInstance].evRange ? : @""
                                          },
                                      @{
                                          @"name": @"TOTAL RANGE",
                                          @"value": [CustomerInfo sharedInstance].evTotleRange ? : @""
                                          }

                                      
                                      ]
                              };
        [diagnosticResponse addObject:dic];
    }
    
    //纯电车续航里程
    if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.bevBatteryRangeSupported) {
        NSDictionary *dic = @{
                              @"name": @"BATTERY RANGE",
                              @"diagnosticElement": @[
                                      @{
                                          @"name": @"BATTERY RANGE",
                                          @"value": [CustomerInfo sharedInstance].bevBatteryRange ? : @""
                                          }
                                      
                                      ]
                              };
        [diagnosticResponse addObject:dic];

    }
    
    //纯电车电池电量
    if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.bevBatteryStatusSupported) {
        NSDictionary *dic = @{
                              @"name": @"BATTERY STATUS",
                              @"diagnosticElement": @[
                                      @{
                                          @"name": @"BATTERY STATUS",
                                          @"value": [CustomerInfo sharedInstance].bevBatteryStatus ? : @""
                                          }
                                      
                                      ]
                              };
        [diagnosticResponse addObject:dic];
        
    }
    
    if (CustomerInfo.sharedInstance.currentVehicle.engineAirFilterMonitorStatusSupported) {
        NSDictionary *dic = @{
                              @"name": @"ENGINE AIR FILTER MONITOR STATUS",
                              @"diagnosticElement": @[
                                      @{
                                          @"name": @"ENGINE AIR FILTER MONITOR STATUS",
                                          @"value": [CustomerInfo sharedInstance].airFilterStatus ? : @""
                                          }
                                      
                                      ]
                              };
        [diagnosticResponse addObject:dic];
    }
    
    if (CustomerInfo.sharedInstance.currentVehicle.brakePadLifeSupported) {
        NSDictionary *dic = @{
            @"name": @"BRAKE PAD LIFE",
            @"diagnosticElement": @[
                    @{
                        @"name": @"BRAKE PAD LIFE FRONT",
                        @"value": [CustomerInfo sharedInstance].brakePadLifeFront ? : @""
                    },
                    @{
                        @"name": @"BRAKE PAD LIFE REAR",
                        @"value": [CustomerInfo sharedInstance].brakePadLifeRear ? : @""
                    }
                    
            ]
        };
        [diagnosticResponse addObject:dic];
    }
    
    return diagnosticResponse;
}


- (NSTimeInterval)setupLastUpdateTime {
    NSTimeInterval timeInterval = 0;
    NSString *year = [CustomerInfo sharedInstance].timeYear;
    NSString *month = [CustomerInfo sharedInstance].timeMonth;
    NSString *day = [CustomerInfo sharedInstance].timeDay;
    NSString *hour = [CustomerInfo sharedInstance].timeHour;
    NSString *minute = [CustomerInfo sharedInstance].timeMinute;
    NSString *second = [CustomerInfo sharedInstance].timeSecond;
    
    if (year && month && day && hour && minute && second) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy-MM-dd-HH-mm-ss";
        NSString *dateString = [NSString stringWithFormat:@"%@-%@-%@-%@-%@-%@", year, month, day, hour, minute, second];
        NSDate *date = [formatter dateFromString:dateString];
        timeInterval = [date timeIntervalSince1970];
    }
    return timeInterval * 1000;
}

- (void)showToast:(NSUInteger)flag text:(NSString *)text subText:(NSString *)subText {
    switch (flag) {
        case 0:
            [Util showErrorHUDWithStatus:text subStatus:subText];
            break;
        case 1:
            [Util showSuccessHUDWithStatus:text subStatus:subText];
            break;
        case 2:
            [Util showInfoHUDWithStatus:text subStatus:subText];
            break;
        case 3:
            [Util showHUDWithStatus:text subStatus:subText];
            break;
        default:
            NSLog(@"flag错误");
            break;
    }
}

- (void)dismissToast {
    [Util dismissHUD];
}


- (void)showAlertWithType:(NSUInteger)flag title:(NSString *)title message:(NSString *)message cancelBtn:(NSString *)cancelBtn otherBtns:(NSString *)otherBtns callback:(void (^)(NSUInteger))callback {
    NSArray<NSString *> *buttonStrs = [otherBtns componentsSeparatedByString:@","];
    NSMutableArray<SOSAlertAction *> *actions = @[].mutableCopy;
    SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil title:title message:message customView:nil preferredStyle:flag];
    SOSAlertAction *cancel = [SOSAlertAction actionWithTitle:cancelBtn style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
        callback(0);
    }];
    [actions addObject:cancel];
    [buttonStrs enumerateObjectsUsingBlock:^(NSString * _Nonnull string, NSUInteger idx, BOOL * _Nonnull stop) {
        SOSAlertAction *action = [SOSAlertAction actionWithTitle:string style:SOSAlertActionStyleDefault handler:^(SOSAlertAction * _Nonnull action) {
            //因为cancel是0，这里其他按钮要序号+1
            callback(idx + 1);
        }];
        [actions addObject:action];
    }];
    [vc addActions:actions];
    [vc show];
}

- (void)showForumShare:(NSString *)funcs sharedData:(NSString *)sharedData callback:(void (^)(NSUInteger))callback {
    NSDictionary *sharedDic = [Util dictionaryWithJsonString:sharedData];
    NSString *defaultPath = [[NSBundle SOSBundle] pathForResource:@"SOSForumShareMenus" ofType:@"json"];
    NSData *defaultData = [[NSData alloc] initWithContentsOfFile:defaultPath];
    NSDictionary *totalButtons = [NSJSONSerialization JSONObjectWithData:defaultData options:kNilOptions error:nil];
    
    NSArray<NSString *> *buttonIds = [funcs componentsSeparatedByString:@","];
    NSMutableArray *filterdBtns = @[].mutableCopy;
    
    [buttonIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = totalButtons[obj];
        if (dic) {
            [filterdBtns addObject:dic];
        }
    }];
    
    dispatch_async_on_main_queue(^{
        SOSForumShareView *shareView = [SOSForumShareView new];
        SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil
                                                                                        title:nil
                                                                                      message:nil
                                                                                   customView:shareView
                                                                               preferredStyle:SOSAlertControllerStyleActionSheet];
        shareView.btnClicked = ^(NSUInteger index, NSDictionary *button) {
            [vc dismissViewControllerAnimated:YES completion:^{
                switch ([button[@"funcId"] integerValue]) {
                    case 0:
                        [self shareForumTopicToIMScene:1 sharedDic:sharedDic];
                        break;
                    case 1:
                        [self shareForumTopicToIMScene:2 sharedDic:sharedDic];
                        break;
                    case 2:
                        [self shareForumTopicToWeixinScene:WXSceneSession sharedDic:sharedDic];
                        break;
                    case 3:
                        [self shareForumTopicToWeixinScene:WXSceneTimeline sharedDic:sharedDic];
                        break;
                    case 4:
                        [self saveForumScreensnap];
                        break;
                    case 5:
                        //举报直接回调给h5就行,客户端无操作
                        break;
                        
                    default:
                        break;
                }
                callback ? callback(index) : nil;

            }];
        };
        shareView.buttons = filterdBtns;

        
        SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:nil];
        
        [vc addActions:@[action]];
        [vc show];

    });
}

- (void)shareForumTopicToIMScene:(int)scene sharedDic:(NSDictionary *)sharedDic {
    if ([sharedDic[@"url"] length] <= 0) {
        [Util showErrorHUDWithStatus:@"分享出错，无分享地址"];
        return;
    }
#ifndef SOSSDK_SDK
    SOSIMMediaMessage *mediaMsg = [SOSIMMediaMessage message];
    mediaMsg.title = sharedDic[@"title"];
    mediaMsg.des = sharedDic[@"message"];

    SendMessageToSOSIMReq *imReq = [[SendMessageToSOSIMReq alloc] init];
//    imReq.bText = YES;
    imReq.messageType = SOSIMMessageTypeText;
    imReq.message = mediaMsg;
    imReq.text = sharedDic[@"url"];
    imReq.scene = scene;
    imReq.fromNav = self.vc.navigationController;
    [SOSIMApi sendReq:imReq];
#endif
}

- (void)shareForumTopicToWeixinScene:(enum WXScene)scene sharedDic:(NSDictionary *)sharedDic {
    if (![[WeiXinManager shareInstance] isWXAppInstalled]) {
        [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:[WXApi getWXAppInstallUrl]]];
        return;
    }
    if ([sharedDic[@"url"] length] <= 0) {
        [Util showErrorHUDWithStatus:@"分享出错，无分享地址"];
        return;
    }
    WeiXinMessageInfo *wxMessageInfo = [[WeiXinMessageInfo alloc] init];
    //set weixin show message
    wxMessageInfo.messageTitle = sharedDic[@"title"];
    wxMessageInfo.messageDescription = sharedDic[@"message"];
    wxMessageInfo.messageThumbImage = [UIImage imageNamed:@"Share_POI_APP_Icon"];
    wxMessageInfo.messageWebpageUrl = sharedDic[@"url"];

    wxMessageInfo.scene = scene;
    [[WeiXinManager shareInstance] shareWebPageContent:wxMessageInfo];

}

- (void)saveForumScreensnap {
    self.vc.navigationController.navigationBar.hidden = YES;
    UIScrollView *scrollView = [self.vc.webView getScrollViewOfWebview];
    //    [scrollView scrollToBottomAnimated:NO];
    scrollView.frame = scrollView.superview.frame;
    CGRect sourceFrame = scrollView.frame;
    CGRect snapshotFrame = scrollView.frame;
    
    snapshotFrame.size.height = self.vc.webView.wkWebView.scrollView.contentSize.height;
    scrollView.frame = snapshotFrame;
    [scrollView.superview layoutIfNeeded];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(scrollView.frame.size.width,scrollView.frame.size.height), NO, 0);     //设置截屏大小
    [scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //重新设置回原frame
    scrollView.frame=sourceFrame;
    [scrollView.superview layoutIfNeeded];
    self.vc.navigationController.navigationBar.hidden = NO;

    [SOSPhotoLibrary saveImage:image assetCollectionName:nil callback:^(BOOL success) {
        if (success) {
//            [Util showSuccessHUDWithStatus:@"图片已保存至手机相册"];
        }
    }];

}

- (void)pushNewWebViewControllerWithUrl:(NSString *)urlString {
    dispatch_async_on_main_queue(^{
        SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:urlString];
        [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
    });

}

- (void)goBannerPage:(NSString *)para {
    [SOSDaapManager sendActionInfo:LIFE_BANNER];
    NSData *jsonData = [para dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&err];
    if (err) {
        return;
    }
    //这里MJExtension似乎有bug,转换para会丢失中文内容
    NNBanner *banner = [NNBanner mj_objectWithKeyValues:para];
    banner.title = dic[@"title"];
    NSString *key = banner.title;
    NSLog(@"goto  %@", key);
    
    // 积分公益 Banner
    if ([banner.partnerId isEqualToString:@"welfare"]) {
        [SOSDaapManager sendActionInfo:SmartVehicle_IntegralCommonweal_Banner];
    }
    CustomNavigationController * pushedCon = [SOSUtil bannerClickShowController:banner];
    if (pushedCon) {
//        [[SOSReportService shareInstance] recordBannerActionWithFunctionIDMA80:SmartVehicle_banner objectID:bannerInfo.bannerID.stringValue];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:pushedCon animated:YES completion:nil];
    }

}

- (BOOL)showLoginVCAndShouldCheckVisitor:(BOOL)shouldCheckVisitor {
    // 调用 suit 成功
    if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
        // 用户是车主/司机/代理
        if ([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy]) {
            return YES;
            // 用户是访客
        }    else if ([SOSCheckRoleUtil isVisitor])     {
            if (shouldCheckVisitor) {
                [SOSCheckRoleUtil checkVisitorInPage:self.vc];
            }else {
                return YES;
            }
        }
        // 登录中
    }    else    {
        [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:self.vc withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
            
        }];
    }
    return NO;
}

- (void)getUserLocationCallback:(void (^)(SOSPOI * currentP))callback {
    
    
    [[SOSUserLocation sharedInstance] getLocationWithAccuarcy:kCLLocationAccuracyNearestTenMeters NeedReGeocode:YES isForceRequest:NO NeedShowAuthorizeFailAlert:YES success:^(SOSPOI *poi) {
        callback([poi copy]);
    } Failure:^(NSError *error) {
        callback(nil);
    }];
    
//    [[SOSUserLocation sharedInstance] getLocationSuccess:^(SOSPOI *userLocationPoi) {
//        callback(userLocationPoi);
//    } Failure:^(NSError *error) {
//        callback(nil);
//    }];
}
- (void)onstarRefreshFootPrint {
    [SOSTripModule refreshFootPrint];
}

@end
