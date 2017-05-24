//
//  VXOpenCVViewController.mm
//  LearnOpenCV3
//
//  Created by vicxia on 24/05/2017.
//  Copyright © 2017 vicxia. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "NSImage+OpenCV.h"
#import "VXOpenCVViewController.h"

@interface VXOpenCVViewController ()

@property (weak) IBOutlet NSImageView *imgView;

@end

@implementation VXOpenCVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"orgImage" ofType:@"jpg"];
    std::string imgPath = std::string([path UTF8String]);
    //读入的格式是BGR
    cv::Mat inCvImg = cv::imread(imgPath, cv::IMREAD_UNCHANGED);
    cv::Mat outCvImg;
    //将格式转换为RGB
    cv::cvtColor(inCvImg, outCvImg, cv::COLOR_BGR2RGB);
    //NSImage+OpenCV提供了NSImage<=>cv::Mat(RGB)的转换
    self.imgView.image = [NSImage imageWithCVMat:outCvImg];
}

@end
