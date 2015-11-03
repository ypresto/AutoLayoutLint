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

// Refer:
// http://stackoverflow.com/a/33502823/1474113

#import "PSTAutoLayoutMethodSwizzling.h"

@import ObjectiveC.runtime;

static PSTAutoLayoutMethodSwizzlingUnsatisfiableConstraintsHandler unsatisfiableConstraintsHandler;

@interface UIView (PSTAutoLayoutMethodSwizzling_UIConstraintBasedLayout_EngineDelegate_PrivateInterface)

- (void)engine:(id /* NSISEngine */)engine willBreakConstraint:(NSLayoutConstraint *)breakConstraint dueToMutuallyExclusiveConstraints:(NSArray<NSLayoutConstraint *> *)mutuallyExclusiveConstraints;

@end

@implementation UIView (PSTAutoLayoutMethodSwizzling)

- (void)PSTAutoLayoutMethodSwizzling_engine:(id /* NSISEngine */)engine willBreakConstraint:(NSLayoutConstraint *)breakConstraint dueToMutuallyExclusiveConstraints:(NSArray<NSLayoutConstraint *> *)mutuallyExclusiveConstraints
{
    unsatisfiableConstraintsHandler(breakConstraint, mutuallyExclusiveConstraints);
    // Call original method
    [self PSTAutoLayoutMethodSwizzling_engine:engine willBreakConstraint:breakConstraint dueToMutuallyExclusiveConstraints:mutuallyExclusiveConstraints];
}

@end

@implementation PSTAutoLayoutMethodSwizzling

+ (void)swizzleAutoLayoutAlertMethod
{
    Class class = [UIView class];
    Method originalMethod = class_getInstanceMethod(class, @selector(engine:willBreakConstraint:dueToMutuallyExclusiveConstraints:));
    if (!originalMethod) {
        [NSException raise:NSInternalInconsistencyException format:@"This platform does not support Auto Layout or interface has been changed."];
    }
    Method swizzledMethod = class_getInstanceMethod(class, @selector(PSTAutoLayoutMethodSwizzling_engine:willBreakConstraint:dueToMutuallyExclusiveConstraints:));
    method_exchangeImplementations(swizzledMethod, originalMethod);
}

+ (void)setUnsatisfiableConstraintsHandler:(PSTAutoLayoutMethodSwizzlingUnsatisfiableConstraintsHandler)newValue
{
    if (!newValue) {
        [self removeUnsatisfiableConstraintsHandler];
        return;
    }

    if (!unsatisfiableConstraintsHandler) {
        [self swizzleAutoLayoutAlertMethod];
    }

    unsatisfiableConstraintsHandler = [newValue copy];
}

+ (void)removeUnsatisfiableConstraintsHandler
{
    if (unsatisfiableConstraintsHandler) {
        [self swizzleAutoLayoutAlertMethod];
        unsatisfiableConstraintsHandler = nil;
    }
}

@end
