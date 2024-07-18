//
//  SOSActionNavigation.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/10.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseXibView.h"

@interface SOSActionNavigation : SOSBaseXibView
@property (weak, nonatomic) IBOutlet UIButton *ODDBtn;
@property (weak, nonatomic) IBOutlet UIButton *TBTBtn;
@property (weak, nonatomic) IBOutlet UIButton *ensureButton;
@property(nonatomic, strong) SOSPOI *poi;

@end
