# ULPriorityView
This can help you organize subview accordding by Priority.<br>
The most priorityLevel in the toppest level of the view instance which inherite from ULPriorityView。<br>
可以设置view的优先级，优先级越高越靠上。（考上是指（view.subViews中的index值））<br>
//如果priorityLevel设置值相等，则谁后加到view上谁靠上。（和普通view特性一致）<br>
+ (void)testSameLevel{<br>
    UIView *subView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];<br>
    subView1.priorityLevel = 1;<br>
    subView1.backgroundColor = [UIColor redColor];<br>
    [view addSubview:subView1];<br>
    <br>
    UIView *subView2 = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 30, 30)];<br>
    subView2.priorityLevel = 1;<br>
    subView2.backgroundColor = [UIColor blueColor];<br>
    [view addSubview:subView2];<br>
    <br>
    //此时subView1的index = 0，subView2的index = 1<br>
    <br>
    [view bringSubviewToFront:subView1];<br>
    <br>
    //此时subview1的index = 1，subview2的index = 0<br>
}

//如果priorityLevel设置值不相等，值越大越靠上（不管谁先加到view上）。<br>
+ (void)testDiffentLevel{<br>
    UIView *subView2 = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 30, 30)];<br>
    subView2.priorityLevel = 2;<br>
    subView2.backgroundColor = [UIColor blueColor];<br>
    [view addSubview:subView2];<br>
    <br>
    UIView *subView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];<br>
    subView1.priorityLevel = 1;<br>
    subView1.backgroundColor = [UIColor redColor];<br>
    [view addSubview:subView1];<br>
    <br>
    //此时subview1的index = 0，subView2的index = 1。虽然subview2先addsubView<br>
    <br>
    [view bringSubviewToFront:subView1];<br>
    <br>
    //由于subView2的priorityLevel比较大，所以调用这个方法之后还是subview1的index = 0，subView2的index = 1。虽然subview2先addsubView.<br>
    //bringSubviewToFront,sendsubviewToBack只针对相同的priorityLevel调用有效<br>
    
}
