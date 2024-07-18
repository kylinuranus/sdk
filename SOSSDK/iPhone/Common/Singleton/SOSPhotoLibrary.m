//
//  SOSPhotoLibrary.m
//  Onstar
//
//  Created by TaoLiang on 2018/8/21.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSPhotoLibrary.h"
#import <Photos/Photos.h>


@implementation SOSPhotoLibrary


+ (void)saveImage:(UIImage *)image {
    [self saveImage:image assetCollectionName:@"安吉星"];
}

+ (void)saveImage:(UIImage *)image assetCollectionName:(NSString *)collectionName {
    [self saveImage:image assetCollectionName:collectionName callback:nil];
}

+ (void)saveImage:(UIImage *)image assetCollectionName:(NSString *)collectionName callback:(void (^)(BOOL success))callback {
    if (collectionName.length <= 0) {
        collectionName = @"安吉星";
    }
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
    switch (authorizationStatus) {
        case PHAuthorizationStatusNotDetermined: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    if (callback) {
                        callback(YES);
                    }
                    [self saveImage:image toCollectionWithName:collectionName];
                }
            }];
        }
            break;
        case PHAuthorizationStatusAuthorized:
            if (callback) {
                callback(YES);
            }
            [self saveImage:image toCollectionWithName:collectionName];
            break;
        default:
            if (callback) {
                callback(NO);
            }
            [Util showErrorHUDWithStatus:@"保存失败，无相册访问权限"];
            break;
    }
}

#pragma mark - private
+ (void)saveImage:(UIImage *)image toCollectionWithName:(NSString *)collectionName {
    
    // 1. 获取相片库对象
    PHPhotoLibrary *library = [PHPhotoLibrary sharedPhotoLibrary];
    
    // 2. 调用changeBlock
    [library performChanges:^{
        
        // 2.1 创建一个相册变动请求
        PHAssetCollectionChangeRequest *collectionRequest;
        
        // 2.2 取出指定名称的相册
        PHAssetCollection *assetCollection = [self getCurrentPhotoCollectionWithTitle:collectionName];
        
        // 2.3 判断相册是否存在
        if (assetCollection) { // 如果存在就使用当前的相册创建相册请求
            collectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        } else { // 如果不存在, 就创建一个新的相册请求
            collectionRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:collectionName];
        }
        
        // 2.4 根据传入的相片, 创建相片变动请求
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
        // 2.4 创建一个占位对象
        PHObjectPlaceholder *placeholder = [assetRequest placeholderForCreatedAsset];
        
        // 2.5 将占位对象添加到相册请求中
        [collectionRequest addAssets:@[placeholder]];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        [Util showSuccessHUDWithStatus:@"图片成功保存至相册"];
        // 3. 判断是否出错, 如果报错, 声明保存不成功
        if (error) {
//            [Util toastWithMessage:@"保存图片失败"];
        } else {
            
        }
    }];
}

+ (PHAssetCollection *)getCurrentPhotoCollectionWithTitle:(NSString *)collectionName {
    
    // 1. 创建搜索集合
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    // 2. 遍历搜索集合并取出对应的相册
    for (PHAssetCollection *assetCollection in result) {
        
        if ([assetCollection.localizedTitle containsString:collectionName]) {
            return assetCollection;
        }
    }
    
    return nil;
}


+(void)getAuthorizationStatusCallback:(void (^)(BOOL))photoCallback{
    
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
    
    if (authorizationStatus == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                if (photoCallback) {
                    photoCallback(YES);
                }
            }else{
                if (photoCallback) {
                    photoCallback(NO);
                }
            }
        }];
    }else if(authorizationStatus == PHAuthorizationStatusAuthorized){
        if (photoCallback) {
            photoCallback(YES);
        }
    }else{
        if (photoCallback) {
            photoCallback(NO);
        }
    }
}

+(void)getAVAuthorizationStatusCallback:(void (^)(BOOL))callback{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (callback) {
                callback(granted);
            }
        }];
    }else if(status == AVAuthorizationStatusAuthorized){
        if (callback) {
            callback(YES);
        }
    }else{
        if (callback) {
            callback(NO);
        }
    }
}

@end
