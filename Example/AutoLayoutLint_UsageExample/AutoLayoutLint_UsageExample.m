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
        return screenSize.width >= 400 && screenSize.height >= 400;
    }
    return ![label containsString:@"Main.storyboard -"];
}

@end
