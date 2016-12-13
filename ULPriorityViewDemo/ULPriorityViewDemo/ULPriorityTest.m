//
//  ULPriorityTest.m
//  UpLive
//
//  Created by jianwei on 17/11/2016.
//  Copyright © 2016 AsiaInnovations. All rights reserved.
//

#import "ULPriorityTest.h"
#import "ULPriorityView.h"
#import "AppDelegate.h"
static ULPriorityView *view;

@implementation ULPriorityTest

+ (void)test{
    [[UIApplication sharedApplication] keyWindow];
    [[UIApplication sharedApplication] windows];
    view = [[ULPriorityView alloc] initWithFrame:CGRectMake(100, 100, 100, 200)];
    [[(AppDelegate*)[[UIApplication sharedApplication] delegate] window].rootViewController.view addSubview:view];
    
    [self testSameLevel];
    
    [self testDiffentLevel];
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
    UIView *subView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 30, 30)];
    subView1.priorityLevel = 1;
    subView1.backgroundColor = [UIColor redColor];
    [view addSubview:subView1];
    
    UIView *subView2 = [[UIView alloc] initWithFrame:CGRectMake(20, 100, 30, 30)];
    subView2.priorityLevel = 2;
    subView2.backgroundColor = [UIColor blueColor];
    [view addSubview:subView2];
    
    [view bringSubviewToFront:subView1];
    
    //    [view addSubview:subView2];
    
}

@end
