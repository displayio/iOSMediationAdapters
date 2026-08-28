#import "DIONativeAdapter.h"
#import <TradPlusAds/TradPlusAdWaterfallItem.h>
#import <DIOSDK/DIONativeMediaView.h>
#import <DIOSDK/DIONativeAdInterface.h>

@interface DIONativeAdapter ()
@property (nonatomic, strong) DIONativeMediaView *mediaSlot;
@property (nonatomic, strong) DIONativeMediaView *iconSlot;
@end

@implementation DIONativeAdapter

- (id<DIONativeAdInterface>)nativeAd {
    if ([self.loadedAd conformsToProtocol:@protocol(DIONativeAdInterface)]) {
        return (id<DIONativeAdInterface>)self.loadedAd;
    }
    return nil;
}

- (void)onAdLoaded:(DIOAd *)ad {
    id<DIONativeAdInterface> native = self.nativeAd;
    if (native == nil) {
        return;
    }

    __weak typeof(self) weakSelf = self;
    [ad setEventHandler:^(DIOAdEvent event) {
        switch (event) {
            case DIOAdEventOnShown:
                [weakSelf AdShow];
                break;
            case DIOAdEventOnClicked:
                [weakSelf AdClick];
                break;
            case DIOAdEventOnClosed:
                [weakSelf AdClose];
                break;
            default:
                break;
        }
    }];

    self.mediaSlot = [[DIONativeMediaView alloc] init];
    self.iconSlot = [[DIONativeMediaView alloc] init];

    TradPlusAdRes *res = [[TradPlusAdRes alloc] init];
    res.title = native.headline;
    res.body = native.body;
    res.ctaText = native.callToAction;
    res.advertiser = native.advertiser;
    res.price = native.price;
    res.mediaView = self.mediaSlot;
    self.waterfallItem.adRes = res;
}

- (UIView *)endRender:(NSDictionary *)viewInfo clickView:(NSArray *)array {
    UIView *root = viewInfo[kTPRendererAdView];
    UILabel *headline = viewInfo[kTPRendererTitleLable];
    UIButton *cta = [viewInfo[kTPRendererCtaLabel] isKindOfClass:[UIButton class]] ? viewInfo[kTPRendererCtaLabel] : nil;

    if (cta) {
        [cta setTitle:self.nativeAd.callToAction forState:UIControlStateNormal];
    }

    UIView *iconContainer = viewInfo[kTPRendererIconView];
    if (iconContainer) {
        iconContainer.userInteractionEnabled = YES;
        [self.iconSlot removeFromSuperview];
        self.iconSlot.translatesAutoresizingMaskIntoConstraints = NO;
        iconContainer.clipsToBounds = YES;
        [iconContainer addSubview:self.iconSlot];
        [NSLayoutConstraint activateConstraints:@[
            [self.iconSlot.leadingAnchor  constraintEqualToAnchor:iconContainer.leadingAnchor],
            [self.iconSlot.trailingAnchor constraintEqualToAnchor:iconContainer.trailingAnchor],
            [self.iconSlot.topAnchor      constraintEqualToAnchor:iconContainer.topAnchor],
            [self.iconSlot.bottomAnchor   constraintEqualToAnchor:iconContainer.bottomAnchor],
        ]];
    }

    [self.nativeAd registerViewForInteraction:root
                                    mediaSlot:self.mediaSlot
                                     iconSlot:self.iconSlot
                                headlineLabel:headline
                                    ctaButton:cta];
    return root;
}

- (void)adViewWillDestroy {
    [self.nativeAd unregisterView];
    [self.nativeAd close];
    [self.mediaSlot destroy];
    [self.iconSlot destroy];
    self.mediaSlot = nil;
    self.iconSlot = nil;
    [super adViewWillDestroy];
}

@end
