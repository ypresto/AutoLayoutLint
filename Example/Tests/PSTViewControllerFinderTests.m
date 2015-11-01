//
//  PSTViewControllerFinderTests.m
//  AutoLayoutLint
//
//  Created by ypresto on 2015/10/30.
//  Copyright © 2015年 Yuya Tanaka. All rights reserved.
//

#import <XCTest/XCTest.h>

@import AutoLayoutLint;

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
    NSMutableArray<NSDictionary *> *items = [NSMutableArray array];
    [self.viewControllerFinder iterateViewControllersInStoryboards:^(UIViewController * _Nonnull viewController, NSString * _Nonnull label) {
        [items addObject:@{@"title": viewController.title, @"label": label, @"viewController": viewController}];
    }];
    // Initial view controller without identifier, which embeddeds view controller with title: "root"
    UINavigationController *navigationController = (UINavigationController *)[self checkContainsViewControllerWithTitle:@"nav" partOfLabel:@"TestStoryboard.storyboard - UINavigationController-" inItems:items];
    XCTAssertEqualObjects(navigationController.viewControllers.firstObject.title, @"root");

    [self checkContainsViewControllerWithTitle:@"main" partOfLabel:@"Main.storyboard - " inItems:items];
    [self checkContainsViewControllerWithTitle:@"identifier" partOfLabel:@"TestStoryboard.storyboard - testIdentifier" inItems:items];
    XCTAssertEqual(items.count, 3);
}

- (void)testViewControllersInXibs
{
    NSMutableArray<NSDictionary *> *items = [NSMutableArray array];
    [self.viewControllerFinder iterateViewControllersInXibs:^(UIViewController * _Nonnull viewController, NSString * _Nonnull label) {
        [items addObject:@{@"title": viewController.title, @"label": label}];
    }];
    [self checkContainsViewControllerWithTitle:@"xib" partOfLabel:@"PSTTestViewController.xib" inItems:items];
    XCTAssertEqual(items.count, 1);
}

- (UIViewController *)checkContainsViewControllerWithTitle:(NSString *)title
                                 partOfLabel:(NSString *)partOfLabel
                                     inItems:(NSArray<NSDictionary *> *)items
{
    for (NSDictionary *item in items) {
        if ([item[@"title"] isEqualToString:title]) {
            XCTAssert(YES, @"Should contain ViewController with title '%@'.", title);
            BOOL containsPartOfLabel = [item[@"label"] rangeOfString:partOfLabel].location != NSNotFound;
            XCTAssertTrue(containsPartOfLabel, @"Looked label for '%@' but was '%@'.", partOfLabel, item[@"label"]);
            return item[@"viewController"];
        }
    }
    XCTFail(@"Should contains ViewController with title '%@'.", title);
    return nil;
}

@end
