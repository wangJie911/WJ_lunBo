//
//  WJWheelPlantView.m
//  WJ-轮播图
//
//  Created by 仁和 on 2018/12/26.
//  Copyright © 2018 完美坏蛋. All rights reserved.
//

#import "WJWheelPlantView.h"

static const int imageBtnCount = 3;//三张图的模式实现多张滚动效果

@interface WJWheelPlantView()<UIScrollViewDelegate>

@property(nonatomic,weak)UIScrollView *WJScrollView;
@property(nonatomic,weak)UIPageControl *WJPageControl;
@property(nonatomic,weak)NSTimer *timer;

@end


@implementation WJWheelPlantView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //定义一个滚动视图
        UIScrollView *scrollView = [[UIScrollView alloc]init];
        scrollView.delegate = self;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        //需要分页
        scrollView.pagingEnabled = YES;
        scrollView.bounces = NO;
        [self addSubview:scrollView];
        self.WJScrollView = scrollView;
        //创建三个轮播图按钮(用于图片点击,优于直接使用图片)
        for (int i = 0; i < imageBtnCount; i++) {
            UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [scrollView addSubview:imageBtn];
        }
        //添加pageControl
        UIPageControl *pageControl = [[UIPageControl alloc]init];
        [self addSubview:pageControl];
        self.WJPageControl = pageControl;
    }
    return self;
}

//子控件进行布局
-(void)layoutSubviews{
    [super layoutSubviews];
    self.WJScrollView.frame = self.bounds;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    //设置contentSize,不同轮播方向的时候contentSize是不一样的
    if (self.isScrollDorectionPortrait) { //竖向
        self.WJScrollView.contentSize = CGSizeMake(width, height * imageBtnCount);
    }else{
        self.WJScrollView.contentSize = CGSizeMake(width * imageBtnCount, height);
    }
    //设置三张图片的位置,并添加点击事件
    for (int i = 0; i < imageBtnCount; i++) {
        UIButton *imageBtn = self.WJScrollView.subviews[i];
         [imageBtn addTarget:self action:@selector(imageBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        if (self.isScrollDorectionPortrait) {
            imageBtn.frame = CGRectMake(0, i*height, width, height);
        }else{
            imageBtn.frame = CGRectMake(i*width, 0, width, height);
        }
    }
    //设置contentOffset,显示最中间的图片
    if (self.isScrollDorectionPortrait) { //竖向
        self.WJScrollView.contentOffset = CGPointMake(0, height);
    }else{
        self.WJScrollView.contentOffset = CGPointMake(width, 0);
    }
    //设置pageControl位置
    CGFloat pageW = 100;
    CGFloat pageH = 20;
    CGFloat pageX = width - pageW;
    CGFloat pageY = height - pageH;
    self.WJPageControl.frame = CGRectMake(pageX, pageY, pageW, pageH);
}
//设置pageControl的CurrentPageColor
-(void)setCurrentPageColor:(UIColor *)currentPageColor{
    _currentPageColor = currentPageColor;
    self.WJPageControl.currentPageIndicatorTintColor = currentPageColor;
}
//设置pageControl的pageColor
-(void)setPageColor:(UIColor *)pageColor{
    _pageColor = pageColor;
    self.WJPageControl.pageIndicatorTintColor = pageColor;
}
//根据传入的图片数组设置图片
-(void)setImageArr:(NSArray *)imageArr{
    _imageArr = imageArr;
    //pageControl的页数就是图片的个数
    self.WJPageControl.numberOfPages = imageArr.count;
    //pageControl默认开始的是0页
    self.WJPageControl.currentPage = 0;
    //设置图片显示内容
    [self setContent];
    [self startTimer];
}
//设置显示内容
- (void)setContent{
    for (int i = 0; i < self.WJScrollView.subviews.count; i++) {
        UIButton *imageBtn = self.WJScrollView.subviews[i];
        NSInteger index = self.WJPageControl.currentPage;
        if (i == 0) { //第一个imageBtn，隐藏在当前显示的imageBtn的左侧
            index--; //当前页索引减1就是第一个imageBtn的图片索引
        } else if (i == 2) { //第三个imageBtn，隐藏在当前显示的imageBtn的右侧
            index++; //当前页索引加1就是第三个imageBtn的图片索引
        }
        //无限循环效果的处理就在这里
        if (index < 0) { //当上面index为0的时候，再向右拖动，左侧图片显示，这时候我们让他显示最后一张图片
            index = self.WJPageControl.numberOfPages - 1;
        } else if (index == self.WJPageControl.numberOfPages) { //当上面的index超过最大page索引的时候，也就是滑到最右再继续滑的时候，让他显示第一张图片
            index = 0;
        }
        imageBtn.tag = index;
        //用上面处理好的索引给imageBtn设置图片
        [imageBtn setBackgroundImage:self.imageArr[index] forState:UIControlStateNormal];
        [imageBtn setBackgroundImage:self.imageArr[index] forState:UIControlStateHighlighted];
    }
}

//状态改变之后更新显示内容
- (void)updateContent {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    [self setContent];
    //唯一跟设置显示内容不同的就是重新设置偏移量，让它永远用中间的按钮显示图片,滑动之后就偷偷的把偏移位置设置回去，这样就实现了永远用中间的按钮显示图片
    //设置偏移量在中间
    if (self.isScrollDorectionPortrait) {
        self.WJScrollView.contentOffset = CGPointMake(0, height);
    } else {
        self.WJScrollView.contentOffset = CGPointMake(width, 0);
    }
}

#pragma mark - UIScrollViewDelegate
//滑动的时候执行哪些操作
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //拖动的时候，哪张图片最靠中间，也就是偏移量最小，就滑到哪页
    //用来设置当前页
    NSInteger page = 0;
    //用来拿最小偏移量
    CGFloat minDistance = MAXFLOAT;
    //遍历三个imageView,看那个图片偏移最小，也就是最靠中间
    for (int i = 0; i < self.WJScrollView.subviews.count; i++) {
        UIButton *imageBtn = self.WJScrollView.subviews[i];
        CGFloat distance = 0;
        if (self.isScrollDorectionPortrait) {
            distance = ABS(imageBtn.frame.origin.y - scrollView.contentOffset.y);
        } else {
            distance = ABS(imageBtn.frame.origin.x - scrollView.contentOffset.x);
        }
        if (distance < minDistance) {
            minDistance = distance;
            page = imageBtn.tag;
        }
    }
    self.WJPageControl.currentPage = page;
}
//开始拖拽的时候停止计时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}
//结束拖拽的时候开始定时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startTimer];
}
//结束拖拽的时候更新image内容
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateContent];
}
//scroll滚动动画结束的时候更新image内容
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self updateContent];
}

#pragma mark - 定时器
//开始计时器
- (void)startTimer {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}
//停止计时器
- (void)stopTimer {
    //结束计时
    [self.timer invalidate];
    //计时器被系统强引用，必须手动释放
    self.timer = nil;
}
//通过改变contentOffset * 2换到下一张图片
- (void)nextImage {
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    if (self.isScrollDorectionPortrait) {
        [self.WJScrollView setContentOffset:CGPointMake(0, 2 * height) animated:YES];
    } else {
        [self.WJScrollView setContentOffset:CGPointMake(2 * width, 0) animated:YES];
    }
}


@end
