//
//  ULPriorityTest.m
//  UpLive
//
//  Created by jianwei on 17/11/2016.
//  Copyright © 2016 AsiaInnovations. All rights reserved.
//

#import "ULPriorityTest.h"
#import "ULPriorityView.h"
static ULPriorityView *view;

@implementation ULPriorityTest

+ (void)test{
    view = [[ULPriorityView alloc] initWithFrame:CGRectMake(100, 100, 100, 200)];
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [self testSameLevel];
}

+ (void)testSameLevel{
    UIView *subView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    subView1.priorityLevel = 1;
    subView1.backgroundColor = [UIColor redColor];
    [view addSubview:subView1];
    
    UIView *subView2 = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 30, 30)];
    subView2.priorityLevel = 1;
    subView2.backgroundColor = [UIColor blueColor];
    [view addSubview:subView2];
    
    [view bringSubviewToFront:subView1];
    
//    [view addSubview:subView2];
    
}


+ (void)testDiffentLevel{
    UIView *subView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    subView1.priorityLevel = 1;
    subView1.backgroundColor = [UIColor redColor];
    [view addSubview:subView1];
    
    UIView *subView2 = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 30, 30)];
    subView2.priorityLevel = 2;
    subView2.backgroundColor = [UIColor blueColor];
    [view addSubview:subView2];
    
    [view bringSubviewToFront:subView1];
    
    //    [view addSubview:subView2];
    
}

@end
