//
//  OCCallJSViewController.m
//  TestDemo
//
//  Created by Jack on 2018/5/21.
//  Copyright © 2018年 Jack. All rights reserved.
//

#import "OCCallJSViewController.h"

@interface OCCallJSViewController ()

@end

@implementation OCCallJSViewController

- (void)loadNavItems
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"加1" style:UIBarButtonItemStyleDone target:self action:@selector(addOne)];
    self.navigationItem.title = @"OC调用JS代码";
    
}

- (void)addOne
{
    //获取context的引用，这里是获取到js代码里的addAction方法
    JSValue *addAction = self.context[@"addAction"];
    //在addAction方法里传入1
    [addAction callWithArguments:@[@1]];
}

@end
