//
//  MePersonalInfoViewCell.m
//  Onstar
//
//  Created by Apple on 16/6/24.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "MePersonalInfoViewCell.h"
#import "CustomerInfo.h"
#import "UIButton+WebCache.h"
#import "LoadingView.h"
#import "AccountInfoUtil.h"
#import "SOSScanPhotoImage.h"
#import "SOSPhotoLibrary.h"
#import "SOSAvatarManager.h"
#import "SOSFlexibleAlertController.h"

@interface MePersonalInfoViewCell()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation MePersonalInfoViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _leftLabel.adjustsFontSizeToFitWidth = YES;
    _rightLabel.adjustsFontSizeToFitWidth = YES;
    self.photoBtn.clipsToBounds = YES;
    [self.photoBtn addTarget:self action:@selector(checkPhotos) forControlEvents:UIControlEventTouchUpInside];
    [self refreshAvatar];
}

- (void)userImageClicked {
    __weak __typeof(self)weakSelf = self;
    SOSFlexibleAlertController *ac = [SOSFlexibleAlertController alertControllerWithImage:nil title:@"选择图像" message:nil customView:nil preferredStyle:SOSAlertControllerStyleActionSheet];
    SOSAlertAction *acCancel = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
        [SOSDaapManager sendActionInfo:Portrait_cancel];
    }];
    SOSAlertAction *acAlbum = [SOSAlertAction actionWithTitle:@"从手机相册选择" style:SOSAlertActionStyleActionSheetDefault handler:^(SOSAlertAction * _Nonnull action) {
        [SOSDaapManager sendActionInfo:Portrait_album];
        [weakSelf showImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    SOSAlertAction *acCamara = [SOSAlertAction actionWithTitle:@"拍照" style:SOSAlertActionStyleActionSheetDefault handler:^(SOSAlertAction * _Nonnull action) {
        [SOSDaapManager sendActionInfo:Portrait_camera];
        [weakSelf showImagePickerController:UIImagePickerControllerSourceTypeCamera];
    }];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [ac addActions:@[acCancel, acAlbum, acCamara]];
    }else {
        [ac addActions:@[acCancel, acAlbum]];
    }
    [ac show];
}

- (void)showImagePickerController:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *pickerController = [UIImagePickerController new];
    pickerController.delegate = self;
    pickerController.allowsEditing = YES;
    pickerController.sourceType = sourceType;
    [self.viewController presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        //保存图片至相册，不需要的话注释
        [SOSPhotoLibrary saveImage:info[UIImagePickerControllerOriginalImage]];
    }
    UIImage *avatar = info[UIImagePickerControllerEditedImage];
    [self uploadAvatar:avatar];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private

- (void)refreshAvatar {
    @weakify(self);
    [[SOSAvatarManager sharedInstance] fetchAvatar:^(UIImage * _Nullable avatar, BOOL isPlacholder) {
        @strongify(self);
        if (avatar) {
            [self.photoBtn setBackgroundImage:avatar forState:UIControlStateNormal];
        }
    }];
}

/**
 *  查看头像
 */
- (void)checkPhotos {
    [SOSScanPhotoImage scanBigImageWithImageView:self.photoBtn];
    [SOSDaapManager sendActionInfo:Portrait_back];
}

- (void)uploadAvatar:(UIImage *)image {
    NSString *imageBase64Str = [UIImageJPEGRepresentation(image, 0.5) base64Encoding];
    __weak __typeof(self)weakSelf = self;
    [SOSDaapManager sendActionInfo:Portrait_update];
    [AccountInfoUtil updateHeadPhoto:imageBase64Str Suffix:@"JPEG" Success:^(NSDictionary *response){
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSString *urlString = response[@"data"][@"fullUrl"];
            if (urlString.isNotBlank) {
                [[SOSAvatarManager sharedInstance] saveImageToCache:image forURL:urlString];
            }
        }
        [weakSelf refreshAvatar];
        
        [Util showSuccessHUDWithStatus:@"上传成功"];
    } Failed:^{
        [Util showSuccessHUDWithStatus:@"上传失败"];
    }];
    
}

@end
