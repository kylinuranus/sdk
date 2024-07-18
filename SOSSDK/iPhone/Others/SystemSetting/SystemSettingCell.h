//
//  CustomTableViewCell.h
//  Onstar
//
//  Created by Onstar on 4/10/13.
//
//

#import <UIKit/UIKit.h>

typedef enum _CellStyle     {
    CellStyleSwitch = 10,
    CellStyleSwitchWithSubText = 11,
    CellStyleDisclosureIndicator,
    CellStyleLabel,
    CellStyleNone
} CellStyle;

@interface SystemSettingCell : UITableViewCell     {
}
@property(strong, nonatomic)UIImageView *iconImageView;
@property(strong, nonatomic)UILabel *subLable;
@property(strong, nonatomic)id cellTarget;
@property(readwrite, nonatomic) SEL cellSelector;
@property(assign, nonatomic)CellStyle cellStyle;
@property(assign, nonatomic)BOOL switchStyleStatus;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier Style:(CellStyle) _cellStyle;
- (void)setTitleIcon:(UIImage *)_titleIcon AndTitleText:(NSString *)_titleText;

- (void)checkMroCellStatus;
@end
