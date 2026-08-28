#import "DIOBannerAdapter.h"
#import <TradPlusAds/TradPlusAdWaterfallItem.h>

@implementation DIOBannerAdapter

- (void)onAdLoaded:(DIOAd *)ad {
    __weak typeof(self) weakSelf = self;
    [ad setEventHandler:^(DIOAdEvent event) {
        switch (event) {
            case DIOAdEventOnShown:
                [weakSelf AdShow];
                break;
            case DIOAdEventOnClicked:
                [weakSelf AdClick];
                break;
            default:
                break;
        }
    }];
    [self AdBannerSizeDidChange:[self sizeForAd:ad]];
}

- (CGSize)sizeForAd:(DIOAd *)ad {
    NSString *type = ad.adUnitType;
    if ([type isEqualToString:INTERSCROLLER]) {
        return [self fullscreenSize];
    }
    if ([type isEqualToString:INFEED]) {
        return CGSizeMake(300, 250);
    }
    return CGSizeMake(320, 50);
}

- (CGSize)fullscreenSize {
    UIViewController *root = self.waterfallItem.bannerRootViewController ?: self.rootViewController;
    UIViewController *top = [self getTopViewController:root];
    CGSize size = top.view.bounds.size;
    if (size.width > 0 && size.height > 0) {
        return size;
    }
    return UIScreen.mainScreen.bounds.size;
}

- (id)getCustomObject {
    return self.loadedAd.view;
}

- (void)bannerDidAddSubView:(UIView *)subView {
    UIView *adView = subView.subviews.firstObject;
    adView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [adView.centerXAnchor constraintEqualToAnchor:subView.centerXAnchor],
        [adView.topAnchor constraintEqualToAnchor:subView.topAnchor],
        [adView.bottomAnchor constraintEqualToAnchor:subView.bottomAnchor],
    ]];
}

@end
