//
//  CVWrapper.mm
//  RA Face Partner
//
//  Created by Swarup Ghosh on 22/07/19.
//  Copyright © 2019 Swarup Ghosh. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "CVWrapper.h"

using namespace std;
using namespace cv;

@implementation CVWrapper

// Copyright © Yiwei Ni
// https://medium.com/@yiweini/opencv-with-swift-step-by-step-c3cc1d1ee5f1

+ (NSString *)openCVVersionInfo {
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}

// Copyright © OpenCV iOS
// https://docs.opencv.org/2.4/doc/tutorials/ios/image_manipulation/image_manipulation.html#opencviosimagemanipulation

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

// Copyright © OpenCV iOS
// https://docs.opencv.org/2.4/doc/tutorials/ios/image_manipulation/image_manipulation.html#opencviosimagemanipulation

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

// Methods for face detection

- (NSString *)getHaarCascadeFrontalFaceFilePath {
    NSString *xmlFilePath = [[NSBundle mainBundle]pathForResource:@"haarcascade_frontalface_alt2" ofType:@"xml"];
    return xmlFilePath;
}

- (NSString *)getNewImagePath: (NSString *)fileExtension {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    
    NSDateFormatter *dateFmt = [NSDateFormatter new];
    [dateFmt setDateFormat:@"dd-MM-yyyy_hh.mm.ss.a"];
    NSDate *dateNow = [NSDate new];
    NSString *timeStr = [dateFmt stringFromDate:dateNow];
    
    int uid = 1;
    
    NSString *filename = [NSString stringWithFormat: @"%@_%d.%@", timeStr, uid, fileExtension];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    while([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        filename = [NSString stringWithFormat: @"%@_%d.%@", timeStr, uid, fileExtension];
        dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
        uid = uid + 1;
    }
    return dataPath;
}

@end
