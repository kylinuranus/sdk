//
//  SOSTempLandingController.m
//  Onstar
//
//  Created by WQ on 2019/1/16.
//  Copyright © 2019年 Shanghai Onstar. All rights reserved.
//

#import "SOSTempLandingController.h"
#import "SOSNetworkOperation.h"


@interface SOSTempLandingController ()

@end

@implementation SOSTempLandingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    NSString *imgName = @"";
//    NSInteger h = SCREEN_HEIGHT;
//    switch (h) {
//        case 480:
//            imgName = @"default960";
//            break;
//        case 568:
//            imgName = @"default1136";
//            break;
//        case 667:
//            imgName = @"default1334";
//            break;
//        case 1792:
//            imgName = @"default1792";
//            break;
//        case 736:
//            imgName = @"default2208";
//            break;
//        case 812:
//            imgName = @"default2436";
//            break;
//        case 896:
//            imgName = @"default2688";
//            break;
//        default:
//            imgName = @"default1334";
//            break;
//    }
    
//
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.imageFromLaunchScreen];
//    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    imageView.userInteractionEnabled = NO;
//    imageView.clipsToBounds = YES;
//    [self.view addSubview:imageView];
////    UIView *view = [[NSBundle SOSBundle] loadNibNamed:@"LaunchScreen" owner:self options:nil][0];
//    
////    [self.view addSubview:view];
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make){
//        make.edges.equalTo(self.view);
//    }];
    

    
}


-(UIImage *)imageFromLaunchScreen{
//    return nil;
    NSString *UILaunchStoryboardName = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchStoryboardName"];
    if(UILaunchStoryboardName == nil){
//        XHLaunchAdLog(@"从 LaunchScreen 中获取启动图失败!");
        return nil;
    }
    UIViewController *LaunchScreenSb = [[UIStoryboard storyboardWithName:UILaunchStoryboardName bundle:nil] instantiateInitialViewController];
    if(LaunchScreenSb){
        UIView * view = LaunchScreenSb.view;
        // 加入到UIWindow后，LaunchScreenSb.view的safeAreaInsets在刘海屏机型才正常。
        UIWindow *containerWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        view.frame = containerWindow.bounds;
        [containerWindow addSubview:view];
        [containerWindow layoutIfNeeded];
        UIImage *image = [self imageFromView:view];
        containerWindow = nil;
        return image;
    }
//    XHLaunchAdLog(@"从 LaunchScreen 中获取启动图失败!");
    return nil;
}

-(UIImage*)imageFromView:(UIView*)view{
    //fix bug:https://github.com/CoderZhuXH/XHLaunchAd/issues/203
    if (CGRectIsEmpty(view.frame)) {
        return nil;
    }
    CGSize size = view.bounds.size;
    //参数1:表示区域大小 参数2:如果需要显示半透明效果,需要传NO,否则传YES 参数3:屏幕密度
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
//    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
//        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
//    }else{
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
//    }
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}



@end
