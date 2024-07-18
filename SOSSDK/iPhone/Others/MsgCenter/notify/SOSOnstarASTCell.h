//
//  SOSOnstarASTCell.h
//  Onstar
//
//  Created by Onstar on 2019/9/2.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>
NS_ASSUME_NONNULL_BEGIN

@interface SOSOnstarASTCell : MGSwipeTableCell
@property(nonatomic ,strong)UILabel * titleL;
@property(nonatomic ,strong)UILabel * timeL;
@property(nonatomic ,strong)UILabel * descL;

@property(nonatomic ,strong)UIImageView * iconImg;
@property(nonatomic ,strong)UILabel * goDetailL;
@property(nonatomic ,strong)UIControl * bottomBase ;
@property(nonatomic ,strong)UIImageView * arrow;
@property(nonatomic ,weak)NotifyOrActModel * model;

-(void)updateView:(NotifyOrActModel*)model;
-(void)setMsgReadState;
@end

NS_ASSUME_NONNULL_END
