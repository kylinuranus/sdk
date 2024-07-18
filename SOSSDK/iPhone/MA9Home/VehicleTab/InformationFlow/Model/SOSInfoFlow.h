//
//  SOSInfoFlow.h
//  Onstar
//
//  Created by TaoLiang on 2018/12/17.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>


@class SOSIFAction;
@class SOSIFAttribute;
@class SOSIFTextInfo;
@class SOSIFBody;

typedef NS_ENUM(NSUInteger, SOSInfoFlowStyle) {
    SOSInfoFlowStyleNormal,
    SOSInfoFlowStyleTail,
    SOSInfoFlowStyleIM,
};


@interface SOSInfoFlow : NSObject
@property (strong, nonatomic) SOSIFAction *action;
@property (strong, nonatomic) SOSIFAttribute *attribute;
@property (strong, nonatomic) SOSIFBody *header;
@property (strong, nonatomic) SOSIFBody *content;
@property (strong, nonatomic) SOSIFBody *tail;

@end

@interface SOSIFAttribute : NSObject
@property (copy, nonatomic) NSString *bid;
@property (copy, nonatomic) NSString *styleId;
@property (copy, nonatomic) NSString *showCardFID;
@property (assign, nonatomic) BOOL click;
@property (assign, nonatomic) BOOL slideDelete;
@property (assign, nonatomic) BOOL viewDelete;
@property (copy, nonatomic) NSString *idt;
///广告ID
@property (copy, nonatomic) NSString *desc;

@end

@interface SOSIFComponent : NSObject
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *color;
@property (copy, nonatomic) NSString *link;
@property (strong, nonatomic) id param;

/**
 按钮触发事件类型 0:跳转H5 1:跳转客户端
 */
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *showFID;
@property (copy, nonatomic) NSString *deleteFID;
@property (copy, nonatomic) NSString *clickFID;

@end

@interface SOSIFTextInfo : NSObject
@property (assign, nonatomic) BOOL fillOrNot;
@property (copy, nonatomic) NSString *pattern;
@property (strong, nonatomic) NSAttributedString *attrString;

@end


@interface SOSIFAction : NSObject

@property (strong, nonatomic) SOSIFComponent *button;
@property (strong, nonatomic) SOSIFComponent *href;
@property (strong, nonatomic) SOSIFComponent *click;

@end

@interface SOSIFBody : NSObject
@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSArray<SOSIFTextInfo *> *infos;

@end
