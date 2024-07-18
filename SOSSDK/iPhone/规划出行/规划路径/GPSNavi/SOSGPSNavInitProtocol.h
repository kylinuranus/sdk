//
//  SOSGPSNavInitProtocol.h
//  Onstar
//
//  Created by onstar on 2018/4/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SOSGPSNavInitProtocol <NSObject>

@required
- (instancetype)initWithStartPoint:(id)startPoint endPoint:(id)endPoint drivingStrategy:(NSInteger)drivingStrategy;
@end
