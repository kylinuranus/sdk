//
//  SOSOnstarPackageChildVC.m
//  Onstar
//
//  Created by Coir on 5/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSOnstarPackageChildVC.h"
#import "SOSAdditionalServiceCell.h"
#import "SOSDataPackageUnOpenedCell.h"

@interface SOSOnstarPackageChildVC ()    <UITableViewDelegate, UITableViewDataSource>    {
    __weak IBOutlet UITableView *packageTableView;
    __weak IBOutlet UIView *noPackageBGView;
    
    NSString *cellName;
    
}

@end

@implementation SOSOnstarPackageChildVC

- (void)viewDidLoad {
    [super viewDidLoad];
    packageTableView.rowHeight = SOSPackageCellHeight;
    packageTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    cellName = @"SOSAdditionalServiceCell";
    switch (self.pageType) {
        case ChildVCType_CurrentPackage:
        case ChildVCType_UnUsedPackage:
            cellName = @"SOSAdditionalServiceCell";
            break;
        case ChildVCType_unUsed4GPackage:
            cellName = @"SOSDataPackageUnOpenedCell";
            break;
        default:
            break;
    }
    [packageTableView registerNib:[UINib nibWithNibName:cellName bundle:nil] forCellReuseIdentifier:cellName];
}

- (void)viewWillAppear:(BOOL)animated   {
    [super viewWillAppear:animated];
    noPackageBGView.hidden = (_packageInfoArray.count != 0);
}

- (void)setPackageInfoArray:(NSArray *)packageInfoArray     {
    _packageInfoArray = packageInfoArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        noPackageBGView.hidden = (packageInfoArray.count != 0);
        [packageTableView reloadData];
    });
}

#pragma mark - TableView Delegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section       {
    return _packageInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    NNPackagelistarray *package = _packageInfoArray[indexPath.row];
    switch (self.pageType) {
        case ChildVCType_CurrentPackage:
            ((SOSAdditionalServiceCell *)cell).cellType = ServiceCellType_Company;
            ((SOSAdditionalServiceCell *)cell).package = package;
            break;
        case ChildVCType_UnUsedPackage:
            ((SOSAdditionalServiceCell *)cell).cellType = ServiceCellType_Company_UnOpened;
            ((SOSAdditionalServiceCell *)cell).package = package;
            break;
        case ChildVCType_unUsed4GPackage:
            ((SOSDataPackageUnOpenedCell *)cell).package = package;
            break;
        default:
            break;
    }
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
