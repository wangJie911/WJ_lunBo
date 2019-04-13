//
//  WJWheelPlantView.h
//  WJ-轮播图
//
//  Created by 仁和 on 2018/12/26.
//  Copyright © 2018 完美坏蛋. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WJWheelPlantView : UIView
//传入的图片数组
@property(nonatomic,copy)NSArray *imageArr;
//pageControl颜色设置
@property (nonatomic, strong) UIColor *currentPageColor;
@property (nonatomic, strong) UIColor *pageColor;
//是否竖向滚动
@property (nonatomic, assign, getter=isScrollDorectionPortrait) BOOL scrollDorectionPortrait;

@end

NS_ASSUME_NONNULL_END
