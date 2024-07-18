//  UnderLineLabel.m

#import "UnderLineLabel.h"
#import "Util.h"

@implementation UnderLineLabel
@synthesize highlightedColor = _highlightedColor;
@synthesize shouldUnderline = _shouldUnderline;

- (void)dealloc     {
    _actionView = nil;
}

- (id)initWithFrame:(CGRect)frame     {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)init     {
    if (self = [super init]) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder     {
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

- (void)setShouldUnderline:(BOOL)shouldUnderline     {
    _shouldUnderline = shouldUnderline;
//    if (_shouldUnderline) {
        [self setup];
//    }
}

- (void)drawRect:(CGRect)rect     {
    [super drawRect:rect];
    if (self.shouldUnderline) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
//        CGSize fontSize =[self.text sizeWithFont:self.font
//                                        forWidth:self.frame.size.width
//                                   lineBreakMode:NSLineBreakByTruncatingTail];
        CGSize fontSize = [self.text boundingRectWithSize:self.frame.size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.font} context:nil].size;
        
        CGContextSetStrokeColorWithColor(ctx, self.textColor.CGColor);  // set as the text's color
        CGContextSetLineWidth(ctx, 2.0f);
        if (self.lineWidth==0.0) {
            CGContextSetLineWidth(ctx, 2.0f);
        }
        else
        {
            CGContextSetLineWidth(ctx, self.lineWidth);
        }
        
        CGPoint leftPoint = CGPointMake(0,
                                        self.frame.size.height - 3);
        CGPoint rightPoint = CGPointMake(fontSize.width,
                                         self.frame.size.height - 3);
        CGContextMoveToPoint(ctx, leftPoint.x, leftPoint.y);
        CGContextAddLineToPoint(ctx, rightPoint.x, rightPoint.y);
        CGContextStrokePath(ctx);
    }
}



- (void)setText:(NSString *)text andCenter:(CGPoint)center     {
    [super setText:text];
//    CGSize fontSize =[self.text sizeWithFont:self.font
//                                    forWidth:SCREEN_WIDTH
//                               lineBreakMode:NSLineBreakByTruncatingTail];
    CGSize fontSize = [self.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, self.frame.size.height) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.font} context:nil].size;
    NSLog(@"%f   %f", fontSize.width, fontSize.height);
    [self setNumberOfLines:0];
    [self setFrame:CGRectMake(0, 0, fontSize.width, fontSize.height)];
    [self setCenter:center];
}


- (void)setText:(NSString *)text andFrame:(CGRect)frame     {
    [super setText:text];
//    CGSize fontSize =[self.text sizeWithFont:self.font
//                                    forWidth:frame.size.width
//                               lineBreakMode:NSLineBreakByTruncatingTail];
    CGSize fontSize = [self.text boundingRectWithSize:frame.size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.font} context:nil].size;
    NSLog(@"%f   %f", fontSize.width, fontSize.height);
    [self setNumberOfLines:0];
    [self setFrame:CGRectMake(frame.origin.x,frame.origin.y, fontSize.width, fontSize.height)];
    //    [self setFrame:CGRectMake(0,frame.origin.y, SCREEN_WIDTH, fontSize.height)];
    [self setTextAlignment:NSTextAlignmentCenter];
}

- (void)setText:(NSString *)text andCustomFrame:(CGRect)frame     {
    [super setText:text];
//    CGSize fontSize =[self.text sizeWithFont:self.font
//                                    forWidth:frame.size.width
//                               lineBreakMode:NSLineBreakByTruncatingTail];
    CGSize fontSize = [self.text boundingRectWithSize:frame.size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.font} context:nil].size;
    NSLog(@"%f   %f", fontSize.width, fontSize.height);
    [self setNumberOfLines:0];
    [self setFrame:CGRectMake(frame.origin.x,frame.origin.y, frame.size.width, fontSize.height)];
    [self setTextAlignment:NSTextAlignmentCenter];
}


- (void)setText:(NSString *)text frame:(CGRect) frame andLineNumber:(NSInteger)lineNumber     {
    [super setText:text];
    CGSize maxSize = CGSizeMake(frame.size.width, frame.size.height*lineNumber);
//    CGSize labelSize = [text sizeWithFont:self.font constrainedToSize:maxSize lineBreakMode: UILineBreakModeTailTruncation];
    CGSize labelSize = [text boundingRectWithSize:maxSize options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.font} context:nil].size;
    [self setNumberOfLines:lineNumber];
    [self setFrame:CGRectMake(frame.origin.x, frame.origin.y, labelSize.width, labelSize.height)];
}


- (void)setup     {
    [self setUserInteractionEnabled:TRUE];
    _actionView = [[UIControl alloc] initWithFrame:self.bounds];
    [_actionView setBackgroundColor:[UIColor clearColor]];
    [_actionView addTarget:self action:@selector(appendHighlightedColor) forControlEvents:UIControlEventTouchDown];
    [_actionView addTarget:self
                    action:@selector(removeHighlightedColor)
          forControlEvents:UIControlEventTouchCancel |
     UIControlEventTouchUpInside |
     UIControlEventTouchDragOutside |
     UIControlEventTouchUpOutside];
    [self addSubview:_actionView];
    [self sendSubviewToBack:_actionView];
}

- (void)addTarget:(id)target action:(SEL)action     {
    [_actionView addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)appendHighlightedColor     {
    self.backgroundColor = self.highlightedColor;
}

- (void)removeHighlightedColor     {
    self.backgroundColor = [UIColor clearColor];
}
@end







