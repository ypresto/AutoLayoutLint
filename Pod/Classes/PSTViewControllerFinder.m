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
