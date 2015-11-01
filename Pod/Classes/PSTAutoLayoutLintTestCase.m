//
//  PSTAutoLayoutLintTestCase.m
//  Pods
//
//  Created by ypresto on 2015/10/28.
//
//

#import "PSTAutoLayoutLintTestCase.h"

#import "PSTViewControllerFinder.h"
#import "PSTViewControllerMethodSwizzling.h"
#import "PSTAutoLayoutMethodSwizzling.h"

@interface PSTAutoLayoutLintTestCase ()

@property (nonatomic) PSTViewControllerFinder *viewControllerFinder;
@property (nonatomic) NSString *testLabel;

@end

@implementation PSTAutoLayoutLintTestCase

+ (void)setUp
{
    [super setUp];
    [PSTViewControllerMethodSwizzling swizzleViewDidLoadOfViewControllerSubclasses];
}

+ (void)tearDown
{
    [PSTViewControllerMethodSwizzling restoreSwizzledViewDidLoadOfViewControllerSubclasses];
    [super tearDown];
}

- (void)setUp
{
    [super setUp];
    self.viewControllerFinder = [PSTViewControllerFinder new];
    [PSTAutoLayoutMethodSwizzling setUnsatisfiableConstraintsHandler:^(NSLayoutConstraint *offendingConstraint, NSArray *allConstraints) {
        [self didConflictConstraint:offendingConstraint inConstraints:allConstraints];
    }];
}

- (void)tearDown
{
    [PSTAutoLayoutMethodSwizzling removeUnsatisfiableConstraintsHandler];
    [super tearDown];
}

- (void)checkForBrokenConstraintsWithScreenSizes:(NSArray<NSValue *> *)screenSizes
{
    [self.viewControllerFinder iterateAllViewControllers:^(UIViewController * _Nonnull viewController, NSString * _Nonnull label) {
        @try {
            for (NSValue *sizeValue in screenSizes) {
                CGSize size = [sizeValue CGSizeValue];
                if (![self shouldCheckForBrokenConstraintsWithViewController:viewController label:label screenSize:size]) {
                    continue;
                }
                [self checkForBrokenConstraintsWithViewController:viewController label:label screenSize:size];
            }
        } @catch (NSException *exception) {
            XCTFail(@"Failed to inflate and layout view %@: '%@'.", self.testLabel, exception);
        }
    }];
}

- (void)checkForBrokenConstraintsWithViewController:(UIViewController *)viewController
                                              label:(NSString *)label
                                         screenSize:(CGSize)screenSize
{
    self.testLabel = [NSString stringWithFormat:@"%@ (%.1f x %.1f)", label, screenSize.width, screenSize.height];
    NSLog(@"Testing %@", self.testLabel);
    viewController.view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    [viewController.view layoutIfNeeded];
    CGSize sizeAfterLayout = viewController.view.frame.size;
    if (!CGSizeEqualToSize(sizeAfterLayout, screenSize)) {
        XCTFail(@"Root view size was set to %@ but changed to %@ after layoutIfNeeded call.", NSStringFromCGSize(screenSize),
                NSStringFromCGSize(sizeAfterLayout));
    }
}

- (void)didConflictConstraint:(NSLayoutConstraint *)offendingConstraint
                inConstraints:(NSArray *)allConstraints
{
    XCTFail(@"Constraints broken for %@.", self.testLabel);
}

- (BOOL)shouldCheckForBrokenConstraintsWithViewController:(UIViewController *)viewController
                                                    label:(NSString *)label
                                               screenSize:(CGSize)screenSize
{
    return YES;
}


+ (NSValue *)valueWithWidth:(CGFloat)width height:(CGFloat)height
{
    return [NSValue valueWithCGSize:CGSizeMake(width, height)];
}

@end
