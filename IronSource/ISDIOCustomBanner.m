//
//  ISDIOCustomBanner.m
//  IronSource_iOS
//
//  Created by Ro Do on 22.03.2024.
//

#import "ISDIOCustomBanner.h"
#import <DIOSDK/DIOSDK.h>

@implementation ISDIOCustomBanner

DIOAd *dioInlineAd;

- (void)loadAdWithAdData:(nonnull ISAdData *)adData
          viewController:(UIViewController *)viewController
                    size:(ISBannerSize *)size
                delegate:(nonnull id<ISBannerAdDelegate>)delegate{
    
    NSString *placementId = [adData getString:@"dio_placement_id"];
    if (placementId == nil || [placementId length] == 0) {
        [delegate adDidFailToLoadWithErrorType:ISAdapterErrorTypeInternal
                                     errorCode:ISAdapterErrorMissingParams
                                  errorMessage:@"Placement Id missed"];
        return;
    }
    DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementId];
    if (placement == nil || [placement isKindOfClass:[DIOInterstitialPlacement class]]
        || [placement isKindOfClass:[DIORewardedVideoPlacement class]]) {
        [delegate adDidFailToLoadWithErrorType:ISAdapterErrorTypeInternal
                                     errorCode:ISAdapterErrorInternal
                                  errorMessage:@"No placement or placement is not an Inline type"];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        DIOAdRequest *adRequest = [placement newAdRequest];
        
        [adRequest requestAdWithAdReceivedHandler:^(DIOAd *ad) {
            dioInlineAd = ad;
            [self handleInlineAdEvents:ad andNotifyDelegate:delegate];
            UIView *adView = [ad view];
            NSString *adUnitType = ad.adUnitType;
            if ([adUnitType isEqualToString:BANNER]) {
                adView.frame = CGRectMake(0, 0, 320, 50);
                [adView.widthAnchor constraintEqualToConstant:320].active = YES;
                [adView.heightAnchor constraintEqualToConstant:50].active = YES;
            } else if ([adUnitType isEqualToString:INFEED] || [adUnitType isEqualToString:MEDIUMRECTANGLE]) {
                adView.frame = CGRectMake(0, 0, 300, 250);
                [adView.widthAnchor constraintEqualToConstant:300].active = YES;
                [adView.heightAnchor constraintEqualToConstant:250].active = YES;
            } else if ([adUnitType isEqualToString:INTERSCROLLER]) {
                CGSize size = viewController.view.bounds.size;
                adView.frame = CGRectMake(0, 0, size.width, size.height);
                [adView.widthAnchor constraintEqualToConstant:size.width].active = YES;
                [adView.heightAnchor constraintEqualToConstant:size.height].active = YES;
            }
            [delegate adDidLoadWithView: adView];
        } noAdHandler:^(NSError *error){
            [delegate adDidFailToLoadWithErrorType:ISAdapterErrorTypeNoFill errorCode:ISAdapterErrorInternal errorMessage:@"No fill"];
        }];
        
    });
}

- (void)destroyAdWithAdData:(nonnull ISAdData *)adData {
    if (dioInlineAd != nil) {
        [dioInlineAd finish];
        dioInlineAd = nil;
    }
}


- (void)handleInlineAdEvents:(DIOAd *)ad andNotifyDelegate:(nonnull id<ISBannerAdDelegate>)delegate{
    if(ad == nil || delegate == nil) {
        return;
    }
    
    [ad setEventHandler:^(DIOAdEvent event) {
        switch (event) {
            case DIOAdEventOnShown:{
                [delegate adDidOpen];
                break;
            }
            case DIOAdEventOnFailedToShow:{
                [delegate adDidDismissScreen];
                break;
            }
            case DIOAdEventOnClicked:{
                [delegate adDidClick];
                break;
            }
            case DIOAdEventOnClosed:{
                [delegate adDidDismissScreen];
                break;
            }
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
