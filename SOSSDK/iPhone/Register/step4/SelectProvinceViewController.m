//
//  SelectProvinceViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/9/1.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SelectProvinceViewController.h"
@interface SelectProvinceViewController ()<UITableViewDelegate,UITableViewDataSource>
{
//    SOSClientAcronymTransverterCollection * provinceInfoArray ;
   
    NSDictionary * selectedProvince;

}
@property (weak, nonatomic) IBOutlet UITableView *provinceTable;
@property(nonatomic,strong)NSIndexPath * selectTypePath;
@property(nonatomic,copy)NSString * currentProvince;

@end

@implementation SelectProvinceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.proTitle) {
         self.title = self.proTitle;
    }else{
         self.title = @"省/直辖市/自治区";
    }
   
    UIView * header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    header.backgroundColor = [SOSUtil onstarLightGray];
    self.provinceTable.tableFooterView = header;
    // Do any additional setup after loading the view from its nib.
//    if (!provinceInfoArray) {
//        SOSClientAcronymTransverterCollection * coll = [[SOSClientAcronymTransverterCollection alloc] init];
//        coll.transArr = [SOSClientAcronymTransverter mj_objectArrayWithKeyValuesArray:[Util provinceInfoArray]];
//        provinceInfoArray = coll;
//    }
    if (self.selectPro) {
        [Util showLoadingView];
        [OthersUtil getCityInfoByProvince:self.selectPro successHandler:^(NSArray *responseCity)
         {
             [Util hideLoadView];
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.proList = responseCity;
                 [self.provinceTable reloadData];
             });
         } failureHandler:^(NSString *responseStr, NSError *error) {
             [Util hideLoadView];
         }];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.proList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    NNProvinceInfoObject * item = ((NNProvinceInfoObject *)[self.proList objectAtIndex:indexPath.row]);
    cell.textLabel.text = item.value;
    if ([item.name isEqualToString:self.currentProvince]) {
        _selectTypePath = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedProvince = [self.proList objectAtIndex:indexPath.row];
    if (_selectTypePath.row != indexPath.row) {
        UITableViewCell * secell = [tableView cellForRowAtIndexPath:_selectTypePath];
        secell.accessoryType = UITableViewCellAccessoryNone;
        _selectTypePath = indexPath;
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    if (self.selectBlock) {
        SOSClientAcronymTransverter * ts = [[SOSClientAcronymTransverter alloc] init];
        ts.clientShow =((NNProvinceInfoObject *)[self.proList objectAtIndex:indexPath.row]).value;
        ts.serverSubstitute =((NNProvinceInfoObject *)[self.proList objectAtIndex:indexPath.row]).name;

        self.selectBlock(ts);
    }
    [SOSDaapManager sendActionInfo:register_city_confirm];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    NSLog(@"SelectProvinceViewController dealloc");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
