//
//  ViewController.m
//  WJ-轮播图
//
//  Created by 仁和 on 2018/12/26.
//  Copyright © 2018 完美坏蛋. All rights reserved.
//

#import "ViewController.h"
#import "WJWheelPlantView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WJWheelPlantView *carousel = [[WJWheelPlantView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 300)];
    //    carousel.scrollDorectionPortrait = YES;
    carousel.imageArr = @[
                        [UIImage imageNamed:@"0"],
                        [UIImage imageNamed:@"1"],
                        [UIImage imageNamed:@"2"],
                        [UIImage imageNamed:@"3"],
                        [UIImage imageNamed:@"4"]
                        ];
    carousel.currentPageColor = [UIColor orangeColor];
    carousel.pageColor = [UIColor grayColor];
    [self.view addSubview:carousel];
}


@end
