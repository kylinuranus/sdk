//
//  SetDepartTimeTableView.m
//  Test
//
//  Created by Coir on 15/12/8.
//  Copyright © 2015年 lyj. All rights reserved.
//

#import "SetDepartTimeTableView.h"
#import "DatePickerBGView.h"
#import "DepartTimeCell.h"
#import "CustomerInfo.h"
#import "SOSCarSecretaryDatePicker.h"
@interface SetDepartTimeTableView ()  <UITableViewDataSource, UITableViewDelegate>  {
    int selectIndex;

}
@property (strong, nonatomic) SOSCarSecretaryDatePicker *datePicker;
@end

@implementation SelectionData

@end

@implementation SetDepartTimeTableView

- (instancetype)init    {
    self = [super init];
    if (self) {
        [self configSelf];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame     {
    self = [super initWithFrame:frame];
    if (self) {
        [self configSelf];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style   {
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self configSelf];
    }
    return self;
}


- (void)configSelf  {
    self.delegate = self;
    self.dataSource = self;
    self.scrollEnabled = NO;
    selectIndex = 999;
    //    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    self.selectionDataArray = [NSMutableArray arrayWithObjects:[SelectionData new], [SelectionData new], [SelectionData new], [SelectionData new], [SelectionData new], [SelectionData new], [SelectionData new], nil];
    
    self.scheduleTime = [CustomerInfo sharedInstance].scheduleList;//@[@{@"dayOfWeek":@"FRI",@"departTime":@"07:00:00"},@{@"dayOfWeek":@"MON",@"departTime":@"07:00:00"},@{@"dayOfWeek":@"SAT",@"departTime":@"07:00:00"},@{@"dayOfWeek":@"SUN",@"departTime":@"07:00:00"},@{@"dayOfWeek":@"THU",@"departTime":@"07:00:00"},@{@"dayOfWeek":@"TUE",@"departTime":@"07:00:00"},@{@"dayOfWeek":@"WED",@"departTime":@"07:00:00"}];
    if (self.scheduleTime.count == 7) {
        SelectionData *data0,*data1,*data2,*data3,*data4,*data5,*data6;
        for(int i = 0; i < self.scheduleTime.count; i ++){
            NNSchedule *day =  [NNSchedule mj_objectWithKeyValues:[self.scheduleTime objectAtIndex:i]];//(NNSchedule *)[self.scheduleTime objectAtIndex:i];
            if([day.dayOfWeek isEqualToString:WEEK_DAY0]){
                NSArray *splitArray= [day.departTime componentsSeparatedByString:@":"];
                data0 = [[SelectionData alloc]init];
                NSString *hour = [splitArray objectAtIndex:0];
                NSString *min = [splitArray objectAtIndex:1];
                data0.selectHour = hour;
                data0.selectMin = min;
            }else if([day.dayOfWeek isEqualToString:WEEK_DAY1]){
                NSArray *splitArray= [day.departTime componentsSeparatedByString:@":"];
                data1 = [[SelectionData alloc]init];
                NSString *hour = [splitArray objectAtIndex:0];
                NSString *min = [splitArray objectAtIndex:1];
                data1.selectHour = hour;
                data1.selectMin = min;
            }
            else if([day.dayOfWeek isEqualToString:WEEK_DAY2]){
                NSArray *splitArray= [day.departTime componentsSeparatedByString:@":"];
                data2 = [[SelectionData alloc]init];
                NSString *hour = [splitArray objectAtIndex:0];
                NSString *min = [splitArray objectAtIndex:1];
                data2.selectHour = hour;
                data2.selectMin = min;
            }
            else if([day.dayOfWeek isEqualToString:WEEK_DAY3]){
                NSArray *splitArray= [day.departTime componentsSeparatedByString:@":"];
                data3 = [[SelectionData alloc]init];
                NSString *hour = [splitArray objectAtIndex:0];
                NSString *min = [splitArray objectAtIndex:1];
                data3.selectHour = hour;
                data3.selectMin = min;
            }
            else if([day.dayOfWeek isEqualToString:WEEK_DAY4]){
                NSArray *splitArray= [day.departTime componentsSeparatedByString:@":"];
                data4 = [[SelectionData alloc]init];
                NSString *hour = [splitArray objectAtIndex:0];
                NSString *min = [splitArray objectAtIndex:1];
                data4.selectHour = hour;
                data4.selectMin = min;
            }
            else if([day.dayOfWeek isEqualToString:WEEK_DAY5]){
                NSArray *splitArray= [day.departTime componentsSeparatedByString:@":"];
                data5 = [[SelectionData alloc]init];
                NSString *hour = [splitArray objectAtIndex:0];
                NSString *min = [splitArray objectAtIndex:1];
                data5.selectHour = hour;
                data5.selectMin = min;
            }
            else if([day.dayOfWeek isEqualToString:WEEK_DAY6]){
                NSArray *splitArray= [day.departTime componentsSeparatedByString:@":"];
                data6 = [[SelectionData alloc]init];
                NSString *hour = [splitArray objectAtIndex:0];
                NSString *min = [splitArray objectAtIndex:1];
                data6.selectHour = hour;
                data6.selectMin = min;
            }
            
        }
        self.selectionDataArray = [NSMutableArray arrayWithObjects:data0, data1, data2, data3, data4, data5, data6, nil];
    }
    
    
    SOSCarSecretaryDatePicker *datePicker = [SOSCarSecretaryDatePicker viewFromXib];
    _datePicker = datePicker;
    
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView   {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return 55.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DepartTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DepartTimeCell"];
    if (!cell) {
        cell = [[NSBundle SOSBundle] loadNibNamed:@"DepartTimeCell" owner:self options:nil][0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.titleLabel.text = @[NSLocalizedString(@"day_0", nil), NSLocalizedString(@"day_1", nil), NSLocalizedString(@"day_2", nil), NSLocalizedString(@"day_3", nil), NSLocalizedString(@"day_4", nil), NSLocalizedString(@"day_5", nil), NSLocalizedString(@"day_6", nil)][indexPath.row];
    NSString * hour = ((SelectionData *)self.selectionDataArray[indexPath.row]).selectHour;
    if (!hour) {
        hour = @"00";
    }
    NSString * min = ((SelectionData *)self.selectionDataArray[indexPath.row]).selectMin;
    if (!min) {
        min = @"00";
    }
    cell.labelTime.text = [NSString stringWithFormat:@"%@:%@", hour,min];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath     {
//    if (indexPath.row)      return;
//    if (indexPath.section == selectIndex)         {
//        selectIndex = 999;
//        [self reloadData];
//    }   else    {
//        selectIndex = (int)indexPath.section;
//        [self reloadData];
//    }
     DepartTimeCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    _datePicker.title = cell.titleLabel.text;
    _datePicker.pickerType = SOSDatePickerTypeHM;
    _datePicker.hours =@[@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23"];
    _datePicker.minutes = @[@"00", @"15", @"30", @"45"];
    NSString * hour = ((SelectionData *)self.selectionDataArray[indexPath.row]).selectHour;
       if (!hour) {
           hour = @"00";
       }
       NSString * min = ((SelectionData *)self.selectionDataArray[indexPath.row]).selectMin;
       if (!min) {
           min = @"00";
       }
//    @autoreleasepool {
//        NSObject * ob = [NSObject al]
//    }
    _datePicker.selectedHourMinute = [NSString stringWithFormat:@"%@/%@",hour,min];
    @weakify(self);
    _datePicker.picked = ^(NSString *result) {
        @strongify(self);
        NSArray * hm = [result componentsSeparatedByString:@"/"];
        SelectionData *tempData = self.selectionDataArray[indexPath.row];
        tempData.selectHour = hm[0];
        tempData.selectMin = hm[1];
        [self reloadRowAtIndexPath:indexPath withRowAnimation:0];
       };
    [_datePicker show];
}

//- (void)updateAndSave:(NSString *)result indexPath:(NSIndexPath *)indexPath {
//    NSString *requestKey = _requestKeys[indexPath.section][indexPath.row];
//    _dataValues[indexPath.section][indexPath.row] = result;
//    [_tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self saveDataRequest:@{requestKey: result} success:^(NSDictionary *params) {
//        if ([requestKey isEqualToString:@"licenseExpireDate"]) {
//            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
//            NSTimeInterval editDate = [[[SOSDateFormatter sharedInstance] style1_dateFromString:result] timeIntervalSince1970];
//            if ([SOSDateFormatter isSameDay:[NSDate date] date2:[[SOSDateFormatter sharedInstance] style1_dateFromString:result]]) {
//
//            }else if (editDate < now) {
//                [Util showAlertWithTitle:@"亲爱的安吉星车主，您的驾照已过期，请及时前往相关部门进行换证" message:nil completeBlock:nil cancleButtonTitle:nil otherButtonTitles:@"知道了",nil];
////                UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:@"亲爱的安吉星车主，您的驾照已过期，请及时前往相关部门进行换证" preferredStyle:UIAlertControllerStyleAlert];
////                UIAlertAction *ac0 = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
////                [ac addAction:ac0];
////                [ac show];
//            }
//        }
//    } failure:nil];
//}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section    {
    return 34.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section    {
    
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
    
    [header.textLabel setText:@"出发时间设置"];
    return header;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[SOSUtil defaultLabelLightBlue]];
    [header.textLabel setFont:[UIFont systemFontOfSize:14.0f]];
    header.contentView.backgroundColor = UIColor.whiteColor;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 6) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, SCREEN_WIDTH)];
    }else{
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 5, 0, 5)];
    }
}
#pragma mark - PickerViewDelegate
//
//- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component    {
//    NSArray *strArray = component ? @[@"00", @"15", @"30", @"45"] : @[@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23"];
//    NSString *titleStr = strArray[component ? (int)(row%4) : (int)(row%24)];
//    NSAttributedString *attributedTitleStr= [[NSAttributedString alloc] initWithString:titleStr attributes:@{NSAttachmentAttributeName: [UIFont systemFontOfSize:30], NSForegroundColorAttributeName: [UIColor blackColor]}];
//    return attributedTitleStr;
//}
//
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component  {
//    NSArray *strArray = component ? @[@"00", @"15", @"30", @"45"] : @[@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23"];
//    SelectionData *tempData = self.selectionDataArray[selectIndex];
//    if (component) {
//        tempData.selectMin = strArray[row % 4];
//    }   else    {
//        tempData.selectHour = strArray[row % 24];
//    }
//    [self.selectionDataArray replaceObjectAtIndex:selectIndex withObject:tempData];
//}



@end
