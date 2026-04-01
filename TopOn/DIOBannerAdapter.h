#import "DIOBaseAdapter.h"

@interface DIOBannerAdapter : DIOBaseAdapter <ATBaseBannerAdapterProtocol>

@property (nonatomic, strong) ATBannerAdStatusBridge *adStatusBridge;

/// Resizes ATBannerView to match the actual DIO ad size by looking for DIOTopOnWrapper in subviews.
/// Required for Interscroller and Inline placements where ad size differs from kATAdLoadingExtraBannerAdSizeKey.
/// Also recommended for any placement that mixes DIO ad sources with different sizes.
///
/// Usage:
/// 1. In didFinishLoadingADWithPlacementID: — after retrieveBannerViewForPlacementID:, before adding positioning constraints.
/// 2. In bannerView:didAutoRefreshWithPlacement:extra: — to handle size changes on auto-refresh.
///
/// @param bannerView The ATBannerView retrieved from TopOn.
/// @param fallbackSize Size to use if DIOTopOnWrapper is not found (e.g. non-DIO ad source won the auction).
/// @return The size that was applied (either from wrapper or fallback).
+ (CGSize)resizeBannerView:(UIView *)bannerView fallbackSize:(CGSize)fallbackSize;

@end
