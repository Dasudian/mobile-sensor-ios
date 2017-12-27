/*
 * Licensed Materials - Property of Dasudian
 * Copyright Dasudian Technology Co., Ltd. 2017
 */

#import <UIKit/UIKit.h>

#define WEAKSELF                __weak typeof(self) weakSelf = self;

#define SCREEN_WIDTH           [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT          [[UIScreen mainScreen] bounds].size.height
#define tempAppdelegate        [UIApplication sharedApplication].delegate

#define ButtonColor            [UIColor colorWithRed:36.0/255.0 green:157.0/255.0 blue:246.0/255.0 alpha:1.0]


@interface ViewController : UIViewController

-(void)destroyClient;

@end
