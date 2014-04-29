//
//  RCPAccount.h
//  Reception
//
//  Created by Sye Boddeus on 24/03/2014.
//  Copyright (c) 2014 UOW. All rights reserved.
//

#ifndef Reception_RCPAccount_h
#define Reception_RCPAccount_h

#ifdef __cplusplus
#include <iostream>
#endif

#include <pjsua2.hpp>

#import "pjsuaAccountDelegate.h"

typedef id<pjsuaAccountDelegate> accountDelegate;

using namespace pj;

// Subclass to extend the Account and get notifications etc.
class RCPAccount : public Account {

private:
    accountDelegate mAgent;

public:
    void setCallBackAgent(accountDelegate agent) {
        mAgent = agent;
    }
    
    virtual void onRegState(OnRegStateParam &prm) {
        AccountInfo ai = getInfo();
        
        if (ai.regIsActive) {
            NSLog(@"Account Registered");
            if (mAgent) {
                [mAgent accountRegistered];
            }
        }
        else {
            NSLog(@"Account Unregistered");
            if (mAgent) {
                [mAgent accountUnRegistered];
            }
        }
    }
};

#endif
