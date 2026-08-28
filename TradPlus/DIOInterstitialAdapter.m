#import "DIOInterstitialAdapter.h"

@implementation DIOInterstitialAdapter

- (void)showAdFromRootViewController:(UIViewController *)rootViewController {
    if (!self.loadedAd) {
        [self AdShowFailWithError:[self dioErrorWithMessage:@"No ad to show"]];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.loadedAd showAdFromViewController:rootViewController eventHandler:^(DIOAdEvent event) {
        [weakSelf handleShowEvent:event];
    }];
}

- (void)handleShowEvent:(DIOAdEvent)event {
    switch (event) {
        case DIOAdEventOnShown:
            [self AdShow];
            break;
        case DIOAdEventOnClicked:
            [self AdClick];
            break;
        case DIOAdEventOnClosed:
            [self AdClose];
            self.loadedAd = nil;
            break;
        case DIOAdEventOnFailedToShow:
            [self AdShowFailWithError:[self dioErrorWithMessage:@"Ad failed to show"]];
            break;
        default:
            break;
    }
}

@end
