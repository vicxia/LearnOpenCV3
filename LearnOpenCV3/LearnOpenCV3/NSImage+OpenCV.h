//
//  NSImage+OpenCV.h
//  LearnOpenCV_Ex_2_1
//
//  Created by vicxia on 23/05/2017.
//  Copyright © 2017 vicxia. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <Cocoa/Cocoa.h>

@interface NSImage (OpenCV)

@property(nonatomic, readonly) cv::Mat CVMat;
@property(nonatomic, readonly) cv::Mat CVGrayscaleMat;

+(NSImage*)imageWithCVMat:(const cv::Mat&)cvMat;
-(id)initWithCVMat:(const cv::Mat&)cvMat;

@end
