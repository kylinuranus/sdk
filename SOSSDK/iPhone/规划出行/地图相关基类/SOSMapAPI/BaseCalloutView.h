//
//  BaseCalloutView.h
//  Onstar
//
//  Created by Coir on 16/8/2.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseCalloutView : UIView

@property (nonatomic, assign) POIType type;

@property (nonatomic, assign) BOOL isLBSMapMode;

@property (nonatomic, strong) NSNumber *totalCount;

@property (nonatomic, strong) NSString *nameStr;

@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, strong) UIImageView *rightArrowImgView;

- (void)configSelf;

@end
