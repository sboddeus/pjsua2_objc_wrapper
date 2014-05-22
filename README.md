# PJSIP - Objective-C Wrapper

First and foremost, see http://www.pjsip.org for details on the pjsip project.

This project currently provides a stable wrapper for pjsip 2.2.1.
The interesting / helpful classes reside in the Facades folder.

After building the libraries and including the pjsip header files, you can use this project to provide a highlevel Objective-C wrapper of the PJSIP C++ API.

## Usage

After including the pjsip libraries and headers, as well as this projects files into your project, the RCPPjsua class can be used as follows.

### Configuring 

First you will need to configure the shared instance of the RCPPjsua class by calling the following methd:

```Objective-C
+ (void)configureSharedInstanceWithEndPointConfig:(NSString*)epcfg accountConfig:(NSString*)acfg;
```

The two arguments should provide json formatted as provided in the Example folder.

You can then get the shared instance by calling:

```Objective-C
+ (instancetype)sharedInstance;
```

At which point you can set its delegate and call methods described in RCPPjsua.h. As well as recieve callbacks described in RCPPjsuaDelegate.h

