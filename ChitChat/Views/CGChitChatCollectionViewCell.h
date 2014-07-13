//
//  CGChitChatCollectionViewCell.h
//  ChitChat
//
//  Created by Neeraj Kumar on 12/07/14.
//  Copyright (c) 2014 CocoaGarage. All rights reserved.
//

/*
 This class is the chat bubble collection view cell.
 */

#import <UIKit/UIKit.h>

/*!
 Who sent the message
 */
typedef enum {
    kSentByUser,
    kSentByOpponent,
} SentBy;

// Used for shared drawing btwn self & chatController
FOUNDATION_EXPORT int const outlineSpace;
FOUNDATION_EXPORT int const maxBubbleWidth;

@interface CGChitChatCollectionViewCell : UICollectionViewCell

/*
 Message Property
 */
@property (strong, nonatomic) NSDictionary * message;

/*!
 Opponent bubble color
 */
@property (strong, nonatomic) UIColor * opponentColor;
/*!
 User bubble color
 */
@property (strong, nonatomic) UIColor * userColor;

@end
