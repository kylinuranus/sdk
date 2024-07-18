//
//  SOSShortCutView.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/10.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseXibView.h"

@interface SOSShortCutView : SOSBaseXibView <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) SOSPOI *selectPOI;

@property (strong, nonatomic) UITableView *shortCutTable;
@property(nonatomic, strong) NSMutableArray  *shortCutArray;
@property(nonatomic, strong) NSMutableArray  *shortCutImageArray;

@end
