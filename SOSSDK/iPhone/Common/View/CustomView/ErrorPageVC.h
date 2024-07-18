//
//  ErrorPageViewController.h
//  Onstar
//
//  Created by Vicky on 16/3/1.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ErrorBackDelegate <NSObject>

- (void)errorPageBackTapped;
@end
@interface ErrorPageVC : UIViewController{
    NSString *_errorTitle;
    NSString *_imageName;
    NSString *_detail;
}
@property (strong, nonatomic) IBOutlet UIImageView *ImageView;
@property (strong, nonatomic) IBOutlet UILabel *labelDetail;
@property (nonatomic, assign) id<ErrorBackDelegate> delegate;

@property (nonatomic, copy) void(^refreshBlock)(void);

- (id)initWithErrorPage:(NSString *)title imageName:(NSString *)imageName detail:(NSString *)detail;
@end
