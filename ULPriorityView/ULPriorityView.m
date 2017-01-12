//
//  ULPriorityView.m
//  UpLive
//
//  Created by jianwei on 10/25/16.
//  Copyright © 2016 jianwei. All rights reserved.
//

#import "ULPriorityView.h"
#import "UIView+ULPriority.h"

#define  kNSAssertExistSubView(subView) {NSAssert((subView).superview != self, @"not invoke addSubview: or not subview of %p",self)};

@interface ULPriorityView()

//dic[priorityLevel] = subviews.根据等级缓存对应视图，加快计算效率
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

#pragma mark Utility
//由于subviews的view的顺序和cacheLevelViews中priorityLevel从小到大的subviews中view顺序一致。
///用于验证算法的正确性
- (void)check{
#ifdef DEBUG
    NSArray *sortedLeves = [self sortedCacheLevels];
    NSArray *subViews = [self subviews];
    __block NSInteger index = 0;
    [sortedLeves enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * stop) {
        NSArray *sameLeves = self.cacheLevelViews[obj];
        NSAssert(sameLeves.count, @"error");//如果没有view，应该在willRemoveSubview的删除
        for (UIView *view in sameLeves) {
//            NSAssert(view == subViews[index++], @"error");
            if (view != subViews[index++]) {
                [[NSException exceptionWithName:@"ULPriorityView" reason:@"error" userInfo:nil] raise];
            }
        }
    }];
#endif
}

//从cache删除元素
- (void)cacheRemoveView:(UIView *)subView{
    kNSAssertExistSubView(subView)
    NSInteger currentLevel = subView.priorityLevel;
    NSMutableArray *sameLeves = self.cacheLevelViews[@(currentLevel)];
    [sameLeves removeObject:subView];
    if ([sameLeves count] == 0) {//subView是这个级别中的最后一个
        self.cacheLevelViews[@(currentLevel)] = nil;
    }
}

//添加subView到cache
- (void)cacheAddSubView:(UIView *)subView topMost:(BOOL)topMost{
    kNSAssertExistSubView(subView)
    NSInteger currentLevel = subView.priorityLevel;
    NSMutableArray *sameLeves = self.cacheLevelViews[@(currentLevel)];
    if (sameLeves == nil) {
        sameLeves = [NSMutableArray array];
        self.cacheLevelViews[@(currentLevel)] = sameLeves;
    }
    if (topMost) {
        [sameLeves addObject:subView];
    }else{
        [sameLeves insertObject:subView atIndex:0];
    }
}

//检查subView，是否是自己的subview
- (BOOL)checkExistSubView:(UIView *)subView{
    kNSAssertExistSubView(subView)
    if (subView.superview != self) {
        return NO;
    }
    return YES;
}

///根据priorityLevel从小到大排序
- (NSArray *)sortedCacheLevels{
    NSArray<NSNumber *> *levels = self.cacheLevelViews.allKeys;
    NSArray *sortedLeves = [levels sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        return [obj1 integerValue] > [obj2 integerValue];
    }];
    return sortedLeves;
}

///比priorityLevel，优先级小的且最接近的level
- (NSInteger)belowPriorityLevel:(NSInteger)priorityLevel{
    NSArray *sortedLeves = [self sortedCacheLevels];
    for (NSNumber *number in sortedLeves.reverseObjectEnumerator) {//从大到小遍历
        if (number.integerValue < priorityLevel) {
            return number.integerValue;
        }
    }
    return NSNotFound;
}

///比priorityLevel优先级大且最接近的level
- (NSInteger)abovePriorityLevel:(NSInteger)priorityLevel{
    return [self abovePriorityLevel:priorityLevel viewIndex:NULL];
}

///所有view.priorityLevel <= priorityLevel的视图数量
- (NSInteger)viewCountForPriorityLevelLessThenOrEqualTo:(NSInteger)priorityLevel{
    NSInteger allCount = 0;
    [self abovePriorityLevel:priorityLevel viewIndex:&allCount];
    return allCount;
}

///比priorityLevel优先级大且最接近的level
- (NSInteger)abovePriorityLevel:(NSInteger)priorityLevel viewIndex:(NSInteger *)viewIndex{
    NSInteger result = NSNotFound;
    NSArray *sortedLeves = [self sortedCacheLevels];
    NSInteger count = 0;
    for (NSNumber *number in sortedLeves) {//从小到大遍历
        if (number.integerValue > priorityLevel) {
            result = number.integerValue;
            break;
        }
        NSArray *cacheArr = self.cacheLevelViews[@(number.integerValue)];
        count += [cacheArr count];
    }
    if (viewIndex != NULL) {
        *viewIndex = count;
    }
    return result ;
}

#pragma mark - Change subview
///更新cacheLevels
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


/*
 *front = YES,表示调用bringSubviewToFront
 *front = NO,表示调用sendSubviewToBack
 *这个方法是针对等级相同的view前置/后置有效
 */
- (void)bringSubView:(UIView *)view
             toFront:(BOOL)front{
    //对于没用调用addSubview，但是调用bringSubviewToFront，sendSubviewToBack健壮性保护
    if (![self checkExistSubView:view]) {
        return;
    }
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


///view在相同优先级中，视图index最大
- (void)bringSubviewToFront:(UIView *)view{
    [self bringSubView:view toFront:YES];
    [self check];
}

///view在相同优先级中，视图index最小
- (void)sendSubviewToBack:(UIView *)view{
    [self bringSubView:view toFront:NO];
    [self check];
}

///准守尽量靠上原则，后addSubview的视图在所有同一个优先级view的最上面
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
            if (belowPriorityLevel != NSNotFound) {//如果存在比当前优先级小的view
                //修改视图层级
                NSArray *belowLeves = self.cacheLevelViews[@(belowPriorityLevel)];
                NSAssert(belowLeves.lastObject, @"not nil");
                UIView *aboveView = belowLeves.lastObject;
                [super insertSubview:view aboveSubview:aboveView];
                //添加缓存
                [sameLeves addObject:view];
            }else{//view的优先级目前最小，或者self第一次调用addSubview
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

/*
 *需要考虑view和siblingSubview的priorityLevel是否相等及view是否已经添加到了self上
 */
- (void)inner_insertSubview:(UIView *)view
         aboveSubview:(UIView *)siblingSubview{

    NSInteger aboveLevel = siblingSubview.priorityLevel;
    NSInteger currentLevel = view.priorityLevel;
    NSAssert(currentLevel >= aboveLevel , @"error");
    if(currentLevel < aboveLevel){//健壮性保护。本视图遵循优先级越大越靠上。所以这种情况不成立
        return;
    }
    
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
        //TODO:可以考虑加上ULSiblingPolicyFarest和ULSiblingPolicyNearest判断
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

///必需相同优先级才能交换
- (void)exchangeSubviewAtIndex:(NSInteger)index1
            withSubviewAtIndex:(NSInteger)index2{
    UIView *index1View = [self.subviews objectAtIndex:index1];
    UIView *index2View = [self.subviews objectAtIndex:index2];
    NSAssert(index1View.priorityLevel == index2View.priorityLevel, @"error");
    if(index1View.priorityLevel != index2View.priorityLevel){
        return;
    }
    
    //update view
    [super exchangeSubviewAtIndex:index1 withSubviewAtIndex:index2];
    //update cache
    NSMutableArray *sameLeves = self.cacheLevelViews[@(index1View.priorityLevel)];
    [sameLeves exchangeObjectAtIndex:[sameLeves indexOfObject:index1View] withObjectAtIndex:[sameLeves indexOfObject:index2View]];
    [self check];
}


- (NSInteger)properIndexForPriorityLevel:(NSInteger)priorityLevel
                                 topMost:(BOOL)topMost{
    
}

//改变视图
/*如果subview还不在ULPriorityView请先调用addSubview
 *
 *这个方法是提供给subView添加到ULPriorityView实例上后，由于需求又需要修改优先级。
 *topMost 如果是Yes,则subView在priorityLevel的最上面，否则在最下面
 */
- (void)changeSubView:(UIView *)subView
        priorityLevel:(NSInteger)priorityLevel
              topMost:(BOOL)topMost{
    if (![self checkExistSubView:subView]) {
        return;
    }
    
    NSInteger beforeLevel = subView.priorityLevel;
    if (beforeLevel == priorityLevel) {//同一个优先级，放到最前或者最后
        if (topMost) {
            [self bringSubviewToFront:subView];
        }else{
            [self sendSubviewToBack:subView];
        }
    }else{//不同优先级，先删除缓存再添加
        //this will triger willRemoveSubview && didMoveToSuperview.sometime we donot want。
//        {
//            [self removeFromSuperview];
//            subView.priorityLevel = priorityLevel;
//            [self addSubview:subView];//默认放在最上方
//            if (!topMost) {//
//                [self sendSubviewToBack:subView];
//            }
//        }
        //所以我们用下面比较高效的方法.先remove cache
        //删除cache
        [self cacheRemoveView:subView];
        //修改优先级
        subView.priorityLevel = priorityLevel;
        
        NSInteger allViewCountLessThenOrEqualTo = [self viewCountForPriorityLevelLessThenOrEqualTo:priorityLevel];
        if (topMost) {
                [super insertSubview:subView atIndex:allViewCountLessThenOrEqualTo];
        }else{//priorityLevel最下面一个
            NSInteger allViewCountLessThen = allViewCountLessThenOrEqualTo - [self.cacheLevelViews[@(priorityLevel)] count];
            [super insertSubview:subView atIndex:allViewCountLessThen];
        }
        //添加到cache
        [self cacheAddSubView:subView topMost:topMost];
    }
    [self check];
}


/*
 *subView 和 siblingView，已经被添加到ULPriorityView实例上。
 * *changed = NO 表示subView 和 siblingView的优先级相同则同层级交换
 * *changed = YES 表示subView 和 siblingView跨优先级交互，并且相互交换priorityLevel值
 */
- (void)exchangeSubView:(UIView *)subView
        withSiblingView:(UIView *)siblingView
       priorityExchange:(BOOL *)changed{
    NSAssert(subView.superview == self && siblingView.superview == self, @"not invoke addSubview");
    NSAssert(subView.superview == siblingView.superview, @"not siblingView");
    
    NSInteger subViewLevel = subView.priorityLevel;
    NSInteger sibilingViewLevel = siblingView.priorityLevel;

    //update view
    NSInteger subViewIndex = [self.subviews indexOfObject:subView];
    NSInteger siblingViewIndex = [self.subviews indexOfObject:siblingView];
    [super exchangeSubviewAtIndex:subViewIndex withSubviewAtIndex:siblingViewIndex];
    
    if (subViewLevel == sibilingViewLevel) {//同层交换
        //update cache
        NSMutableArray *sameLeves = self.cacheLevelViews[@(subViewLevel)];
        [sameLeves exchangeObjectAtIndex:[sameLeves indexOfObject:subView] withObjectAtIndex:[sameLeves indexOfObject:siblingView]];
        //not changed priorityLevel
        if (changed != NULL) {
            *changed = NO;
        }
    }else{
        NSMutableArray *subViewLevelCaches = self.cacheLevelViews[@(subViewLevel)];
        NSMutableArray *sibilingViewLevelCaches = self.cacheLevelViews[@(sibilingViewLevel)];
        [subViewLevelCaches replaceObjectAtIndex:[subViewLevelCaches indexOfObject:subView] withObject:siblingView];
        [sibilingViewLevelCaches replaceObjectAtIndex:[sibilingViewLevelCaches indexOfObject:siblingView] withObject:subView];
        //exchange priorityLevel
        subView.priorityLevel = sibilingViewLevel;
        siblingView.priorityLevel = subViewLevel;
        if (*changed != NULL) {
            *changed = YES;
        }
    }
    [self check];
}

///TODO:可以考虑如index相应的viewA 和 view 的priorityLevel相等情况，其他情况不考虑
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

@end
