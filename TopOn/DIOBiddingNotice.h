#import <AnyThinkSDK/AnyThinkSDK.h>
#import <DIOSDK/DIOSDK.h>

@interface DIOBiddingNotice : NSObject

+ (void)handleBidResult:(ATBidWinLossResult *)result forAd:(DIOAd *)ad;

@end
