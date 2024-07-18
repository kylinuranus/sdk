//
//  SOSLifeTabViewController.h
//  Onstar
//
//  Created by Onstar on 2018/11/17.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSModuleProtocols.h"

#if __has_include(<CheLunQueryOutSDK/CLQuery.h>)
#import "CheLunQueryOutSDK/CLQuery.h"
#endif
NS_ASSUME_NONNULL_BEGIN

@interface SOSLifeTabViewController : SOSBaseViewController<SOSHomeLifeTabProtocol>
@end

NS_ASSUME_NONNULL_END
