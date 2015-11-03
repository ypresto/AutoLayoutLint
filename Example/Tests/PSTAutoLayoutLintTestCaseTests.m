//  The MIT License (MIT)
//
//  Copyright (c) 2015 Yuya Tanaka
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

@import XCTest;

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
