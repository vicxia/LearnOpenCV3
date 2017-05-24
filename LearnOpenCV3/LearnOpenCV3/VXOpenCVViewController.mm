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

@interface VXOpenCVViewController () {
    cv::VideoCapture _cap;
    cv::Mat orgCvImg;
    NSInteger _frameCnt;
    CFAbsoluteTime beginTime;
}

@property (weak) IBOutlet NSImageView *leftImgView;
@property (weak) IBOutlet NSImageView *rightImgView;
@property (weak) IBOutlet NSView *bottomMaskView;
@property (weak) IBOutlet NSSlider *slider;
@property (weak) IBOutlet NSTextField *sliderLabel;
@property (weak) IBOutlet NSTextField *costLabel;

@end

@implementation VXOpenCVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    NSString *path = [[NSBundle mainBundle] pathForResource:@"orgImage" ofType:@"jpg"];
    std::string imgPath = std::string([path UTF8String]);
    //读入的格式是BGR
    cv::Mat inCvImg = cv::imread(imgPath, cv::IMREAD_UNCHANGED);
    //将格式转换为RGB
    cv::cvtColor(inCvImg, orgCvImg, cv::COLOR_BGR2RGB);
    //NSImage+OpenCV提供了NSImage<=>cv::Mat(RGB)的转换
    [self showLeftImage:orgCvImg];
    
//    self.slider.intValue = 5;
//    [self updateBlurWithBoxSize:5];
//    
//    [self downSample];
    
//    [self cannyedgeThreshold1:10 threshold2:100];
    
//    [self downAndCannyedgeThreshold1:10 threshold2:100];
    
    [self motifyPixels];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    self.bottomMaskView.layer.backgroundColor = [NSColor colorWithWhite:0 alpha:0.3].CGColor;
}

- (IBAction)onSliderChange:(NSSlider *)sender
{
    self.sliderLabel.stringValue = [NSString stringWithFormat:@"%3d", sender.intValue];
//    [self updateBlurWithBoxSize:sender.intValue];
//    [self cannyedgeThreshold1:10 threshold2:sender.intValue];
//    [self cannyedgeThreshold1:sender.intValue threshold2:100];
    
    [self downAndCannyedgeThreshold1:10 threshold2:sender.intValue];
//    [self downAndCannyedgeThreshold1:sender.intValue threshold2:100];
}

//blur
- (void)updateBlurWithBoxSize:(int)size
{
    cv::Mat blurMat;
    if (size % 2 == 0) {
        size += 1;
    }
    [self beginProcessImage];
    //refer: http://monkeycoding.com/?p=570
    //Could use GaussianBlur(), blur(), medianBlur() or bilateralFilter()
    cv::GaussianBlur(orgCvImg, blurMat, cv::Size(size, size), 10, 10);
//    cv::blur(orgCvImg, blurMat, cv::Size(size, size));
    //refer:http://blog.csdn.net/poem_qianmo/article/details/23184547
//    cv::medianBlur(orgCvImg, blurMat, size);
//    cv::bilateralFilter(orgCvImg, blurMat, size, size * 2, size / 2);
    [self endProcessImage];
    self.rightImgView.image = [NSImage imageWithCVMat:blurMat];
}

//down sample
- (void)downSample
{
    [self beginProcessImage];
    cv::Mat outMat;
    cv::pyrDown(orgCvImg, outMat);
//    cv::pyrDown(outMat, outMat);
    [self endProcessImage];
    [self showRightImage:outMat];
}

- (void)cannyedgeThreshold1:(double)th1 threshold2:(double)th2
{
    [self beginProcessImage];
    cv::Mat grayMat;
    //orgCvImg is RGB format
    cv::cvtColor(orgCvImg, grayMat, cv::COLOR_RGB2GRAY);
    [self showLeftImage:grayMat];
    cv::Mat cannyMat;
    cv::Canny(grayMat, cannyMat, th1, th2, 3, true);
    [self endProcessImage];
    [self showRightImage:cannyMat];
}

- (void)downAndCannyedgeThreshold1:(double)th1 threshold2:(double)th2
{
    cv::Mat grayMat, downMat, cannyMat;
    [self beginProcessImage];
    cv::cvtColor(orgCvImg, grayMat, cv::COLOR_RGB2GRAY);
    cv::pyrDown(grayMat, downMat);
    cv::Canny(downMat, cannyMat, th1, th2, 3, true);
    [self showLeftImage:cannyMat];
    
    cv::pyrDown(downMat, downMat);
    cv::Canny(downMat, cannyMat, th1, th2, 3, true);
    [self endProcessImage];
    [self showRightImage:cannyMat];
}

- (void)motifyPixels
{
    cv::Mat grayMat, downMat, cannyMat;
    cv::cvtColor(orgCvImg, grayMat, cv::COLOR_RGB2GRAY);
    cv::pyrDown(grayMat, downMat);
    cv::pyrDown(downMat, downMat);
    cv::Canny(downMat, cannyMat, 10, 100, 3, true);
    
    int x = 16, y = 32;
    cv::Vec3b intensity = orgCvImg.at<cv::Vec3b>(y, x);
    
    // ( Note: We could write img_rgb.at< cv::Vec3b >(x,y)[0] )
    //
    uchar blue  = intensity[0];
    uchar green = intensity[1];
    uchar red   = intensity[2];
    
    std::cout << "At (x,y) = (" << x << ", " << y <<
    "): (blue, green, red) = (" <<
    (unsigned int)  blue <<
    ", " << (unsigned int)green << ", " <<
    (unsigned int)  red << ")" << std::endl;
    
    std::cout << "Gray pixel there is: " <<
    (unsigned int)  grayMat.at<uchar>(y, x) << std::endl;
    
    x /= 4; y /= 4;
    
    std::cout << "Pyramid2 pixel there is: " <<
    (unsigned int)downMat.at<uchar>(y, x) << std::endl;
    
    cannyMat.at<uchar>(x, y) = 128;
    [self showRightImage:cannyMat];
}


- (IBAction)onCaptureBtnTap:(NSButton *)sender
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_cap.isOpened()) {
            sender.title = @"Capture";
        } else {
            _cap.open(0);
            if (!_cap.isOpened()){
                NSLog(@"open camer failed");
                return;
            }
            sender.title = @"Stop";
        }
        
        NSInteger frameIdx = 0;
        cv::Mat frame;
        cv::Mat rgbMat;
        while(true) {
            if ([sender.title isEqualToString:@"Capture"]) {
                break;
            }
            _cap >> frame;
            frameIdx ++;
            if (frame.empty()) break;
            cv::cvtColor(frame, rgbMat, cv::COLOR_BGR2RGB);
            NSImage *image = [NSImage imageWithCVMat:rgbMat];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.leftImgView.image = image;
//                self.slider.doubleValue = frameIdx * 100 / _frameCnt;
            });
            [NSThread sleepForTimeInterval:0.033];
        }
        NSLog(@"end, readFrame count = %ld", frameIdx);
        //crash https://github.com/opencv/opencv/issues/7833
        _cap.release();
    });
}

#pragma mark - help Method
- (void)showLeftImage:(cv::Mat)mat
{
    NSImage *image = [NSImage imageWithCVMat:mat];
    NSLog(@"left image: %@", image);
    self.leftImgView.image = image;
}

- (void)showRightImage:(cv::Mat)mat
{
    NSImage *image = [NSImage imageWithCVMat:mat];
    NSLog(@"right image: %@", image);
    self.rightImgView.image = image;
}

- (void)beginProcessImage
{
    beginTime = CFAbsoluteTimeGetCurrent();
}

- (void)endProcessImage
{
    CFAbsoluteTime costTime = CFAbsoluteTimeGetCurrent() -beginTime;
    self.costLabel.stringValue = [NSString stringWithFormat:@"cost: %.2f ms", costTime * 1000];
}

@end
