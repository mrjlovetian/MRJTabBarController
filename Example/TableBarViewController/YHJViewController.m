//
//  MRJ_ViewController.m
//  TableBarViewController
//
//  Created by mrjyuhongjiang on 08/11/2017.
//  Copyright (c) 2017 mrjyuhongjiang. All rights reserved.
//

#import "YHJViewController.h"
#import "RunTimeObject.h"


@interface YHJViewController ()

@end

@implementation YHJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    RunTimeObject *runTime = [[RunTimeObject alloc] init];
    [runTime methodName];
    
    
    [runTime performSelectorOnMainThread:@selector(otherMehod) withObject:self waitUntilDone:YES];
    
    NSLog(@"%@", [runTime description]);
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
