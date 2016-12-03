//
//  UIView+ULPriority.h
//  UpLive
//
//  Created by jianwei on 10/25/16.
//  Copyright © 2016 jianwei. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPriorityLevel(level) level

//值越大越靠上
typedef NS_ENUM(NSInteger,kPriorityLevel){//优先级越大越靠近上
    kPriorityLevelBelowest = - 10000,   //最底层
    kPriorityLevelBelow = -1000,        //偏底层
    kPriorityLevelDefault = 0,          //默认
    kPriorityLevelMiddle = 1000,        //偏向上面
    kPriorityLevelTop = 10000,          //最上面
};


@interface UIView (ULPriority)
//先调用priorityLevel，然后在放到父视图上
@property (nonatomic, assign) NSInteger priorityLevel;



@end
