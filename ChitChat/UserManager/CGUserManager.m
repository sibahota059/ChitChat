//
//  CGUserManager.m
//  ChitChat
//
//  Created by Neeraj Kumar on 11/07/14.
//  Copyright (c) 2014 CocoaGarage. All rights reserved.
//

#import "CGUserManager.h"
#import "CGConstants.h"
#import "CGPeer.h"

@implementation CGUserManager

+ (void)savePeer:(CGPeer *)peer {
    @synchronized(self) {
        if (peer.peerName ) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:peer.peerName forKey:KeyPeerName];
            if (peer.avatarImage) {
                [prefs setObject:UIImagePNGRepresentation(peer.avatarImage) forKey:KeyPeerImage];
            }
            [prefs synchronize];
        }
    }
}

+ (void)deletePeer:(CGPeer *)peer {
    @synchronized(self) {
        if (peer.peerName) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs removeObjectForKey:KeyPeerName];
            [prefs removeObjectForKey:KeyPeerImage];
            [prefs synchronize];
        }
    }
}

+ (CGPeer *)currentPeer {
    @synchronized(self) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        CGPeer *peer = [[CGPeer alloc] init];
        peer.peerName = [prefs objectForKey:KeyPeerName];
        NSData* imageData = [prefs objectForKey:KeyPeerImage];
        peer.avatarImage = [UIImage imageWithData:imageData];
        return peer;
    }
}

@end

