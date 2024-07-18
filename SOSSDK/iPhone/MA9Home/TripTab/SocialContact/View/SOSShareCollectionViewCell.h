//
//  SOSShareCollectionViewCell.h
//  Onstar
//
//  Created by Onstar on 2020/1/19.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSShareCollectionViewCell : UICollectionViewCell
//@property(nonatomic ,strong)NSDictionary * shareDic;
-(void)setShareIconWithDic:(NSDictionary *)shareDic;
@end

NS_ASSUME_NONNULL_END
