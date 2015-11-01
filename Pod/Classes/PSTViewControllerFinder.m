//
//  PSTViewControllerFinder.m
//  Pods
//
//  Created by ypresto on 2015/10/28.
//
//

#import "PSTViewControllerFinder.h"

/// Ignores all IBOutlets.
@interface PSTViewControllerFinderDummyOwner : NSObject
@end

@implementation PSTViewControllerFinderDummyOwner

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
}

@end

@implementation PSTViewControllerFinder

- (void)iterateAllViewControllers:(PSTViewControllerFinderIterator _Nonnull)iterator
{
    [self iterateViewControllersInStoryboards:iterator];
    [self iterateViewControllersInXibs:iterator];
}

- (void)iterateViewControllersInStoryboards:(PSTViewControllerFinderIterator _Nonnull)iterator
{
    NSArray<NSString *> *storyboardPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"storyboardc" inDirectory:@"/"];
    for (NSString *storyboardPath in storyboardPaths) {
        NSString *storyboardName = [storyboardPath.lastPathComponent stringByDeletingPathExtension];
        if ([storyboardName containsString:@"~ipad"] || [storyboardName containsString:@"~iphone"]) {
            // They seems to be pointing non-tilde-suffixed storyboardc directory when targeted to iOS 8.0+.
            continue;
        }
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
        NSDictionary *identifierToNibNameMap = [storyboard valueForKey:@"identifierToNibNameMap"];  // private API
        for (NSString *identifier in identifierToNibNameMap.allKeys) {
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
            NSString *label = [NSString stringWithFormat:@"%@.storyboard - %@", storyboardName, identifier];
            iterator(viewController, label);
        }
    }
}

- (void)iterateViewControllersInXibs:(PSTViewControllerFinderIterator _Nonnull)iterator
{
    NSArray<NSString *> *nibPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"nib" inDirectory:@"/"];
    for (NSString *nibPath in nibPaths) {
        NSString *nibName = [nibPath.lastPathComponent stringByDeletingPathExtension];
        if ([nibName containsString:@"~ipad"] || [nibName containsString:@"~iphone"]) {
            // They seems to be pointing non-tilde-suffixed storyboardc directory when targeted to iOS 8.0+.
            continue;
        }
        id instantiated = [[NSBundle mainBundle] loadNibNamed:nibName owner:[PSTViewControllerFinderDummyOwner new] options:nil].firstObject;
        if (![instantiated isKindOfClass:[UIViewController class]]) {
            // Perhaps it is plain view.
            continue;
        }
        UIViewController *viewController = instantiated;
        NSString *label = [NSString stringWithFormat:@"%@.xib", nibName];
        iterator(viewController, label);
    }
}

@end
