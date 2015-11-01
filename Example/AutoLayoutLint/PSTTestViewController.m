//
//  PSTTestViewController.m
//  AutoLayoutTestCase
//
//  Created by ypresto on 2015/10/28.
//  Copyright © 2015年 Yuya Tanaka. All rights reserved.
//

#import "PSTTestViewController.h"

@interface PSTTestViewController ()

@end

@implementation PSTTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    @throw @"viewDidLoad should not be called, because there mighe be API calls and/or assertions.";
}

@end
