//
//  PSTAutoLayoutMethodSwizzling.h
//  Pods
//
//  Created by ypresto on 2015/10/28.
//
//

#import <UIKit/UIKit.h>

typedef void (^PSTAutoLayoutMethodSwizzlingUnsatisfiableConstraintsHandler)(NSLayoutConstraint *offendingConstraint,
                                                                          NSArray *allConstraints);

@interface PSTAutoLayoutMethodSwizzling : NSObject

+ (void)setUnsatisfiableConstraintsHandler:(PSTAutoLayoutMethodSwizzlingUnsatisfiableConstraintsHandler)newValue;

+ (void)removeUnsatisfiableConstraintsHandler;

@end
