//
//  SOSTestAlertViewController.m
//  Onstar
//
//  Created by TaoLiang on 2018/12/24.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSTestAlertViewController.h"
#import "SOSFlexibleAlertController.h"
#import "SOSTestView.h"
#import "SOSTestMasonryView.h"
#import "SOSTestShareView.h"

@interface SOSTestAlertViewController ()
@property (strong, nonatomic) NSArray<NSArray<NSString *> *> *titles;

@end

@implementation SOSTestAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = NO;
    
    _titles = @[@[@"HUD-Loading-No-Label", @"HUD-Loading-Label", @"HUD-Success-SubLabel", @"HUD-Error", @"HUD-Info"], @[@"AlertView-顶部图片", @"AlertView-单行Label", @"AlertView-多行Label", @"AlertView-CustomView-XIB", @"AlertView-CustomView-Masonry", @"AlertView-CustomView-Frame", @"AlertView-Util工具类通用方法1", @"AlertView-Util工具类通用方法2", @"ActionSheet", @"ActionSheet-分享自定义View", @"ActionSheet-内容多行"]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _titles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titles[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = _titles[indexPath.section][indexPath.row];
    return cell;
}
#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:{
                
                SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:[UIImage imageNamed:@"Icon_60x60_bottom-bar_On_longOn_60x60"]
                                                                                                title:@"我是标题"
                                                                                              message:@"我是马杀鸡"
                                                                                           customView:nil
                                                                                       preferredStyle:SOSAlertControllerStyleAlert];
                
                SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"确定" style:SOSAlertActionStyleDefault handler:nil];
                [vc addActions:@[action]];
                [vc show];
                break;
            }
            case 1: {
                SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil
                                                                                                title:nil
                                                                                              message:@"我是马杀鸡,水电费第三方第三方第三方第三方"
                                                                                           customView:nil
                                                                                       preferredStyle:SOSAlertControllerStyleAlert];
                
                SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"确定" style:SOSAlertActionStyleDefault handler:nil];
                [vc addActions:@[action]];
                
                [vc show];
                break;
            }
            case 2: {
                SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil
                                                                                                title:@"我是长标题我是长标题我是长标题我是长标题我是长标题我是长标题"
                                                                                              message:@"我是马杀鸡我是马杀鸡我是马杀鸡我是马杀鸡我是马杀鸡我是马杀鸡我是马杀鸡"
                                                                                           customView:nil
                                                                                       preferredStyle:SOSAlertControllerStyleAlert];
                
                SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:nil];
                SOSAlertAction *action1 = [SOSAlertAction actionWithTitle:@"确定" style:SOSAlertActionStyleDefault handler:nil];
                
                [vc addActions:@[action1, action]];
                [vc show];
                
                break;
            }
            case 3: {
                //XIB
                SOSTestView *testView = [SOSTestView viewFromXib];
                SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:[UIImage imageNamed:@"Icon_60x60_bottom-bar_On_longOn_60x60"]
                                                                                                title:@"我是长标题我是长标题我是长标题我是长标题我是长标题我是长标题"
                                                                                              message:@"我是马杀鸡我是马杀鸡我是马杀鸡我是马杀鸡我是马杀鸡我是马杀鸡我是马杀鸡"
                                                                                           customView:testView
                                                                                       preferredStyle:SOSAlertControllerStyleAlert];
                
                SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"确定" style:SOSAlertActionStyleDestructive handler:nil];
                [vc addActions:@[action]];
                [vc show];
                break;
            }
            case 4: {
                //Masonry
                SOSTestMasonryView *view = [SOSTestMasonryView new];
                SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:[UIImage imageNamed:@"Icon_60x60_bottom-bar_On_longOn_60x60"]
                                                                                                title:@"我是长标题我是长标题我是长标题我是长标题我是长标题我是长标题"
                                                                                              message:@"我是马杀鸡我是马杀鸡我是马杀鸡我是马杀鸡我是马杀鸡我是马杀鸡我是马杀鸡"
                                                                                           customView:view
                                                                                       preferredStyle:SOSAlertControllerStyleAlert];
                SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"确定" style:SOSAlertActionStyleCancel handler:nil];
                [vc addActions:@[action]];
                [vc show];
                break;
            }
            case 5: {
                //Frame
                UIView *redView = [UIView new];
                redView.backgroundColor = [UIColor redColor];
                redView.height = 123.4;
                SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:[UIImage imageNamed:@"Icon_60x60_bottom-bar_On_longOn_60x60"]
                                                                                                title:@"我是长标题我是长标题我是长标题我是长标题我是长标题我是长标题"
                                                                                              message:@"我是马杀鸡我是马杀鸡我是马杀鸡我是马杀鸡我是马杀鸡我是马杀鸡我是马杀鸡"
                                                                                           customView:redView
                                                                                       preferredStyle:SOSAlertControllerStyleAlert];
                SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"确定" style:SOSAlertActionStyleCancel handler:nil];
                [vc addActions:@[action]];
                [vc show];
                break;
                
            }
            case 6: {
                [Util showAlertWithTitle:@"title" message:@"马杀鸡" completeBlock:^(NSInteger buttonIndex) {
                    NSLog(@"clicked")
                }];
                break;
            }
            case 7: {
                [Util showAlertWithTitle:@"title" message:@"马杀鸡" completeBlock:^(NSInteger buttonIndex) {
                    NSLog(@"%@ clicked", @(buttonIndex));
                } cancleButtonTitle:@"取消" otherButtonTitles:@"1", @"2", @"3", @"4", nil];
                break;
            }
            case 8: {
                SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil
                                                                                                title:nil
                                                                                              message:nil
                                                                                           customView:nil
                                                                                       preferredStyle:SOSAlertControllerStyleActionSheet];
                
                SOSAlertAction *actionCancel = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:nil];
                SOSAlertAction *action1 = [SOSAlertAction actionWithTitle:@"确定" style:SOSAlertActionStyleActionSheetDefault handler:^(SOSAlertAction * _Nonnull action) {
                    NSLog(@"confirm");
                }];
                SOSAlertAction *action2 = [SOSAlertAction actionWithTitle:@"确定1" style:SOSAlertActionStyleActionSheetDefault handler:nil];
                SOSAlertAction *action3 = [SOSAlertAction actionWithTitle:@"确定2" style:SOSAlertActionStyleActionSheetDefault handler:nil];
                
                [vc addActions:@[action1, action2, action3, actionCancel]];
                [vc show];
                break;
            }
            case 9: {
                SOSTestShareView *view = [SOSTestShareView viewFromXib];
                SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil
                                                                                                title:nil
                                                                                              message:nil
                                                                                           customView:view
                                                                                       preferredStyle:SOSAlertControllerStyleActionSheet];
                
                SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:nil];
                
                [vc addActions:@[action]];
                [vc show];
                break;
            }
            case 10: {
                SOSTestView *testView = [SOSTestView viewFromXib];
                SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:[UIImage imageNamed:@"Icon_60x60_bottom-bar_On_longOn_60x60"]
                                                                                                title:@"我是标题我是标题我是标题我是标题我是标题我是标题我是标题我是标题我是标题我是标题我是标题我是标题我是标题"
                                                                                              message:@"我是马杀鸡"
                                                                                           customView:testView
                                                                                       preferredStyle:SOSAlertControllerStyleActionSheet];
                
                SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:nil];
                SOSAlertAction *action1 = [SOSAlertAction actionWithTitle:@"确定" style:SOSAlertActionStyleActionSheetDefault handler:^(SOSAlertAction * _Nonnull action) {
                    NSLog(@"confirm");
                }];
                SOSAlertAction *action2 = [SOSAlertAction actionWithTitle:@"确定1" style:SOSAlertActionStyleActionSheetDefault handler:nil];
                
                [vc addActions:@[action, action1, action2]];
                [vc show];
                break;
            }
                
            default:
                break;
        }
    }else if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [Util showHUDWithStatus:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [Util dismissHUD];
                });
                break;
            case 1:
                [Util showHUDWithStatus:@"读取中"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [Util dismissHUD];
                });
                break;
            case 2:
                [Util showSuccessHUDWithStatus:@"你成功了" subStatus:@"我很长我很长我很长我很长我很长我很长我很长我很长我很长我很长我很长"];
                break;
            case 3:
                [Util showErrorHUDWithStatus:@"你错了你错了你错了你错了你错了你错了你错了你错了你错了你错了你错了你错了" subStatus:@"啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"];
                break;
            case 4:
                [Util showInfoHUDWithStatus:@"exclamation"];
                break;
            default:
                break;
        }
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"HUD";
    }else {
        return @"SOSFlexibleAlertController";
    }
}

@end
