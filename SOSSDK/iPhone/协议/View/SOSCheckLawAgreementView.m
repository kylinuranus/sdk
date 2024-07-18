//
//  SOSCheckLawAgreementView.m
//  Onstar
//
//  Created by Creolophus on 2020/2/11.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import "SOSCheckLawAgreementView.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@interface SOSCheckLawAgreementView ()
@property (strong, nonatomic) UILabel *contentLabel;
@end

@implementation SOSCheckLawAgreementView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString: @"在您使用安吉星App前，请认真阅读并《安吉星服务协议》及《安吉星隐私声明》全部条款，如果同意，请点击“同意“开始使用我们的服务。" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
        NSArray<NSValue *> *ranges = [self getRangesForAgreement:content.string];
        [ranges enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [content addAttribute:NSForegroundColorAttributeName value:SOSUtil.defaultLabelLightBlue range:obj.rangeValue];
        }];

        _contentLabel = UILabel.new;
        _contentLabel.numberOfLines = 0;
        _contentLabel.attributedText = content;
        [self addSubview:_contentLabel];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(15, 15, 15, 15));
        }];

        __weak __typeof(self)weakSelf = self;
        [_contentLabel detectRanges:ranges tapped:^(NSInteger index) {
            if (weakSelf.tapAgreement) {
                weakSelf.tapAgreement(0, index);
            }
        }];

    }
    return self;
}



- (instancetype)initWithFrameAndData:(NSMutableArray<SOSAgreement*> *) agreementData   {
    self = [super initWithFrame:self.frame];
    if (self) {
        
        NSMutableString *tempStr = [NSMutableString stringWithString:@"在您使用安吉星App前，请认真阅读并"];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5; // 设置行间距
        for ( int  i=0 ;i<agreementData.count;i++){
            
            SOSAgreement * model = agreementData[i];
            if(agreementData.count ==1 ){
                [tempStr appendFormat:@"《%@》",model.docTitle];
                
            }else if( i == agreementData.count-1&&agreementData.count>2){
                
                [tempStr appendFormat:@"及《%@》",model.docTitle];
                
            }else{
                
                if(agreementData.count==2){
                    
                    if(i==0){
                        [tempStr appendFormat:@"《%@》、",model.docTitle];
                    }else{
                        [tempStr appendFormat:@"《%@》",model.docTitle];
                    }
                    
                }else{
                    [tempStr appendFormat:@"《%@》、",model.docTitle];
                }
                
            }
            
        }
        
        [tempStr appendString:@"全部条款，如果同意，请点击“同意“开始使用我们的服务。"];
        
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:tempStr   attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
        
       
        
        [content addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, content.length)];
        [content addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"7f7f7f"] range:NSMakeRange(0, content.length)];
        
        NSArray<NSValue *> *ranges = [self getRangesForAgreement:content.string];
        [ranges enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [content addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"0079FF"] range:obj.rangeValue];
        }];

        _contentLabel = UILabel.new;
        _contentLabel.numberOfLines = 0;
        _contentLabel.attributedText = content;
        [self addSubview:_contentLabel];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(15, 15, 15, 15));
        }];
        
        __weak __typeof(self)weakSelf = self;
        [_contentLabel detectRanges:ranges tapped:^(NSInteger index) {
            
            SOSAgreement * model = agreementData[index];
            if (weakSelf.tapAgreement2) {
                weakSelf.tapAgreement2(0, model);
            }
        }];

    }
    return self;
}


@end
