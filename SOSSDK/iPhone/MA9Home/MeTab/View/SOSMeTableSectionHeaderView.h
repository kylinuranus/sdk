//
//  SOSMeTableSectionHeaderView.h
//  Onstar
//
//  Created by Onstar on 2018/12/13.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSMeTableSectionHeaderView : UITableViewHeaderFooterView{
    UIImageView * imgV;
    UILabel * textLabel;
}
@property(nonatomic,strong)    UIButton * rightBtn;

-(void)makeIcon:(NSString *)imgName titleText:(NSString *)title showAdditionRightButton:(BOOL)rightButton;
@end

NS_ASSUME_NONNULL_END
