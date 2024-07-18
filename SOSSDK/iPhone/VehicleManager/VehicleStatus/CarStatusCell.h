//
//  CarStatusCell.h
//  Onstar
//
//  Created by Joshua on 14-9-11.
//  Copyright (c) 2014年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarStatusCell : UITableViewCell     {
    UILabel *title;
    UILabel *hint;
    UILabel *warning;
}

- (void)fillContent:(NSArray *)array withMultiLabel:(BOOL)multiLabel;
@end
