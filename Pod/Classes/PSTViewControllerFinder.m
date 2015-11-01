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

typedef UIViewController *(^PSTViewControllerFinderResultItemInstantiator)();

@interface PSTViewControllerFinderResultItem ()

@property (nonatomic, copy, readonly) PSTViewControllerFinderResultItemInstantiator instantiator;

@end

@implementation PSTViewControllerFinderResultItem

- (instancetype)initWithLabel:(NSString *)label instantiator:(PSTViewControllerFinderResultItemInstantiator)instantiator
{
    self = [super init];
    if (self) {
        _label = label;
        _instantiator = [instantiator copy];
    }
    return self;
}

- (UIViewController *)instantiate
{
    return self.instantiator();
}

@end

@implementation PSTViewControllerFinder

- (NSArray<PSTViewControllerFinderResultItem *> * _Nonnull)findAllViewControllers
{
    return [[self findViewControllersInStoryboards] arrayByAddingObjectsFromArray:[self findViewControllersInXibs]];
}

- (NSArray<PSTViewControllerFinderResultItem *> * _Nonnull)findViewControllersInStoryboards
{
    NSMutableArray *resultItems = [NSMutableArray array];
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
            NSString *label = [NSString stringWithFormat:@"%@.storyboard - %@", storyboardName, identifier];
            PSTViewControllerFinderResultItem *resultItem = [[PSTViewControllerFinderResultItem alloc] initWithLabel:label instantiator:^UIViewController *{
                return [storyboard instantiateViewControllerWithIdentifier:identifier];
            }];
            [resultItems addObject:resultItem];
        }
    }
    return [resultItems copy];
}

- (NSArray<PSTViewControllerFinderResultItem *> * _Nonnull)findViewControllersInXibs
{
    NSMutableArray *resultItems = [NSMutableArray array];
    NSArray<NSString *> *nibPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"nib" inDirectory:@"/"];
    for (NSString *nibPath in nibPaths) {
        NSString *nibName = [nibPath.lastPathComponent stringByDeletingPathExtension];
        if ([nibName containsString:@"~ipad"] || [nibName containsString:@"~iphone"]) {
            // They seems to be pointing non-tilde-suffixed storyboardc directory when targeted to iOS 8.0+.
            continue;
        }
        
        id (^instantiator)() = ^id{
            return [[NSBundle mainBundle] loadNibNamed:nibName owner:[PSTViewControllerFinderDummyOwner new] options:nil].firstObject;
        };

        id instantiatedObject = instantiator();
        if (![instantiatedObject isKindOfClass:[UIViewController class]]) {
            // Perhaps it is plain view.
            continue;
        }

        NSString *label = [NSString stringWithFormat:@"%@.xib", nibName];
        PSTViewControllerFinderResultItem *resultItem = [[PSTViewControllerFinderResultItem alloc] initWithLabel:label instantiator:instantiator];
        [resultItems addObject:resultItem];
    }
    return [resultItems copy];
}

@end
