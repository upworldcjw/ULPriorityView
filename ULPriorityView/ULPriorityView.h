//
//  ULPriorityView.h
//  UpLive
//
//  Created by jianwei on 10/25/16.
//  Copyright © 2016 jianwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+ULPriority.h"

//调用insert：above 或者insert：below的时候两个view 距离遵循原则
typedef NS_ENUM(NSInteger,ULSiblingPolicy){
    ULSiblingPolicyDefault, //计算效率最优先
    ULSiblingPolicyNearest, //两个视图距离最近
    ULSiblingPolicyFarest,  //两个视图距离最远
};


@interface ULPriorityView : UIView

//调用insert：above 或者insert：below的时候遵循两个view 距离的最近，否则最远
@property (nonatomic, assign) ULSiblingPolicy siblingPolicy;

@end
