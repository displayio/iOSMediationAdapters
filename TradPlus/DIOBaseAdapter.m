#import "DIOBaseAdapter.h"
#import <TradPlusAds/TradPlusAdWaterfallItem.h>
#import <TradPlusAds/TradPlusUnitManager.h>
#import <DIOSDK/DIOInterscrollerPlacement.h>

NSString * const kDIOAppIdKey = @"appID";
NSString * const kDIOPlacementIdKey = @"placementID";

NSString * const kDIOAdRequestKey = @"DIO_AD_REQUEST";
NSString * const kDIORevealKey = @"DIO_IS_REVEAL";
NSString * const kDIOShowHeaderKey = @"DIO_SHOW_HEADER";
NSString * const kDIOShowTapHintKey = @"DIO_SHOW_TAP_HINT";

@interface DIOBaseAdapter ()
- (void)ensureDIOInitializedWithAppId:(nullable NSString *)appId completion:(void (^)(BOOL success))completion;
- (void)requestDIOAdWithConfig:(nullable NSDictionary *)cfg completion:(void (^)(DIOAd * _Nullable ad, NSError * _Nullable error))completion;
- (DIOAdRequest *)resolveAdRequestForPlacement:(DIOPlacement *)placement localParams:(nullable NSDictionary *)localParams;
- (void)applyInterscrollerOptions:(nullable NSDictionary *)serverConfig localParams:(nullable NSDictionary *)localParams toPlacement:(DIOPlacement *)placement;
- (nullable NSNumber *)boolOptionForKey:(NSString *)key serverConfig:(nullable NSDictionary *)serverConfig localParams:(nullable NSDictionary *)localParams;
@end

@implementation DIOBaseAdapter

#pragma mark - Waterfall entry

- (void)loadAdWithWaterfallItem:(TradPlusAdWaterfallItem *)item {
    __weak typeof(self) weakSelf = self;
    [self requestDIOAdWithConfig:item.config completion:^(DIOAd *ad, NSError *error) {
        if (error) {
            [weakSelf AdLoadFailWithError:error];
        } else {
            [weakSelf AdLoadFinsh];
        }
    }];
}

#pragma mark - C2S bidding entry

- (BOOL)extraActWithEvent:(NSString *)event info:(NSDictionary *)config {
    if ([event isEqualToString:@"C2SBidding"]) {
        NSDictionary *cfg = config.count > 0 ? config : self.waterfallItem.config;
        __weak typeof(self) weakSelf = self;
        [self requestDIOAdWithConfig:cfg completion:^(DIOAd *ad, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (error || !ad) {
                NSString *message = error.localizedDescription ?: @"C2S bidding failed";
                [strongSelf ADLoadExtraCallbackWithEvent:@"C2SBiddingFail" info:@{@"error": message}];
            } else {
                NSString *ecpm = ad.ecpm != nil ? [NSString stringWithFormat:@"%@", ad.ecpm] : @"0";
                NSString *version = [[DIOController sharedInstance] getSDKVersion] ?: @"";
                [strongSelf ADLoadExtraCallbackWithEvent:@"C2SBiddingFinish" info:@{@"ecpm": ecpm, @"version": version}];
            }
        }];
        return YES;
    } else if ([event isEqualToString:@"LoadAdC2SBidding"]) {
        if ([self isReady]) {
            [self AdLoadFinsh];
        } else {
            [self AdLoadFailWithError:[self dioErrorWithMessage:@"Ad not ready after C2S bidding"]];
        }
        return YES;
    } else if ([event isEqualToString:@"C2SLoss"]) {
        return YES;
    }
    return NO;
}

#pragma mark - Shared request pipeline

- (void)requestDIOAdWithConfig:(NSDictionary *)cfg completion:(void (^)(DIOAd *, NSError *))completion {
    NSString *appId = cfg[kDIOAppIdKey];
    NSString *placementId = cfg[kDIOPlacementIdKey];
    if (placementId.length == 0) {
        completion(nil, [self dioErrorWithMessage:@"Missing placementID"]);
        return;
    }

    __weak typeof(self) weakSelf = self;
    [self ensureDIOInitializedWithAppId:appId completion:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;

            if (!success) {
                completion(nil, [strongSelf dioErrorWithMessage:@"DIO SDK init failed"]);
                return;
            }

            DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementId];
            if (!placement) {
                completion(nil, [strongSelf dioErrorWithMessage:@"Placement not found"]);
                return;
            }

            NSDictionary *localParams = strongSelf.waterfallItem.unitManager.localParams;
            [strongSelf applyInterscrollerOptions:cfg localParams:localParams toPlacement:placement];
            DIOAdRequest *request = [strongSelf resolveAdRequestForPlacement:placement localParams:localParams];
            [request requestAdWithAdReceivedHandler:^(DIOAd *ad) {
                __strong typeof(weakSelf) innerSelf = weakSelf;
                if (!innerSelf) return;
                innerSelf.loadedAd = ad;
                [innerSelf onAdLoaded:ad];
                completion(ad, nil);
            } noAdHandler:^(NSError *error) {
                __strong typeof(weakSelf) innerSelf = weakSelf;
                if (!innerSelf) return;
                completion(nil, error ?: [innerSelf dioErrorWithMessage:@"No ad"]);
            }];
        });
    }];
}

static BOOL sInitStarted = NO;
static NSMutableArray<void (^)(BOOL)> *sPendingInit = nil;

- (DIOAdRequest *)resolveAdRequestForPlacement:(DIOPlacement *)placement localParams:(NSDictionary *)localParams {
    id custom = localParams[kDIOAdRequestKey];
    if (![custom isKindOfClass:[DIOAdRequest class]]) {
        return [placement newAdRequest];
    }
    DIOAdRequest *request = (DIOAdRequest *)custom;
    if ([placement adRequestById:request.ID]) {
        return [placement newAdRequest];
    }
    [placement addAdRequest:request];
    return request;
}

- (void)applyInterscrollerOptions:(NSDictionary *)serverConfig localParams:(NSDictionary *)localParams toPlacement:(DIOPlacement *)placement {
    if (![placement isKindOfClass:[DIOInterscrollerPlacement class]]) {
        return;
    }
    DIOInterscrollerPlacement *interscroller = (DIOInterscrollerPlacement *)placement;
    NSNumber *reveal = [self boolOptionForKey:kDIORevealKey serverConfig:serverConfig localParams:localParams];
    if (reveal != nil) {
        interscroller.reveal = reveal.boolValue;
    }
    NSNumber *showHeader = [self boolOptionForKey:kDIOShowHeaderKey serverConfig:serverConfig localParams:localParams];
    if (showHeader != nil) {
        interscroller.showHeader = showHeader.boolValue;
    }
    NSNumber *showTapHint = [self boolOptionForKey:kDIOShowTapHintKey serverConfig:serverConfig localParams:localParams];
    if (showTapHint != nil) {
        interscroller.showTapHint = showTapHint.boolValue;
    }
}

- (NSNumber *)boolOptionForKey:(NSString *)key serverConfig:(NSDictionary *)serverConfig localParams:(NSDictionary *)localParams {
    id value = localParams[key];
    if (value == nil) {
        value = serverConfig[key];
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return @([value boolValue]);
    }
    if ([value isKindOfClass:[NSString class]]) {
        NSString *lower = [(NSString *)value lowercaseString];
        if ([lower isEqualToString:@"true"] || [lower isEqualToString:@"1"] || [lower isEqualToString:@"yes"]) {
            return @YES;
        }
        if ([lower isEqualToString:@"false"] || [lower isEqualToString:@"0"] || [lower isEqualToString:@"no"]) {
            return @NO;
        }
    }
    return nil;
}

- (void)ensureDIOInitializedWithAppId:(NSString *)appId completion:(void (^)(BOOL))completion {
    if ([DIOController sharedInstance].initialized) {
        completion(YES);
        return;
    }
    if (appId.length == 0) {
        completion(NO);
        return;
    }

    @synchronized (DIOBaseAdapter.class) {
        if (sPendingInit == nil) {
            sPendingInit = [NSMutableArray array];
        }
        [sPendingInit addObject:[completion copy]];
        if (sInitStarted) {
            return;
        }
        sInitStarted = YES;
    }

    [[DIOController sharedInstance] initializeWithAppId:appId
        completionHandler:^{
            [DIOBaseAdapter flushInit:YES];
        }
        errorHandler:^(NSError *error) {
            [DIOBaseAdapter flushInit:NO];
        }];
}

+ (void)flushInit:(BOOL)success {
    NSArray<void (^)(BOOL)> *blocks;
    @synchronized (self) {
        blocks = [sPendingInit copy];
        [sPendingInit removeAllObjects];
        sInitStarted = NO;
    }
    for (void (^block)(BOOL) in blocks) {
        block(success);
    }
}

#pragma mark - Shared lifecycle

- (void)onAdLoaded:(DIOAd *)ad { }

- (BOOL)isReady {
    return self.loadedAd != nil;
}

- (void)adViewWillDestroy {
    [self.loadedAd finish];
    self.loadedAd = nil;
}

- (NSError *)dioErrorWithMessage:(NSString *)message {
    return [NSError errorWithDomain:@"DIOTradPlusAdapter"
                               code:-1
                           userInfo:@{NSLocalizedDescriptionKey: message ?: @"Unknown error"}];
}

@end
