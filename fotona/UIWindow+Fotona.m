//
//  UIWindow+Fotona.m
//  Wave2pay
//
//

#import "UIWindow+Fotona.h"

@implementation UIWindow (Fotona)

- (UIViewController *)visibleViewController {
    UIViewController *rootViewController = self.rootViewController;
    return [UIWindow getVisibleViewControllerFrom:rootViewController];
}

+ (UIViewController *) getVisibleViewControllerFrom:(UIViewController *) vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [UIWindow getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [UIWindow getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [UIWindow getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}

- (UIViewController *)getViewControllerOfClass:(Class)classType
{
    UIViewController *rootViewController = self.rootViewController;
    return [UIWindow getViewControllerFrom:rootViewController ofClass:classType];
}

+ (UIViewController *) getViewControllerFrom:(UIViewController *) vc ofClass:(Class)classType
{
    if ([vc isKindOfClass:[UINavigationController class]])
    {
        NSArray *vcsInNavigation = ((UINavigationController *) vc).viewControllers;
        for (UIViewController *vcInNavigation in vcsInNavigation)
        {
            UIViewController *foundVcInNavigation = [UIWindow getViewControllerFrom:vcInNavigation ofClass:classType];
            if (foundVcInNavigation)
            {
                return foundVcInNavigation;
            }
        }
        
        return nil;
    }
    else if ([vc isKindOfClass:[UITabBarController class]])
    {
        return [UIWindow getViewControllerFrom:[((UITabBarController *) vc) selectedViewController] ofClass:classType];
    }
    else
    {
        if (vc.presentedViewController)
        {
            if ([vc isKindOfClass:classType])
            {
                return vc;
            }
            else
            {
                return [UIWindow getViewControllerFrom:vc.presentedViewController ofClass:classType];
            }
        }
        else
        {
            if ([vc isKindOfClass:classType])
            {
                return vc;
            }
            
            return nil;
        }
    }
}

@end
