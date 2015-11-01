//
//  PSTAutoLayoutLintTestCase.h
//  Pods
//
//  Created by ypresto on 2015/10/28.
//
//

#import <XCTest/XCTest.h>

@interface PSTAutoLayoutLintTestCase : XCTestCase

/// Override this to supply list of screen sizes to be tested.
+ (NSArray<NSValue *> * _Nonnull)screenSizes;

/// Shortcut method to create NSValue of CGSize.
+ (NSValue * _Nonnull)valueWithWidth:(CGFloat)width height:(CGFloat)height;

/// Override this to skip specific test.
+ (BOOL)shouldTestViewControllerWithLabel:(NSString * _Nonnull)label screenSize:(CGSize)screenSize;

@end
