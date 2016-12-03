//
//  ViewController.m
//  ULPriorityViewDemo
//
//  Created by JianweiChenJianwei on 2016/12/3.
//  Copyright © 2016年 UL. All rights reserved.
//

#import "ViewController.h"
#import "ULPriorityTest.h"
#import <ULPriorityView/ULPriorityView.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [ULPriorityTest testSameLevel];
    [ULPriorityTest testDiffentLevel];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
