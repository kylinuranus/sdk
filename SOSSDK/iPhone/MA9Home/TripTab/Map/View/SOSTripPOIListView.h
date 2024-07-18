//
//  SOSTripPOIListView.h
//  Onstar
//
//  Created by Coir on 2019/4/10.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum {
    SOSTripListTableType_Void = 0,
    SOSTripListTableType_POI_List,
    SOSTripListTableType_Oli_List,
    SOSTripListTableType_selectPoint
}	SOSTripListTableType;

@protocol SOSTripPOIListDelegate <NSObject>

@required
/// 点击列表某项
- (void)didSelectCellWithPOI:(SOSPOI *)poi;

@end

@interface SOSTripPOIListView : UIView

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopGuide;

@property (nonatomic, copy) NSArray <SOSPOI *> * poiArray;
@property (nonatomic, weak) id <SOSTripPOIListDelegate> delegate;
@property (nonatomic, assign) SOSTripListTableType tableType;
@property (nonatomic, assign) SelectPointOperation operationType;

@end

NS_ASSUME_NONNULL_END
