//
//  ISDIOCustomAdapter.m
//  IronSource_iOS
//
//  Created by Ro Do on 22.03.2024.
//

#import "ISDIOCustomAdapter.h"
#import <DIOSDK/DIOSDK.h>

@implementation ISDIOCustomAdapter

- (void)init:(ISAdData*)adData delegate:(id<ISNetworkInitializationDelegate>)delegate {
    
    if ( [[DIOController sharedInstance] initialized]) {
        [delegate onInitDidSucceed];
        return;
    }
    NSString* appID =  [adData getString:@"dio_app_id"];
   
    if (appID == nil || [appID length] == 0) {
        [delegate onInitDidFailWithErrorCode:ISAdapterErrorMissingParams errorMessage:@"Missing App Id"];
        return;
    }
    
    [[DIOController sharedInstance] initializeWithAppId:appID completionHandler:^{
        [delegate onInitDidSucceed];
    } errorHandler:^(NSError *error) {
        [delegate onInitDidFailWithErrorCode:ISAdapterErrorInternal errorMessage:[error localizedDescription]];
    }];
}

- (NSString*)networkSDKVersion {
    return [[DIOController sharedInstance] getSDKVersion];
}

- (NSString*)adapterVersion {
    return [[DIOController sharedInstance] getSDKVersion];
}

@end
