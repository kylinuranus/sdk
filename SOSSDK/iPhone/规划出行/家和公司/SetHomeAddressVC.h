//
//  SetHomeAddressVC.h
//  Onstar
//
//  Created by Coir on 16/1/28.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseSearchTableVC.h"
#import "SOSHomeAndCompanyTool.h"

@interface SetHomeAddressVC : BaseSearchTableVC

@property (nonatomic, assign) SetHomeAddress_PageType pageType;

- (void)handlePoiResult:(SOSPOI *)tempPoi;

///获取家和公司Poi信息
- (void)getHomeAndCompanyPoiInfo;

@end
