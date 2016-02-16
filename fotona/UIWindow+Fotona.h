//
//  UIWindow+Fotona.h
//  Wave2pay
//
//

#import <UIKit/UIKit.h>

@interface UIWindow (Fotona)

- (UIViewController *) visibleViewController;
- (UIViewController *)getViewControllerOfClass:(Class)classType;

@end
