//
//  TLMrORestrictionCell.m
//  Onstar
//
//  Created by TaoLiang on 2017/11/21.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "TLMrORestrictionCell.h"
#import "TLMrORestrictionPickerView.h"
#import "SOSDateFormatter.h"

@interface TLMrORestrictionCell ()

@property (weak, nonatomic) IBOutlet UIView *cityContainerView;
@property (weak, nonatomic) IBOutlet UIView *timeContainerView;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (strong, nonatomic) NSArray *cities;

@end

@implementation TLMrORestrictionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self configureUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self configureUI];
}

- (void)setRestrictions:(TLMroRestrictions *)restrictions {
    _restrictions = restrictions;
    _timeLabel.text = restrictions.searchDate.length > 0 ? restrictions.searchDate : _timeLabel.text;
    _cityLabel.text = restrictions.searchCity.length > 0 ? restrictions.searchCity : _cityLabel.text;
    
    _searchBtn.enabled = !restrictions.isSearching;
    _cityContainerView.userInteractionEnabled = !restrictions.isSearching;
    _timeContainerView.userInteractionEnabled = !restrictions.isSearching;
}

static NSString *kCities = @"restriction_cities";
- (void)selectCity:(id)sender {
    //从接口获取城市列表并保存本地,如果接口失败,则直接调本地默认JSON
    if (_cities.count <= 0) {
        [OthersUtil asyncRequestForRestrictCitysWithSuccessBlock:^(SOSNetworkOperation *operation, NSDictionary *resultDic) {
            _cities = resultDic[@"cities"];
            NSData *offersJSONData = [NSJSONSerialization dataWithJSONObject:_cities options:0 error:nil];
            NSString *offersJSONString = [[NSString alloc] initWithData:offersJSONData encoding:NSUTF8StringEncoding];
            [[NSUserDefaults standardUserDefaults] setObject:offersJSONString forKey:kCities];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            dispatch_async_on_main_queue(^(){
                [self showCityPickerView];
            });
        } failureBlock:^(SOSNetworkOperation *operation, NNError *definedError, NSString *errorStr) {
            NSString *citiesJsonString = [[NSUserDefaults standardUserDefaults] objectForKey:kCities];
            if (citiesJsonString.length <= 0) {
                citiesJsonString = [self saveDefaultJsonString];
            }
            _cities = [Util arrayWithJsonString:citiesJsonString];
            dispatch_async_on_main_queue(^(){
                [self showCityPickerView];

            });

        }];
    }else {
        [self showCityPickerView];


    }
}

- (void)selectTime:(id)sender {
    @weakify(self);
    [self showPickerView:MrORestrictionPickerTypeDate object:nil picker:^(NSString *result, NSUInteger index) {
        @strongify(self);
        self.timeLabel.text = result;
        self.restrictions.searchDate = result;
        [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_Date_Confirm];
    } cancel:^(NSString *result, NSUInteger index) {
        [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_Date_Cancel];

    }];
}

- (IBAction)searchBtnClicked:(id)sender {
    if (_searchBtnClicked) {
        _searchBtnClicked(_cityLabel.text, _timeLabel.text);
    }
}

- (void)configureUI {
    self.backgroundColor = [UIColor clearColor];
    _containerView.layer.cornerRadius = 5;
    _containerView.layer.masksToBounds = YES;
    _searchBtn.layer.cornerRadius = 5;
    _searchBtn.layer.masksToBounds = YES;
    [self.contentView addSubview:_containerView];
    [self addBorderLineForView:_cityContainerView];
    [self addBorderLineForView:_timeContainerView];
    UITapGestureRecognizer *cityGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCity:)];
    _cityContainerView.userInteractionEnabled = YES;
    [_cityContainerView addGestureRecognizer:cityGesture];
    UITapGestureRecognizer *timeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectTime:)];
    _timeContainerView.userInteractionEnabled = YES;
    [_timeContainerView addGestureRecognizer:timeGesture];

    
    
}

- (void)showCityPickerView {
    @weakify(self);
    [self showPickerView:MrORestrictionPickerTypeCity object:_cities picker:^(NSString *result, NSUInteger index) {
        @strongify(self);
        self.cityLabel.text = result;
        self.restrictions.searchCity = result;
        NSDictionary *dic = self.cities[index];
        [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_City_BeiJing_Confirm];

    } cancel:^(NSString *result, NSUInteger index) {
        NSDictionary *dic = self.cities[index];
        [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_City_HaErBin_Cancel];

    }];

}

- (void)showPickerView:(MrORestrictionPickerType)type object:(id)object picker:(void(^)(NSString *result, NSUInteger index))picker cancel:(void(^)(NSString *result, NSUInteger index))cancel{
    TLMrORestrictionPickerView *pickerView = [TLMrORestrictionPickerView viewFromXib];
    pickerView.object = object;
    pickerView.pickerType = type;
    pickerView.picked = picker;
    pickerView.cancel = cancel;
    UIWindow *keyWindow = SOS_ONSTAR_WINDOW;
    [keyWindow addSubview:pickerView];
    [pickerView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(keyWindow);
    }];
    [pickerView show];

}

- (void)addBorderLineForView:(__kindof UIView *)view {
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.right.equalTo(view);
        make.top.equalTo(view.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];

}

- (NSString *)saveDefaultJsonString {
    NSString *citiesJsonString = @"[{\"city\":\"北京市\",\"cityCode\":\"110000\"},{\"city\":\"天津市\",\"cityCode\":\"120000\"},{\"city\":\"长春市\",\"cityCode\":\"220100\"},{\"city\":\"哈尔滨市\",\"cityCode\":\"230100\"},{\"city\":\"杭州市\",\"cityCode\":\"330100\"},{\"city\":\"武汉市\",\"cityCode\":\"420100\"},{\"city\":\"成都市\",\"cityCode\":\"510100\"},{\"city\":\"贵阳市\",\"cityCode\":\"520100\"},{\"city\":\"兰州市\",\"cityCode\":\"620100\"},{\"city\":\"北京市\",\"cityCode\":\"110000\"}]";
    [[NSUserDefaults standardUserDefaults] setObject:citiesJsonString forKey:kCities];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return citiesJsonString;
}

@end
