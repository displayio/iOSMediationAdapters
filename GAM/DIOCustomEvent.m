//
//  DisplayIOCustomEvent.m
//  GAMAdapterForiOS
//
//  Created by Ro Do on 21.08.2023.
//  Copyright © 2023 Display.io. All rights reserved.
//

#import "DIOCustomEvent.h"
#import <DIOSDK/DIOSDK.h>
#include <stdatomic.h>


static NSString *const PARAMETER = @"parameter";
static NSString *const PLACEMENT_ID = @"placementID";

@interface DIOCustomEvent () <GADMediationBannerAd, GADMediationInterstitialAd>

@property(nonatomic, strong) id<GADMediationInterstitialAdEventDelegate> interstitialDelegate;
@property(nonatomic, strong) id<GADMediationBannerAdEventDelegate> inlineDelegate;
@property(nonatomic, strong) DIOAd *dioInterstitialAd;
@property(nonatomic, strong) UIView *adView;

@end

@implementation DIOCustomEvent

#pragma mark GADMediationAdapter implementation

+ (GADVersionNumber)versionFromString:(NSString *)versionString {
    NSArray *versionComponents = [versionString componentsSeparatedByString:@"."];
    GADVersionNumber version = {0};
    if (versionComponents.count > 0) {
        version.majorVersion = [versionComponents[0] integerValue];
    }
    if (versionComponents.count > 1) {
        version.minorVersion = [versionComponents[1] integerValue];
    }
    if (versionComponents.count > 2) {
        version.patchVersion = [versionComponents[2] integerValue];
    }
    return version;
}

+ (GADVersionNumber)adSDKVersion {
    return [self versionFromString:[[DIOController sharedInstance] getSDKVersion]];
}

+ (GADVersionNumber)adapterVersion {
    return [self versionFromString:[[DIOController sharedInstance] getSDKVersion]];
}

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
    return DIOCustomEvent.class;
}

+ (void)setUpWithConfiguration:(GADMediationServerConfiguration *)configuration
             completionHandler:(GADMediationAdapterSetUpCompletionBlock)completionHandler {
    completionHandler(nil);
}

- (nullable NSDictionary *)parseParamsFromConfig:(GADMediationAdConfiguration *)config
                                           error:(NSError **)error {
    NSString *parameter = config.credentials.settings[PARAMETER];
    if (parameter.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:DIO_CUSTOM_EVENT code:GADErrorInvalidArgument userInfo:nil];
        }
        return nil;
    }

    NSData *data = [parameter dataUsingEncoding:NSUTF8StringEncoding];
    id params = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![params isKindOfClass:NSDictionary.class]) {
        if (error) {
            *error = [NSError errorWithDomain:DIO_CUSTOM_EVENT code:GADErrorInvalidArgument userInfo:nil];
        }
        return nil;
    }
    return params;
}

- (DIOAdRequest *)resolveAdRequestForPlacement:(DIOPlacement *)placement
                                        config:(GADMediationAdConfiguration *)config {
    DIOAdRequest *request;
    @try {
        GADCustomEventExtras *extras = config.extras;
        NSDictionary *dioCustomEvent = [extras extrasForLabel:DIO_CUSTOM_EVENT];
        if (dioCustomEvent != nil) {
            request = dioCustomEvent[DIO_AD_REQUEST];
        }
    } @catch (NSException *ignored) {

    }

    if (request == nil) {
        request = [placement newAdRequest];
    } else {
        DIOAdRequest *existed = [placement adRequestById:request.ID];
        if (existed) {
            request = [placement newAdRequest];
        } else {
            [placement addAdRequest:request];
        }
    }
    return request;
}

- (void)loadBannerForAdConfiguration:(GADMediationBannerAdConfiguration *)adConfiguration
                   completionHandler:(GADMediationBannerLoadCompletionHandler)completionHandler {

    if (![DIOController sharedInstance].initialized) {
        NSError *error = [NSError errorWithDomain:DIO_CUSTOM_EVENT code:GADErrorInternalError userInfo:nil];
        completionHandler(nil, error);
        return;
    }

    NSError *paramsError;
    NSDictionary *params = [self parseParamsFromConfig:adConfiguration error:&paramsError];
    if (!params) {
        completionHandler(nil, paramsError);
        return;
    }

    NSString* placementID = params[PLACEMENT_ID];
    if (!placementID) {
        NSError *error = [NSError errorWithDomain:DIO_CUSTOM_EVENT code:GADErrorInvalidArgument userInfo:nil];
        completionHandler(nil, error);
        return;
    }

    DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementID];

    if (!placement) {
        NSError *error = [NSError errorWithDomain:DIO_CUSTOM_EVENT code:GADErrorInvalidArgument userInfo:nil];
        completionHandler(nil, error);
        return;
    }

    DIOAdRequest *request = [self resolveAdRequestForPlacement:placement config:adConfiguration];

    if ([placement isKindOfClass: DIOInterscrollerPlacement.class]){
        DIOInterscrollerPlacement *interscrollerPlacement = (DIOInterscrollerPlacement*)placement;

        if(params[@"isReveal"]){
            BOOL isReveal = [[params valueForKey:@"isReveal"] boolValue];
            interscrollerPlacement.reveal = isReveal;
        }
        if(params[@"showHeader"]){
            BOOL showHeader = [[params valueForKey:@"showHeader"] boolValue];
            interscrollerPlacement.showHeader = showHeader;
        }
        if(params[@"showTapHint"]){
            BOOL showTapHint = [[params valueForKey:@"showTapHint"] boolValue];
            interscrollerPlacement.showTapHint = showTapHint;
        }
    }
    if ([placement isKindOfClass: DIOInlinePlacement.class]){
        DIOInterscrollerPlacement *subPlacement = (DIOInterscrollerPlacement*)[((DIOInlinePlacement*)placement) getSubPlacement:INTERSCROLLER];

        if(params[@"isReveal"]){
            BOOL isReveal = [[params valueForKey:@"isReveal"] boolValue];
            subPlacement.reveal = isReveal;
        }
        if(params[@"showHeader"]){
            BOOL showHeader = [[params valueForKey:@"showHeader"] boolValue];
            subPlacement.showHeader = showHeader;
        }
        if(params[@"showTapHint"]){
            BOOL showTapHint = [[params valueForKey:@"showTapHint"] boolValue];
            subPlacement.showTapHint = showTapHint;
        }
    }

    __weak typeof(self) weakSelf = self;
    [request requestAdWithAdReceivedHandler:^(DIOAd *ad) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        strongSelf.adView = [ad view];

        NSString* type = ad.adUnitType;
        if ([type isEqual:INTERSCROLLER]){
            UIViewController *topViewController = adConfiguration.topViewController;

            if(topViewController == nil) {
                NSError *error = [NSError errorWithDomain:DIO_CUSTOM_EVENT code:GADErrorInternalError userInfo:nil];
                strongSelf.inlineDelegate = completionHandler(nil, error);
                return;
            }
            strongSelf.adView.frame = CGRectMake(0, 0,
                                           topViewController.view.frame.size.width,
                                           topViewController.view.frame.size.height);
        } else if ([type isEqual:BANNER]){
            strongSelf.adView.frame = CGRectMake(0, 0, 320, 50);
        }
        else if ([type isEqual:INFEED] || [type isEqual:MEDIUMRECTANGLE]){
            strongSelf.adView.frame = CGRectMake(0, 0, 300, 250);
        } else {
            strongSelf.inlineDelegate = completionHandler(nil, [NSError errorWithDomain:DIO_CUSTOM_EVENT code:GADErrorMediationAdapterError userInfo:nil]);
            return;
        }
        strongSelf.inlineDelegate = completionHandler(strongSelf, nil);
        [strongSelf handleInlineAdEvents:ad];
    } noAdHandler:^(NSError *error){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        strongSelf.inlineDelegate = completionHandler(nil, error);
    }];

}


- (void)loadInterstitialForAdConfiguration:
(GADMediationInterstitialAdConfiguration *)adConfiguration
                         completionHandler:
(GADMediationInterstitialLoadCompletionHandler)completionHandler {
    self.dioInterstitialAd = nil;
    if (![DIOController sharedInstance].initialized) {
        NSError *error = [NSError errorWithDomain:DIO_CUSTOM_EVENT code:GADErrorInternalError userInfo:nil];
        completionHandler(nil, error);
        return;
    }

    NSError *paramsError;
    NSDictionary *params = [self parseParamsFromConfig:adConfiguration error:&paramsError];
    if (!params) {
        completionHandler(nil, paramsError);
        return;
    }

    NSString* placementID = params[PLACEMENT_ID];
    if (!placementID) {
        NSError *error = [NSError errorWithDomain:DIO_CUSTOM_EVENT code:GADErrorInvalidArgument userInfo:nil];
        completionHandler(nil, error);
        return;
    }
    DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementID];

    if (!placement) {
        NSError *error = [NSError errorWithDomain:DIO_CUSTOM_EVENT code:GADErrorInvalidArgument userInfo:nil];
        completionHandler(nil, error);
        return;
    }

    DIOAdRequest *request = [self resolveAdRequestForPlacement:placement config:adConfiguration];

    __weak typeof(self) weakSelf = self;
    [request requestAdWithAdReceivedHandler:^(DIOAd *ad) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        strongSelf.dioInterstitialAd = ad;
        strongSelf.interstitialDelegate = completionHandler(strongSelf, nil);
    } noAdHandler:^(NSError *error){
        completionHandler(nil, error);
    }];

}

#pragma mark GADMediationBannerAd implementation
- (nonnull UIView *)view {
    return self.adView;
}

#pragma mark GADMediationInterstitialAd implementation
- (void)presentFromViewController:(nonnull UIViewController *)viewController {
    if(!self.dioInterstitialAd) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.dioInterstitialAd showAdFromViewController:viewController eventHandler:^(DIOAdEvent event){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf == nil || strongSelf.interstitialDelegate == nil) {
            return;
        }

        switch (event) {
            case DIOAdEventOnShown:
                [strongSelf.interstitialDelegate willPresentFullScreenView];
                [strongSelf.interstitialDelegate reportImpression];
                break;
            case DIOAdEventOnFailedToShow:{
                NSError *error = [NSError errorWithDomain:DIO_CUSTOM_EVENT code:GADErrorInternalError userInfo:nil];
                [strongSelf.interstitialDelegate didFailToPresentWithError:error];
                break;
            }
            case DIOAdEventOnClicked:
                [strongSelf.interstitialDelegate reportClick];
                break;
            case DIOAdEventOnClosed:
            case DIOAdEventOnAdCompleted:
                [strongSelf.interstitialDelegate willDismissFullScreenView];
                [strongSelf.interstitialDelegate didDismissFullScreenView];
                break;
            case DIOAdEventOnAdStarted:
            case DIOAdEventOnSwipedOut:
            case DIOAdEventOnSnapped:
            case DIOAdEventOnMuted:
            case DIOAdEventOnUnmuted:
                break;
        }
    }];
}

- (void)handleInlineAdEvents:(DIOAd *)ad {
    if(ad == nil || self.inlineDelegate == nil) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [ad setEventHandler:^(DIOAdEvent event) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf == nil || strongSelf.inlineDelegate == nil) {
            return;
        }
        switch (event) {
            case DIOAdEventOnShown:
                [strongSelf.inlineDelegate reportImpression];
                break;
            case DIOAdEventOnFailedToShow:{
                NSError *error = [NSError errorWithDomain:DIO_CUSTOM_EVENT code:GADErrorInternalError userInfo:nil];
                [strongSelf.inlineDelegate didFailToPresentWithError:error];
                break;
            }
            case DIOAdEventOnClicked:
                [strongSelf.inlineDelegate reportClick];
                break;
            case DIOAdEventOnClosed:
            case DIOAdEventOnAdStarted:
            case DIOAdEventOnAdCompleted:
            case DIOAdEventOnSwipedOut:
            case DIOAdEventOnSnapped:
            case DIOAdEventOnMuted:
            case DIOAdEventOnUnmuted:
                break;
        }
    }];
}

@end
