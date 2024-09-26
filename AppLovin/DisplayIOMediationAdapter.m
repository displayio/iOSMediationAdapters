//
//  DisplayIOMediationAdapter.m
//  AppLovinMediation
//
//  Created by Ro Do on 04.04.2022.
//

#import "DisplayIOMediationAdapter.h"
#import <DIOSDK/DIOController.h>
#import <DIOSDK/DIOPlacement.h>
#import <DIOSDK/DIOBannerPlacement.h>
#import <DIOSDK/DIOMediumRectanglePlacement.h>
#import <DIOSDK/DIOInfeedPlacement.h>
#import <DIOSDK/DIOInterstitialPlacement.h>
#import <DIOSDK/DIOInterstitialHtml.h>
#import <DIOSDK/DIOInterstitialVast.h>
#import <DIOSDK/DIOInterscrollerPlacement.h>


@implementation DisplayIOMediationAdapter

DIOAd *dioInterstitialAd;
DIOAd *dioInlineAd;
DIOAd *dioInlineAdImpressed;

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    if ( [[DIOController sharedInstance] initialized]) {
        completionHandler(MAAdapterInitializationStatusInitializedSuccess, nil);
        [self log: @"DIO SDK Initialized"];
        return;
    }
    NSString* appID =  parameters.serverParameters[@"app_id"];
    [self log: @"Initializing DIO SDK adapter... "];
    completionHandler(MAAdapterInitializationStatusInitializing, nil);
    
    [[DIOController sharedInstance] initializeWithAppId:appID completionHandler:^{
        completionHandler(MAAdapterInitializationStatusInitializedSuccess, nil);
        [self log: @"DIO SDK Initialized"];
    } errorHandler:^(NSError *error) {
        completionHandler(MAAdapterInitializationStatusInitializedFailure, nil);
        [self log: @"DIO SDK Initialization Fail"];
    }];
}

- (NSString *)SDKVersion
{
    return [DIOController sharedInstance].getSDKVersion;
}

- (NSString *)adapterVersion
{
    return [DIOController sharedInstance].getSDKVersion;
}

- (void)destroy
{
    if (dioInterstitialAd != nil && dioInterstitialAd.impressed) {
        [dioInterstitialAd finish];
        dioInterstitialAd = nil;
    }
    if (dioInlineAdImpressed != nil) {
        [dioInlineAdImpressed finish];
        dioInlineAdImpressed = nil;
    }
}


- (void)loadInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate {
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    
    DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementId];
    if (![placement isKindOfClass:[DIOInterstitialPlacement class]]) {
        [delegate didFailToLoadInterstitialAdWithError:MAAdapterError.internalError];
        return;
    }
    DIOAdRequest *adRequest;
    
    @try {
        NSDictionary<NSString *, id> * localParams = [parameters localExtraParameters];
        adRequest = localParams[DIO_AD_REQUEST];
    } @catch (NSException *ignored) {
        
    }
    if (adRequest != nil) {
        [placement addAdRequest: adRequest];
    } else {
        adRequest = [placement newAdRequest];
    }
    
    [adRequest requestAdWithAdReceivedHandler:^(DIOAd *ad) {
        [self log: @"AD LOADED"];
        dioInterstitialAd = ad;
        [delegate didLoadInterstitialAd];
    } noAdHandler:^(NSError *error){
        [self log: @"NO AD: %@", error.localizedDescription];
        [delegate didFailToLoadInterstitialAdWithError:MAAdapterError.noFill];
    }];
}

- (void)showInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate {
    if (dioInterstitialAd != nil) {
        UIViewController *presentingViewController;
        if ( ALSdk.versionCode >= 11020199 ) {
            presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        } else {
            presentingViewController = [ALUtils topViewControllerFromKeyWindow];
        }
        
        [dioInterstitialAd showAdFromViewController:presentingViewController eventHandler:^(DIOAdEvent event){
            switch (event) {
                case DIOAdEventOnShown:{
                    [delegate didDisplayInterstitialAd];
                    break;
                }
                case DIOAdEventOnFailedToShow:{
                    [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adDisplayFailedError];
                    break;
                }
                case DIOAdEventOnClicked:{
                    [delegate didClickInterstitialAd];
                    break;
                }
                case DIOAdEventOnClosed:
                case DIOAdEventOnAdCompleted:{
                    [delegate didHideInterstitialAd];
                    break;
                }
                    
                case DIOAdEventOnSwipedOut:
                case DIOAdEventOnSnapped:
                case DIOAdEventOnMuted:
                case DIOAdEventOnUnmuted:
                    break;
            }
        }];
        
    } else {
        [delegate didFailToDisplayInterstitialAdWithError:MAAdapterError.internalError];
    }
}

- (void)loadAdViewAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters adFormat:(nonnull MAAdFormat *)adFormat andNotify:(nonnull id<MAAdViewAdapterDelegate>)delegate {
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    
    DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementId];
    DIOAdRequest *adRequest;
    
    @try {
        NSDictionary<NSString *, id> * localParams = [parameters localExtraParameters];
        adRequest = localParams[DIO_AD_REQUEST];
    } @catch (NSException *ignored) {
        
    }
    if (adRequest != nil) {
        [placement addAdRequest: adRequest];
    } else {
        adRequest = [placement newAdRequest];
    }
    
    [adRequest requestAdWithAdReceivedHandler:^(DIOAd *ad) {
        [self log: @"AD LOADED"];
        dioInlineAdImpressed = dioInlineAd;
        dioInlineAd = ad;
        [self handleInlineAdEvents:ad andNotify:delegate];
        
        UIView *adView = [ad view];
        [delegate didLoadAdForAdView: adView];
    } noAdHandler:^(NSError *error){
        [self log: @"NO AD: %@", error.localizedDescription];
        [delegate didFailToLoadAdViewAdWithError:MAAdapterError.noFill];
    }];
}

- (void)handleInlineAdEvents:(DIOAd *)ad andNotify:(nonnull id<MAAdViewAdapterDelegate>)inlineDelegate{
    if(ad == nil || inlineDelegate == nil) {
        return;
    }
    
    [ad setEventHandler:^(DIOAdEvent event) {
        switch (event) {
            case DIOAdEventOnShown:
                [inlineDelegate didDisplayAdViewAd];
                break;
            case DIOAdEventOnFailedToShow:{
                [inlineDelegate didFailToDisplayAdViewAdWithError: MAAdapterError.adDisplayFailedError];
                break;
            }
            case DIOAdEventOnClicked:
                [inlineDelegate didClickAdViewAd];
                break;
            case DIOAdEventOnClosed:
                [inlineDelegate didHideAdViewAd];
                break;
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
