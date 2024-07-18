//
//  SOSInfoFlow.m
//  Onstar
//
//  Created by TaoLiang on 2018/12/17.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSInfoFlow.h"
#import "SOSInfoFlowArchiver.h"

@implementation SOSInfoFlow
SOS_IMPLEMENTATION_CODING
@end

@implementation SOSIFAttribute
SOS_IMPLEMENTATION_CODING

@end

@implementation SOSIFComponent
SOS_IMPLEMENTATION_CODING

@end

@implementation SOSIFTextInfo
SOS_IMPLEMENTATION_CODING

- (void)setPattern:(NSString *)pattern {
    _pattern = pattern;
    if ([pattern containsString:@"{arrow}"]) {
        NSString *imgString = [NSString stringWithFormat:@"<img src='data:image/png;base64,%@' width='16'>", self.arrowBase64];
        pattern = [pattern stringByReplacingOccurrencesOfString:@"{arrow}" withString:imgString];
    }
    
    NSAttributedString *attrStr = [[NSAttributedString alloc]
                                   initWithData:[pattern dataUsingEncoding:NSUnicodeStringEncoding]
                                   options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil
                                   error:nil];
    _attrString = attrStr;
}

- (NSString *)arrowBase64 {
    UIImage *image = [UIImage imageNamed:@"icon_arrow_right_22x22"];
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    NSString *arrowBase64 = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return arrowBase64;
}

@end

@implementation SOSIFAction
SOS_IMPLEMENTATION_CODING
@end


@implementation SOSIFBody

+ (void)load {
    
    [SOSIFBody mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"infos": SOSIFTextInfo.className
                 };
    }];
}
SOS_IMPLEMENTATION_CODING
@end
