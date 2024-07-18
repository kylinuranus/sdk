//
//  SOSNotifyController.h
//  Onstar
//
//  Created by WQ on 2018/5/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSNotifyController : UIViewController

@property(nonatomic,assign)NSInteger unreadNum;
@property(nonatomic,assign)NSInteger totalNum;
@property(nonatomic,copy)NSString * notifyCategory;//Category
@property(nonatomic,copy)NSString * notifyTitle;//Title


- (void)go:(BOOL)isDragDown pageNum:(NSInteger)num;
- (void)cleanData;

@end
