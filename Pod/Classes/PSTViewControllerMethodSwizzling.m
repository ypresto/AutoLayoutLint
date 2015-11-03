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
