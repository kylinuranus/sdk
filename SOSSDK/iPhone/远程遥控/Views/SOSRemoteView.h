//
//  SOSRemoteView.h
//  Onstar
//
//  Created by Coir on 2018/6/20.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SOSBaseXibView.h"

@protocol SOSRemoteDelegate <NSObject>

- (void)operationButtonTapped:(UIButton *)button;

@end

@interface SOSRemoteView : UIView

@property (weak, nonatomic) IBOutlet UILabel *lastOperationLabel;
@property (nonatomic, weak) id <SOSRemoteDelegate> delegate;

@end
