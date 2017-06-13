//
//  UIView+MZToast.m
//  WePlayVoiceDemo
//
//  Created by Me on 13/06/2017.
//  Copyright © 2017 veryitman.com. All rights reserved.
//

#import "UIView+MZToast.h"

@implementation UIView (MZToast)

- (void)showToast:(NSString *)string
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.layer.cornerRadius = 6.f;
    view.layer.masksToBounds = YES;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:view];
    view.frame = CGRectMake((window.frame.size.width-200)/2, window.frame.size.height-100, 200, 50);
    
    view.backgroundColor = [UIColor grayColor];
    
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectZero];
    lb.text = string;
    
    [view addSubview:lb];
    lb.numberOfLines = 1;
    lb.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    lb.textAlignment = NSTextAlignmentCenter;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5f animations:^{
            view.alpha = 0.f;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    });
}

@end
