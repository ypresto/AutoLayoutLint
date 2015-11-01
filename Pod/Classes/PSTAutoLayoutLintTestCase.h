//
//  PSTAutoLayoutLintTestCase.h
//  Pods
//
//  Created by ypresto on 2015/10/28.
//
//

#import <XCTest/XCTest.h>

@interface PSTAutoLayoutLintTestCase : XCTestCase

/// Call this from your subclass.
- (void)checkForBrokenConstraintsWithScreenSizes:(NSArray<NSValue *> *)screenSizes;

/// Override this to skip specific test.
- (BOOL)shouldCheckForBrokenConstraintsWithViewController:(UIViewController *)viewController
                                                    label:(NSString *)label
                                               screenSize:(CGSize)screenSize;

/// Shortcut method to create NSValue of CGSize.
+ (NSValue *)valueWithWidth:(CGFloat)width height:(CGFloat)height;

@end
