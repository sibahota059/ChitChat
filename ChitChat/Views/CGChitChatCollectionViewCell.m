//
//  CGChitChatCollectionViewCell.m
//  ChitChat
//
//  Created by Neeraj Kumar on 12/07/14.
//  Copyright (c) 2014 CocoaGarage. All rights reserved.
//

#import "CGChitChatCollectionViewCell.h"
#import "CGConstants.h"

// External Constants
int const outlineSpace = 22; // 11 px on each side for border
int const maxBubbleWidth = 260; // Max Bubble Size

NSString * const kMessageSize = @"size";
NSString * kMessageContent = @"content";
NSString * const kMessageRuntimeSentBy = @"runtimeSentBy";

// Instance Level Constants
static int offsetX = 6; // 6 px from each side
// Minimum Bubble Height
static int minimumHeight = 30;

@interface CGChitChatCollectionViewCell()
// Who Sent The Message
@property (nonatomic) SentBy sentBy;

// Received Size
@property CGSize textSize;

// Bubble, Text, ImgV
@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) UILabel *bgLabel;

@end

@implementation CGChitChatCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (self) {
            // Initialization code
            self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
            // Dark Blue.
            self.opponentColor = [UIColor blueColor];
            
            // Light Blue
            self.userColor = AppLightBlueColor();
            
            if (!_bgLabel) {
                _bgLabel = [UILabel new];
                _bgLabel.layer.borderWidth = 2;
                _bgLabel.layer.cornerRadius = minimumHeight / 2;
                _bgLabel.alpha = .925;
                [self.contentView addSubview:self.bgLabel];
            }
            
            if (!_textLabel) {
                _textLabel = [UILabel new];
                _textLabel.layer.rasterizationScale = 2.0f;
                _textLabel.layer.shouldRasterize = YES;
                _textLabel.font = [UIFont systemFontOfSize:15.0f];
                _textLabel.textColor = [UIColor whiteColor];
                _textLabel.numberOfLines = 0;
                [self.contentView addSubview:self.textLabel];
            }
        }
    }
    return self;
}

- (void) setOpponentColor:(UIColor *)opponentColor {
    if (_sentBy == kSentByOpponent) {
        _bgLabel.layer.borderColor = opponentColor.CGColor;
    }
    _opponentColor = opponentColor;
}

- (void) setUserColor:(UIColor *)userColor {
    if (_sentBy == kSentByUser) {
        _bgLabel.layer.borderColor = userColor.CGColor;
    }
    _userColor = userColor;
}

- (void) setMessage:(NSDictionary *)message {
    _message = message;
    [self drawCell];
}

- (void) drawCell {
    self.bgLabel.layer.backgroundColor = self.userColor.CGColor;
    // Get Our Stuff
    self.textSize = [self.message[kMessageSize] CGSizeValue];
    self.textLabel.text = self.message[kMessageContent];
    self.sentBy = [self.message[kMessageRuntimeSentBy] intValue];
    
    // the height that we want our text bubble to be
    CGFloat height = self.contentView.bounds.size.height - 10;
    if (height < minimumHeight) height = minimumHeight;
    
    if (self.sentBy == kSentByUser) {
        // then this is a message that the current user created . . .
        self.bgLabel.frame = CGRectMake(ScreenWidth() - offsetX, 0, - self.textSize.width - outlineSpace, height);
        self.bgLabel.layer.borderColor = self.userColor.CGColor;
    }
    else {
        // sent by opponent
        self.bgLabel.frame = CGRectMake(offsetX, 0, self.textSize.width + outlineSpace, height);
        self.bgLabel.layer.borderColor = self.opponentColor.CGColor;
    }
    
    // position _textLabel in the _bgLabel;
    self.textLabel.frame = CGRectMake(self.bgLabel.frame.origin.x + (outlineSpace / 2), 0, self.bgLabel.bounds.size.width - outlineSpace, self.bgLabel.bounds.size.height);
}

@end
