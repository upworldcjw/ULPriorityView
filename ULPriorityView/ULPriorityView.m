//
//  ULPriorityView.m
//  UpLive
//
//  Created by jianwei on 10/25/16.
//  Copyright © 2016 jianwei. All rights reserved.
//

#import "ULPriorityView.h"
#import "UIView+ULPriority.h"

@interface ULPriorityView()

@property (nonatomic, strong) NSMutableDictionary *cacheLevelViews;

@end

@implementation ULPriorityView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.cacheLevelViews = [NSMutableDictionary dictionary];
        self.siblingPolicy = ULSiblingPolicyDefault;
    }
    return self;
}

- (void)check{
    NSArray *sortedLeves = [self sortedCacheLevels];
    NSArray *subViews = [self subviews];
    __block NSInteger index = 0;
    [sortedLeves enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * stop) {
        NSArray *sameLeves = self.cacheLevelViews[obj];
        NSAssert(sameLeves.count, @"error");
        for (UIView *view in sameLeves) {
//            NSAssert(view == subViews[index++], @"error");
            if (view != subViews[index++]) {
                [[NSException exceptionWithName:@"ULPriorityView" reason:@"error" userInfo:nil] raise];
            }
        }
    }];
}

//更新cacheLevels
- (void)willRemoveSubview:(UIView *)subview{
    [super willRemoveSubview:subview];
    
    NSInteger currentLevel = subview.priorityLevel;
    NSMutableArray *sameLeves = self.cacheLevelViews[@(currentLevel)];
    NSAssert([sameLeves containsObject:subview], @"error");
    [sameLeves removeObject:subview];
    if ([sameLeves count] == 0) {//subView是这个级别中的最后一个
        self.cacheLevelViews[@(currentLevel)] = nil;
    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self check];
//    });
}


- (void)bringSubView:(UIView *)view
             toFront:(BOOL)front{
    NSInteger currentLevel = view.priorityLevel;
    NSMutableArray<UIView *> *sameLeves = self.cacheLevelViews[@(currentLevel)];
    NSAssert([sameLeves containsObject:view], @"error");
    
    if (front) {
        UIView *exchangeToIndexView = sameLeves.lastObject;
        if (exchangeToIndexView != view) {
            //subView视图修改
            [super insertSubview:view aboveSubview:exchangeToIndexView];
            //缓存更新,修改
            NSInteger sameLeveOriginalIndex = [sameLeves indexOfObject:view];
            [sameLeves removeObjectAtIndex:sameLeveOriginalIndex];
            [sameLeves addObject:view];
        }
    }else{
        UIView *exchangeToIndexView = sameLeves.firstObject;
        if (exchangeToIndexView != view) {
            //subView视图修改
            [super insertSubview:view belowSubview:exchangeToIndexView];
            //缓存更新，修改
            NSInteger sameLeveOriginalIndex = [sameLeves indexOfObject:view];
            [sameLeves removeObjectAtIndex:sameLeveOriginalIndex];
            [sameLeves insertObject:view atIndex:0];
        }
    }
}


//view在相同优先级中，视图index最大
- (void)bringSubviewToFront:(UIView *)view{
    [self bringSubView:view toFront:YES];
    [self check];
}

//view在相同优先级中，视图index最小
- (void)sendSubviewToBack:(UIView *)view{
    [self bringSubView:view toFront:NO];
    [self check];
}

- (NSArray *)sortedCacheLevels{
    NSArray<NSNumber *> *levels = self.cacheLevelViews.allKeys;
    NSArray *sortedLeves = [levels sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        return [obj1 integerValue] > [obj2 integerValue];
    }];
    return sortedLeves;
}

- (NSInteger)belowPriorityLevel:(NSInteger)priorityLevel{
    NSArray *sortedLeves = [self sortedCacheLevels];
    for (NSNumber *number in sortedLeves.reverseObjectEnumerator) {//从大到小遍历
        if (number.integerValue < priorityLevel) {
            return number.integerValue;
        }
    }
    return NSNotFound;
}

//比priorityLevel优先级大的最近的一个优先级视图
- (NSInteger)abovePriorityLevel:(NSInteger)priorityLevel{
    NSArray *sortedLeves = [self sortedCacheLevels];
    for (NSNumber *number in sortedLeves) {//从小到大遍历
        if (number.integerValue > priorityLevel) {
            return number.integerValue;
        }
    }
    return NSNotFound;
}

//准守尽量靠上原则
- (void)addSubview:(UIView *)view{
    //view 已经在视图上，再次加入
    if ([self.subviews containsObject:view]) {
        [self bringSubviewToFront:view];
    }else{
        NSInteger currentLevel = view.priorityLevel;
        NSMutableArray<UIView *> *sameLeves = self.cacheLevelViews[@(currentLevel)];
        if (sameLeves == nil) {
            sameLeves = [[NSMutableArray alloc] init];
            self.cacheLevelViews[@(currentLevel)] = sameLeves;
            
            NSInteger belowPriorityLevel = [self belowPriorityLevel:currentLevel];
            if (belowPriorityLevel != NSNotFound) {
                //修改视图层级
                NSArray *belowLeves = self.cacheLevelViews[@(belowPriorityLevel)];
                NSAssert(belowLeves.lastObject, @"not nil");
                UIView *aboveView = belowLeves.lastObject;
                [super insertSubview:view aboveSubview:aboveView];
                //添加缓存
                [sameLeves addObject:view];
            }else{
                //修改视图层级
                [super insertSubview:view atIndex:0];
                //添加缓存
                [sameLeves addObject:view];
            }
        }else{
            //修改视图层级
            [super insertSubview:view aboveSubview:sameLeves.lastObject];
            //添加缓存
            [sameLeves addObject:view];
        }
    }
    [self check];
}


//view和siblingSubview如果不在相同视图等级上
//这个方法的时候考虑view不在self上
- (void)inner_insertSubview:(UIView *)view
         aboveSubview:(UIView *)siblingSubview{

    NSInteger aboveLevel = siblingSubview.priorityLevel;
    NSInteger currentLevel = view.priorityLevel;
    NSAssert(currentLevel >= aboveLevel , @"error");
    
    BOOL isExistAddView = [self.subviews containsObject:view];
    //保持视图间距最近
    if (aboveLevel == currentLevel) {
        //修改缓存
        NSMutableArray *sameLeves = self.cacheLevelViews[@(currentLevel)];
        if (isExistAddView) {
            [sameLeves removeObject:view];
        }
        NSInteger siblingIndex = [sameLeves indexOfObject:siblingSubview];
        if(sameLeves.count -1 == siblingIndex){//最后一个
            [sameLeves addObject:view];
        }else{
            [sameLeves insertObject:view atIndex:siblingIndex + 1];
        }
        //修改视图结构
        [super insertSubview:view aboveSubview:siblingSubview];
    }else{
        NSInteger blowPriorityLevel = [self belowPriorityLevel:currentLevel];
        NSAssert(blowPriorityLevel>= aboveLevel, @"error");
        
        if (isExistAddView) {
            //如果不在相同层级
            if (self.siblingPolicy == ULSiblingPolicyDefault) {
                return;//已经满足上下层关系。
            }else if (self.siblingPolicy == ULSiblingPolicyNearest){
                [self sendSubviewToBack:view];
            }else if (self.siblingPolicy == ULSiblingPolicyFarest){
                [self bringSubviewToFront:view];
            }
        }else{//如果view 不在self上
            NSMutableArray *sameLeves = self.cacheLevelViews[@(currentLevel)];
            if (sameLeves == nil) {
                //缓存数据
                sameLeves = [NSMutableArray array];
                self.cacheLevelViews[@(currentLevel)] = sameLeves;
                [sameLeves addObject:view];
                //修改视图层级
                NSArray *belowSubViews = self.cacheLevelViews[@(blowPriorityLevel)];
                UIView *doBelowView = belowSubViews.lastObject;
                [super insertSubview:view aboveSubview:doBelowView];
            }else{//sameLeves
                if (self.siblingPolicy == ULSiblingPolicyNearest) {
                    //修改视图层级
                    UIView *originalSameLevelFirstView = sameLeves.firstObject;
                    [super insertSubview:view belowSubview:originalSameLevelFirstView];
                    //缓存数据
                    [sameLeves insertObject:view atIndex:0];
                }else if(self.siblingPolicy == ULSiblingPolicyFarest ||
                         self.siblingPolicy == ULSiblingPolicyDefault){
                    //修改视图层级
                    UIView *originalSameLevelLastView = sameLeves.lastObject;
                    [super insertSubview:view aboveSubview:originalSameLevelLastView];
                    //缓存数据
                    [sameLeves addObject:view];
                }
            }
        }
    }
}

- (void)insertSubview:(UIView *)view
         aboveSubview:(UIView *)siblingSubview{
    NSAssert([self.subviews containsObject:siblingSubview], @"error");
    [self inner_insertSubview:view aboveSubview:siblingSubview];
}


//view和siblingSubview，在准守等级的情况下距离最小
//这个方法的时候考虑view不在self上
- (void)inner_insertSubview:(UIView *)view
               belowSubview:(UIView *)siblingSubview{
    
    NSInteger aboveLevel = siblingSubview.priorityLevel;
    NSInteger currentLevel = view.priorityLevel;
    NSAssert(currentLevel <= aboveLevel , @"error");
    
    BOOL isExistAddView = [self.subviews containsObject:view];
    //保持视图间距最近
    if (aboveLevel == currentLevel) {//ok
        //修改缓存
        NSMutableArray *sameLeves = self.cacheLevelViews[@(currentLevel)];
        if (isExistAddView) {
            [sameLeves removeObject:view];
        }
        NSInteger siblingIndex = [sameLeves indexOfObject:siblingSubview];
        [sameLeves insertObject:view atIndex:siblingIndex];
        //修改视图结构
        [super insertSubview:view belowSubview:siblingSubview];
    }else{
        NSInteger properPriorityLevel = [self abovePriorityLevel:currentLevel];
        NSAssert(properPriorityLevel != NSNotFound &&
                 properPriorityLevel <= aboveLevel, @"error");
        
        if (isExistAddView) {
            //如果不在相同层级
            if (self.siblingPolicy == ULSiblingPolicyDefault) {
                return;//已经满足上下层关系。
            }else if (self.siblingPolicy == ULSiblingPolicyNearest){
                [self bringSubviewToFront:view];
            }else if (self.siblingPolicy == ULSiblingPolicyFarest){
                [self sendSubviewToBack:view];
            }
        }else{//如果view 不在self上
            NSMutableArray *sameLeves = self.cacheLevelViews[@(currentLevel)];
            if (sameLeves == nil) {
                //缓存数据
                sameLeves = [NSMutableArray array];
                self.cacheLevelViews[@(currentLevel)] = sameLeves;
                [sameLeves addObject:view];
                //修改视图层级
                NSArray *properSubViews = self.cacheLevelViews[@(properPriorityLevel)];
                UIView *doBelowView = properSubViews.firstObject;
                [super insertSubview:view belowSubview:doBelowView];
            }else{//sameLeves
                if (self.siblingPolicy == ULSiblingPolicyNearest||
                    self.siblingPolicy == ULSiblingPolicyDefault) {
                    //修改视图层级
                    UIView *originalSameLevelLastView = sameLeves.lastObject;
                    [super insertSubview:view aboveSubview:originalSameLevelLastView];
                    //缓存数据
                    [sameLeves addObject:view];
                }else if(self.siblingPolicy == ULSiblingPolicyFarest){
                    //修改视图层级
                    UIView *originalSameLevelFirstView = sameLeves.firstObject;
                    [super insertSubview:view belowSubview:originalSameLevelFirstView];
                    //缓存数据
                    [sameLeves insertObject:view atIndex:0];
                }
            }
        }
    }
}


- (void)insertSubview:(UIView *)view
         belowSubview:(UIView *)siblingSubview{
    NSAssert([self.subviews containsObject:siblingSubview], @"error");
    [self inner_insertSubview:view belowSubview:siblingSubview];
    [self check];
}


- (void)exchangeSubviewAtIndex:(NSInteger)index1
            withSubviewAtIndex:(NSInteger)index2{
    UIView *index1View = [self.subviews objectAtIndex:index1];
    UIView *index2View = [self.subviews objectAtIndex:index2];
    NSAssert(index1View.priorityLevel == index2View.priorityLevel, @"error");
    //update view
    [super exchangeSubviewAtIndex:index1 withSubviewAtIndex:index2];
    //update cache
    NSMutableArray *sameLeves = self.cacheLevelViews[@(index1View.priorityLevel)];
    [sameLeves exchangeObjectAtIndex:[sameLeves indexOfObject:index1View] withObjectAtIndex:[sameLeves indexOfObject:index2View]];
    [self check];
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index{
    NSAssert(false, @"not support");
    //    if ([self.subviews count] > 0) {
    //        NSInteger currentLevel = view.priorityLevel;
    //        UIView *originalView = [self.subviews objectAtIndex:index];
    //        NSAssert(currentLevel <= originalView.priorityLevel, @"error");
    //        if ([self.subviews containsObject:view]) {
    //            NSArray *sameLevels = self.cacheLevelViews[@(currentLevel)];
    //            UIView *firstView = sameLevels.firstObject;
    //            UIView *lastView = sameLevels.lastObject;
    //            NSInteger firstIndex = [self.subviews indexOfObject:firstView];
    //            NSInteger lastIndex = [self.subviews indexOfObject:lastView];
    //            NSAssert(firstIndex >=, <#desc, ...#>)
    //            //TODO:index 需要转换
    //            [super insertSubview:view atIndex:index];
    //        }else{
    //
    //        }
    //    }else{
    //        [self addSubview:view];
    //    }
    //    [self check];
}


//- (UIView * (^)(UIView *subView))addSubview{
//    return ^(UIView *subView){
//        [self addSubview:subView];
//        return subView;
//    };
//}
//
//- (UIView *(^)(kPriorityLevel level))level{
//    return ^(kPriorityLevel level){
//        self.priorityLevel = level;
//        if (self.superview) {
//            [self.superview pp_addSubview:self];
//        }
//        return self;
//    };
//}
@end
