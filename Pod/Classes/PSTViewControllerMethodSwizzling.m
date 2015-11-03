//
//  PSTViewControllerMethodSwizzling.m
//  Pods
//
//  Created by ypresto on 2015/10/28.
//
//

#import "PSTViewControllerMethodSwizzling.h"

@import ObjectiveC.runtime;

@implementation UIViewController (PSTViewControllerMethodSwizzling)

- (void)PSTViewControllerMethodSwizzling_swizzledViewDidLoad
{
}

@end

static BOOL isSwizzled = NO;

@implementation PSTViewControllerMethodSwizzling

+ (void)swizzleViewDidLoadOfViewControllerSubclasses
{
    if (isSwizzled) {
        return;
    }

    SEL swizzledSelector = @selector(PSTViewControllerMethodSwizzling_swizzledViewDidLoad);
    Method templateMethod = class_getInstanceMethod([UIViewController class], swizzledSelector);
    
    for (Class class in [self findSubclassesForClass:[UIViewController class]]) {
        SEL originalSelector = @selector(viewDidLoad);
        // NOTE: returns NO when already added.
        class_addMethod(class,
                        swizzledSelector,
                        method_getImplementation(templateMethod),
                        method_getTypeEncoding(templateMethod));
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        method_exchangeImplementations(swizzledMethod, originalMethod);
    }

    isSwizzled = YES;
}

+ (void)restoreSwizzledViewDidLoadOfViewControllerSubclasses
{
    if (!isSwizzled) {
        return;
    }

    SEL swizzledSelector = @selector(PSTViewControllerMethodSwizzling_swizzledViewDidLoad);
    
    for (Class class in [self findSubclassesForClass:[UIViewController class]]) {
        SEL originalSelector = @selector(viewDidLoad);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        method_exchangeImplementations(swizzledMethod, originalMethod);
    }

    isSwizzled = NO;
}

+ (NSArray<Class> *)findSubclassesForClass:(Class)parentClass
{
    NSMutableArray<Class> *array = [NSMutableArray array];
    int numClasses = objc_getClassList(NULL, 0);
    Class *classes = NULL;
    @try
    {
        if (numClasses > 0) {
            classes = (__unsafe_unretained Class *) malloc(sizeof(Class) * numClasses);
            numClasses = objc_getClassList(classes, numClasses);
        }
        for (int i = 0; i < numClasses; i++) {
            // http://www.cocoawithlove.com/2010/01/getting-subclasses-of-objective-c-class.html
            Class class = classes[i];
            Class superClass = class;
            do {
                superClass = class_getSuperclass(superClass);
            } while(superClass && superClass != parentClass);
            if (superClass) {
                [array addObject:class];
            }
        }
    }
    @finally
    {
        free(classes);
    }
    return [array copy];
}

@end
