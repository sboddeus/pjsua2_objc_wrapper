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

@property (assign) int incomingCallID;

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
    
    // Create SIP transport. With error handling
    TransportConfig tcfg;
    tcfg.port = 5060;
    try {
        mEndPoint->transportCreate(PJSIP_TRANSPORT_UDP, tcfg);
    } catch (Error &err) {
        NSLog(@"%s", err.info().c_str());
        return;
    }
    mEndPoint->libStart();
    
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

#pragma mark - Instance Initialisation
- (id)init
{
    if (self = [super init]) {
        self.incomingCallID = PJSUA_INVALID_ID;
    }
    
    return self;
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
    
    [self.delegate callEnded];
}

- (void)answerIncomingCall
{
    if (self.incomingCallID == PJSUA_INVALID_ID) {
        return;
    }
    
    // else make call
    mCallAgent = std::make_shared<RCPCall>(*(mAccountAgent.get()), self.incomingCallID);
    mCallAgent->setCallBackAgent(self);
    
    CallOpParam prm(true);
    prm.opt.audioCount = 1;
    prm.opt.videoCount = 0;
    prm.statusCode = PJSIP_SC_OK;

    try {
        mCallAgent->answer(prm);
    } catch (std::exception & exc) {
        NSLog(@"Could not handle call %s", exc.what());
    }
    
    // clean up
    self.incomingCallID = PJSUA_INVALID_ID;
}

#pragma mark - pjsuaCallDelegate Methods

- (void)pjsuaCallEnded
{
    [self.delegate callEnded];
}

- (void)pjsuaCallFailed
{
    [self.delegate callFailed];
}

- (void)pjsuaCallBegan
{
    [self.delegate callBegan];
}

- (void)pjsuaCallRejected
{
    [self.delegate callRejected];
}

#pragma mark - pjsuaAccountDelegate Methods

- (void)incomingCallWithID: (int)callID
{
    self.incomingCallID = callID;
    [self.delegate incomingCall];
}

- (void)accountUnRegistered
{
    [self.delegate accountUnRegistered];
}

- (void)accountRegistered
{
    [self.delegate accountRegistered];
}

@end
