//
//  SOSSocialLocationView.h
//  Onstar
//
//  Created by onstar on 2019/4/22.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSSocialLocationView : UIView

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationDetailLabel;

@property (nonatomic, copy) void(^sendToCarTap)(void);
@property (nonatomic, copy) void(^cancelTap)(void);
@property (nonatomic, copy) void(^acceptTap)(void);


@end

NS_ASSUME_NONNULL_END
