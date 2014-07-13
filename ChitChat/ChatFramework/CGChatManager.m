//
//  CGChatManager.m
//  ChitChat
//
//  Created by Neeraj Kumar on 11/07/14.
//  Copyright (c) 2014 CocoaGarage. All rights reserved.
//

#import "CGChatManager.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "CGUserManager.h"
#import "CGConstants.h"
#import "UIActionSheet+MKBlockAdditions.h"

 static CGChatManager *_sharedInstance = nil;

@interface CGChatManager()<MCNearbyServiceAdvertiserDelegate, MCSessionDelegate>
@property (nonatomic, strong)MCPeerID *peerID; // Represents the device.
@property (nonatomic, strong)MCAdvertiserAssistant *advertiser; // Advertising that the peer is willing to look for chat sessions.
@property (nonatomic, strong)MCSession *session;
@property (nonatomic, strong)MCBrowserViewController *browser;
@end

@implementation CGChatManager

+ (CGChatManager *)sharedInstance {
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
        [_sharedInstance setup];
    });
    return _sharedInstance;
}

- (void)setup {
    // Initialize the peer.
    self.peerID = [[MCPeerID alloc] initWithDisplayName:[CGUserManager currentPeer].peerName];
    self.session = [[MCSession alloc] initWithPeer:_peerID];
    self.session.delegate = self;
    self.advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:SERVICE_TYPE
                                                           discoveryInfo:nil
                                                                 session:_session];

    self.browser = [[MCBrowserViewController alloc] initWithServiceType:SERVICE_TYPE session:self.session];
}

#pragma mark - Public

- (void)startAdvertising {
    [self.advertiser start];
}

- (void)stopAdvetising {
    [self.advertiser stop];
}

#pragma mark - MCNearbyServiceAdvertiserDelegate methods.

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler {
    NSArray *buttons = @[
                         @"Accept",
                         ];
    [UIActionSheet actionSheetWithTitle:[NSString stringWithFormat:@"Received invitation from %@", peerID.displayName] message:nil destructiveButtonTitle:@"Reject" buttons:buttons showInView:[[[UIApplication sharedApplication] delegate] window] onDismiss:^(int buttonIndex) {
        self.session.delegate = self;
        invitationHandler(YES, self.session);
    } onCancel:^{
    }];
    }

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
}

#pragma mark - MCSessionDelegate methods.

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    NSDictionary *dict = @{@"peerID": peerID,
                           @"state" : [NSNumber numberWithInt:state]
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:PeerStateChangeNotification
                                                        object:nil
                                                      userInfo:dict];
}


- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSDictionary *dict = @{@"data": data,
                           @"peerID": peerID
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MessageReceivedNotification
                                                        object:nil
                                                      userInfo:dict];
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    // Not supported now.
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    // Not Supported now.
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    // Not Supported now.
}

#pragma mark -
- (void)sendMessage:(NSString *)message {
    NSError *error = nil;
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    // Since we have 1 session all connected peers.Send the chat to all of them.
    if (self.session.connectedPeers.count > 0) {
        [self.session sendData:messageData
                       toPeers:self.session.connectedPeers
                      withMode:MCSessionSendDataReliable
                         error:&error];
   
    }
    else {
        NSLog(@"No connected peers.");
    }
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

@end
