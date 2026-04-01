#import "DIOTopOnWrapper.h"

@implementation DIOTopOnWrapper

- (instancetype)initWithAdView:(UIView *)adView adSize:(CGSize)adSize {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _adSize = adSize;

        adView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:adView];
        [NSLayoutConstraint activateConstraints:@[
            [adView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [adView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [adView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [adView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
        ]];
    }
    return self;
}

@end
