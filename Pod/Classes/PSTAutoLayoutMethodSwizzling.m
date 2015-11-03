//
//  PSTAutoLayoutMethodSwizzling.m
//  Pods
//
//  Created by ypresto on 2015/10/28.
//
//  Refer: http://stackoverflow.com/a/32677457/1474113
//
//

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
