//
//  CGChitChatInputView.m
//  ChitChat
//
//  Created by Neeraj Kumar on 12/07/14.
//  Copyright (c) 2014 CocoaGarage. All rights reserved.
//

#import "CGChitChatInputView.h"
#import "CGConstants.h"

#define DESIRED_HEIGHT 40

@interface CGChitChatInputView()<UITextViewDelegate> {
    int currentKeyboardHeight;
    BOOL isKeyboardVisible;
}

@property (strong, nonatomic) UITextView * textView;
@property (strong, nonatomic) UIButton * sendBtn;

@property (strong, nonatomic) UIToolbar * bgToolbar;
@property (strong, nonatomic) CAGradientLayer *shadow;

@end

@implementation CGChitChatInputView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.frame = CGRectMake(0, ScreenHeight() - DESIRED_HEIGHT, ScreenWidth(), DESIRED_HEIGHT);
        
        self.layer.masksToBounds = YES;
        self.clipsToBounds = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        
        _maxY = [NSNumber numberWithInt:60]; // A frame origin y of 60 will prevent further expansion
        
        [self addSubview:self.textView];
        
        self.sendBtnActiveColor = [UIColor colorWithRed:0.142954 green:0.60323 blue:0.862548 alpha:1];
        self.sendBtnInactiveColor = [UIColor lightGrayColor];
        
        [self deactivateSendBtn];
        
        [self addSubview:self.sendBtn];
        
        // Background
        [self insertSubview:self.bgToolbar belowSubview:self.textView];
        
        [self.layer addSublayer:self.shadow];
        
        // Get Keyboard Notes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
    }
    return self;
}

#pragma mark - Getters

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _textView.frame = CGRectMake(5, 6, self.bounds.size.width - 75, 28);
        _textView.delegate = self;
        _textView.layer.cornerRadius = 4;
        _textView.font = [UIFont systemFontOfSize:16];
        _textView.layer.borderWidth = .5;
        _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _textView.textColor = [UIColor darkTextColor];
        _textView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.825f];
    }
    return _textView;
}

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _sendBtn.frame = CGRectMake(self.bounds.size.width - 60, 0, 50, 40);
        _sendBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [_sendBtn setTitle:@"Send" forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [_sendBtn addTarget:self action:@selector(sendBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        _sendBtn.userInteractionEnabled = YES;
    }
    return _sendBtn;
}

- (UIToolbar *)bgToolbar {
    if (!_bgToolbar) {
        _bgToolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        _bgToolbar.barStyle = UIBarStyleDefault;
        _bgToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _bgToolbar;
}

- (CAGradientLayer *)shadow {
    if (_shadow) {
        _shadow = [CAGradientLayer layer];
        _shadow.frame = CGRectMake(0, 0, self.bounds.size.width, 0.5);
        _shadow.colors = [NSArray arrayWithObjects:(id)[[UIColor lightGrayColor] CGColor], (id)[[UIColor clearColor] CGColor], nil];
        _shadow.opacity = .6;
    }
    return _shadow;
}

- (UILabel *) placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc]initWithFrame:_textView.frame];
        _placeholderLabel.userInteractionEnabled = NO;
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        _placeholderLabel.font = [UIFont systemFontOfSize:14];
        _placeholderLabel.textColor = [UIColor lightGrayColor];
        _placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        [self insertSubview:_placeholderLabel aboveSubview:_textView];
    }
    
    return _placeholderLabel;
}

- (NSNumber *) maxY {
    if (!_maxY) {
        _maxY = [NSNumber numberWithInt:60];
    }
    return _maxY;
}


#pragma mark - 

- (void) layoutSubviews {
    self.bgToolbar.frame = self.bounds;
    self.shadow.frame = CGRectMake(0, 0, self.bounds.size.width, 1);
}

- (void)removeFromSuperview {
    
    // Cleanup.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_shadow removeFromSuperlayer];
    _shadow = nil;
    
    [_placeholderLabel removeFromSuperview];
    _placeholderLabel = nil;
    
    [_textView removeFromSuperview];
    _textView.text = nil;
    _textView.delegate = nil;
    _textView = nil;
    
    [_sendBtn removeTarget:self action:@selector(sendBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_sendBtn removeFromSuperview];
    _sendBtn = nil;
    
    [_bgToolbar removeFromSuperview];;
    _bgToolbar = nil;
    
    _delegate = nil;
    _maxY = nil;
    _sendBtnActiveColor = nil;
    _sendBtnInactiveColor = nil;
    [super removeFromSuperview];
}

#pragma mark - Button handlers

- (void)sendBtnPressed:(id)sender {
    if (self.textView.text.length > 0) {
         self.shouldIgnoreKeyboardNotifications = YES;
        [self.textView endEditing:YES];
        [self.textView setKeyboardType:UIKeyboardTypeAlphabet];
        [self.textView becomeFirstResponder];
         self.shouldIgnoreKeyboardNotifications = NO;
        
        NSString *chatText = self.textView.text;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.placeholderLabel.hidden = NO;
            self.textView.text = @"";
            [self deactivateSendBtn];
            // Reset Frame
            self.frame = CGRectMake(0, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, -40);
            
        } completion:^(BOOL finished) {
            [self resizeTextView];
            [self alignTextViewWithAnimation:NO];
            
            // Pass Off The Message
            [self.delegate chatInputNewMessageSent:chatText];

            
        }];
    }
}


#pragma mark

- (void) activateSendBtn {
    [self.sendBtn setTitleColor:self.sendBtnActiveColor forState:UIControlStateNormal];
}

- (void) deactivateSendBtn {
    [self.sendBtn setTitleColor:self.sendBtnInactiveColor forState:UIControlStateNormal];
}

#pragma mark

- (void) close {
    [self.textView resignFirstResponder];
}

- (void) open {
    [self.textView becomeFirstResponder];
}


#pragma mark TextView delegate

- (void) textViewDidBeginEditing:(UITextView *)textView {
    if (![textView.text isEqualToString:@""]) {
        self.placeholderLabel.hidden = YES;
    }
    
    [self resizeTextView];
    [self alignTextViewWithAnimation:NO];
}

- (void) textViewDidChange:(UITextView *)textView {
    
    if (![textView.text isEqualToString:@""]) {
        self.placeholderLabel.hidden = YES;
    }
    else {
        self.placeholderLabel.hidden = NO;
    }
    
    [self resizeTextView];
    [self alignTextViewWithAnimation:NO];
}

- (void) textViewDidChangeSelection:(UITextView *)textView {
    [self resizeTextView];
    [self alignTextViewWithAnimation:NO];
}

- (void) textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        self.placeholderLabel.hidden = NO;
    }
}


#pragma mark - Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *keyboardAnimationDetail = [notification userInfo];
    UIViewAnimationCurve animationCurve = [keyboardAnimationDetail[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat duration = [keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // Get Keyboard Height
    NSValue* keyboardFrameBegin = [keyboardAnimationDetail valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    currentKeyboardHeight = keyboardFrameBeginRect.size.height;
    // Keyboard Is Visible
    isKeyboardVisible = YES;
    
    if (_shouldIgnoreKeyboardNotifications != YES) {
        UIViewAnimationOptions options = (animationCurve << 16);
        
        [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
            [self resizeTextView];
        } completion:^(BOOL finished) {
            [self alignTextViewWithAnimation:YES];
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    if (_shouldIgnoreKeyboardNotifications != YES) {
        isKeyboardVisible = NO;
        NSDictionary *keyboardAnimationDetail = [notification userInfo];
        UIViewAnimationCurve animationCurve = [keyboardAnimationDetail[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        CGFloat duration = [keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        
        UIViewAnimationOptions options = (animationCurve << 16);
        
        [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
            [self resizeTextView];
        } completion:^(BOOL finished) {
            [self alignTextViewWithAnimation:YES];
        }];
    }
}


#pragma mark TextView resize/Algin

- (void)resizeTextView {
    
    CGFloat inputStartingPoint;
    CGFloat maxHeight;
    if (isKeyboardVisible) {
        inputStartingPoint = ScreenHeight() - currentKeyboardHeight;
    }
    else {
      inputStartingPoint = ScreenHeight();
    }

    if (isKeyboardVisible) {
      maxHeight = inputStartingPoint - _maxY.intValue;
    }
    else {
        int adjustment = 216; // portrait keyboard height
        maxHeight = ScreenHeight() - adjustment - _maxY.intValue;
    }
    
    NSString * content = _textView.text;
    
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithString:content attributes:@{ NSFontAttributeName : _textView.font, NSStrokeColorAttributeName : [UIColor darkTextColor]}];
    
    CGFloat width = _textView.bounds.size.width - 10;
    
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    CGFloat height = rect.size.height;
    
    if ([_textView.text hasSuffix:@"\n"]) {
        height = height + _textView.font.lineHeight;
    }
    
    int originalHeight = 30;
    
    int offset = originalHeight - _textView.font.lineHeight;
    
    int targetHeight = height + offset + 6;
    
    if(targetHeight > maxHeight) {
       targetHeight = maxHeight;
    }
    
    else if (targetHeight < 40) {
      targetHeight = 40;
    }
    
    self.frame = CGRectMake(0, inputStartingPoint, self.bounds.size.width, -targetHeight);
    
    // in case they backspaced and we need to block send
    if (_textView.text.length > 0) {
        [self activateSendBtn];
    }
    else {
        [self deactivateSendBtn];
    }
}

- (void) alignTextViewWithAnimation:(BOOL)shouldAnimate {
    
    CGRect line = [_textView caretRectForPosition:_textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height - (_textView.contentOffset.y + _textView.bounds.size.height - _textView.contentInset.bottom - _textView.contentInset.top);
    
    CGPoint offsetP = _textView.contentOffset;
    offsetP.y += overflow + 3; // 3 px margin
    
    if (offsetP.y >= 0) {
        if (shouldAnimate) {
            [UIView animateWithDuration:0.2 animations:^{
                [_textView setContentOffset:offsetP];
            }];
        }
        else {
            [_textView setContentOffset:offsetP];
        }
    }
}

#pragma mark - Hit Test
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(self.bounds, point)) {
        if (CGRectContainsPoint(_textView.frame, point)) {
            [self open];
        }
        
        return YES;
    }
    else {
        if (isKeyboardVisible && _textView.text.length == 0) {
            [self close];
        }
        return NO;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.textView = nil;
}

@end
