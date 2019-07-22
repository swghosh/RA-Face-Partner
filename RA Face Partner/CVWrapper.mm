//
//  CVWrapper.mm
//  RA Face Partner
//
//  Created by Swarup Ghosh on 22/07/19.
//  Copyright © 2019 Swarup Ghosh. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "CVWrapper.h"

@implementation CVWrapper

+ (NSString *)openCVVersionInfo {
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}

@end
