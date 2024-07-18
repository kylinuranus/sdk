//
//  KeyListViewController.m
//  BlueTools
//
//  Created by onstar on 2018/6/13.
//  Copyright © 2018年 onstar. All rights reserved.
//

#import "KeyListViewController.h"
#import "SOSVKeys.h"
#import <BlePatacSDK/DBManager.h>
#import "KeyinfoViewController.h"
#import "UIView+Toast.h"

@interface KeyListViewController ()

@end
@implementation KeyListViewController
{
    NSArray *sourceAry;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[DBManager sharedInstance] managedObjectContext:bledbkey];
    sourceAry = [[DBManager sharedInstance] GetSomeKeyInDB:INT_MAX];
    if (sourceAry.count == 0) {
        [self.view makeToast:@"本地无钥匙" duration:2 position:CSToastPositionCenter];
    }
    NSLog(@"%@",sourceAry);
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [[DBManager sharedInstance] managedObjectContext:bledbkey];
    sourceAry = [[DBManager sharedInstance] GetSomeKeyInDB:INT_MAX];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return sourceAry.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid" forIndexPath:indexPath];
    
    Keyinfo *info = sourceAry[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"kno:%@",info.vkno];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Keyinfo *info = sourceAry[indexPath.row];
    
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Ble" bundle:[NSBundle SOSBundle]];
    KeyinfoViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"keyinfo"];
    vc.info = info;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
