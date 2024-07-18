//
//  SOSContact.h
//  Onstar
//
//  Created by Onstar on 2018/3/7.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSContact : NSObject
@property(nonatomic,copy)NSString *givenName;
@property(nonatomic,copy)NSString *familyName;
@property(nonatomic,copy)NSString *mobile;
@property(nonatomic,copy)NSString *email;
@property(nonatomic,copy)NSString *preferenceLanguage;
@end
