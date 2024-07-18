//
//  SOSDealerSearchController.h
//  Onstar
//
//  Created by TaoLiang on 2018/1/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "ResponseDataObject.h"

@interface SOSDealerSearchController : SOSBaseViewController
@property (strong, nonatomic) NSArray <NNDealers *>*dealers;
@property (copy, nonatomic) NSString *searchKey;
@property (strong, nonatomic) NNDealers *selectedDealer;

@end
