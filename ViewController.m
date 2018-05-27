//
//  ViewController.m
//  GCD
//
//  Created by wuxinyi on 18/5/21.
//  Copyright © 2018年 wuxinyi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self sisuo];
//    [self syncConcurrent];
//    [self asyncSerial];
//   [self syncMain];
    [self sisuo_4];
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSLog(@"=================1");
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            NSLog(@"=================2");
//        });
//        NSLog(@"=================3");
//    });
//    NSLog(@"==========阻塞主线程");
//    NSLog(@"========2==阻塞主线程");
    

}

- (void)syncConcurrent {
    //并行队列+同步执行 串行执行  （同步执行不具备开发线程的能力）
    //注意：异步执行不会进行任何等待，可以继续执行任务
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"syncConcurrent---begin");
    
    dispatch_queue_t queue = dispatch_queue_create("oneQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_sync(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_sync(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_sync(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    NSLog(@"syncConcurrent---end");
}



- (void)asyncSerial {
    //串行队列+异步执行 具备开启线程的能力（但由于串行，所以只能按照顺序执行）
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncSerial---begin");
    
    dispatch_queue_t queue = dispatch_queue_create("twoQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    NSLog(@"asyncSerial---end");
}
- (void)syncMain {
    
    //同步执行+主队列
    //主队列是在加入线程中的所有执行完后，才会执行block块
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"syncMain---begin");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_sync(queue, ^{
        // 追加任务1
        NSLog(@"sdavgd");
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_sync(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_sync(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    NSLog(@"syncMain---end");
}

//死锁
- (void) sisuo {
        dispatch_queue_t queue = dispatch_queue_create("cn.chutong.www", DISPATCH_QUEUE_SERIAL);
    
        dispatch_sync(queue, ^{
    
            NSLog(@"****1");
    
            dispatch_sync(queue, ^{
                NSLog(@"2");
            });
    
            NSLog(@"3");
            
        });
        NSLog(@"4");
}

- (void)sisuo_4 {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"任务1");
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"任务2");
        });
        NSLog(@"任务3");
    });
    NSLog(@"任务4");
    while (1) {
        
    }
   // NSLog(@"任务5");
    /*
     
     1.一开始就是一个异步线程，任务4，死循环和任务5，这里注定了任务5不会被执行，如果其他线程有任务加到主线程中来，那么必定卡死
     
     2.肯定能打印1和4，然后异步线程中遇到同步线程，同步线程的任务是加到mainQueue中的，也就是加到任务5之后，我擦，这肯定炸了，任务5是不会执行的，因此，任务3肯定不会被执行，而且异步线程里面的是同步阻塞的，那么任务3之后的代码肯定也不会执行
     
     3.这里main里面的死循环理论上是不会影响异步线程中的任务1，2，3的，但是任务2是要被加到主队列执行的，那么忧郁FIFO的原理，导致不会执行任务2，那么就死锁了
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
