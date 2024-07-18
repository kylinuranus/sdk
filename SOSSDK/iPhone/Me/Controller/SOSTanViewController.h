//
//  SOSTanViewController.h
//  Onstar
//
//  Created by Genie Sun on 2017/3/15.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    Gen10TrafficOver,
    gen9ServiceOver,
} ValidityType;

@interface SOSTanViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UILabel *tipLb;
@property(nonatomic, assign) ValidityType validity;

@end
