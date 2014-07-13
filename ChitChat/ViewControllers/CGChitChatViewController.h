//
//  CGChitChatViewController.h
//  ChitChat
//
//  Created by Neeraj Kumar on 12/07/14.
//  Copyright (c) 2014 CocoaGarage. All rights reserved.
//


/*
  This class handles chat page.It shows chats from the peers on left side and your own chats on the right side of the screen.
 */

#import <UIKit/UIKit.h>
#import "CGChitChatInputView.h"


// Message Dictionary Keys (defined in MessageCell)
FOUNDATION_EXPORT NSString * const kMessageSize;
FOUNDATION_EXPORT NSString * const kMessageContent;
FOUNDATION_EXPORT NSString * const kMessageRuntimeSentBy;

@class CGChitChatViewController;

@interface CGChitChatViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, ChatInputDelegate>

/*!
 The color of the user's chat bubbles
 */
@property (strong, nonatomic) UIColor * userBubbleColor;
/*!
 The color of the opponent's chat bubbles
 */
@property (strong, nonatomic) UIColor * opponentBubbleColor;
/*!
 Change Overall Tint (send btn, & top bar)
 */
@property (strong, nonatomic) UIColor * tintColor;

/*!
 To set the title
 */
@property (strong, nonatomic) NSString * chatTitle;

/*!
 The messages to display in the controller
 */
@property (strong, nonatomic) NSMutableArray * messagesArray;

#pragma mark ADD NEW MESSAGE

/*!
 Add new message to view
 */
- (void) addNewMessage:(NSDictionary *)message;

@end
