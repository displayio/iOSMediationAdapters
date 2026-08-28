#import "DIORewardedAdapter.h"

@implementation DIORewardedAdapter

- (void)handleShowEvent:(DIOAdEvent)event {
    if (event == DIOAdEventOnAdCompleted) {
        [self AdRewardedWithInfo:nil];
        return;
    }
    [super handleShowEvent:event];
}

@end
