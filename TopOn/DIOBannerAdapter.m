#import "DIOBannerAdapter.h"
#import "DIOBiddingNotice.h"
#import "DIOTopOnWrapper.h"
#import <DIOSDK/DIOSDK.h>

@interface DIOBannerAdapter ()
@property (nonatomic, strong) DIOAd *loadedAd;
@end

@implementation DIOBannerAdapter

+ (ATBaseMediationAdapter *)getLoadAdAdapter:(ATAdMediationArgument *)argument {
    return [[self alloc] init];
}

- (void)loadADWithArgument:(ATAdMediationArgument *)argument {
    NSString *placementId = argument.serverContentDic[@"placementID"];
    NSDictionary *localExtra = argument.localInfoDic;

    DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementId];
    if (!placement) {
        NSError *error = [NSError errorWithDomain:@"DIOErrorDomain" code:kDIOErrorMisc
                                         userInfo:@{NSLocalizedDescriptionKey: @"Placement not found"}];
        [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
        return;
    }

    [self setupInterscrollerConfig:localExtra placement:placement];

    DIOAdRequest *adRequest = [self resolveAdRequest:localExtra placement:placement];
    [adRequest setMediationPlatform:DIOMediationPlatformTopOn];

    __weak typeof(self) weakSelf = self;
    [adRequest requestAdWithAdReceivedHandler:^(DIOAd *ad) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        strongSelf.loadedAd = ad;
        UIView *adView = [ad view];

        [ad setEventHandler:^(DIOAdEvent event) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            switch (event) {
                case DIOAdEventOnShown:
                    [self.adStatusBridge atOnAdShow:nil];
                    break;
                case DIOAdEventOnClicked:
                    [self.adStatusBridge atOnAdClick:nil];
                    break;
                case DIOAdEventOnClosed:
                    [self.adStatusBridge atOnAdClosed:nil];
                    break;
                case DIOAdEventOnAdStarted:
                    [self.adStatusBridge atOnAdVideoStart:nil];
                    break;
                case DIOAdEventOnAdCompleted:
                    [self.adStatusBridge atOnAdVideoEnd:nil];
                    break;
                case DIOAdEventOnFailedToShow: {
                    NSError *err = [NSError errorWithDomain:@"DIOErrorDomain" code:kDIOErrorMisc
                                                  userInfo:@{NSLocalizedDescriptionKey: @"Ad failed to show"}];
                    [self.adStatusBridge atOnAdShowFailed:err extra:nil];
                    break;
                }
                default:
                    break;
            }
        }];

        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        if (ad.ecpm) {
            extra[ATAdSendC2SBidPriceKey] = [NSString stringWithFormat:@"%@", ad.ecpm];
            extra[ATAdSendC2SCurrencyTypeKey] = @(ATBiddingCurrencyTypeUS);
        }

        CGSize adSize = [strongSelf adSizeForAdUnitType:ad.adUnitType];
        DIOTopOnWrapper *wrapper = [[DIOTopOnWrapper alloc] initWithAdView:adView adSize:adSize];
        [strongSelf.adStatusBridge atOnBannerAdLoadedWithView:wrapper adExtra:extra];
    } noAdHandler:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        [strongSelf.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
    }];
}

+ (CGSize)resizeBannerView:(UIView *)bannerView fallbackSize:(CGSize)fallbackSize {
    DIOTopOnWrapper *wrapper = nil;
    for (UIView *sub in bannerView.subviews) {
        if ([sub isKindOfClass:[DIOTopOnWrapper class]]) {
            wrapper = (DIOTopOnWrapper *)sub;
            break;
        }
    }

    CGSize size = (wrapper && !CGSizeEqualToSize(wrapper.adSize, CGSizeZero)) ? wrapper.adSize : fallbackSize;

    // Remove old width/height constraints before adding new ones (auto-refresh case)
    NSMutableArray *toRemove = [NSMutableArray array];
    for (NSLayoutConstraint *c in bannerView.constraints) {
        if (c.firstAttribute == NSLayoutAttributeWidth || c.firstAttribute == NSLayoutAttributeHeight) {
            if (c.firstItem == bannerView && c.secondItem == nil) {
                [toRemove addObject:c];
            }
        }
    }
    [NSLayoutConstraint deactivateConstraints:toRemove];

    [NSLayoutConstraint activateConstraints:@[
        [bannerView.widthAnchor constraintEqualToConstant:size.width],
        [bannerView.heightAnchor constraintEqualToConstant:size.height]
    ]];

    if (wrapper) {
        wrapper.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [wrapper.topAnchor constraintEqualToAnchor:bannerView.topAnchor],
            [wrapper.bottomAnchor constraintEqualToAnchor:bannerView.bottomAnchor],
            [wrapper.leadingAnchor constraintEqualToAnchor:bannerView.leadingAnchor],
            [wrapper.trailingAnchor constraintEqualToAnchor:bannerView.trailingAnchor]
        ]];
    }

    return size;
}

- (void)didReceiveBidResult:(ATBidWinLossResult *)result {
    [DIOBiddingNotice handleBidResult:result forAd:self.loadedAd];
}

#pragma mark - Ad Size

- (CGSize)adSizeForAdUnitType:(NSString *)adUnitType {
    if ([adUnitType isEqualToString:BANNER]) {
        return CGSizeMake(320, 50);
    } else if ([adUnitType isEqualToString:INFEED] || [adUnitType isEqualToString:MEDIUMRECTANGLE]) {
        return CGSizeMake(300, 250);
    } else if ([adUnitType isEqualToString:INTERSCROLLER]) {
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        return CGSizeMake(screenBounds.size.width, screenBounds.size.height);
    }
    return CGSizeZero;
}

#pragma mark - Interscroller Config

- (void)setupInterscrollerConfig:(NSDictionary *)localExtra placement:(DIOPlacement *)placement {
    if ([placement.type isEqualToString:INTERSCROLLER]) {
        [self applyInterscrollerSettings:localExtra placement:(DIOInterscrollerPlacement *)placement];
    } else if ([placement.type isEqualToString:INLINE]) {
        DIOInlinePlacement *inlinePlacement = (DIOInlinePlacement *)placement;
        DIOPlacement *subPlacement = [inlinePlacement getSubPlacement:INTERSCROLLER];
        if (subPlacement) {
            [self applyInterscrollerSettings:localExtra placement:(DIOInterscrollerPlacement *)subPlacement];
        }
    }
}

- (void)applyInterscrollerSettings:(NSDictionary *)localExtra placement:(DIOInterscrollerPlacement *)placement {
    NSNumber *isReveal = localExtra[kDIOIsRevealKey];
    NSNumber *showHeader = localExtra[kDIOShowHeaderKey];
    NSNumber *showTapHint = localExtra[kDIOShowTapHintKey];

    if (isReveal && ![isReveal boolValue]) {
        placement.reveal = NO;
    }
    if (showHeader && ![showHeader boolValue]) {
        placement.showHeader = NO;
    }
    if (showTapHint && ![showTapHint boolValue]) {
        placement.showTapHint = NO;
    }
}

#pragma mark - AdRequest Reuse

- (DIOAdRequest *)resolveAdRequest:(NSDictionary *)localExtra placement:(DIOPlacement *)placement {
    DIOAdRequest *adRequest = localExtra[kDIOAdRequestKey];
    BOOL isUsed = NO;

    if (adRequest) {
        @try {
            DIOAdRequest *existing = [placement adRequestById:adRequest.ID];
            isUsed = (existing != nil);
        } @catch (NSException *e) {
            isUsed = YES;
        }
    }

    if (!adRequest || isUsed) {
        adRequest = [placement newAdRequest];
    } else {
        [placement addAdRequest:adRequest];
    }

    return adRequest;
}

- (void)dealloc {
    [_loadedAd finish];
}

@end
