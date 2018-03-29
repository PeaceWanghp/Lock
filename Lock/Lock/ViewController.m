//
//  ViewController.m
//  Lock
//
//  Created by peace on 2018/3/29.
//  Copyright © 2018 peace. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>
#import <libkern/OSAtomic.h>

@interface ViewController ()

@end

@implementation ViewController

#pragma mark -
#pragma mark -- Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self testLockButton:0];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark -- Action
#define CycleTime (1024*1024*32)
- (void)testAction {
    NSTimeInterval time = [NSDate date].timeIntervalSince1970;
    
    //同步锁
    for (int i = 0; i < CycleTime; i++) {
        @synchronized(self) {
            
        }
    }
    NSLog(@"%f : work time of Synchronized",[NSDate date].timeIntervalSince1970-time);
    time = [NSDate date].timeIntervalSince1970;
    
    //条件锁
    NSConditionLock *conditionLock = [[NSConditionLock alloc] init];
    for (int i = 0; i < CycleTime; i++) {
        [conditionLock lock];
        [conditionLock unlock];
    }
    NSLog(@"%f : work time of NSConditionLock",[NSDate date].timeIntervalSince1970-time);
    time = [NSDate date].timeIntervalSince1970;
    
    //递归锁
    NSRecursiveLock *rsLock = [[NSRecursiveLock alloc] init];
    for (int i = 0; i < CycleTime; i++) {
        [rsLock lock];
        [rsLock unlock];
    }
    NSLog(@"%f : work time of NSRecursiveLock",[NSDate date].timeIntervalSince1970-time);
    time = [NSDate date].timeIntervalSince1970;
    
    //互斥锁
    NSLock *mutexLock = [[NSLock alloc] init];
    for (int i = 0; i < CycleTime; i++) {
        [mutexLock lock];
        [mutexLock unlock];
    }
    NSLog(@"%f : work time of NSLock",[NSDate date].timeIntervalSince1970-time);
    time = [NSDate date].timeIntervalSince1970;
    
    //互斥锁
    pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    for (int i = 0; i < CycleTime; i++) {
        pthread_mutex_lock(&mutex);
        pthread_mutex_unlock(&mutex);
    }
    NSLog(@"%f : work time of pthread_mutex",[NSDate date].timeIntervalSince1970-time);
    time = [NSDate date].timeIntervalSince1970;
    
    //信号量
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    for (int i = 0; i < CycleTime; i++) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_signal(semaphore);
    }
    NSLog(@"%f : work time of dispatch_semaphore",[NSDate date].timeIntervalSince1970-time);
    time = [NSDate date].timeIntervalSince1970;
    
    //自旋锁
    OSSpinLock spinlock = OS_SPINLOCK_INIT;
    for (int i = 0; i < CycleTime; i++) {
        OSSpinLockLock(&spinlock);
        OSSpinLockUnlock(&spinlock);
    }
    NSLog(@"%f : work time of OSSpinLock",[NSDate date].timeIntervalSince1970-time);
}

#pragma mark -
#pragma mark -- UI
- (void)testLockButton:(int)index {
    float y = 20 + index * 50;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, y, self.view.frame.size.width, 40)];
    [button setTitle:@"Lock Test" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor purpleColor]];
    [button addTarget:self action:@selector(testAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

@end
