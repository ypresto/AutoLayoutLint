//
//  PSTAutoLayoutLintTestCaseTests.m
//  AutoLayoutLint
//
//  Created by ypresto on 2015/10/31.
//  Copyright © 2015年 Yuya Tanaka. All rights reserved.
//

#import <XCTest/XCTest.h>

@import AutoLayoutLint;

@interface PSTAutoLayoutLintTestCase ()

- (void)checkForBrokenConstraintsWithViewController:(UIViewController *)viewController
                                         screenSize:(CGSize)screenSize;

- (void)didConflictConstraint:(NSLayoutConstraint *)offendingConstraint inConstraints:(NSArray *)allConstraints;

@end

@interface PSTAutoLayoutLintTestCaseTests : PSTAutoLayoutLintTestCase

@property (nonatomic) NSInteger conflictCount;

@end

@implementation PSTAutoLayoutLintTestCaseTests

+ (NSArray<NSInvocation *> *)testInvocations
{
    // Suppress super impl.
    return [[super testInvocations] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSInvocation *invocation = evaluatedObject;
        return [invocation.target class] == [PSTAutoLayoutLintTestCaseTests class];
    }]];
}

- (UIViewController *)instantiateViewController
{
    return [[UIStoryboard storyboardWithName:@"TestStoryboard" bundle:nil] instantiateInitialViewController];
}

- (void)testCheckForBrokenConstraintsWithViewControllerScreenSize
{
    XCTAssertEqual(self.conflictCount, 0);
    [self checkForBrokenConstraintsWithViewController:[self instantiateViewController] screenSize:CGSizeMake(800, 800)];
    XCTAssertEqual(self.conflictCount, 0);
    [self checkForBrokenConstraintsWithViewController:[self instantiateViewController] screenSize:CGSizeMake(800, 100)];
    XCTAssertEqual(self.conflictCount, 1);
    [self checkForBrokenConstraintsWithViewController:[self instantiateViewController] screenSize:CGSizeMake(100, 100)];
    XCTAssertEqual(self.conflictCount, 3);
}

- (void)didConflictConstraint:(NSLayoutConstraint *)offendingConstraint inConstraints:(NSArray *)allConstraints
{
    self.conflictCount++;
}

@end

@interface PSTAutoLayoutLintTestCaseTestsIntegrationTest : PSTAutoLayoutLintTestCase

@property (nonatomic) NSInteger conflictCount;

@end

static NSInteger callCount;
static NSString *lastLabel;

@implementation PSTAutoLayoutLintTestCaseTestsIntegrationTest

+ (void)setUp
{
    [super setUp];
    callCount = 0;
}

+ (void)tearDown
{
    NSAssert(callCount == 5, @"Should be invoked 5 times."); // Main + TestStoryboard x2 + xib x2
    [super tearDown];
}

+ (NSArray<NSValue *> *)screenSizes
{
    return @[
             [self valueWithWidth:600 height:600],
             [self valueWithWidth:100 height:600],
    ];
}

+ (BOOL)shouldTestViewControllerWithLabel:(NSString *)label screenSize:(CGSize)screenSize
{
    lastLabel = label;
    return ![label containsString:@"PSTTestViewController2.xib"];
}

- (void)tearDown
{
    callCount++;
    if ([lastLabel containsString:@"PSTTestViewController2.xib"] || [lastLabel containsString:@"Main.storyboard"]) {
        XCTAssertEqual(self.conflictCount, 0);
    } else {
        XCTAssertEqual(self.conflictCount, 1);
    }
    [super tearDown];
}

- (void)didConflictConstraint:(NSLayoutConstraint *)offendingConstraint inConstraints:(NSArray *)allConstraints
{
    self.conflictCount++;
}

@end
