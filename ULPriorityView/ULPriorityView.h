//
//  ULPriorityView.h
//  UpLive
//
//  Created by jianwei on 10/25/16.
//  Copyright © 2016 jianwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+ULPriority.h"

//调用insert：above 或者insert：below的时候两个view距离遵循原则
typedef NS_ENUM(NSInteger,ULSiblingPolicy){
    ULSiblingPolicyDefault, //计算效率最优先
    ULSiblingPolicyNearest, //两个视图距离最近
    ULSiblingPolicyFarest,  //两个视图距离最远
};

@interface ULPriorityView : UIView

//调用insert：above 或者insert：below的时候遵循两个view 之间距离策略
@property (nonatomic, assign) ULSiblingPolicy siblingPolicy;

//改变视图
/*如果subview还不在ULPriorityView请先调用addSubview
 *
 *这个方法是提供给subView添加到ULPriorityView实例上后，由于需求又需要修改优先级。
 *topMost 如果是Yes,则subView在priorityLevel的最上面，否则在最下面
 */
- (void)changeSubView:(UIView *)subView
        priorityLevel:(NSInteger)priorityLevel
              topMost:(BOOL)topMost;

/*
 *subView 和 siblingView，已经被添加到ULPriorityView实例上。
 * *changed = NO 表示subView 和 siblingView的优先级相同，执行的是同层级交换
 * *changed = YES 表示subView 和 siblingView跨优先级交换，并且相互交换priorityLevel值
 */
- (void)exchangeSubView:(UIView *)subView
        withSiblingView:(UIView *)siblingView
       priorityExchange:(BOOL *)changed;

@end
