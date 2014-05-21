//
//  RCPPjsua.h
//  Reception
//
//  Created by Sye Boddeus on 24/03/2014.
//  Copyright (c) 2014 UOW. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCPPjsuaDelegate.h"
#import "pjsuaCallDelegate.h"
#import "pjsuaAccountDelegate.h"

@interface RCPPjsua : NSObject <pjsuaCallDelegate, pjsuaAccountDelegate>

@property (weak) id<RCPPjsuaDelegate> delegate;

+ (void)configureSharedInstanceWithEndPointConfig:(NSString*)epcfg accountConfig:(NSString*)acfg;
+ (instancetype)sharedInstance;
+ (BOOL)configured;

- (void)makeCallTo:(NSString*)number;
- (void)endCall;

- (void)answerIncomingCall;

@end
