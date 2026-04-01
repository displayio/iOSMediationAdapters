#import "DIOInitAdapter.h"
#import <DIOSDK/DIOController.h>

@implementation DIOInitAdapter

- (void)initWithInitArgument:(ATAdInitArgument *)adInitArgument {
    NSString *appId = adInitArgument.serverContentDic[@"appID"];

    if ([DIOController sharedInstance].initialized) {
        [self notificationNetworkInitSuccess];
        return;
    }

    [[DIOController sharedInstance] initializeWithAppId:appId
        completionHandler:^{
            NSLog(@"[DIO] SDK initialized, version: %@", [[DIOController sharedInstance] getSDKVersion]);
            [self notificationNetworkInitSuccess];
        }
        errorHandler:^(NSError *error) {
            NSLog(@"[DIO] SDK init failed: %@", error.localizedDescription);
            [self notificationNetworkInitFail:error];
        }];
}

+ (NSString *)sdkVersion {
    return [[DIOController sharedInstance] getSDKVersion];
}

+ (NSString *)adapterVersion {
    return @"1.0.0";
}

@end
