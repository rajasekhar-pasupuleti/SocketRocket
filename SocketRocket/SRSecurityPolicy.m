//
// Copyright (c) 2016-present, Facebook, Inc.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree. An additional grant
// of patent rights can be found in the PATENTS file in the same directory.
//

#import "SRSecurityPolicy.h"
#import "SRPinningSecurityPolicy.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const SRSSLClientCertificatesKey = @"SocketRocket_SSLClientCertificate";

@interface SRSecurityPolicy ()

@property (nonatomic, assign, readonly) BOOL certificateChainValidationEnabled;

@end

@implementation SRSecurityPolicy

+ (instancetype)defaultPolicy
{
    return [self new];
}

+ (instancetype)pinnningPolicyWithCertificates:(NSArray *)pinnedCertificates
{
    return [[SRPinningSecurityPolicy alloc] initWithCertificates:pinnedCertificates];
}


- (instancetype)initWithCertificateChainValidationEnabled:(BOOL)enabled
{
    self = [super init];
    if (!self) { return self; }

    _certificateChainValidationEnabled = enabled;

    return self;
}

- (instancetype)init
{
    return [self initWithCertificateChainValidationEnabled:YES];
}

- (void)updateSecurityOptionsInStream:(NSStream *)stream
{
    // Enforce TLS 1.2
    [stream setProperty:(__bridge id)CFSTR("kCFStreamSocketSecurityLevelTLSv1_2") forKey:(__bridge id)kCFStreamPropertySocketSecurityLevel];

    // Validate certificate chain for this stream if enabled.
    NSMutableDictionary *sslOptions = [NSMutableDictionary new];
    [sslOptions setDictionary: @{ (__bridge NSString *)kCFStreamSSLValidatesCertificateChain : @(self.certificateChainValidationEnabled) }];
    
    
    
    // Import client Certificate
    
    NSData *clientCertificate = _SR_SSLClientCertificate;
    
    if (clientCertificate) {
       
        // Import .p12 data
        CFArrayRef keyref = NULL;
        OSStatus sanityChesk = SecPKCS12Import((__bridge CFDataRef)clientCertificate,
                                               (__bridge CFDictionaryRef)[NSDictionary
                                                                          dictionaryWithObject: @"CSyXr3C05AWS"
                                                                          forKey:(__bridge id)kSecImportExportPassphrase],
                                               &keyref);
        if (sanityChesk != noErr) {
            NSLog(@"Error while importing pkcs12 [%d]", (int)sanityChesk);
        } else
          NSLog(@"Success opening p12 certificate.");

        // Identity
        CFDictionaryRef identityDict = CFArrayGetValueAtIndex(keyref, 0);
        SecIdentityRef identityRef = (SecIdentityRef)CFDictionaryGetValue(identityDict,
                                                                          kSecImportItemIdentity);

        // Cert
        SecCertificateRef cert = NULL;
        OSStatus status = SecIdentityCopyCertificate(identityRef, &cert);
        if (status)
          NSLog(@"SecIdentityCopyCertificate failed.");

        // the certificates array, containing the identity then the root certificate
        NSArray *myCerts = [[NSArray alloc] initWithObjects:(__bridge id)identityRef, (__bridge id)cert, nil];
        
    [sslOptions setValue:(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL forKey:(NSString*)kCFStreamSSLLevel];
    [sslOptions setValue:(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL forKey:(NSString*)kCFStreamPropertySocketSecurityLevel];
    [sslOptions setValue:myCerts forKey:(NSString *)kCFStreamSSLCertificates];
    [sslOptions setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCFStreamSSLIsServer];

    }
    
    [stream setProperty:sslOptions forKey:(__bridge NSString *)kCFStreamPropertySSLSettings];
}

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain
{
    // No further evaluation happens in the default policy.
    return YES;
}

@end

NS_ASSUME_NONNULL_END

