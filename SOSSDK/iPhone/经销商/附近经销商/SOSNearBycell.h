//
//  SOSNearBycell.h
//  Onstar
//
//  Created by WQ on 2018/7/5.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef void(^OnPress)(NSString *phoneBum);

@interface SOSNearBycell : UITableViewCell


- (void)fillCellData:(NearByDealerModel*)m;

@end
