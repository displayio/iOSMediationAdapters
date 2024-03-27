//
//  ISDIOCustomInterstitial.m
//  IronSource_iOS
//
//  Created by Ro Do on 22.03.2024.
//

#import "ISDIOCustomInterstitial.h"
#import <DIOSDK/DIOSDK.h>


@implementation ISDIOCustomInterstitial

DIOAd *dioInterstitialAd;

- (void)loadAdWithAdData:(nonnull ISAdData *)adData delegate:(nonnull id<ISInterstitialAdDelegate>)delegate {
    NSString *placementId = [adData getString:@"dio_placement_id"];
    if (placementId == nil || [placementId length] == 0) {
        [delegate adDidFailToLoadWithErrorType:ISAdapterErrorTypeInternal
                                     errorCode:ISAdapterErrorMissingParams
                                  errorMessage:@"Placement Id missed"];
        return;
    }
    DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementId];
    if (placement == nil || ![placement isKindOfClass:[DIOInterstitialPlacement class]]) {
        [delegate adDidFailToLoadWithErrorType:ISAdapterErrorTypeInternal
                                     errorCode:ISAdapterErrorInternal
                                  errorMessage:@"No placement or placement is not an Interstitial type"];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        DIOAdRequest *adRequest = [placement newAdRequest];
        
        [adRequest requestAdWithAdReceivedHandler:^(DIOAd *ad) {
            dioInterstitialAd = ad;
            [delegate adDidLoad];
        } noAdHandler:^(NSError *error){
            [delegate adDidFailToLoadWithErrorType:ISAdapterErrorTypeNoFill
                                         errorCode:ISAdapterErrorInternal
                                      errorMessage:@"No fill"];
        }];
    });
}

- (void)showAdWithViewController:(nonnull UIViewController *)viewController
                          adData:(nonnull ISAdData *)adData
                        delegate:(nonnull id<ISInterstitialAdDelegate>)delegate {
    if (dioInterstitialAd == nil || dioInterstitialAd.impressed) {
        [delegate adDidFailToShowWithErrorCode:ISAdapterErrorInternal errorMessage:@"Failed to show Ad"];
        return;
    }
    [dioInterstitialAd showAdFromViewController:viewController eventHandler:^(DIOAdEvent event) {
        switch (event) {
            case DIOAdEventOnShown:{
                [delegate adDidOpen];
                [delegate adDidShowSucceed];
                if ([dioInterstitialAd isKindOfClass:DIOInterstitialVast.class]) {
                    [delegate adDidStart];
                }
                break;
            }
            case DIOAdEventOnFailedToShow:{
                if (dioInterstitialAd.impressed) {
                    [delegate adDidFailToShowWithErrorCode:ISAdapterErrorInternal errorMessage:@"Failed to show ad"];
                }
                dioInterstitialAd = nil;
                break;
            }
            case DIOAdEventOnClicked:{
                [delegate adDidClick];
                break;
            }
            case DIOAdEventOnClosed:
            case DIOAdEventOnAdCompleted:{
                [delegate adDidClose];
                if ([dioInterstitialAd isKindOfClass:DIOInterstitialVast.class]) {
                    [delegate adDidEnd];
                }
                dioInterstitialAd = nil;
                break;
            }
                
            case DIOAdEventOnSwipedOut:
            case DIOAdEventOnSnapped:
            case DIOAdEventOnMuted:
            case DIOAdEventOnUnmuted:
                break;
        }
    }];
}

- (BOOL)isAdAvailableWithAdData:(nonnull ISAdData *)adData {
    return dioInterstitialAd != nil && !dioInterstitialAd.impressed;
}

@end
