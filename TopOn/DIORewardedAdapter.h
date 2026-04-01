#import "DIOBaseAdapter.h"

@interface DIORewardedAdapter : DIOBaseAdapter <ATBaseRewardedAdapterProtocol>

@property (nonatomic, strong) ATRewardedAdStatusBridge *adStatusBridge;

@end
