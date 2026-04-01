#import <AnyThinkSDK/AnyThinkSDK.h>

extern NSString *const kDIOAdRequestKey;
extern NSString *const kDIOIsRevealKey;
extern NSString *const kDIOShowHeaderKey;
extern NSString *const kDIOShowTapHintKey;

@interface DIOBaseAdapter : ATBaseMediationAdapter

- (Class)initializeClassName;

@end
