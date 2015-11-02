//
//  PSTViewControllerFinderTests.m
//  AutoLayoutLint
//
//  Created by ypresto on 2015/10/30.
//  Copyright © 2015年 Yuya Tanaka. All rights reserved.
//

#import <XCTest/XCTest.h>

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
