#import <TradPlusAds/TradPlusBaseAdapter.h>
#import <DIOSDK/DIOSDK.h>

NS_ASSUME_NONNULL_BEGIN

/// Keys read from `item.config` (configured in the TradPlus dashboard custom-network JSON).
extern NSString * const kDIOAppIdKey;        // "appID"
extern NSString * const kDIOPlacementIdKey;  // "placementID"

extern NSString * const kDIOAdRequestKey;    // "DIO_AD_REQUEST"     DIOAdRequest *
extern NSString * const kDIORevealKey;       // "DIO_IS_REVEAL"      NSNumber (BOOL)
extern NSString * const kDIOShowHeaderKey;   // "DIO_SHOW_HEADER"    NSNumber (BOOL)
extern NSString * const kDIOShowTapHintKey;  // "DIO_SHOW_TAP_HINT"  NSNumber (BOOL)

@interface DIOBaseAdapter : TradPlusBaseAdapter

@property (nonatomic, strong, nullable) DIOAd *loadedAd;

/// Format-specific setup right after a DIO ad is received (banner overrides for size + event handler).
- (void)onAdLoaded:(DIOAd *)ad;

- (NSError *)dioErrorWithMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
