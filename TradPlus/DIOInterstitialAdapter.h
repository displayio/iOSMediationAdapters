#import "DIOBaseAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIOInterstitialAdapter : DIOBaseAdapter

/// Maps a DIO ad event to TradPlus callbacks. Overridable (rewarded adds the reward callback).
- (void)handleShowEvent:(DIOAdEvent)event;

@end

NS_ASSUME_NONNULL_END
