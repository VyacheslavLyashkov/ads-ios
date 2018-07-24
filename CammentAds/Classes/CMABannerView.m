//
// Created by Alexander Fedosov on 23/07/2018.
//

#import "CMABannerView.h"
#import "CMABanner.h"
#import "UIKit+AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@interface CMABannerView()

@property (nonnull, nonatomic, strong) UIImageView *bannerImageView;
@property (nonatomic, strong) NSTimer *timer;
@property(nonatomic, copy) void (^bannerDeletionBlock)();

- (instancetype)initWithBanner:(CMABanner *)banner bannerDeletionBlock:(void (^)())block;

@end

@implementation CMABannerView

- (instancetype)initWithBanner:(CMABanner *)banner bannerDeletionBlock:(void (^)())bannerDeletionBlock {
    self = [super init];
    if (self) {
        _banner = banner;
        _bannerDeletionBlock = bannerDeletionBlock;
        
        _bannerImageView = [UIImageView new];
        _bannerImageView.backgroundColor = [UIColor blackColor];
        _bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_bannerImageView setImageWithURL:[[NSURL alloc] initWithString:_banner.imageURL]];

        [_bannerImageView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                initWithTarget:self
                        action:@selector(handleTapOnBanner)];
        [_bannerImageView addGestureRecognizer:tapGestureRecognizer];

        [self addSubview:_bannerImageView];
    }

    return self;
}

- (void)dealloc {
    if (self.timer && [self.timer isValid]) {
        [self.timer invalidate];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _bannerImageView.frame = self.bounds;
    _bannerImageView.contentMode = (self.bounds.size.height > self.bounds.size.width)
                                            ? UIViewContentModeScaleAspectFit
                                            : UIViewContentModeScaleAspectFill;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    __weak typeof(self) _weakSelf = self;
    if (self.timer && [self.timer isValid]) {
        [self.timer invalidate];
    }

    self.timer = [NSTimer scheduledTimerWithTimeInterval:_banner.timeToShow
                                                  target:_weakSelf
                                                selector:@selector(handleTimerEvent)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)handleTimerEvent {
    if (self.bannerDeletionBlock) {
        self.bannerDeletionBlock();
    }
}

- (void)handleTapOnBanner {
    if (!_banner.redirectURL) { return; }

    NSURL *url = [[NSURL alloc] initWithString:_banner.redirectURL];

    UIApplication *application = [UIApplication sharedApplication];
    if (@available(iOS 10.0, *)) {
        [application openURL:url options:@{} completionHandler:^(BOOL success) {}];
    } else {
        [application openURL:url];
    }
}

@end