//
//  PSTViewControllerFinder.h
//  Pods
//
//  Created by ypresto on 2015/10/28.
//
//

#import <Foundation/Foundation.h>

@interface PSTViewControllerFinderResultItem : NSObject

@property (nonatomic, nonnull) NSString *label;

- (UIViewController * _Nonnull)instantiate;

@end


@interface PSTViewControllerFinder : NSObject

- (NSArray<PSTViewControllerFinderResultItem * > * _Nonnull)findAllViewControllers;

- (NSArray<PSTViewControllerFinderResultItem *> * _Nonnull)findViewControllersInStoryboards;

- (NSArray<PSTViewControllerFinderResultItem *> * _Nonnull)findViewControllersInXibs;

@end
