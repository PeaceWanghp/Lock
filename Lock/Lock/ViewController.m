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
{
    int _ticketsCount;
}

@end

@implementation ViewController

#pragma mark -
#pragma mark -- Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self testLockButton:0];
    [self sycnButton:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark -- Test

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

- (void)testLockButton:(int)index {
    float y = 20 + index * 50;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, y, self.view.frame.size.width, 40)];
    [button setTitle:@"Lock Test" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor purpleColor]];
    [button addTarget:self action:@selector(testAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

#pragma mark -
#pragma mark -- Sync
- (void)sycnButton:(int)index {
    float y = 20 + index * 50;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, y, self.view.frame.size.width, 40)];
    [button setTitle:@"Sync" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor purpleColor]];
    [button addTarget:self action:@selector(sycnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)sycnAction {
    //设置票的数量为5
    _ticketsCount = 5;
    
    NSLog(@"Start tickets count = %d, Thread:%@",_ticketsCount,[NSThread currentThread]);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self saleTickets];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self saleTickets];
    });
}

- (void)saleTickets {
    while (YES) {
        /*
         注意点:
         1.加锁的代码尽量少
         2.添加的OC对象必须在多个线程中都是同一对象
         3.优点是不需要显式的创建锁对象，便可以实现锁的机制。
         4.@synchronized块会隐式的添加一个异常处理例程来保护代码，该处理例程会在异常抛出的时候自动的释放互斥锁。所以如果不想让隐式的异常处理例程带来额外的开销，你可以考虑使用锁对象。
         */
        
        //这里参数添加一个OC对象，一般使用self
        @synchronized(self) {
            [NSThread sleepForTimeInterval:1];
            if (_ticketsCount > 0) {
                _ticketsCount--;
                NSLog(@"Tickets = %d, Thread:%@",_ticketsCount,[NSThread currentThread]);
            }
            else {
                NSLog(@"Clear  Thread:%@",[NSThread currentThread]);
                break;
            }
        }
    }
}

#pragma mark -
#pragma mark --

@end
