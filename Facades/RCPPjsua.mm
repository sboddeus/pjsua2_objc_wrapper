//
//  RCPPjsua.m
//  Reception
//
//  Created by Sye Boddeus on 24/03/2014.
//  Copyright (c) 2014 UOW. All rights reserved.
//

#import "RCPPjsua.h"

#include "RCPCall.h"
#include "RCPAccount.h"

@interface RCPPjsua() {
    std::shared_ptr<RCPCall> mCallAgent;
}

@end

@implementation RCPPjsua

static std::shared_ptr<RCPAccount> mAccountAgent;
static std::shared_ptr<Endpoint> mEndPoint;

#pragma mark - Class Methods

+ (instancetype)sharedInstance
{
    static RCPPjsua* _sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
}

+ (void)configureSharedInstanceWithEndPointConfig:(NSString*)epcfg accountConfig:(NSString*)acfg;
{
    RCPPjsua* sharedInstance = [self sharedInstance];
    
    mEndPoint = std::make_shared<Endpoint>();
    mEndPoint->libCreate();
    
    EpConfig ep_cfg;

    JsonDocument jDocEP;
    jDocEP.loadString(std::string([epcfg cStringUsingEncoding:NSASCIIStringEncoding]));
    jDocEP.readObject(ep_cfg);
    
    mEndPoint->libInit(ep_cfg);
    mEndPoint->libStart();
    
    // Create SIP transport. With error handling
    TransportConfig tcfg;
    tcfg.port = 5060;
    try {
        mEndPoint->transportCreate(PJSIP_TRANSPORT_UDP, tcfg);
    } catch (Error &err) {
        NSLog(@"%s", err.info().c_str());
        return;
    }
    
    // Now create account
    AccountConfig a_cfg;
    
    JsonDocument jDocAcfg;
    jDocAcfg.loadString(std::string([acfg cStringUsingEncoding:NSASCIIStringEncoding]));
    jDocAcfg.readObject(a_cfg);
    
    mAccountAgent = std::make_shared<RCPAccount>();
    mAccountAgent->setCallBackAgent(sharedInstance);
    mAccountAgent->create(a_cfg);
}

+ (BOOL)configured
{
    if (mEndPoint && mAccountAgent) {
        return YES; // Have to do this because of type casting
    }
    
    return NO;
}

#pragma mark - Method Implementations

- (void)makeCallTo:(NSString *)number
{
    if (!mEndPoint || !mAccountAgent) {
        NSLog(@"Class has not been configured");
        return;
    }
    // else make call
    mCallAgent = std::make_shared<RCPCall>(*(mAccountAgent.get()));
    mCallAgent->setCallBackAgent(self);
    
    CallOpParam prm(true);
    prm.opt.audioCount = 1;
    prm.opt.videoCount = 0;
    
    mCallAgent->makeCall([[[NSString alloc]
                           initWithFormat:@"sip:%@", number] cStringUsingEncoding:NSASCIIStringEncoding],
                         prm);
}

- (void)endCall
{
    if (mEndPoint) {
        mEndPoint->hangupAllCalls();
    }
    
    if (self.delegate) {
        [self.delegate callEnded];
    }
}

#pragma mark - pjsuaCallDelegate Methods

- (void)pjsuaCallEnded
{
    if (self.delegate) {
        [self.delegate callEnded];
    }
}

#pragma mark - pjsuaAccountDelegate Methods

- (void)accountUnRegistered
{
    if (self.delegate) {
        [self.delegate accountUnRegistered];
    }
}

- (void)accountRegistered
{
    if (self.delegate) {
        [self.delegate accountRegistered];
    }
}

@end
