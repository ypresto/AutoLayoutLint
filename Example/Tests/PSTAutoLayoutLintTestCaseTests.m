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
                                              label:(NSString *)label
                                         screenSize:(CGSize)screenSize;

- (void)didConflictConstraint:(NSLayoutConstraint *)offendingConstraint inConstraints:(NSArray *)allConstraints;

@end

@interface PSTAutoLayoutLintTestCaseTests : PSTAutoLayoutLintTestCase

@property (nonatomic) NSInteger conflictCount;

@end

@implementation PSTAutoLayoutLintTestCaseTests

- (void)testCheckForBrokenConstraintsWithViewControllerLabelScreenSize {
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"TestStoryboard" bundle:nil] instantiateInitialViewController];
    XCTAssertEqual(self.conflictCount, 0);
    [self checkForBrokenConstraintsWithViewController:viewController label:@"hoge" screenSize:CGSizeMake(800, 800)];
    XCTAssertEqual(self.conflictCount, 0);
    [self checkForBrokenConstraintsWithViewController:viewController label:@"hoge" screenSize:CGSizeMake(800, 100)];
    XCTAssertEqual(self.conflictCount, 1);
    [self checkForBrokenConstraintsWithViewController:viewController label:@"hoge" screenSize:CGSizeMake(100, 100)];
    XCTAssertEqual(self.conflictCount, 2); // XXX: Currently reusing same view for every check. So conflict only happens twice: X and Y axes.
}

- (void)didConflictConstraint:(NSLayoutConstraint *)offendingConstraint inConstraints:(NSArray *)allConstraints
{
    self.conflictCount++;
}

@end
