//
//  CGUserManager.h
//  ChitChat
//
//  Created by Neeraj Kumar on 11/07/14.
//  Copyright (c) 2014 CocoaGarage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CGPeer.h"

@interface CGUserManager : NSObject
+ (void)savePeer:(CGPeer *)peer;
+ (void)deletePeer:(CGPeer *)peer;
+ (CGPeer *)currentPeer;
@end
