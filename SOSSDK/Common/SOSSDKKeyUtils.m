//
//  SOSSDKKeyUtils.m
//  Onstar
//
//  Created by onstar on 2019/3/26.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSSDKKeyUtils.h"

@implementation SOSSDKKeyUtils

+ (NSString *)wxKey {
    if (SOS_BUICK_PRODUCT) {
        return  @"wx3387202af77c0648";
        
    }else if (SOS_CD_PRODUCT) {
        return @"wxc1cbcfd64b6d7b36";
    }else if (SOS_MYCHEVY_PRODUCT) {
        return @"wxb84552d78f4540f9";
    }
    return @"wxf058abe511185306";
}

+ (NSString *)universalLink {
    if (SOS_BUICK_PRODUCT) {
        return @"https://cms.cw.sgmlink.com/ibuickapp/";
    }else if (SOS_CD_PRODUCT) {
        return @"https://cms.cw.sgmlink.com/mycadillac/";
    }else if (SOS_MYCHEVY_PRODUCT) {
        return @"https://mychevyh5.cw.sgmlink.com/landing/";
    }
    return @"https://m.onstar.com.cn/onstar/";
}

+ (NSString *)mapKey {
    if (SOS_BUICK_PRODUCT) {
        return @"5afd3d1aabcc8bfdbb4e0b8032a36ec1";
    }else if (SOS_CD_PRODUCT) {
        return @"495db65492a57ad8edca701a0cbcc1b4";
    }else if (SOS_MYCHEVY_PRODUCT) {
        return @"e2890b4372597547fe9c4a0d272edb7d";
    }
    return @"c246ca608a358678e954c21384c5a6db";
}



 
+ (NSString *)idCardKey {
    if (SOS_BUICK_PRODUCT) {
        return @"yySWY7h3BbS1g4YdJ030JaRf";
    }else if (SOS_CD_PRODUCT) {
        return @"2773CeT03QHTeS0M1HT3CPrN";
    }else if (SOS_MYCHEVY_PRODUCT) {
        return @"Ba9DrEPBAdVdUXPU97W42SWY";
    }
  return  @"Hd2K02TBYHHNN0bC1fge2D8C";
}


+ (NSString *)mdAppId {
    if (SOS_BUICK_PRODUCT) {
        return @"1030";
    }else if (SOS_CD_PRODUCT) {
        return @"";
    }
    return @"1040";
}

+ (NSString *)mdAppKey {
    if (SOS_BUICK_PRODUCT) {
        return @"695eb46b572321ddc412989e160e637e";
    }else if (SOS_CD_PRODUCT) {
        return @"";
    }
    return @"364ab7012fcd85d086b52936d3a62976";
}

+ (NSInteger)mdAppSrc {
    if (SOS_BUICK_PRODUCT) {
        return 130;
    }else if (SOS_CD_PRODUCT) {
        return 0;
    }
    return 40;
}




+ (NSString *)nimAppKey {
    if (SOS_BUICK_PRODUCT) {
        return SOS_DEV?@"b1cc823483bb7bfee064d7c3da5ffba7":@"a7a049214fdfbd799351e8cdac40466d";
    }else if (SOS_CD_PRODUCT) {
        return @"";
    }
    return  SOS_DEV?@"b1cc823483bb7bfee064d7c3da5ffba7":@"a7a049214fdfbd799351e8cdac40466d";
}

+ (NSString *)nimCerName {
    if (SOS_BUICK_PRODUCT) {
        return SOS_DEV?@"newTestP12":@"iOSProduction";
    }else if (SOS_CD_PRODUCT) {
        return @"";
    }
    return SOS_DEV?@"newTestP12":@"iOSProduction";
}

+ (NSString *)updateSecret {
    if (SOS_BUICK_PRODUCT) {
        return @"V+fyMb4X6oRc+E/ZzxOIVw==";
    }else if (SOS_CD_PRODUCT) {
        return @"/j2CTBUaTn8U0Sr6EQMxRw==";
    }else if (SOS_MYCHEVY_PRODUCT) {
        return @"0s9IVoYGOscZzEILDS/+ZA==";
    }
    return @"w8/l5lAOQOxL3S/VRqtuJA==";
}


+ (NSString *)versionPrefix {
    if (SOS_BUICK_PRODUCT) {
        return @"B";
    }else if (SOS_CD_PRODUCT) {
        return @"C";
    }else if (SOS_MYCHEVY_PRODUCT) {
        return @"X";
    }
    return @"";
}

+ (NSString *)appVersion {
    if (SOS_BUICK_PRODUCT) {
        return SOSSDK_VERSION;
    }else if (SOS_CD_PRODUCT) {
        return SOSSDK_VERSION;
    }else if (SOS_MYCHEVY_PRODUCT) {
        return SOSSDK_VERSION;
    }
    return ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]);
}

+ (NSString *)onstarVersion {
    if (SOS_BUICK_PRODUCT) {
        return SOSSDK_VERSION;
    }else if (SOS_CD_PRODUCT) {
        return SOSSDK_VERSION;
    }else if (SOS_MYCHEVY_PRODUCT) {
        return SOSSDK_VERSION;
    }
    return APP_VERSION;
}

+ (NSString *)sdkWebSource {
    if (SOS_ONSTAR_PRODUCT) {
        return @"";
    }
    return @"oneapp";
}

+ (NSString *)paySchemeUrl {
    if (SOS_BUICK_PRODUCT) {
        return @"SOSPayBuick";
    }else if (SOS_CD_PRODUCT) {
        return @"SOSPayCadillac";
    }else if (SOS_MYCHEVY_PRODUCT) {
        return @"SOSPayMychevy";
    }
    return @"";
}

+ (NSString *)bleSchemeUrl {
    if (SOS_BUICK_PRODUCT) {
        return @"com.onstar.buick";
    }else if (SOS_CD_PRODUCT) {
        return @"";
    }else if (SOS_MYCHEVY_PRODUCT) {
        return  @"com.onstar.mychevy";
    }
    return @"com.onstar.onstarble";
}



+ (NSString *)jpushAppKey {
    if (SOS_ONSTAR_PRODUCT) {
        return SOS_DEV ? @"b4f8632dc45c1e12ab227ed9" : @"14f111976871931c0786ba3a";
    }else if (SOS_MYCHEVY_PRODUCT) {
        return SOS_DEV ? @"788ac27be9293eb78a83e6d7" : @"72670b55cd481ce9f461c627";
    }
    return @"";
}

+ (NSString *)buglyAppKey {
    if (SOS_BUICK_PRODUCT) {
        return SOS_DEV ? @"f3a83ac978" : @"15c796aa62";
    }else if (SOS_CD_PRODUCT) {
        return SOS_DEV ? @"8c660265f3" : @"5670457ed8";
    }else if (SOS_MYCHEVY_PRODUCT) {
        return SOS_DEV ? @"" : @"";
    }
    return SOS_DEV ? @"c3ed189f55" : @"6d74944cbb";
}


@end
