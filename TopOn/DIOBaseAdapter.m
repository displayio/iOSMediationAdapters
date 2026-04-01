#import "DIOBaseAdapter.h"

NSString *const kDIOAdRequestKey = @"dioAdRequest";
NSString *const kDIOIsRevealKey = @"isReveal";
NSString *const kDIOShowHeaderKey = @"showHeader";
NSString *const kDIOShowTapHintKey = @"showTapHint";

@implementation DIOBaseAdapter

- (Class)initializeClassName {
    return NSClassFromString(@"DIOInitAdapter");
}

@end
