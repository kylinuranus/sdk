//
//  SOSImagePickerManager.h
//  Onstar
//
//  Created by lizhipan on 2017/8/23.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^imageSelectBlock)(UIImage *selectImage);
//相册选择管理
@interface SOSImagePickerManager : NSObject<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property(nonatomic,copy)imageSelectBlock  selectBlock;
@property(nonatomic,weak)UIViewController * sourceController;
- (void)invokeImagePicker:(UIViewController *)sourceController;
@end
