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

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_datas;
}

@end

@implementation ViewController

#pragma mark -
#pragma mark -- Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _datas = @[@"Lock Test",@"Sync",@"NSLock",@"NSRecursiveLock",@"NSConditionLock",@"pthread_mutex",@"dispatch_semaphore",@"OSSpinLock"];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark -- TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TableViewCell"];
    }
    
    cell.textLabel.text = [_datas objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *string = [_datas objectAtIndex:indexPath.row];
    if ([string isEqualToString:@"Lock Test"]) {
        [self testAction];
    }
    else if ([string isEqualToString:@"Sync"]) {
        [self sycnAction];
    }
    else if ([string isEqualToString:@"NSLock"]) {
        [self lockAction];
    }
    else if ([string isEqualToString:@"NSRecursiveLock"]) {
        [self recursiveLockAction];
    }
    else if ([string isEqualToString:@"NSConditionLock"]) {
        [self conditionLockActive];
    }
    else if ([string isEqualToString:@"pthread_mutex"]) {
        [self pthreadMutexAction];
    }
    else if ([string isEqualToString:@"dispatch_semaphore"]) {
        [self semaphoreAction];
    }
    else if ([string isEqualToString:@"OSSpinLock"]) {
        [self spinAction];
    }
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

#pragma mark -
#pragma mark -- Lock Action
- (void)sycnAction {
    //设置票的数量为5
    __block int ticketsCount = 5;
    
    void(^saleTickets)(void) = ^() {
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
                if (ticketsCount > 0) {
                    ticketsCount--;
                    NSLog(@"Tickets = %d, Thread:%@",ticketsCount,[NSThread currentThread]);
                }
                else {
                    NSLog(@"Clear  Thread:%@",[NSThread currentThread]);
                    break;
                }
            }
        }
    };
    
    NSLog(@"Start tickets count = %d, Thread:%@",ticketsCount,[NSThread currentThread]);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        saleTickets();
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        saleTickets();
    });
}

- (void)lockAction {
    //设置票的数量为5
    __block int ticketsCount = 5;
    
    //创建锁
    NSLock *lock = [[NSLock alloc] init];
    
    void(^lockSaleTickets)(void) = ^() {
        while (1) {
            [lock lock];
            
            [NSThread sleepForTimeInterval:1];
            if (ticketsCount > 0) {
                ticketsCount--;
                NSLog(@"Tickets= %d, Thread:%@",ticketsCount,[NSThread currentThread]);
            }
            else {
                NSLog(@"Clear  Thread:%@",[NSThread currentThread]);
                break;
            }
            
            [lock unlock];
        }
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        lockSaleTickets();
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        lockSaleTickets();
    });
}

- (void)recursiveLockAction {
//    NSLock *lock = [[NSLock alloc] init];
    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void(^TestMethod)(int);
        
        TestMethod = ^(int value) {
            [lock lock];
            if (value > 0) {
                NSLog(@"value = %d",value);
                [NSThread sleepForTimeInterval:1];
                TestMethod(--value);
            }
            [lock unlock];
        };
        
        NSLog(@"Begain Test");
        TestMethod(5);
    });
}

- (void)conditionLockActive {
    NSConditionLock *lock = [[NSConditionLock alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i <= 5; i++) {
            [lock lock];
            NSLog(@"1.thread1 condition = %ld, i = %d",(long)lock.condition,i);
            [lock unlockWithCondition:i];
            NSLog(@"2.thread1 condition = %ld, i = %d",(long)lock.condition,i);
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [lock lockWhenCondition:2];
        NSLog(@"thread2");
        [lock unlock];
    });
}

- (void)pthreadMutexAction {
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(2);
        pthread_mutex_lock(&mutex);
        NSLog(@"任务2");
        
        pthread_mutex_unlock(&mutex);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        pthread_mutex_lock(&mutex);
        NSLog(@"任务1");
        pthread_mutex_unlock(&mutex);
    });
}

- (void)semaphoreAction {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    __block int count = 10;
    
    void(^TestMethod)(void) = ^() {
        while (YES) {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (count > 0) {
                count --;
                NSLog(@"value = %d, %@",count,[NSThread currentThread]);
                [NSThread sleepForTimeInterval:1];
            }
            else {
                NSLog(@"Done %@",[NSThread currentThread]);
                break;
            }
            dispatch_semaphore_signal(semaphore);
        }
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TestMethod();
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TestMethod();
    });
}

- (void)spinAction {
    __block int tickets = 5;
    
    OSSpinLock spinlock = OS_SPINLOCK_INIT;
    
    void(^TestMethod)(void) = ^() {
        while (YES) {
            OSSpinLockLock(&spinlock);
            if (tickets > 0) {
                tickets --;
                NSLog(@"value = %d, %@",tickets,[NSThread currentThread]);
                [NSThread sleepForTimeInterval:1];
            }
            else {
                NSLog(@"Done %@",[NSThread currentThread]);
                break;
            }
            OSSpinLockUnlock(&spinlock);
        }
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TestMethod();
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TestMethod();
    });
}

@end
