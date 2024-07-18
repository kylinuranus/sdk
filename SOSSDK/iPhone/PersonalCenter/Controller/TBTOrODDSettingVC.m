
//
//  TBTOrODDSettingVC.m
//  Onstar
//
//  Created by huyuming on 16/2/17.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "TBTOrODDSettingVC.h"

@interface TBTOrODDSettingVC ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation TBTOrODDSettingVC     {
    NSIndexPath *selectIndexPath;
    NSIndexPath * pathOne;
    NSIndexPath * pathTwo;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.saveBtn.layer.cornerRadius = 3;
    self.saveBtn.layer.masksToBounds = YES;
    [self.saveBtn setTitle:NSLocalizedString(@"Geo_OK", nil) forState:0];
    self.title = NSLocalizedString(@"Navigation_options", nil);
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath     {
    NSInteger row = indexPath.row;
    static NSString *CellIdentifier = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];        
    }
    
    BOOL ODD_first = [[NSUserDefaults standardUserDefaults] boolForKey:IS_SENDING_ODD_First_REQUEST];

    if (row == 0) {
        cell.textLabel.text = NSLocalizedString(@"Send_TBT", nil);
        pathOne = indexPath;
        if (!ODD_first) {
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        cell.textLabel.text = NSLocalizedString(@"Send_ODD", nil);
        pathTwo = indexPath;
        
        if (!ODD_first) {
            
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.alpha = 0.5;
    //横线
    UIView *lineV= [[UIView alloc] initWithFrame:CGRectMake(15, SCALE_HEIGHT(53), SCREEN_WIDTH - 30, 1)];
    lineV.backgroundColor = [UIColor lightGrayColor];
    lineV.alpha = 0.5;
    [cell addSubview:lineV];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (pathOne.row == indexPath.row && pathOne.section == indexPath.section) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell *cellTwo = [tableView cellForRowAtIndexPath:pathTwo];
        cellTwo.accessoryType = UITableViewCellAccessoryNone;
    }else if (pathTwo.row == indexPath.row && pathTwo.section == indexPath.section){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell *cellTwo = [tableView cellForRowAtIndexPath:pathOne];
        cellTwo.accessoryType = UITableViewCellAccessoryNone;
    }
    selectIndexPath = indexPath;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section     {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCALE_HEIGHT(54);
}

- (IBAction)saveClick:(id)sender {

    if (pathOne.row == selectIndexPath.row && pathOne.section == selectIndexPath.section) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IS_SENDING_ODD_First_REQUEST];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [SOSDaapManager sendActionInfo:SS_sendtocarpreference_TBT];


    }else if (pathTwo.row == selectIndexPath.row && pathTwo.section == selectIndexPath.section) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_SENDING_ODD_First_REQUEST];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [SOSDaapManager sendActionInfo:SS_sendtocarpreference_ODD];


    }
    
    if (_saveSuccess) {
        _saveSuccess();
    }
    
    //[[SOSReportService shareInstance] recordActionWithFunctionID:(selectIndexPath.row == 0) ? Setting_PreferODD : Setting_PreferTBT];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
