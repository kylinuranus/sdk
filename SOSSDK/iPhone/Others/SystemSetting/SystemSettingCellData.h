//
//  SettingCellData.h
//  Onstar
//
//  Created by Onstar on 4/15/13.
//
//

#import <Foundation/Foundation.h>
#import "SystemSettingCell.h"

@interface SystemSettingCellData : NSObject
@property(strong, nonatomic)UIImage *thumImage;
@property(strong, nonatomic)NSString *titleText;
@property(strong, nonatomic)NSString *subtitleText;
@property(weak, nonatomic)id cellTarget;
@property(readwrite, nonatomic)SEL cellSelector;
@property(readwrite, nonatomic)CellStyle cellStyle;
@property(readwrite, nonatomic)BOOL switchStyleStatus;


@end
