#import "DIOBiddingNotice.h"

static NSString *const kMacroMinToWin = @"${AUCTION_MIN_TO_WIN}";
static NSString *const kMacroLoss = @"${AUCTION_LOSS}";

@implementation DIOBiddingNotice

+ (void)handleBidResult:(ATBidWinLossResult *)result forAd:(DIOAd *)ad {
    if (!ad) return;

    if (result.bidResultType == ATBidWinLossResultTypeWin) {
        NSString *nurl = ad.nurl;
        if (nurl.length == 0) return;
        NSString *url = [nurl stringByReplacingOccurrencesOfString:kMacroMinToWin
                                                        withString:result.secondPrice ?: @""];
        [[DIOController sharedInstance].serviceClient callBeaconWithURLString:url];
    } else {
        NSString *lurl = ad.lurl;
        if (lurl.length == 0) return;
        NSString *lossCode = [NSString stringWithFormat:@"%ld", (long)result.lossReasonType];
        NSString *url = [lurl stringByReplacingOccurrencesOfString:kMacroMinToWin
                                                        withString:result.winPrice ?: @""];
        url = [url stringByReplacingOccurrencesOfString:kMacroLoss withString:lossCode];
        [[DIOController sharedInstance].serviceClient callBeaconWithURLString:url];
    }
}

@end
