//
//  CGConstants.h
//  ChitChat
//
//  Created by Neeraj Kumar on 11/07/14.
//  Copyright (c) 2014 CocoaGarage. All rights reserved.
//

static NSString *const  CGServiceType = @"com.cocoagarage.ChitChat-service";
static NSString *const  KeyPeerName = @"peerName";
static NSString *const  KeyPeerImage = @"peerImage";

#define SERVICE_TYPE @"SampleService" // Remove this.

// Notification constants
static NSString *const FoundPeerNotification = @"com.cg.notification.foundPeer";
static NSString *const PeerStateChangeNotification = @"com.cg.notification.peerStateChange";
static NSString *const MessageReceivedNotification = @"com.cg.notification.MessageReceived";


// String constants.
static NSString *const TapToBrowse = @"Tap to Browse for Devices";


#ifndef MyMacros_h
#define MyMacros_h

static inline CGFloat width(UIView *view) { return view.frame.size.width; }
static inline CGFloat height(UIView *view) { return view.frame.size.height; }
static inline int ScreenHeight(){ return [UIScreen mainScreen].bounds.size.height; }
static inline int ScreenWidth(){ return [UIScreen mainScreen].bounds.size.width; }
static inline UIColor *AppLightBlueColor() {
    return [UIColor colorWithRed:30.0/255.0 green:174.0/255.0 blue:236.0/255.0 alpha:1.0];
}
static inline UIColor *AppDarkBlueColor() {
    return [UIColor colorWithRed:30/255.0 green:66.0/255.0 blue:147.0/255.0 alpha:1.0];
}
static inline NSString *InviteToChat(NSString *invitee) {
    return [NSString stringWithFormat:@"You were invited to chat by : %@", invitee];
}

#endif






