//
//  UIView+ULPriority.m
//  UpLive
//
//  Created by jianwei on 10/25/16.
//  Copyright © 2016 jianwei. All rights reserved.
//

#import "UIView+ULPriority.h"
#import <objc/runtime.h>

@implementation UIView (ULPriority)

static const void *kPriority = &kPriority;

- (void)setPriorityLevel:(NSInteger)priorityLevel{
    objc_setAssociatedObject(self, kPriority, @(priorityLevel), OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)priorityLevel{
    NSNumber *num = objc_getAssociatedObject(self, &kPriority);
    if (num != nil) {
        return num.integerValue;
    }
    return kPriorityLevelDefault;
}
@end
