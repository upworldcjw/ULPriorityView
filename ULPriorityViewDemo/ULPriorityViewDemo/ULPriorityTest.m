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


@implementation ULPriorityTest

+ (UIView *)view{
    static ULPriorityView *view;
    if (view == nil) {
        [[UIApplication sharedApplication] keyWindow];
        [[UIApplication sharedApplication] windows];
//        view = [[ULPriorityView alloc] initWithFrame:CGRectMake(100, 100, 100, 200)];
        view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 200)];
        [[(AppDelegate*)[[UIApplication sharedApplication] delegate] window].rootViewController.view addSubview:view];
    }
    return view;
}


+ (void)testSameLevel{
    UIView *subView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    subView1.priorityLevel = 1;
    subView1.backgroundColor = [UIColor redColor];
    [self.view addSubview:subView1];
    
    UIView *subView2 = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 30, 30)];
    subView2.priorityLevel = 1;
    subView2.backgroundColor = [UIColor blueColor];
    [self.view addSubview:subView2];
    
//    [self.view insertSubview:subView1 atIndex:1];
    
    UIView *subView3 = [[UIView alloc] initWithFrame:CGRectMake(30, 30, 30, 30)];
    subView3.priorityLevel = 1;
    subView3.backgroundColor = [UIColor greenColor];
//    [self.view addSubview:subView3];
    [self.view insertSubview:subView3 atIndex:2];
    
//    [self.view bringSubviewToFront:subView1];
    
//    [view addSubview:subView2];
    
}


+ (void)testDiffentLevel{
    UIView *subView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 30, 30)];
    subView1.priorityLevel = 1;
    subView1.backgroundColor = [UIColor redColor];
    [self.view addSubview:subView1];
    
    UIView *subView2 = [[UIView alloc] initWithFrame:CGRectMake(20, 100, 30, 30)];
    subView2.priorityLevel = 2;
    subView2.backgroundColor = [UIColor blueColor];
    [self.view addSubview:subView2];
    
    [self.view bringSubviewToFront:subView1];
    
    //    [view addSubview:subView2];
    
}

@end
