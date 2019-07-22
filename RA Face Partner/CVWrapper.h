//
//  CVWrapper.h
//  RA Face Partner
//
//  Created by Swarup Ghosh on 22/07/19.
//  Copyright © 2019 Swarup Ghosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CVWrapper : NSObject

+ (NSString *)openCVVersionInfo;
+ (NSInteger) detectFacesAndSave:(UIImage *) source transpose: (BOOL)transposeFlag flip: (BOOL)flipFlag;

@end

NS_ASSUME_NONNULL_END
