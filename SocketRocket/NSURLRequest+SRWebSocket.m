//
// Copyright 2012 Square Inc.
// Portions Copyright (c) 2016-present, Facebook, Inc.
//
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree. An additional grant
// of patent rights can be found in the PATENTS file in the same directory.
//

#import "NSURLRequest+SRWebSocket.h"
#import "NSURLRequest+SRWebSocketPrivate.h"

// Required for object file to always be linked.
void import_NSURLRequest_SRWebSocket() { }

NS_ASSUME_NONNULL_BEGIN

static NSString *const SRSSLPinnnedCertificatesKey = @"SocketRocket_SSLPinnedCertificates";
static NSString *const SRSSLClientCertificatesKey = @"SocketRocket_SSLClientCertificate";


@implementation NSURLRequest (SRWebSocket)

- (nullable NSArray *)SR_SSLPinnedCertificates
{
    return [NSURLProtocol propertyForKey:SRSSLPinnnedCertificatesKey inRequest:self];
}

- (nullable NSData *)SR_SSLClientCertificate
{
    return [NSURLProtocol propertyForKey:SRSSLClientCertificatesKey inRequest:self];
}
@end

@implementation NSMutableURLRequest (SRWebSocket)

- (nullable NSArray *)SR_SSLPinnedCertificates
{
    return [NSURLProtocol propertyForKey:SRSSLPinnnedCertificatesKey inRequest:self];
}

- (void)setSR_SSLPinnedCertificates:(nullable NSArray *)SR_SSLPinnedCertificates
{
    [NSURLProtocol setProperty:[SR_SSLPinnedCertificates copy] forKey:SRSSLPinnnedCertificatesKey inRequest:self];
}

//Client
- (nullable NSData *)SR_SSLClientCertificate
{
    return [NSURLProtocol propertyForKey:SRSSLClientCertificatesKey inRequest:self];
}


- (void)setSR_SSLClientCertificate:(nullable NSData *)SR_SSLClientCertificate {
    [NSURLProtocol setProperty:[SR_SSLClientCertificate copy] forKey:SRSSLClientCertificatesKey inRequest:self];
}



@end

NS_ASSUME_NONNULL_END
