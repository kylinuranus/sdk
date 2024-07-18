//
//  SOSMeDonateView.h
//  Onstar
//
//  Created by Onstar on 2018/12/21.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSMeDonateView : UIView
- (void)refreshWithResponseData:(id)responseData status:(RemoteControlStatus)status;
@end

NS_ASSUME_NONNULL_END
