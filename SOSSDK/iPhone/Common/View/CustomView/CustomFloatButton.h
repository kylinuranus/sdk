//
//  CustomFloatButton.h
//  Onstar
//
//  Created by Genie Sun on 16/3/8.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger ,ButtonPosition){
    PositionRightTarget = 0,
    PositionLeftTarget,
    PositionCenter,
    PositionMoveLeft,
    PositionMoveRight
};

@interface CustomFloatButton : UIButton     {
    SEL        _action;
    id         _target;
}

 
@end
