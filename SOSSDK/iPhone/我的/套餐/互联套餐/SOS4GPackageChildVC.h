//
//  SOS4GPackageChildVC.h
//  Onstar
//
//  Created by Coir on 11/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOS4GPackageChildVC : UIViewController

@property (nonatomic, copy) NSArray *packageInfoArray;

@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, strong) SOSWebView *contentWebView;

@end
