//
//  SliderBar.h
//  Onstar
//
//  Created by Joshua on 15-4-8.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaclulateDateModel.h"

@interface SliderBar : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *subTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *valueLabel;
@property (nonatomic, strong) IBOutlet UILabel *unitLabel;
@property (nonatomic, strong) IBOutlet UISlider *slider;

@property (nonatomic, assign) SEL sel;
@property (nonatomic, weak) id target;

- (IBAction)selectDidChange:(UISlider *)sender;

- (void)reloadWithCaclulateDateModel:(CaclulateDateModel *) model;

@end
