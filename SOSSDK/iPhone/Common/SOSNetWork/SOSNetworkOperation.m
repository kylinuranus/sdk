//
//  SOSNetworkOperation.m
//  OnStarAFNetWork
//
//  Created by Gennie Sun on 15/8/20.
//  Modified by Joshua Xu on 15/8/31.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "SOSNetworkOperation.h"
#import "CustomerInfo.h"
#import "SOSMonitor.h"
#import "PingHelper.h"
#import "ClientTraceIdManager.h"
#if __has_include("SOSSDK.h")
#import "SOSSDK.h"
#endif
#import "HDWindowLogger.h"

#pragma mark - testcerBase64 对应域名: *.shanghaionstar.com
//*.shanghaionstar.com
static NSString * const testcerBase64 = @"MIIFGTCCBAGgAwIBAgIQYjsTcjI/52CXFcpCcbSOCjANBgkqhkiG9w0BAQsFADBEMQswCQYDVQQGEwJVUzEWMBQGA1UEChMNR2VvVHJ1c3QgSW5jLjEdMBsGA1UEAxMUR2VvVHJ1c3QgU1NMIENBIC0gRzMwHhcNMTUwOTE3MDAwMDAwWhcNMTgwOTE2MjM1OTU5WjCBjjELMAkGA1UEBhMCQ04xETAPBgNVBAgTCFNoYW5naGFpMREwDwYDVQQHFAhTaGFuZ2hhaTEtMCsGA1UEChQkU2hhbmdoYWkgT25TdGFyIFRlbGVtYXRpY3MgQ28uLCBMdGQuMQswCQYDVQQLFAJJVDEdMBsGA1UEAxQUKi5zaGFuZ2hhaW9uc3Rhci5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC81/gWhch/6utmeKS/+x10D/p4cOyZXoZ97VFq6asSkSYeJXejQ8hsGKomHP5HLnofCmVXfNZiQQrHYiIKktDz/7IoPXyXHV6ciH3vZrmMraZyDmPvqOOCUWzcTKZcXncFw0jkz9KytEpIXht5bPREhRgwMn9jp/+e3tqGnuVyTuGqfkQWlmr253YRr9ghmwogWUDJEC//4aztCkH3zooQ6oYGunsEnn1c4gJQGoVSZTQ+Kx1AauqfxU5zSVdxlz8cIeDraMVLkO8PF99CEVPr0Z17XEW91/PQRzSVi0Tf6iVYcQdydkzuIOaPgSkPJJ1ygI6VN+GiF5swjlVHiPirAgMBAAGjggG6MIIBtjAzBgNVHREELDAqghQqLnNoYW5naGFpb25zdGFyLmNvbYISc2hhbmdoYWlvbnN0YXIuY29tMAkGA1UdEwQCMAAwDgYDVR0PAQH/BAQDAgWgMCsGA1UdHwQkMCIwIKAeoByGGmh0dHA6Ly9nbi5zeW1jYi5jb20vZ24uY3JsMIGdBgNVHSAEgZUwgZIwgY8GBmeBDAECAjCBhDA/BggrBgEFBQcCARYzaHR0cHM6Ly93d3cuZ2VvdHJ1c3QuY29tL3Jlc291cmNlcy9yZXBvc2l0b3J5L2xlZ2FsMEEGCCsGAQUFBwICMDUMM2h0dHBzOi8vd3d3Lmdlb3RydXN0LmNvbS9yZXNvdXJjZXMvcmVwb3NpdG9yeS9sZWdhbDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwHwYDVR0jBBgwFoAU0m/3lvSFP3I8MH0j2oV4m6N8WnwwVwYIKwYBBQUHAQEESzBJMB8GCCsGAQUFBzABhhNodHRwOi8vZ24uc3ltY2QuY29tMCYGCCsGAQUFBzAChhpodHRwOi8vZ24uc3ltY2IuY29tL2duLmNydDANBgkqhkiG9w0BAQsFAAOCAQEACAA+uHtX9wajLjvoxsh+0TqR5P9+yxvbfS6sFgsBcYg70+W7IvUuY64eWo7m1Ms4Hd8/zpOcU3TAIzno5G9p1eO36ThN81Yl7UXmnhvUJILj6DsQrBQKqxTupaC9pSsej5G8XcgvnXlUksf/P2DI+esTdagWliMA+TlsQFT/dMeuM4gowx5DJb/nXpyR5oniZ6+cidoF0jE4AQ2IczpPo8NbH6LicnVrcClec7Wkhbk/p5/zNzw+jMLnwGNauMoXKeB39drRroJcuQexxAQ0JVzGdV8Z7jXhgo5SkXGOBjqdVloBq6vqvtMfP4mx0aQBLevbxgaUUPJGez9E0aMYJw==";
#pragma mark - prdcerBase64  对应域名: api.shanghaionstar.com
//api.shanghaionstar.com
static NSString * const prdcerBase64 = @"MIIFBzCCA++gAwIBAgIQJX1i9u96vUEd6/EQjptXSDANBgkqhkiG9w0BAQsFADBEMQswCQYDVQQGEwJVUzEWMBQGA1UEChMNR2VvVHJ1c3QgSW5jLjEdMBsGA1UEAxMUR2VvVHJ1c3QgU1NMIENBIC0gRzMwHhcNMTUwOTE3MDAwMDAwWhcNMTgwOTE2MjM1OTU5WjCBjjELMAkGA1UEBhMCQ04xETAPBgNVBAgTCFNoYW5naGFpMREwDwYDVQQHFAhTaGFuZ2hhaTErMCkGA1UEChQiU2hhbmdoYWkgT25TdGFyIFRlbGVtYXRpY3MgQ28uIEx0ZDELMAkGA1UECxQCSVQxHzAdBgNVBAMUFmFwaS5zaGFuZ2hhaW9uc3Rhci5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQChgGc2ywqAGU6mYLfiCa7amctBv/0A79o93ZfXSTQP8yRCquo419GgF5v3Z1UIzGuzyPc6x/CQzFydA9qT7weweL6L2SriFrWXwOD27mz+xXUM8cUoFCcHxIamsJ/iTJFwxtekZVGsPOSXFAxXe4yzLm+wVv3mWlt1qYVjjjT/11GuZcyJAvtPTJ0ct0OiA4ymTTkd5wbvgc3rFoYsQGfN/f1EnAGFD0a5h50IVxyrTaS7hizS8JFhrTSf1nta2I/Dt752G1JAz5AiaHujyTAstZBog2zNKoVAWQLymxVOR4zTOqyNFu4GFw85kduLjMmp5/krZ5y7Dpne54alsAyxAgMBAAGjggGoMIIBpDAhBgNVHREEGjAYghZhcGkuc2hhbmdoYWlvbnN0YXIuY29tMAkGA1UdEwQCMAAwDgYDVR0PAQH/BAQDAgWgMCsGA1UdHwQkMCIwIKAeoByGGmh0dHA6Ly9nbi5zeW1jYi5jb20vZ24uY3JsMIGdBgNVHSAEgZUwgZIwgY8GBmeBDAECAjCBhDA/BggrBgEFBQcCARYzaHR0cHM6Ly93d3cuZ2VvdHJ1c3QuY29tL3Jlc291cmNlcy9yZXBvc2l0b3J5L2xlZ2FsMEEGCCsGAQUFBwICMDUMM2h0dHBzOi8vd3d3Lmdlb3RydXN0LmNvbS9yZXNvdXJjZXMvcmVwb3NpdG9yeS9sZWdhbDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwHwYDVR0jBBgwFoAU0m/3lvSFP3I8MH0j2oV4m6N8WnwwVwYIKwYBBQUHAQEESzBJMB8GCCsGAQUFBzABhhNodHRwOi8vZ24uc3ltY2QuY29tMCYGCCsGAQUFBzAChhpodHRwOi8vZ24uc3ltY2IuY29tL2duLmNydDANBgkqhkiG9w0BAQsFAAOCAQEAvedBQuLluuqQ73EHdhKchduWa/sBxpbsBkjqp4tqatNr2fVDZ4I/4Kjm6nMPU0D3TO0Pd4HNMQbesFuxJRbIWRIBEA3N8UWUShux0b5UXS7r8nEMvO9o8I71/Fsoxa09g8WT4OvKo+PIYA+Kyw317ICIo1I5zH0bvVTivaNasUPV6Q8U1dSLfuajk8IU4fwY0d9JIDiabn3ndUkAjbCFDTwzoPrStn0o8+/WHoUN2EGIL2Zs2ZZrClv8/QC9Bjc7+PeTO6EsaRRJsT0xyLiT2k/2CMmZmndgy3NUZemjWCP4/E4P6XEj/FxdTidzNO6wu+wgMSMR3BIQz1KvB1VGUw==";
#pragma mark - portal_testcerBase64 对应域名: *.onstar.com.cn
//*.onstar.com.cn
NSString * const portal_testcerBase64 = @"MIIFCjCCA/KgAwIBAgIQHruUR/7mNs1CurtFGPB4sDANBgkqhkiG9w0BAQsFADBEMQswCQYDVQQGEwJVUzEWMBQGA1UEChMNR2VvVHJ1c3QgSW5jLjEdMBsGA1UEAxMUR2VvVHJ1c3QgU1NMIENBIC0gRzMwHhcNMTUwOTE3MDAwMDAwWhcNMTgwOTE2MjM1OTU5WjCBiTELMAkGA1UEBhMCQ04xETAPBgNVBAgTCFNoYW5naGFpMREwDwYDVQQHFAhTaGFuZ2hhaTEtMCsGA1UEChQkU2hhbmdoYWkgT25TdGFyIFRlbGVtYXRpY3MgQ28uLCBMdGQuMQswCQYDVQQLFAJJVDEYMBYGA1UEAxQPKi5vbnN0YXIuY29tLmNuMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkwQ10636UZfz6O5A46Ph2Rv+PrS3ksH5sJlYQdc457bL3MOLIdZ6+9ujkrwLiuqO1RsG9yXVjBzRJ9ii6I5u6NKXr9k6whKaz0bcK+JLJR5zEUEKwHcRLy+DRNVzAzZ2F8V15RwchpqOy/NopmJOSnJB9uqJCqfXEYHHB28jJjwE7Y4Kjbp5xju7FmE8aR8X2HOzfGizar8Qh1PIsMrY4UrrDYi4i0t4i4ihVxJ5d8BO4K40a4Omg6lt6smU+zRDxzOkio/lB9DRz7XPBRyJUnMf/7qn9rtpePpx35kI6sWEUHvE9MxpdVDWpI2w/bGFvVU86tw+M3DnaAyXPLXiowIDAQABo4IBsDCCAawwKQYDVR0RBCIwIIIPKi5vbnN0YXIuY29tLmNugg1vbnN0YXIuY29tLmNuMAkGA1UdEwQCMAAwDgYDVR0PAQH/BAQDAgWgMCsGA1UdHwQkMCIwIKAeoByGGmh0dHA6Ly9nbi5zeW1jYi5jb20vZ24uY3JsMIGdBgNVHSAEgZUwgZIwgY8GBmeBDAECAjCBhDA/BggrBgEFBQcCARYzaHR0cHM6Ly93d3cuZ2VvdHJ1c3QuY29tL3Jlc291cmNlcy9yZXBvc2l0b3J5L2xlZ2FsMEEGCCsGAQUFBwICMDUMM2h0dHBzOi8vd3d3Lmdlb3RydXN0LmNvbS9yZXNvdXJjZXMvcmVwb3NpdG9yeS9sZWdhbDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwHwYDVR0jBBgwFoAU0m/3lvSFP3I8MH0j2oV4m6N8WnwwVwYIKwYBBQUHAQEESzBJMB8GCCsGAQUFBzABhhNodHRwOi8vZ24uc3ltY2QuY29tMCYGCCsGAQUFBzAChhpodHRwOi8vZ24uc3ltY2IuY29tL2duLmNydDANBgkqhkiG9w0BAQsFAAOCAQEApXusT68JqoVfAlKIh0XhlNtm2mOfmWLt/hhZigr6PX9w1ahToJ4j/wCThhcWO1eqmtxg96SdgCJlIMiRlmS0Db6rkekYC8UR28v9RkeHzhqlTVBrQzcdMNaDde2D0EFoQmuryT2AlXCZOpqRXd+T1K1O87+u6PbiDY+3B/wfw21T2+AVM89uPkQVfMsiGY10cyXY6q3/oF5LxoAruyzc6v5lrh60yi0lpRKi62IRo6khxd0QqrOGQjHPiNMghE9Ie9n6oG5xjCAl/SXsPERphqZD+/vIV3pJo0lYBzqsUh6bya2HaVbr3E4j41ps9wtzqq+FCez6jPLRN+SrAnbGAQ==";
#pragma mark - portal_prdcerBase64 对应域名: www.onstar.com.cn
//www.onstar.com.cn
NSString * const portal_prdcerBase64 = @"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";
#pragma mark - mprdcerBase64 对应域名: m.onstar.com.cn
//m.onstar.com.cn
static NSString * const mprdcerBase64 = @"MIIE+TCCA+GgAwIBAgIQaMXS9Zy01767FaxoHDH14jANBgkqhkiG9w0BAQsFADBEMQswCQYDVQQGEwJVUzEWMBQGA1UEChMNR2VvVHJ1c3QgSW5jLjEdMBsGA1UEAxMUR2VvVHJ1c3QgU1NMIENBIC0gRzMwHhcNMTUwOTE3MDAwMDAwWhcNMTgwOTE2MjM1OTU5WjCBhzELMAkGA1UEBhMCQ04xETAPBgNVBAgTCFNoYW5naGFpMREwDwYDVQQHFAhTaGFuZ2hhaTErMCkGA1UEChQiU2hhbmdoYWkgT25TdGFyIFRlbGVtYXRpY3MgQ28uIEx0ZDELMAkGA1UECxQCSVQxGDAWBgNVBAMUD20ub25zdGFyLmNvbS5jbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALte5KQmqnW60/FYMCV+YNiyLBFryb4GJR8jYa0dSgwL6yedVY/QqOHznc3tJP1Rz3QM3yvrUm1CpLEhTTApsWwSRkxc3CpkzfimJldvg4loIyYM/++R4332mnlQ2Wsb+o1Wm0dPmHofL0Tz/K9rT5BwqiFW5jZ4uZWXXNWkh1VGShawjMYNmPIjJoioVjWddpULYYs0xONBR7QL4fGTIUbrDwixVOZALnlTctcu5W2OtFWhd4WrgFWRiK7RiZrIhLIUJt+fIBy7Ky6vKRpXlUNclw7ehik/Im108Vuf96p61mA8+HsIpqUQiA+WAjCIUS+75wNbJqMlCYJpHj5AansCAwEAAaOCAaEwggGdMBoGA1UdEQQTMBGCD20ub25zdGFyLmNvbS5jbjAJBgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIFoDArBgNVHR8EJDAiMCCgHqAchhpodHRwOi8vZ24uc3ltY2IuY29tL2duLmNybDCBnQYDVR0gBIGVMIGSMIGPBgZngQwBAgIwgYQwPwYIKwYBBQUHAgEWM2h0dHBzOi8vd3d3Lmdlb3RydXN0LmNvbS9yZXNvdXJjZXMvcmVwb3NpdG9yeS9sZWdhbDBBBggrBgEFBQcCAjA1DDNodHRwczovL3d3dy5nZW90cnVzdC5jb20vcmVzb3VyY2VzL3JlcG9zaXRvcnkvbGVnYWwwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMB8GA1UdIwQYMBaAFNJv95b0hT9yPDB9I9qFeJujfFp8MFcGCCsGAQUFBwEBBEswSTAfBggrBgEFBQcwAYYTaHR0cDovL2duLnN5bWNkLmNvbTAmBggrBgEFBQcwAoYaaHR0cDovL2duLnN5bWNiLmNvbS9nbi5jcnQwDQYJKoZIhvcNAQELBQADggEBAGdYEVkZtEkCdjLnUxQdnoX9R4nJ4HRisrOt2j1A5FHzzHmGlkZR4cgl8sN3oDc3VrT9hhAryWMgAH+k/b4HeweAF1lJ3XLA2CWH/C0Psgg3xS7zJ5Jdfh6Ac3L/Ij+NWCyk9LOKWPbpDxj2sRkBzmIBBvANVx7e3foGCEgQ0JaW5KGiA4wf14wDPggJU1781F57OlIxUzBEeDnA4h5yClPGmu9B8oOmCVIghfgLqjyX8b4McMGuqamhgmLoEHi6zU4OA6KkZJwXZe+cFSOcmTjyBo88Zv3yy6k2DwL96WVaFtpOGSnely+ctPb/VZkBJT/bUM/PQz8jMZxl7njmwxI=";
#pragma mark - 2018年4月新的*.shanghaionstar.com 域名证书
static NSString * const newcerBase64 = @"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";
#pragma mark - 2018年8月新的*.shanghaionstar.com 域名证书
static NSString * const newcer201808 = @"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";
#pragma mark - 2018年6月新的*.onstar.com.cn 域名证书
static NSString * const newNginxBase64 = @"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";
#pragma mark - 2018年8月新的*.onstar.com.cn 域名证书
static NSString * const newonstarc201808 = @"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";

#pragma mark - 2020-09-10 测试环境通配符 *.shanghaionstar.com 域名证书
static NSString * const shanghaionstarCer =
    @"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";

#pragma mark - 2020-09-10 测试环境通配符 *.onstar.com.cn 域名证书
static NSString * const onstarCer =
    @"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";


@interface SOSNetworkOperation ()    {
    SOSSuccessBlock mSuccessBlock;
    SOSFailureBlock mFailureBlock;
    dispatch_semaphore_t semo;
    
//    AFHTTPRequestSerializer *requestSerializer;
//    AFHTTPResponseSerializer *responseSerializer;
    BOOL shouldReturnSourceData;
}

/**
 *  网络请求的ID，用于管理请求
 */
@property (nonatomic, assign) unsigned long operationID;

/**
 *  NSMutableURLRequest成员变量
 */
@property (nonatomic ,strong) NSMutableURLRequest *mRequest;

//@property (nonatomic, strong) AFHTTPSessionManager *manager;



//是否显示所有log   NO:只显示错误log
@property (nonatomic, assign) BOOL enableNormalLog;

//监控用，保存当前请求接口连接
@property (nonatomic, copy)NSString *url;

@end

@implementation SOSNetworkOperation
{
    double startTime;
    double endTime;
    double interval;
}

+ (SOSNetworkOperation *)requestWithURL:(NSString *)url
                                 params:(NSString *)params
                           successBlock:(SOSSuccessBlock)successBlock
                           failureBlock:(SOSFailureBlock)failureBlock
{
    return [[SOSNetworkOperation alloc] initWithURL:url
                                             params:params
                                       successBlock:successBlock
                                       failureBlock:failureBlock];

}

+ (SOSNetworkOperation *)requestWithURL:(NSString *)url
                                 params:(NSString *)params
                           successBlock:(SOSSuccessBlock)successBlock
                           failureBlock:(SOSFailureBlock)failureBlock
                   needReturnSourceData:(BOOL)needReturnSourceData
{
    return  [[SOSNetworkOperation alloc] initWithURL:url
                                              params:params
                                        successBlock:successBlock
                                        failureBlock:failureBlock
                                needReturnSourceData:needReturnSourceData];

}

- (SOSNetworkOperation *)initWithURL:(NSString *)url
                              params:(NSString *)params
                        successBlock:(SOSSuccessBlock)successBlock
                        failureBlock:(SOSFailureBlock)failureBlock
{
    return [self initWithURL:url
                      params:params
        needReturnSourceData:NO
                successBlock:successBlock
                failureBlock:failureBlock];
}

- (SOSNetworkOperation *)initWithURL:(NSString *)url
                              params:(NSString *)params
                        successBlock:(SOSSuccessBlock)successBlock
                        failureBlock:(SOSFailureBlock)failureBlock
                needReturnSourceData:(BOOL)needReturnSourceData
{
    return [self initWithURL:url
                      params:params
        needReturnSourceData:needReturnSourceData
                successBlock:successBlock
                failureBlock:failureBlock];
}


- (SOSNetworkOperation *)initWithURL:(NSString *)url
                              params:(NSString *)params
                needReturnSourceData:(BOOL)needReturnSourceData
                        successBlock:(SOSSuccessBlock)successBlock
                        failureBlock:(SOSFailureBlock)failureBlock
{
    return [self initWithURL:url
                      params:params
        needReturnSourceData:needReturnSourceData
        needSSLPolicyWithCer:YES
                successBlock:successBlock
                failureBlock:failureBlock];
}

- (SOSNetworkOperation *)initWithURL:(NSString *)url
                              params:(NSString *)params
                needReturnSourceData:(BOOL)needReturnSourceData
                needSSLPolicyWithCer:(BOOL)needSSLPolicyWithCer
                        successBlock:(SOSSuccessBlock)successBlock
                        failureBlock:(SOSFailureBlock)failureBlock
{
    return [self initWithURL:url
                      params:params
        needReturnSourceData:needReturnSourceData
        needSSLPolicyWithCer:needSSLPolicyWithCer
                 cacheConfig:nil
                successBlock:successBlock
                failureBlock:failureBlock];
}

+ (SOSNetworkOperation *)requestWithURL:(NSString *)url
                                 params:(NSString *)params
                            cacheConfig:(SOSNetWorkCacheConfig *)cacheConfig
                           successBlock:(SOSSuccessBlock)successBlock
                           failureBlock:(SOSFailureBlock)failureBlock
{
    return [[SOSNetworkOperation alloc] initWithURL:url
                                             params:params
                               needReturnSourceData:NO
                               needSSLPolicyWithCer:YES
                                        cacheConfig:cacheConfig
                                       successBlock:successBlock
                                       failureBlock:failureBlock];
}

- (SOSNetworkOperation *)initWithURL:(NSString *)url
                              params:(NSString *)params
                needReturnSourceData:(BOOL)needReturnSourceData
                    needSSLPolicyWithCer:(BOOL)needSSLPolicyWithCer
                         cacheConfig:(SOSNetWorkCacheConfig *)cacheConfig
                        successBlock:(SOSSuccessBlock)successBlock
                        failureBlock:(SOSFailureBlock)failureBlock    {
    return [[SOSNetworkOperation alloc] initWithURL:url params:params enableLog:YES needReturnSourceData:needReturnSourceData needSSLPolicyWithCer:needSSLPolicyWithCer cacheConfig:cacheConfig successBlock:successBlock failureBlock:failureBlock];
}



- (SOSNetworkOperation *)initWithURL:(NSString *)url
                              params:(NSString *)params
                           enableLog:(BOOL)enableLog
                needReturnSourceData:(BOOL)needReturnSourceData
                needSSLPolicyWithCer:(BOOL)needSSLPolicyWithCer
                         cacheConfig:(SOSNetWorkCacheConfig *)cacheConfig
                        successBlock:(SOSSuccessBlock)successBlock
                        failureBlock:(SOSFailureBlock)failureBlock


{
    if (self = [super init]) {
        shouldReturnSourceData = needReturnSourceData;
        self.cacheConfig = cacheConfig;
        self.enableLog = enableLog;
//        self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:url]];
//        [self setSSLPolicyWithCer:needSSLPolicyWithCer && [self.manager.baseURL.scheme isEqualToString:@"https"]];
        [self setSSLPolicyWithCer:[url hasPrefix:@"https"]];
        AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        responseSerializer.acceptableContentTypes = [responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        _enableNormalLog = [SOSEnvConfig config].enableNormalLog;
        _operationID = (NSInteger)[[NSDate date] timeIntervalSince1970] * 1000 + arc4random()%1000;
        NSError *serializationError = nil;
        self.mRequest = [requestSerializer requestWithMethod:@"POST" URLString:url parameters: [params dataUsingEncoding:NSUTF8StringEncoding] error:&serializationError];


        if (successBlock) {

            self.url = url;
            mSuccessBlock = successBlock;
        }
        if (failureBlock) {
            mFailureBlock = failureBlock;
        }
        if (serializationError) {
            if (failureBlock) {
                failureBlock(serializationError.code, nil, serializationError);
            }
            return nil;
        }
        if (params) {
            [self.mRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [self initDefaultHeaderValueForRequest:NO];
        
        self.manager.responseSerializer = responseSerializer;
        self.manager.requestSerializer = requestSerializer;
    }
    return self;
}


- (SOSNetworkOperation *)initWithNOSSLURL:(NSString *)url
                                   params:(NSString *)params
                     needReturnSourceData:(BOOL)needReturnSourceData
                             successBlock:(SOSSuccessBlock)successBlock
                             failureBlock:(SOSFailureBlock)failureBlock
{
    return [self initWithURL:url
                      params:params
        needReturnSourceData:needReturnSourceData
        needSSLPolicyWithCer:NO
                successBlock:successBlock
                failureBlock:failureBlock];
}

- (void)initDefaultHeaderValueForRequest:(BOOL)isUpload    {
    [_mRequest setTimeoutInterval:HTTP_TIME_OUT_NORMAL];
    [_mRequest setValue:@"zh-CN" forHTTPHeaderField:@"Accept-Language"];
    [_mRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    if (!isUpload) {
        //[_mRequest setValue:@"application/json;charset=UTF-8;application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [_mRequest setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];

    }
    [_mRequest setValue:[Util clientInfo] forHTTPHeaderField:@"CLIENT-INFO"];
    [_mRequest setValue:[ClientTraceIdManager sharedInstance].clientTraceId forHTTPHeaderField:@"CLIENT-TRACE-ID"];
    
    NSString * TraceId =[SOSMonitor createTraceId];
    [_mRequest setValue:TraceId forHTTPHeaderField:@"X-B3-TraceId"];
    [_mRequest setValue:TraceId forHTTPHeaderField:@"X-B3-SpanId"];
    [_mRequest setValue:TraceId forHTTPHeaderField:@"X-B3-ParentSpanId"];
    [_mRequest setValue:@"1" forHTTPHeaderField:@"X-B3-Sampled"];
    
}


- (void)setHttpMethod:(NSString *)httpMethod    {
    [SOSMonitor shareInstance].method = httpMethod;
    [_mRequest setHTTPMethod:httpMethod];
}

- (void)setHttpHeaders:(NSDictionary *)headerDict    {
    NSArray* keyList = [headerDict allKeys];
    for(NSString* key in keyList)    {
        NSString *value = [headerDict objectForKey:key];
        if (key && value) {
            [_mRequest setValue:[headerDict objectForKey:key] forHTTPHeaderField:key];
            [self.manager.requestSerializer setValue:[headerDict objectForKey:key] forHTTPHeaderField:key];
        }
    }
}

- (void)setHttpTimeOutInterval:(NSInteger)timeOutInterval    {
    [_mRequest setTimeoutInterval:timeOutInterval];
    self.manager.requestSerializer.timeoutInterval = timeOutInterval;
//    requestSerializer.timeoutInterval = timeOutInterval;
}

- (void)start    {
    //缓存策略
    if (self.cacheConfig) {
        //取缓存
        NSString *cache = [self.cacheConfig getCache];
        if (cache.isNotBlank) {
            self.statusCode = 200;
            self.isFromCache = YES;
            if (mSuccessBlock) {
                mSuccessBlock(self, cache);
            }
        }
    }
    NSDate *startDt = [NSDate date];
    if (!_afOperation) {
        _afOperation = [self.manager dataTaskWithRequest:_mRequest
                                          uploadProgress:nil
                                        downloadProgress:nil
                                       completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                            [self requestCompleteWithResp:response startTime:startDt responseObject:responseObject error:error];
                                       }];
    }
    
    if (self.enableLog && _enableNormalLog) {
        [self printLog];
    }
    [self startCount];
    [_afOperation resume];
}


- (void)setSSLPolicyWithCer:(BOOL) fromCer{
    self.manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    self.manager.securityPolicy.allowInvalidCertificates = YES;
    self.manager.securityPolicy.validatesDomainName = NO;
}

- (void)startSync    {
    semo = dispatch_semaphore_create(0);
    [self start];
    dispatch_semaphore_wait(semo, DISPATCH_TIME_FOREVER);
}

- (void)pause    {
    if (_afOperation.state == NSURLSessionTaskStateRunning) {
        [_afOperation suspend];
    }
}

- (void)resume    {
    if (!_afOperation) {
        [self start];
    }
    if (_afOperation.state == NSURLSessionTaskStateSuspended) {
        [_afOperation resume];
    }   else    {
        //        [_afOperation start];
    }
}

- (void)cancel    {
    [_afOperation cancel];
}

- (void)printLog    {
    DebugLog(@"\n>>>>>> HTTP request [%ld]\nURL [%@]\nMethod [%@]\nHeaders ==>> %@ <<==\nBody ==>> %@ <<===",
          _operationID, [_mRequest.URL absoluteString], [_mRequest HTTPMethod],
          [_mRequest allHTTPHeaderFields], [[NSString alloc] initWithData:[_mRequest HTTPBody] encoding:NSUTF8StringEncoding]);
}


- (NSString *)getErrorStr:(NSError *)error        {
    NSString *errorStr = @"";
    if (error.code == -1009) {
        NNError * offLineError = [[NNError alloc] init];
        [offLineError setCode:[NSString stringWithFormat:@"%ld",(long)error.code]];
        [offLineError setDesc: NSLocalizedString(@"Network_Error_Toast_Message", nil)];
        errorStr = [offLineError mj_JSONString];
    }
    if (error.code == -1011) {
        NNError * offLineError = [[NNError alloc] init];
        [offLineError setCode:[NSString stringWithFormat:@"%ld",(long)error.code]];
        [offLineError setDesc: NSLocalizedString(@"Network_Error_Toast_Message", nil)];
        errorStr = [offLineError mj_JSONString];
    }
    if (error.userInfo) {
        for (id obj in error.userInfo.allValues) {
            if ([obj isKindOfClass:[NSData class]]) {
                errorStr = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
                break;
            }
        }
    }
    return errorStr;
}


+ (SOSNetworkOperation *)requestWithURL:(NSString *)url
                                 params:(NSString *)params
              constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                           successBlock:(SOSSuccessBlock)successBlock
                           failureBlock:(SOSFailureBlock)failureBlock
{
    return [[SOSNetworkOperation alloc] initWithURL:url
                                             params:params
                          constructingBodyWithBlock:block
                                       successBlock:successBlock
                                       failureBlock:failureBlock];
}

- (SOSNetworkOperation *)initWithURL:(NSString *)url
                              params:(NSString *)params
           constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                        successBlock:(SOSSuccessBlock)successBlock
                        failureBlock:(SOSFailureBlock)failureBlock
{
    return [self initWithURL:url
                      params:params
   constructingBodyWithBlock:block
        needReturnSourceData:NO
                successBlock:successBlock
                failureBlock:failureBlock];
}

- (SOSNetworkOperation *)initWithURL:(NSString *)url
                              params:(NSString *)params
           constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                needReturnSourceData:(BOOL)needReturnSourceData
                        successBlock:(SOSSuccessBlock)successBlock
                        failureBlock:(SOSFailureBlock)failureBlock
{
    if (self = [super init]) {
        shouldReturnSourceData = needReturnSourceData;
//        self.manager = [[AFHTTPSessionManager manager] initWithBaseURL:[NSURL URLWithString:url]];
        
        [self setSSLPolicyWithCer:YES];
        AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        _enableNormalLog = [SOSEnvConfig config].enableNormalLog;
        _operationID = (NSInteger)[[NSDate date] timeIntervalSince1970] * 1000 + arc4random()%1000;
        NSError *serializationError = nil;
        self.mRequest = [requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                URLString:url
                                                               parameters:nil
                                                constructingBodyWithBlock:block
                                                                    error:&serializationError];
        if (successBlock) {
            mSuccessBlock = successBlock;
        }
        if (failureBlock) {
            mFailureBlock = failureBlock;
        }
        if (serializationError) {
            if (failureBlock) {
                failureBlock(serializationError.code, nil, serializationError);
            }
            return nil;
        }
        if (params) {
            [self.mRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [self initDefaultHeaderValueForRequest:YES];
        self.manager.responseSerializer = responseSerializer;
        self.manager.requestSerializer = requestSerializer;
    }
    return self;
}

- (void)startUploadTask        {
    NSDate *startDt = [NSDate date];
    if (!_uploadTask) {
        _uploadTask = [self.manager uploadTaskWithStreamedRequest:_mRequest
                                                         progress:nil
                                                completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                                    [self requestCompleteWithResp:response
                                                                        startTime:startDt
                                                                   responseObject:responseObject
                                                                            error:error];
                                                }];
    }
    if (self.enableLog && _enableNormalLog) {
        [self printLog];
    }
    [_uploadTask resume];
}


- (void)requestCompleteWithResp:(NSURLRequest * _Nonnull)response
                      startTime:(NSDate *)startDt
                 responseObject:(id  _Nullable)responseObject
                          error:(NSError * _Nullable) error
{
    _statusCode = ((NSHTTPURLResponse *)response).statusCode;
    NSString *responseStr = shouldReturnSourceData?responseObject:[responseObject mj_JSONString];
    if (![responseObject isKindOfClass:[NSString class]]) {
        responseStr = [responseObject toJson];
        if (!responseStr.length && error.userInfo) {
            responseStr = [self getErrorStr:error];
        }
    }
    NSString *requestLog =  [NSString stringWithFormat:@"\nHTTP request [%ld]\nURL [%@]\nMethod [%@]\nHeaders ==>> %@ <<==\nBody ==>> %@ <<===",
                         _operationID, [_mRequest.URL absoluteString], [_mRequest HTTPMethod],
                         [_mRequest allHTTPHeaderFields], [[NSString alloc] initWithData:[_mRequest HTTPBody] encoding:NSUTF8StringEncoding]];
    if (self.enableLog && _enableNormalLog)     HDNormalLog(requestLog);
    
    if (error) {
        NSString *respLog =  [NSString stringWithFormat:@"\nURL:[%@] \nHTTP response [%ld]\nStatus code [%@] \nError Message [%@]", _afOperation.currentRequest.URL.absoluteString, self.operationID,@(self.statusCode), responseStr];
        
        if (self.enableLog && _enableNormalLog) {
            HDErrorLog(respLog);
            NSLog(@"\nURL:[%@] \n<<<<<< HTTP response [%ld]\nStatus code [%@] \nError Message [%@]", _afOperation.currentRequest.URL.absoluteString, self.operationID,@(self.statusCode), responseStr);
        }
        if (mFailureBlock) {
            if (responseObject == nil && (error.code == - 1009/*网络连接失败*/ || error.code == -1001/*请求超时*/)) {
                [PingHelper sharedInstance].host = @"www.baidu.com";
                [[PingHelper sharedInstance] pingWithBlock:^(BOOL isSuccess) {
                    if (!isSuccess) {
                        [Util showNetworkErrorToastView];
                    }
                }];
            }
            if (_statusCode== 500 && ([responseStr isEqualToString:@""] || responseStr== nil)){
                NNError * serverError = [[NNError alloc] init];
                [serverError setCode:[NSString stringWithFormat:@"%ld",(long)error.code]];
                [serverError setDesc: NSLocalizedString(@"Network_Error_Toast_Message", nil)];
                responseStr = [serverError mj_JSONString];
            }else if (_statusCode == 404) {
                [Util toastWithMessage:@"资源信息未找到"];
            }else{
                if (_statusCode == 508){
                    NNError * serverError = [[NNError alloc] init];
                    NSDictionary *errorDic = [responseStr mj_JSONObject];
                    if (errorDic) {
                        [serverError setCode:errorDic[@"bizCode"]];
                        [serverError setDesc:errorDic[@"bizMsg"]];
                        responseStr = [serverError mj_JSONString];
                    }}
            }
            
            mFailureBlock(_statusCode, responseStr, error);
            [self endCount];
            [[SOSMonitor shareInstance] sendMonitorInfo:self.url ResultCode:[NSString stringWithFormat:@"%ld",_statusCode] spanId:[self.mRequest.allHTTPHeaderFields valueForKey:@"X-B3-TraceId"] responseInterval:[self getResponeInterval]];
        }
    } else {
        NSString *respLog =  [NSString stringWithFormat:@"\nURL:[%@] \nHTTP response [%ld] \n%@ \nStatus code [%@]", _afOperation.currentRequest.URL.absoluteString, self.operationID, responseStr,@(self.statusCode)];
        
        if (self.enableLog && _enableNormalLog) {
            HDSuccessLog(respLog);

            NSLog(@"\nURL:[%@] \nHTTP response [%ld] \n%@ \nStatus code [%@]", _afOperation.currentRequest.URL.absoluteString, self.operationID, responseStr,@(self.statusCode));
        }
        [self endCount];
        if (mSuccessBlock) {
            mSuccessBlock(self, responseStr.length ? responseStr : responseObject);
        }
        [[SOSMonitor shareInstance] sendMonitorInfo:self.url ResultCode:@"200" spanId:[self.mRequest.allHTTPHeaderFields valueForKey:@"X-B3-TraceId"] responseInterval:[self getResponeInterval]];

        //存
        if (self.cacheConfig) {
            [self.cacheConfig saveCache:responseStr];
        }
    }
    if (mSuccessBlock || mFailureBlock) {
        [self handleCommenErrorWithErrorData:responseStr];
    }
//    [self sendRequestDaapWithError:error responseStr:responseStr startTime:startDt];
    semo==NULL?0:dispatch_semaphore_signal(semo);
}

- (void)handleCommenErrorWithErrorData:(NSString *)errorStr    {
    NSDictionary *errorDic = [Util dictionaryWithJsonString:errorStr];
    if ([errorDic isKindOfClass:[NSDictionary class]] && errorDic.allKeys.count) {
        NSString *code = errorDic[@"code"];
        if (!IsStrEmpty(code) && [code isEqualToString:@"E9000"]) {
            NSString *msg = errorDic[@"description"];
            [Util toastWithMessage:[NSString stringWithFormat:@"%@", msg.length ? msg : @""]];
        }
        #if __has_include("SOSSDK.h")
        NSString *error = errorDic[@"error"];
        if ([error isKindOfClass:[NSString class]] && [error isEqualToString:@"invalid_token"] &&
                ![self.url containsString:ONSTAR_API_OAUTH]
            ) {
            [SOSSDK shareInstance].loginState = SOSSDKLoginStateNone;
            //登出操作
#ifndef SOSSDK_SDK
            [Util toastWithMessage:@"登录已过期,请重新登录"];
#endif
            [SOSSDK sos_logOut];
            
        }
        #endif
    }
}

- (AFHTTPSessionManager *)manager {
    static AFHTTPSessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //必须设置BaseURL，坑。。。
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://xxx.xxx.com"]];
//        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    return manager;;
}

- (void)cancelAllRequest
{
    if (self.manager) {
        for (NSURLSessionTask * task in self.manager.tasks) {
            [task cancel];
        }
    }
   
}


-(void)startCount
{
    startTime = CACurrentMediaTime();
}


-(void)endCount
{
    endTime = CACurrentMediaTime();
}


-(NSString*)getResponeInterval
{
    interval = endTime - startTime;
    startTime = 0.0;
    endTime = 0.0;
    interval = interval *1000000;
    NSInteger n = interval;
    return [NSString stringWithFormat:@"%ld",(long)n];
}

+(void)netWorkStatusStart;
{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            {
                //未知网络
                NSLog(@"未知网络");
            }
                break;
            case AFNetworkReachabilityStatusNotReachable:
            {
                //无法联网
                NSLog(@"无法联网");
            }
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                //手机自带网络
                NSLog(@"当前使用的是2g/3g/4g网络");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"netWorkWiFi" object:@NO];
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                //WIFI
                [[NSNotificationCenter defaultCenter] postNotificationName:@"netWorkWiFi" object:@YES];
                NSLog(@"当前在WIFI网络下");
            }
        }
    }];
}

+ (NSString *)getFlutterCerString {
    NSArray *list = @[testcerBase64,portal_testcerBase64,prdcerBase64,portal_prdcerBase64,mprdcerBase64,newcerBase64,newcer201808,newonstarc201808,newNginxBase64];
    NSString *head = @"-----BEGIN CERTIFICATE-----\n";
    NSString *content = [list componentsJoinedByString:@"\n-----END CERTIFICATE-----\n-----BEGIN CERTIFICATE-----\n"];
    NSString *end = @"\n-----END CERTIFICATE-----";;
    return [NSString stringWithFormat:@"%@%@%@",head,content,end];
}

- (void)setHttpbody2:(NSData *)bodyData    {
    [_mRequest setHTTPBody:bodyData];
}

@end

