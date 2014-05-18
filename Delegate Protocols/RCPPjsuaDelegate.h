//
//  RCPPjsuaDelegate.h
//  Reception
//
//  Created by Sye Boddeus on 24/03/2014.
//  Copyright (c) 2014 UOW. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RCPPjsuaDelegate <NSObject>

- (void)callEnded;
- (void)callBegan;
- (void)callFailed;
- (void)callRejected;

- (void)accountRegistered;
- (void)accountUnRegistered;

@end
