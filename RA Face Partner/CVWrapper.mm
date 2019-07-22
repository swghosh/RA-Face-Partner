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

// Copyright © Dmytro Nasyrov, Pharos Production Inc.
// https://github.com/dmytronasyrov/Swift-with-OpenCV/blob/master/OpenCV/Classes/OpenCVWrapper.mm

+ (Mat)matFrom:(UIImage *)source {
    
    CGImageRef image = CGImageCreateCopy(source.CGImage);
    CGFloat cols = CGImageGetWidth(image);
    CGFloat rows = CGImageGetHeight(image);
    Mat result(rows, cols, CV_8UC4);
    
    CGBitmapInfo bitmapFlags = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = result.step[0];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
    
    CGContextRef context = CGBitmapContextCreate(result.data, cols, rows, bitsPerComponent, bytesPerRow, colorSpace, bitmapFlags);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, cols, rows), image);
    CGContextRelease(context);
    
    return result;
}

// Copyright © Yiwei Ni
// https://medium.com/@yiweini/opencv-with-swift-step-by-step-c3cc1d1ee5f1

+ (NSString *)openCVVersionInfo {
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}

// Methods for face detection

+ (NSString *)getHaarCascadeFrontalFaceFilePath {
    NSString *xmlFilePath = [[NSBundle mainBundle]pathForResource:@"haarcascade_frontalface_alt2" ofType:@"xml"];
    return xmlFilePath;
}

+ (NSString *)getNewImagePath: (NSString *)fileExtension {
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

+ (cv::Rect)increaseRect: (cv::Rect)rect byPercentage: (float)percentage maxWidth:(int)widthLimit maxHeight:(int)heightLimit {
    
    int extraHeight = (int)(rect.height * percentage);
    int extraWidth = (int)(rect.width * percentage);
    
    rect.width += extraWidth;
    rect.height += extraHeight;
    
    rect.x -= extraWidth / 2;
    rect.y -= extraHeight / 2;
    
    // handle Rect out of bounds
    if(rect.x < 0) rect.x = 0;
    if(rect.y < 0) rect.y = 0;
    
    if(rect.x + rect.width > widthLimit) rect.width = widthLimit - rect.x;
    if(rect.y + rect.height > heightLimit) rect.height = heightLimit - rect.y;
    
    return rect;
}

// using JPG images!
+ (void)writeImage: (Mat)source {
    string newPath = string([[CVWrapper getNewImagePath: @"jpg"] UTF8String]);
    cvtColor(source, source, COLOR_RGB2BGR);
    imwrite(newPath, source);
    cout << "Wrote image to path " << newPath << "\n";
}

const float INCREASE_PERCENT = 0.6f;

+ (int)detectFacesAndSave:(Mat)source {
    string hccXmlPath = string([[CVWrapper getHaarCascadeFrontalFaceFilePath] UTF8String]);
    CascadeClassifier faceCascade = CascadeClassifier(hccXmlPath);
    
    vector<cv::Rect> faces;
    Mat grayImg;
    
    cvtColor(source, grayImg, COLOR_RGB2GRAY);
    faceCascade.detectMultiScale(grayImg, faces, 1.35, 5.0);
    
    for(int i = 0; i < faces.size(); i++) {
        faces[i] = [CVWrapper increaseRect:faces[i] byPercentage:INCREASE_PERCENT maxWidth:grayImg.cols maxHeight:grayImg.rows];
        Mat faceFrame = source(faces[i]);
        [CVWrapper writeImage:faceFrame];
    }
    
    return (int)faces.size();
}

+ (NSInteger) faceDetector:(UIImage *) source transpose: (BOOL)transposeFlag flip: (BOOL)flipFlag  {
    Mat frame = [CVWrapper matFrom:source];
    if(transposeFlag) transpose(frame, frame);
    if(flipFlag) flip(frame, frame, 1); // horizontal flip
    
    int facesCount = [CVWrapper detectFacesAndSave:frame];
    
    return [[NSNumber numberWithInt:facesCount] integerValue];
}

@end
