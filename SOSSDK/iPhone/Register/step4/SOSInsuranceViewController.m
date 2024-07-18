//
//  SOSInsuranceViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/9/12.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSInsuranceViewController.h"

@interface SOSInsuranceViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    NSArray * insuranceArr;
    NSString * selectInsurance;
    UITextField * inputInsuranceField;
    BOOL isInputInsurance;
}
@property(nonatomic,strong)NSIndexPath * selectTypePath;
@end
const CGFloat cellHeight = 55.0f;
@implementation SOSInsuranceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isInputInsurance = NO;
    self.title = @"选择保险公司";
    insuranceArr = [Util insuranceInfoArray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"OK", nil)style:UIBarButtonItemStylePlain target:self action:@selector(confirm)];
    switch (self.pageType) {
        case SOSInsuranceVCPageType_OwnerLife:
            self.backRecordFunctionID = Insurance_back;
            break;
        case SOSInsuranceVCPageType_BBWC:
            self.backRecordFunctionID = Vehicleinfo_insurance_back;
            break;
        case SOSInsuranceVCPageType_VehicleInfo:
            self.backRecordFunctionID = Vehicleinfo_insurance_back;
            break;
    }
    _insuranceTable.backgroundColor = SOSUtil.onstarLightGray;
    _insuranceTable.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
}

- (void)confirm	{
    if (self.needUpdateInfo) {
        //如果需要调用接口更新保险公司
        if (isInputInsurance) {
            [self updateInsuranceInfo:inputInsuranceField.text];
        }	else	{
            [self updateInsuranceInfo:selectInsurance];
        }
    }	else	{
        NSString *funcIDStr = @"";
        switch (self.pageType) {
            case SOSInsuranceVCPageType_OwnerLife:
                funcIDStr = Insurance_Editnsurer_Save;
                break;
            case SOSInsuranceVCPageType_BBWC:
                funcIDStr = Psn_BBWC_insuranceco_save;
                break;
            case SOSInsuranceVCPageType_VehicleInfo:
                funcIDStr = Vehicleinfo_insurance_confirm;
                break;
        }
        [SOSDaapManager sendActionInfo:funcIDStr];
        if (isInputInsurance) {
            if (inputInsuranceField.text.isNotBlank) {
                if (self.selectInsurenceBlock) {
                    self.selectInsurenceBlock(inputInsuranceField.text);
                    NSString *funcIDStr = @"";
                    switch (self.pageType) {
                        case SOSInsuranceVCPageType_OwnerLife:
//                            funcIDStr = insuranceco_Others;
                            break;
                        case SOSInsuranceVCPageType_BBWC:
                            funcIDStr = Psn_BBWC_insuranceco_Others;
                            break;
                        case SOSInsuranceVCPageType_VehicleInfo:
                            funcIDStr = Vehicleinfo_insurance_Others;
                            break;
                    }
                    [SOSDaapManager sendActionInfo:funcIDStr];
                    
                }
            }	else	[Util toastWithMessage:@"请输入保险公司名称"];
        }	else	{
            if (self.selectInsurenceBlock) {
                self.selectInsurenceBlock(selectInsurance);
                if ([selectInsurance isEqualToString:@"平安车险"]) {
                    switch (self.pageType) {
                        case SOSInsuranceVCPageType_OwnerLife:
//                            funcIDStr = Insurance_Editnsurer_Save;
                            break;
                        case SOSInsuranceVCPageType_BBWC:
                            funcIDStr = Psn_BBWC_insuranceco_PINGAN;
                            break;
                        case SOSInsuranceVCPageType_VehicleInfo:
                            funcIDStr = Vehicleinfo_insurance_PINGAN;
                            break;
                    }
                    [SOSDaapManager sendActionInfo:funcIDStr];
                }	else if ([selectInsurance isEqualToString:@"中国人保车险"]){
                    switch (self.pageType) {
                        case SOSInsuranceVCPageType_OwnerLife:
                            //funcIDStr = Insurance_Editnsurer_Save;
                            break;
                        case SOSInsuranceVCPageType_BBWC:
                            funcIDStr = Psn_BBWC_insuranceco_PICC;
                            break;
                        case SOSInsuranceVCPageType_VehicleInfo:
                            funcIDStr = Vehicleinfo_insurance_PICC;
                            break;
                    }
                    [SOSDaapManager sendActionInfo:funcIDStr];
                }	else if ([selectInsurance isEqualToString:@"太平洋车险"]){
                    switch (self.pageType) {
                        case SOSInsuranceVCPageType_OwnerLife:
                            //funcIDStr = Insurance_Editnsurer_Save;
                            break;
                        case SOSInsuranceVCPageType_BBWC:
                            funcIDStr = Psn_BBWC_insuranceco_PCPIC;
                            break;
                        case SOSInsuranceVCPageType_VehicleInfo:
                            funcIDStr = Vehicleinfo_insurance_PCPIC;
                            break;
                    }
                    [SOSDaapManager sendActionInfo:Psn_BBWC_insuranceco_PCPIC];
                    
                }
            }
        }
    }
}

- (void)updateInsuranceInfo:(NSString *)insurance	{
    if ([insurance isEqualToString:self.sourceInsurance]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin&&[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin.length>0){
        
        NNVehicleInfoRequest *request = [[NNVehicleInfoRequest alloc]init];
        [request setAccountID:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId];
        [request setVin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
        [request setInsuranceComp:insurance];
        NSString *url = [BASE_URL stringByAppendingFormat:VEHICLE_INFO_URL,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];

        [Util showLoadingView];
        SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:[request mj_JSONString] successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            [Util hideLoadView];
            dispatch_async(dispatch_get_main_queue(), ^{
                !_selectInsurenceBlock ? : _selectInsurenceBlock(insurance);
                [self.navigationController popViewControllerAnimated:YES];
            });
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
            [Util showAlertWithTitle:nil message:dic[@"description"] completeBlock:nil];
            [Util hideLoadView];
        }];
        [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [operation setHttpMethod:@"PUT"];
        [operation start];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return insuranceArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)([[[insuranceArr objectAtIndex:section] objectForKey:@"Companies"] performSelector:@selector(count)]);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section	{
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section	{
    return 34.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section	{
    
    NSString * reuseID = @"header_cell";
    UITableViewHeaderFooterView * header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseID];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:reuseID];
        UIView *tag = UIView.new;
        tag.backgroundColor = SOSUtil.defaultLabelLightBlue;
        [header addSubview:tag];
        [tag mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(header);
            make.centerY.equalTo(header);
            make.height.equalTo(@16);
            make.width.equalTo(@4);
        }];
        UIView *lineTop = UIView.new;
        lineTop.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:244/255.0 alpha:1.0];
        [header addSubview:lineTop];
        [lineTop mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.right.top.equalTo(header);
            make.height.equalTo(@1);
        }];
        UIView *lineBottom = UIView.new;
        lineBottom.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:244/255.0 alpha:1.0];
        [header addSubview:lineBottom];
        [lineBottom mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.bottom.right.equalTo(header);
            make.height.equalTo(@1);
        }];
    }
    [header.textLabel setText:[[insuranceArr objectAtIndex:section] objectForKey:@"Title"]];
    return header;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[SOSUtil defaultLabelLightBlue]];
    [header.textLabel setFont:[UIFont systemFontOfSize:14.0f]];
    header.contentView.backgroundColor = UIColor.whiteColor;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == insuranceArr.count -1) {
        //输入框cell
        UITableViewCell *cell ;
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"inputCell"];
        
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.textLabel.textColor = [SOSUtil defaultLabelBlack];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!inputInsuranceField) {
            inputInsuranceField = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, tableView.frame.size.width - 180, cellHeight)];
            inputInsuranceField.delegate = self;
            inputInsuranceField.placeholder = @"请输入保险公司名称";
            inputInsuranceField.font = [UIFont systemFontOfSize:14];
            inputInsuranceField.textColor = [SOSUtil onstarTextFontColor];
        }
        [cell.contentView addSubview:inputInsuranceField];
        cell.textLabel.text = [[[insuranceArr objectAtIndex:indexPath.section] objectForKey:@"Companies"] objectAtIndex:indexPath.row];

        return cell;
    }	else	{
        static NSString *identifier = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.textLabel.font = [UIFont fontWithName:@"PingFang SC" size:15.0f];
            cell.textLabel.textColor = [SOSUtil defaultLabelBlack];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (_selectTypePath) {
            if ([_selectTypePath isEqual:indexPath]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }	else	{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        cell.textLabel.text = [[[insuranceArr objectAtIndex:indexPath.section] objectForKey:@"Companies"] objectAtIndex:indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath		{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqualToString:@"其 他"]) {
        [inputInsuranceField becomeFirstResponder];
        isInputInsurance = YES;
    }	else	{
        selectInsurance = cell.textLabel.text;
        isInputInsurance = NO;
    }
    if (_selectTypePath != indexPath) {
        UITableViewCell * secell = [tableView cellForRowAtIndexPath:_selectTypePath];
        secell.accessoryType = UITableViewCellAccessoryNone;
        _selectTypePath = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }	else	{
        _selectTypePath = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

#pragma mark -  textField Protol
- (void)textFieldDidBeginEditing:(UITextField *)textField	{
    //首先去除选中的checkmark状态
    UITableViewCell * secell = [self.insuranceTable cellForRowAtIndexPath:_selectTypePath];
    secell.accessoryType = UITableViewCellAccessoryNone;
    //然后设置field所在cell的checkmark状态
    UITableViewCell * cell = (UITableViewCell *)textField.superview.superview;
    _selectTypePath = [self.insuranceTable indexPathForCell:cell];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    isInputInsurance = YES;
}

@end
