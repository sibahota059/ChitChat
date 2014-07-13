//
//  CGChitChatInputView.h
//  ChitChat
//
//  Created by Neeraj Kumar on 12/07/14.
//  Copyright (c) 2014 CocoaGarage. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
  This class is the chat input view which is used in chat page (chat collection view).
 */

@protocol ChatInputDelegate
// User has sent a new message.
@required - (void) chatInputNewMessageSent:(NSString *)messageString;

@end


@interface CGChitChatInputView : UIView

@property (weak, nonatomic) id<ChatInputDelegate>delegate;

@property (nonatomic, strong)UILabel *placeholderLabel;

@property (strong, nonatomic) UIColor * sendBtnActiveColor;

@property (strong, nonatomic) UIColor * sendBtnInactiveColor;


@property BOOL stopAutoClose;

//  The maximum point on the Y axis that simpleInput can extend to - default: 60
@property (strong, nonatomic) NSNumber * maxY;

@property BOOL shouldIgnoreKeyboardNotifications;

//  Closes keyboard and resigns first responder
- (void) close;

// Opens keyboard and makes simple input first responder.
- (void) open;

@end
