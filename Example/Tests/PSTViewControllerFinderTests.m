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

#import "PSTViewControllerFinder.h"
#import "PSTViewControllerMethodSwizzling.h"

@interface PSTViewControllerFinderTests : XCTestCase

@property (nonatomic) PSTViewControllerFinder *viewControllerFinder;

@end

@implementation PSTViewControllerFinderTests

+ (void)setUp
{
    [PSTViewControllerMethodSwizzling swizzleViewDidLoadOfViewControllerSubclasses];
}

+ (void)tearDown
{
    [PSTViewControllerMethodSwizzling restoreSwizzledViewDidLoadOfViewControllerSubclasses];
}

- (void)setUp
{
    self.viewControllerFinder = [PSTViewControllerFinder new];
}

- (void)testViewControllersInStoryboards
{
    NSArray *items = [self.viewControllerFinder findViewControllersInStoryboards];
    // Initial view controller without identifier, which embeddeds view controller with title: "root"
    UINavigationController *navigationController = (UINavigationController *)[self checkContainsViewControllerWithTitle:@"nav" partOfLabel:@"TestStoryboard.storyboard - UINavigationController-" inItems:items];
    XCTAssertEqualObjects(navigationController.viewControllers.firstObject.title, @"root");

    [self checkContainsViewControllerWithTitle:@"main" partOfLabel:@"Main.storyboard - " inItems:items];
    [self checkContainsViewControllerWithTitle:@"identifier" partOfLabel:@"TestStoryboard.storyboard - testIdentifier" inItems:items];
    XCTAssertEqual(items.count, 3);
}

- (void)testViewControllersInXibs
{
    NSArray *items = [self.viewControllerFinder findViewControllersInXibs];
    [self checkContainsViewControllerWithTitle:@"xib" partOfLabel:@"PSTTestViewController.xib" inItems:items];
    [self checkContainsViewControllerWithTitle:@"xib2" partOfLabel:@"PSTTestViewController2.xib" inItems:items];
    XCTAssertEqual(items.count, 2);
}

- (UIViewController *)checkContainsViewControllerWithTitle:(NSString *)title
                                 partOfLabel:(NSString *)partOfLabel
                                     inItems:(NSArray<NSDictionary *> *)items
{
    for (PSTViewControllerFinderResultItem *item in items) {
        UIViewController *viewController = [item instantiate];
        if ([viewController.title isEqualToString:title]) {
            XCTAssert(YES, @"Should contain ViewController with title '%@'.", title);
            XCTAssertNotNil(item.label);
            BOOL containsPartOfLabel = [item.label rangeOfString:partOfLabel].location != NSNotFound;
            XCTAssertTrue(containsPartOfLabel, @"Looked label for '%@' but was '%@'.", partOfLabel, item.label);
            return viewController;
        }
    }
    XCTFail(@"Should contains ViewController with title '%@'.", title);
    return nil;
}

@end
