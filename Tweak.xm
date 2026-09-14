\
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/CAMetalLayer.h>
#import <objc/runtime.h>
#import <math.h>

static CGFloat gDLSScale = 0.65;
static BOOL gConfigLoaded = NO;
static BOOL gLogged = NO;
static const void *kDLSLastScaledSizeKey = &kDLSLastScaledSizeKey;

static CGFloat DLSLoadScale(void) {
    if (gConfigLoaded) return gDLSScale;
    gConfigLoaded = YES;

    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/dlslowres.txt"];
    NSError *err = nil;
    NSString *raw = [NSString stringWithContentsOfFile:path
                                              encoding:NSUTF8StringEncoding
                                                 error:&err];

    if (raw.length > 0) {
        double value = raw.doubleValue;
        if (value > 1.0) value /= 100.0;

        // Keep it sane. 40% is already extremely low.
        if (value >= 0.40 && value <= 1.00) {
            gDLSScale = (CGFloat)value;
        }
    }

    return gDLSScale;
}

static void DLSWriteStatus(CGSize input, CGSize output, CGFloat scale) {
    if (gLogged) return;
    gLogged = YES;

    NSString *status = [NSString stringWithFormat:
        @"DLSLowRes active\n"
         "scale=%.3f\n"
         "input=%.0fx%.0f\n"
         "output=%.0fx%.0f\n",
         scale, input.width, input.height, output.width, output.height];

    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/dlslowres_status.txt"];
    [status writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"[DLSLowRes] %@", status);
}

%hook CAMetalLayer

- (void)setDrawableSize:(CGSize)size {
    CGFloat scale = DLSLoadScale();

    if (scale >= 0.999 ||
        size.width < 256.0 ||
        size.height < 256.0) {
        %orig(size);
        return;
    }

    // Prevent accidental repeated scaling if the engine re-submits
    // the last scaled size instead of the original size.
    NSValue *lastValue = objc_getAssociatedObject(self, kDLSLastScaledSizeKey);
    if (lastValue) {
        CGSize last = [lastValue CGSizeValue];
        if (fabs(last.width - size.width) < 0.5 &&
            fabs(last.height - size.height) < 0.5) {
            %orig(size);
            return;
        }
    }

    CGSize scaled = CGSizeMake(floor(size.width * scale),
                               floor(size.height * scale));

    // Avoid pathological tiny render targets.
    if (scaled.width < 320.0) scaled.width = 320.0;
    if (scaled.height < 180.0) scaled.height = 180.0;

    objc_setAssociatedObject(self,
                             kDLSLastScaledSizeKey,
                             [NSValue valueWithCGSize:scaled],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    DLSWriteStatus(size, scaled, scale);
    %orig(scaled);
}

%end
