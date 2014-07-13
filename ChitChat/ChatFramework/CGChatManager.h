//
//  CGChatManager.h
//  ChitChat
//
//  Created by Neeraj Kumar on 11/07/14.
//  Copyright (c) 2014 CocoaGarage. All rights reserved.
//

/*
 This class is the chat manager. It initiates the local peer and session.
 It adds new peers to the sessino.
 It sends message to the connected peers
 */

#import <Foundation/Foundation.h>
@class MCPeerID;
@class MCBrowserViewController;

@interface CGChatManager : NSObject
@property (nonatomic, readonly) MCBrowserViewController *browser;
+ (CGChatManager *)sharedInstance;
- (void)startAdvertising;
- (void)stopAdvetising;
- (void)sendMessage:(NSString *)message;

@end
