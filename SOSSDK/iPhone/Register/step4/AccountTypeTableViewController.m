//
//  AccountTypeTableViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/8/22.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "AccountTypeTableViewController.h"
#import "SOSRegisterInformation.h"
@interface AccountTypeTableViewController ()
{
    NSString * substitute;

}
@property (nonatomic,strong)SOSClientAcronymTransverterCollection * dataSourceArray;
@property(nonatomic,strong)NSIndexPath * selectTypePath;
@end

@implementation AccountTypeTableViewController
- (instancetype)initWithSource:(SOSClientAcronymTransverterCollection *)sourceArr dataSourceType:(SourceType)dataType
{
    self = [super init];
    if (self) {
        self.dataSourceArray = sourceArr;
        self.type = dataType;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [SOSUtil onstarLightGray];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    switch (self.type) {
        case SourceTypeGender:
        {
            substitute = [SOSRegisterInformation sharedRegisterInfoSingleton].gender;
            self.title = @"性别";
        }
            break;
        case SourceTypeVehicleType:
        {
            substitute = [SOSRegisterInformation sharedRegisterInfoSingleton].accountType;
            self.title = @"账户类型";
        }
            break;
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.transArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountTypeCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"accountTypeCell"];
        cell.separatorInset = UIEdgeInsetsMake(0, 40, 0, 0);
        cell.textLabel.font = [UIFont fontWithName:@"PingFang SC" size:16.0f];
        cell.textLabel.textColor = [UIColor colorWithRGB:0x59708A];
    }
    SOSClientAcronymTransverter * item = ((SOSClientAcronymTransverter *)[self.dataSourceArray.transArr objectAtIndex:indexPath.row]);
    cell.textLabel.text = item.clientShow ;
    if ([item.serverSubstitute isEqualToString:substitute]) {
        _selectTypePath = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_selectTypePath.row != indexPath.row) {
        UITableViewCell * secell = [tableView cellForRowAtIndexPath:_selectTypePath];
        secell.accessoryType = UITableViewCellAccessoryNone;
        _selectTypePath = indexPath;
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    SOSClientAcronymTransverter * item = ((SOSClientAcronymTransverter *)[self.dataSourceArray.transArr objectAtIndex:indexPath.row]);

    switch (self.type) {
        case SourceTypeGender:
        {
            [SOSRegisterInformation sharedRegisterInfoSingleton].gender = item.serverSubstitute;
        }
            break;
        case SourceTypeVehicleType:
        {
            [SOSRegisterInformation sharedRegisterInfoSingleton].accountType = item.serverSubstitute;
        }
            break;
        default:
            break;
    }
    if (self.selectBlock) {
        self.selectBlock([self.dataSourceArray.transArr objectAtIndex:indexPath.row]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
