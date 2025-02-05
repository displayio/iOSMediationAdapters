//
//  DisplayIOMediationAdapter.h
//  AppLovinMediation
//
//  Created by Ro Do on 04.04.2022.
//

#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const DIO_AD_REQUEST = @"dioAdRequest";

@interface DisplayIOMediationAdapter : ALMediationAdapter<MAInterstitialAdapter, MAAdViewAdapter, MARewardedAdapter>

@end

NS_ASSUME_NONNULL_END
