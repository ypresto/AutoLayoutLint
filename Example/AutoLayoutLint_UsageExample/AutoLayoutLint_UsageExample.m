//
//  AutoLayoutLint_UsageExample.m
//  AutoLayoutLint_UsageExample
//
//  Created by ypresto on 2015/11/02.
//  Copyright © 2015年 Yuya Tanaka. All rights reserved.
//

@import XCTest;

@import AutoLayoutLint;

@interface AutoLayoutLint_UsageExample : PSTAutoLayoutLintTestCase

@end

@implementation AutoLayoutLint_UsageExample

+ (NSArray<NSValue *> *)screenSizes
{
    return @[
       [self valueWithWidth:320 height:480], // iPhone 4S
       [self valueWithWidth:480 height:320],
       [self valueWithWidth:320 height:568], // iPhone 5, 5S
       [self valueWithWidth:568 height:320],
       [self valueWithWidth:375 height:667], // iPhone 6, 6S
       [self valueWithWidth:667 height:375],
       [self valueWithWidth:414 height:736], // iPhone 6 Plus, 6S Plus
       [self valueWithWidth:736 height:414],
    ];
}

+ (BOOL)shouldTestViewControllerWithLabel:(NSString *)label screenSize:(CGSize)screenSize
{
    if ([label containsString:@"PSTTestViewController2.xib"]) {
        return screenSize.width <= 600 && screenSize.height <= 600;
    }
    return ![label containsString:@"Main.storyboard -"];
}

@end
