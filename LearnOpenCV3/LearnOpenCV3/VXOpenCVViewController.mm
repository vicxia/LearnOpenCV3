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
    NSInteger _frameCnt;
}

@property (weak) IBOutlet NSImageView *imgView;
@property (weak) IBOutlet NSView *bottomMaskView;
@property (weak) IBOutlet NSSlider *slider;

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

- (void)viewWillAppear
{
    [super viewWillAppear];
    self.bottomMaskView.layer.backgroundColor = [NSColor colorWithWhite:0 alpha:0.3].CGColor;
}

- (IBAction)onPlayBtnTap:(NSButton *)sender
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"orgVideo" ofType:@"mp4"];
        if (_cap.isOpened()){
            _cap.set(cv::CAP_PROP_POS_FRAMES, 0);
        } else {
            _cap.open(std::string([videoPath UTF8String]));
            _frameCnt = _cap.get(cv::CAP_PROP_FRAME_COUNT);
            int tmpw = (int) _cap.get(cv::CAP_PROP_FRAME_WIDTH);
            int tmph = (int) _cap.get(cv::CAP_PROP_FRAME_HEIGHT);
            NSLog(@"videoCapture: frameCnt = %ld; size=(%d, %d)", _frameCnt, tmpw, tmph);
        }
        NSInteger frameIdx = 0;
        cv::Mat frame;
        while(true) {
            _cap >> frame;
            frameIdx ++;
            if (frame.empty()) break;
            NSImage *image = [NSImage imageWithCVMat:frame];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imgView.image = image;
                self.slider.doubleValue = frameIdx * 100 / _frameCnt;
            });
            [NSThread sleepForTimeInterval:0.045];
        }
        NSLog(@"end, readFrame count = %ld", frameIdx);
    });
}

- (IBAction)onSliderChange:(NSSlider *)sender
{
    
}

@end
