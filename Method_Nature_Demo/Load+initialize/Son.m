//
//  Son.m
//  TestDemo
//
//  Created by Jack on 2018/3/23.
//  Copyright © 2018年 Jack. All rights reserved.
//

#import "Son.h"

@implementation Son

+ (void)load{
    NSLog(@"%s====%@",__FUNCTION__,[self class]);
    NSArray *array = [NSArray array];
    //此处ARC已经做出了优化
    NSLog(@"%@",array);
}

//+ (void)initialize{
//    NSLog(@"%s====%@",__FUNCTION__,[self class]);
//}

@end
