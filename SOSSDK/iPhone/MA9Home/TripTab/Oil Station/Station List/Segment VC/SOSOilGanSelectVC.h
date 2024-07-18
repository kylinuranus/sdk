//
//  SOSOilGanSelectVC.h
//  Onstar
//
//  Created by Coir on 2019/9/1.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSOilGanSelectVC : UIViewController

@property (nonatomic, copy) SOSOilStation *station;
@property (nonatomic, strong) NSArray <SOSOilStation *>*oilInfoArray;

@end

NS_ASSUME_NONNULL_END
