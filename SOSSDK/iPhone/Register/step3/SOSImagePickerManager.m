//
//  SOSImagePickerManager.m
//  Onstar
//
//  Created by lizhipan on 2017/8/23.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSImagePickerManager.h"


@implementation SOSImagePickerManager
{
    UIAlertController *sheet;
    UIImagePickerController *imagePickerController;
}
- (void)invokeImagePicker:(UIViewController *)sourceController
{
    self.sourceController = sourceController;
    // 判断是否支持相机
    //    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [sheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Choose_from_photos", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            // 跳转到相机或相册页面
            imagePickerController = [[UIImagePickerController alloc] init];
            [[imagePickerController navigationBar] setTintColor:[UIColor colorWithHexString:@"131329"]];
            [imagePickerController navigationBar].translucent = NO;
            
            NSDictionary *dict = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"131329"],
                                   NSFontAttributeName:[UIFont systemFontOfSize:17]};
            [[imagePickerController navigationBar] setTitleTextAttributes:dict];
            imagePickerController.delegate = self;
//            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = sourceType;
            [self performSelector:@selector(pushCamer) withObject:nil afterDelay:0];
            
        }]];
        
        [sheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Take_photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSUInteger sourceType = UIImagePickerControllerSourceTypeCamera;
            // 跳转到相机或相册页面
            imagePickerController = [[UIImagePickerController alloc] init];
            [[imagePickerController navigationBar] setTintColor:[UIColor colorWithHexString:@"131329"]];
            [imagePickerController navigationBar].translucent = NO;
            
            NSDictionary *dict = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"131329"],
                                   NSFontAttributeName:[UIFont systemFontOfSize:17]};
            [[imagePickerController navigationBar] setTitleTextAttributes:dict];
            imagePickerController.delegate = self;
//            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = sourceType;
            [self performSelector:@selector(pushCamer) withObject:nil afterDelay:0];
            
        }]];
        
        [sheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
    }
    else
    {
        sheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [sheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Choose_from_photos", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSUInteger sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            // 跳转到相机或相册页面
            imagePickerController = [[UIImagePickerController alloc] init];
            [[imagePickerController navigationBar] setTintColor:[UIColor colorWithHexString:@"131329"]];
            [imagePickerController navigationBar].translucent = NO;
            
            NSDictionary *dict = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"131329"],
                                   NSFontAttributeName:[UIFont systemFontOfSize:17]};
            [[imagePickerController navigationBar] setTitleTextAttributes:dict];
            imagePickerController.delegate = self;
//            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = sourceType;
            [self performSelector:@selector(pushCamer) withObject:nil afterDelay:0];
            
        }]];
        
        [sheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"点击警告");
        }]];
    }
    [self.sourceController presentViewController:sheet animated:YES completion:nil];
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [[UIApplication  sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [[UIApplication  sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)pushCamer{
    [self.sourceController presentViewController:imagePickerController animated:NO completion:^{}];
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info     {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        if (_selectBlock) {
            if (picker.allowsEditing) {
                _selectBlock([info objectForKey:UIImagePickerControllerEditedImage]);
            }
            else
            {
                _selectBlock([info objectForKey:UIImagePickerControllerOriginalImage]);
            }
        }
    }];
    //    //保存原始图片
    //    currentImage = [info objectForKey:UIImagePickerControllerEditedImage];
    //
    //    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    //    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    //    {
    //        ALAssetRepresentation *representation = [myasset defaultRepresentation];
    //        fileName = [representation filename];
    //        NSLog(@"fileName =====%@",fileName);
    //        if ([Util isBlankString:fileName]) {
    //            fileName = @"customIcon.png";
    //        }
    //
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            NSMutableDictionary *photoMutableDic = [[NSMutableDictionary alloc] init];
    //            [photoMutableDic setValue:currentImage forKey:@"currentImage"];
    //            [photoMutableDic setValue:fileName forKey:@"fileName"];
    //            [photoMutableArr addObject:photoMutableDic];
    //            [self.collectionView reloadData];
    //        });
    //    };
    //
    //    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    //    [assetslibrary assetForURL:imageURL resultBlock:resultblock failureBlock:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
