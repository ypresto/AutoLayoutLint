//
//  PSTViewControllerMethodSwizzling.h
//  Pods
//
//  Created by ypresto on 2015/10/28.
//
//

#import <Foundation/Foundation.h>

@interface PSTViewControllerMethodSwizzling : NSObject

+ (void)swizzleViewDidLoadOfViewControllerSubclasses;

+ (void)restoreSwizzledViewDidLoadOfViewControllerSubclasses;

@end
