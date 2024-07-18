//
//  SOSItemModel.h
//  Onstar
//
//  Created by Genie Sun on 2017/5/18.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSQSModelProtol.h"
@interface SOSItemModel : NSObject<SOSQSModelProtol>

@property (nonatomic, strong) NSString * ID;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * image;
@property (nonatomic, assign) BOOL  viewOnly;
@property (nonatomic, assign) BOOL  show;
@property (nonatomic, strong) NSString * groupName;
@property (nonatomic, strong) NSString * action;
@property (nonatomic, strong) NSString * specialVisiableCondition;
@property (nonatomic, assign) BOOL needLogin;
@property (nonatomic, copy) NSDictionary *resource;
@property (nonatomic, copy) NSDictionary *generation;
@property (nonatomic, copy) NSDictionary *role;
@property (assign, nonatomic) NSInteger opeType;


//- (id)initWithID:(NSString *)ID Title:(NSString *)title Image:(NSString *)image ViewOnly:(BOOL)viewOnly Show:(BOOL)show GroupName:(NSString *)groupName;

@end

