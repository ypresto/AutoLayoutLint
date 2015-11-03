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

@import ObjectiveC.runtime;

@interface PSTAutoLayoutLintTestCase ()

@property (nonatomic) PSTViewControllerFinderResultItem *finderResultItem;
@property (nonatomic, readonly) NSString *viewControllerLabel;
@property (nonatomic) CGSize currentScreenSize;

@end

static NSDictionary *selectorStringToFinderResultItem;

@implementation PSTAutoLayoutLintTestCase

+ (void)initialize
{
    if (self != [PSTAutoLayoutLintTestCase class]) {
        return;
    }

    PSTViewControllerFinder *finder = [PSTViewControllerFinder new];
    [PSTViewControllerMethodSwizzling swizzleViewDidLoadOfViewControllerSubclasses];
    NSArray<PSTViewControllerFinderResultItem *> *items = [finder findAllViewControllers];
    [PSTViewControllerMethodSwizzling restoreSwizzledViewDidLoadOfViewControllerSubclasses];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    Method checkMethod = class_getInstanceMethod(self, @selector(checkForBrokenConstraints));
    for (PSTViewControllerFinderResultItem *item in items) {
        SEL selector = [self selectorForLabel:item.label];
        [dict setObject:item forKey:NSStringFromSelector(selector)];
        class_addMethod(self, selector, method_getImplementation(checkMethod), method_getTypeEncoding(checkMethod));
    }
    selectorStringToFinderResultItem = [dict copy];
}

+ (NSArray<NSInvocation *> *)testInvocations
{
    if (self == [PSTAutoLayoutLintTestCase class]) {
        // abstract
        return @[];
    }
    return [super testInvocations];
}

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
    [PSTAutoLayoutMethodSwizzling setUnsatisfiableConstraintsHandler:^(NSLayoutConstraint *breakConstraint, NSArray *mutuallyExclusiveConstraints) {
        [self didConflictConstraint:breakConstraint inConstraints:mutuallyExclusiveConstraints];
    }];
}

- (void)tearDown
{
    [PSTAutoLayoutMethodSwizzling removeUnsatisfiableConstraintsHandler];
    [super tearDown];
}

- (void)invokeTest
{
    _finderResultItem = selectorStringToFinderResultItem[NSStringFromSelector(self.invocation.selector)];
    [super invokeTest];
}

#pragma mark Methods to Override

+ (BOOL)shouldTestViewControllerWithLabel:(NSString * _Nonnull)label screenSize:(CGSize)screenSize
{
    return YES;
}

+ (NSArray<NSValue *> *)screenSizes
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"screenSizes must be overridden." userInfo:nil];
}

#pragma mark Defining Screen Sizes


+ (NSValue * _Nonnull)valueWithWidth:(CGFloat)width height:(CGFloat)height
{
    return [NSValue valueWithCGSize:CGSizeMake(width, height)];
}

#pragma mark Custom Getters

- (NSString *)viewControllerLabel
{
    return self.finderResultItem.label;
}

#pragma mark Private Methods

+ (SEL)selectorForLabel:(NSString *)label
{
    NSString *baseString = [NSString stringWithFormat:@"testConstraints__%@", label];
    baseString = [[baseString componentsSeparatedByCharactersInSet:[NSCharacterSet alphanumericCharacterSet].invertedSet] componentsJoinedByString:@"_"];
    baseString = [[baseString componentsSeparatedByCharactersInSet:[NSCharacterSet nonBaseCharacterSet]] componentsJoinedByString:@"_"];
    return NSSelectorFromString(baseString);
}

- (void)checkForBrokenConstraints
{
    for (NSValue *screenSizeValue in [self.class screenSizes]) {
        CGSize screenSize = [screenSizeValue CGSizeValue];
        if (![self.class shouldTestViewControllerWithLabel:self.viewControllerLabel screenSize:screenSize]) {
            continue;
        }
        [self checkForBrokenConstraintsWithViewController:[self.finderResultItem instantiate] screenSize:screenSize];
    }
}

- (void)checkForBrokenConstraintsWithViewController:(UIViewController *)viewController
                                         screenSize:(CGSize)screenSize
{
    self.currentScreenSize = screenSize;
    viewController.view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    [viewController.view layoutIfNeeded];
    CGSize sizeAfterLayout = viewController.view.frame.size;
    if (!CGSizeEqualToSize(sizeAfterLayout, screenSize)) {
        [NSException raise:NSInternalInconsistencyException format:@"Root view size was set to %@ but changed to %@ after layoutIfNeeded call.", NSStringFromCGSize(screenSize),
                NSStringFromCGSize(sizeAfterLayout)];
    }
    self.currentScreenSize = CGSizeZero;
}

- (void)didConflictConstraint:(NSLayoutConstraint *)offendingConstraint
                inConstraints:(NSArray *)allConstraints
{
    XCTFail(@"Constraints broken for [%@].", NSStringFromCGSize(self.currentScreenSize));
}

@end
