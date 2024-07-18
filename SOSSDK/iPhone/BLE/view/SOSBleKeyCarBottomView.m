//
//  SOSBleKeyCarBottomView.m
//  Onstar
//
//  Created by onstar on 2018/10/18.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleKeyCarBottomView.h"

@interface SOSBleKeyCarBottomView ()
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation SOSBleKeyCarBottomView

- (void)awakeFromNib {
    [super awakeFromNib];

}


- (IBAction)tapButton:(id)sender {
    !self.searchButtonClick?:self.searchButtonClick();
}
- (IBAction)tapLabel:(id)sender {
    !self.textButtonClick?:self.textButtonClick();
}

@end
