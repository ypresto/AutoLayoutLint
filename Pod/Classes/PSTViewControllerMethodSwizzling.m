//
//  PSTViewControllerMethodSwizzling.m
//  Pods
//
//  Created by ypresto on 2015/10/28.
//
//

#import "PSTViewControllerMethodSwizzling.h"

#import "MARTNSObject.h"
#import "RTMethod.h"

@implementation UIViewController (PSTViewControllerMethodSwizzling)

- (void)PSTViewControllerMethodSwizzling_swizzledViewDidLoad
{
}

@end

@implementation PSTViewControllerMethodSwizzling

+ (void)swizzleViewDidLoadOfViewControllerSubclasses
{
    SEL swizzledSelector = @selector(PSTViewControllerMethodSwizzling_swizzledViewDidLoad);
    Method templateMethod = class_getInstanceMethod([UIViewController class], swizzledSelector);
    
    for (Class class in [UIViewController rt_subclasses]) {
        SEL originalSelector = @selector(viewDidLoad);
        [class rt_addMethod:[RTMethod methodWithObjCMethod:templateMethod]]; // returns NO when already added.
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        method_exchangeImplementations(swizzledMethod, originalMethod);
    }
}

+ (void)restoreSwizzledViewDidLoadOfViewControllerSubclasses
{
    SEL swizzledSelector = @selector(PSTViewControllerMethodSwizzling_swizzledViewDidLoad);
    
    for (Class class in [UIViewController rt_subclasses]) {
        SEL originalSelector = @selector(viewDidLoad);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        method_exchangeImplementations(swizzledMethod, originalMethod);
    }
}

@end
