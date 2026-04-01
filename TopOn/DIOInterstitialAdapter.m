#import "DIOInterstitialAdapter.h"
#import "DIOBiddingNotice.h"
#import <DIOSDK/DIOSDK.h>

@interface DIOInterstitialAdapter ()
@property (nonatomic, strong) DIOAd *loadedAd;
@end

@implementation DIOInterstitialAdapter

+ (ATBaseMediationAdapter *)getLoadAdAdapter:(ATAdMediationArgument *)argument {
    return [[self alloc] init];
}

- (void)loadADWithArgument:(ATAdMediationArgument *)argument {
    NSString *placementId = argument.serverContentDic[@"placementID"];

    DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementId];
    if (!placement) {
        NSError *error = [NSError errorWithDomain:@"DIOErrorDomain" code:kDIOErrorMisc
                                         userInfo:@{NSLocalizedDescriptionKey: @"Placement not found"}];
        [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
        return;
    }

    DIOAdRequest *adRequest = [placement newAdRequest];
    [adRequest setMediationPlatform:DIOMediationPlatformTopOn];

    __weak typeof(self) weakSelf = self;
    [adRequest requestAdWithAdReceivedHandler:^(DIOAd *ad) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        strongSelf.loadedAd = ad;

        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        if (ad.ecpm) {
            extra[ATAdSendC2SBidPriceKey] = [NSString stringWithFormat:@"%@", ad.ecpm];
            extra[ATAdSendC2SCurrencyTypeKey] = @(ATBiddingCurrencyTypeUS);
        }

        [strongSelf.adStatusBridge atOnInterstitialAdLoadedExtra:extra];
    } noAdHandler:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        [strongSelf.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
    }];
}

- (BOOL)adReadyInterstitialWithInfo:(NSDictionary *)info {
    return self.loadedAd != nil;
}

- (void)showInterstitialInViewController:(UIViewController *)viewController {
    if (!self.loadedAd) return;

    __weak typeof(self) weakSelf = self;
    [self.loadedAd showAdFromViewController:viewController eventHandler:^(DIOAdEvent event) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        switch (event) {
            case DIOAdEventOnShown:
                [strongSelf.adStatusBridge atOnAdShow:nil];
                break;
            case DIOAdEventOnAdStarted:
                [strongSelf.adStatusBridge atOnAdVideoStart:nil];
                break;
            case DIOAdEventOnClicked:
                [strongSelf.adStatusBridge atOnAdClick:nil];
                break;
            case DIOAdEventOnClosed:
                [strongSelf.adStatusBridge atOnAdClosed:nil];
                strongSelf.loadedAd = nil;
                break;
            case DIOAdEventOnAdCompleted:
                [strongSelf.adStatusBridge atOnAdVideoEnd:nil];
                break;
            case DIOAdEventOnFailedToShow:
                {
                    NSError *err = [NSError errorWithDomain:@"DIOErrorDomain" code:kDIOErrorMisc
                                                  userInfo:@{NSLocalizedDescriptionKey: @"Ad failed to show"}];
                    [strongSelf.adStatusBridge atOnAdShowFailed:err extra:nil];
                }
                break;
            default:
                break;
        }
    }];
}

- (void)didReceiveBidResult:(ATBidWinLossResult *)result {
    [DIOBiddingNotice handleBidResult:result forAd:self.loadedAd];
}

- (void)dealloc {
    [_loadedAd finish];
}

@end
