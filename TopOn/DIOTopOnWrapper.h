#import <UIKit/UIKit.h>

@interface DIOTopOnWrapper : UIView

@property (nonatomic, assign) CGSize adSize;

- (instancetype)initWithAdView:(UIView *)adView adSize:(CGSize)adSize;

@end
