//
//  SOSICMRemoteView.h
//  Onstar
//
//  Created by Coir on 2018/4/27.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSBaseXibView.h"

@protocol SOSICMRemoteDelegate <NSObject>

- (void)operationButtonTapped:(UIButton *)button;

@end

@interface SOSICMRemoteView : SOSBaseXibView

@property (weak, nonatomic) IBOutlet UILabel *lastOperationLabel;

@property (nonatomic, weak) id <SOSICMRemoteDelegate> delegate;

- (void)resetFrame;

- (void)showAuthorizedDetailLabel:(BOOL)show;

@end
