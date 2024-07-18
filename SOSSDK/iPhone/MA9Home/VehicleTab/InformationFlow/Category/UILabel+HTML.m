//
//  UILabel+HTML.m
//  Onstar
//
//  Created by TaoLiang on 2018/12/13.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "UILabel+HTML.h"

static NSString *htmlStringKey = @"htmlStringKey";

@implementation UILabel (HTML)

- (void)setHtmlString:(NSString *)htmlString {
    if ([htmlString containsString:@"{arrow}"]) {
        NSString *imgString = [NSString stringWithFormat:@"<img src='data:image/png;base64,%@' width='16'>", self.arrowBase64];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{arrow}" withString:imgString];
    }

    objc_setAssociatedObject(self, &htmlStringKey, htmlString, OBJC_ASSOCIATION_COPY_NONATOMIC);
    NSAttributedString *attrStr = [[NSAttributedString alloc]
                                   initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding]
                                   options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil
                                   error:nil];
    self.attributedText = attrStr;

}

- (NSString *)htmlString {
    return objc_getAssociatedObject(self, &htmlStringKey);
}

- (NSString *)arrowBase64 {
    UIImage *image = [UIImage imageNamed:@"icon_arrow_right_22x22"];
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    NSString *arrowBase64 = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return arrowBase64;
}


@end
