//
//  SOSAvatarView.m
//  Onstar
//
//  Created by Onstar on 2018/11/22.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSAvatarView.h"
#import "SOSAvatarManager.h"
#import "UIButton+WebCache.h"

@interface SOSAvatarView(){
    UIButton * avatar;
    UILabel * nickNameLabel;
}
@end
@implementation SOSAvatarView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configView];
        [self addObserver];
    }
    return self;
}

//- (void)layoutSubviews{
//    [super layoutSubviews];
//
//}
//- (CGSize)intrinsicContentSize{
//    return CGSizeMake(180, 40);
//}
-(void)configView{
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarClick:)]];
     avatar = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:avatar];
    [avatar addTarget:self action:@selector(avatarClick:) forControlEvents:UIControlEventTouchUpInside];
    avatar.autoresizingMask = UIViewAutoresizingNone;
    avatar.contentMode = UIViewContentModeScaleToFill;
    avatar.layer.masksToBounds = YES;
    avatar.layer.cornerRadius=15;

    [avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
        make.leading.mas_equalTo(0);
    }];
    
    [RACObserve([CustomerInfo sharedInstance],userBasicInfo.preference.avatarUrl) subscribeNext:^(NSString*  _Nullable x) {
        [[SOSAvatarManager sharedInstance] fetchAvatar:^(UIImage * _Nullable avatarImage, BOOL isPlacholder) {
            dispatch_async_on_main_queue(^{
                [avatar setImage:avatarImage forState:UIControlStateNormal];
            });
        }];
    }];
    
//
    nickNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nickNameLabel.textAlignment = NSTextAlignmentLeft;
    if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
        nickNameLabel.text = [self getNickNameAfterLogin];
    }
    nickNameLabel.font=[UIFont systemFontOfSize:15.0f];
    [self addSubview:nickNameLabel];
    [nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(avatar.mas_right).with.offset(2);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(self);
        make.centerY.mas_equalTo(self);
    }];
    
    
}
-(void)addObserver{

    @weakify(avatar);
    @weakify(nickNameLabel);
    [RACObserve([LoginManage sharedInstance], loginState) subscribeNext:^(NSNumber*  _Nullable x) {
        @strongify(avatar);
         @strongify(nickNameLabel);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (x.integerValue == LOGIN_STATE_NON ||x.integerValue == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS) {
                [[SOSAvatarManager sharedInstance] fetchAvatar:^(UIImage * _Nullable avatarImage, BOOL isPlacholder) {
                    [avatar setImage:avatarImage forState:UIControlStateNormal];
                }];
                dispatch_async_on_main_queue(^{
                    if (x.integerValue == LOGIN_STATE_NON) {
                        nickNameLabel.text=@"欢迎来到安吉星";
                    }else{
                        nickNameLabel.text = [self getNickNameAfterLogin];
                    }
                });
            }
        });
        
    }];
    
    [RACObserve([CustomerInfo sharedInstance],tokenBasicInfo.nickName) subscribeNext:^(NSString*  _Nullable x) {
        dispatch_async_on_main_queue(^{
            if (x) {
                nickNameLabel.text = [self getNickNameAfterLogin];
            }
            
        });
       
    }];
}
-(void)avatarClick:(id)sender{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(SOSHomeMeTabProtocol)]) {
        [self.delegate clickLogin];
        [SOSDaapManager sendActionInfo:ME_MY];
    }
    
}
-(NSString *)getNickNameAfterLogin{
    NSString * nick = [CustomerInfo sharedInstance].tokenBasicInfo.nickName;
    return  [nick isNotBlank]?nick:[CustomerInfo sharedInstance].userBasicInfo.idpUserId;
}
/*nic
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
