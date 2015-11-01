//
//  PSTViewControllerFinder.h
//  Pods
//
//  Created by ypresto on 2015/10/28.
//
//

#import <Foundation/Foundation.h>

typedef void (^PSTViewControllerFinderIterator)(UIViewController * _Nonnull viewController, NSString * _Nonnull label);

@interface PSTViewControllerFinder : NSObject

- (void)iterateAllViewControllers:(PSTViewControllerFinderIterator _Nonnull)iterator;

- (void)iterateViewControllersInStoryboards:(PSTViewControllerFinderIterator _Nonnull)iterator;

- (void)iterateViewControllersInXibs:(PSTViewControllerFinderIterator _Nonnull)iterator;

@end
