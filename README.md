# AutoLayoutLint

[![CI Status](https://img.shields.io/circleci/project/ypresto/AutoLayoutLint.svg?style=flat)](https://circleci.com/gh/ypresto/AutoLayoutLint)
[![Version](https://img.shields.io/cocoapods/v/AutoLayoutLint.svg?style=flat)](http://cocoapods.org/pods/AutoLayoutLint)
[![License](https://img.shields.io/cocoapods/l/AutoLayoutLint.svg?style=flat)](http://cocoapods.org/pods/AutoLayoutLint)
[![Platform](https://img.shields.io/cocoapods/p/AutoLayoutLint.svg?style=flat)](http://cocoapods.org/pods/AutoLayoutLint)

AutoLayoutLint provides automated test to detect runtime conflicts of Auto Layout
constraints in each view controller.

## Why

Auto Layout is simple and powerful solution to create responsible views.
But there are pitfalls of conflicting constraints on specific screen sizes,
and they cannot detect statically. This library helps detecting runtime
conflicts using unit test.

## How it works

Iterates through all view controllers in app and manually sets
`view.frame.size` to specified screen sizes to detect conflicting constraints.

It utilizes method/function swizzling for testing:

- Swizzles well-known `UIViewAlertForUnsatisfiableConstraints` function for detection.
- Stubs `viewDidLoad` which can cause I/O or assertion failure in your code.

## Usage

1. Create subclass of `PSTAutoLayoutLintTestCase` in your test directory.
2. Implement `+ (NSArray<NSValue *> *)screenSizes` to provide sizes to be tested.
   You can use `+[PSTAutoLayoutLintTestCase valueWithWidth:height:]` for convenience.

```objc
@import AutoLayoutLint;

@interface YourAutoLayoutLintTests : PSTAutoLayoutLintTestCase

@end

@implementation YourAutoLayoutLintTests

+ (NSArray<NSValue *> *)screenSizes
{
    return @[
             [self valueWithWidth:600 height:600],
             [self valueWithWidth:100 height:600],
    ];
}

@end
```

Refer `Example/AutoLayoutLint_UsageExample/AutoLayoutLint_UsageExample.m` for
example of PSTAutoLayoutLintTestCase subclass.

Refer [The Ultimate Guide To iPhone Resolutions](http://www.paintcodeapp.com/news/ultimate-guide-to-iphone-resolutions) for screen sizes of each device.

### Excluding specific view controller or screen size

Implement `+ (BOOL)shouldTestViewControllerWithLabel:(NSString * _Nonnull)label screenSize:(CGSize)screenSize`
   if you want to skip some of tests.

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 8.0+
- Tested on Xcode 7.1

## Installation

TBD (Carthage and Cocoapods)

## Author

Yuya Tanaka (@ypresto)

## License

AutoLayoutLint is available under the MIT license. See the LICENSE file for more info.
