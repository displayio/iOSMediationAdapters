#import "DIOBaseAdapter.h"

@interface DIOInterstitialAdapter : DIOBaseAdapter <ATBaseInterstitialAdapterProtocol>

@property (nonatomic, strong) ATInterstitialAdStatusBridge *adStatusBridge;

@end
