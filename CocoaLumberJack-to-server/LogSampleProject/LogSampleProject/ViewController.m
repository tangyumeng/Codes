//
//  ViewController.m
//  LogSampleProject
//
//  Created by tangyumeng on 2017/5/13.
//  Copyright © 2017年 DiDiMap. All rights reserved.
//

#import "ViewController.h"
#import <CocoaLumberjack/DDLegacyMacros.h>
#import <CocoaLumberjack/DDLogMacros.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    DDLogVerbose(@"Verbose -------");
//    DDLogDebug(@"Debug ----- tangyumeng");
//    DDLogInfo(@"Info--- xxx tangyumeng");
//    DDLogWarn(@"Warn --xxx tangyumeng");
//    DDLogError(@"Error tangyumeng xcc l; ");
    
    
    for (int i = 0 ; i < 6; i++) {
        
        DDLogWarn(@"self logger test is:%d",i);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
