//
//  ViewController.m
//  testLiveActivity
//
//  Created by js on 2023/7/6.
//

#import "ViewController.h"
#import "testliveactivity-swift.h"

@interface ViewController ()
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSInteger allStudentCount;
@property (nonatomic) NSMutableDictionary <NSString /*id*/*, NSString /*step*/*>*idDic;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initViews];
    [self startTimer];
}

- (void)initData {
    self.allStudentCount = 5;
    self.idDic = [NSMutableDictionary dictionary];
}

- (void)initViews {
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:button1];
    button1.frame = CGRectMake(50, 100, 200, 50);
    [button1 addTarget:self action:@selector(button1DidSelect) forControlEvents:UIControlEventTouchUpInside];
    [button1 setTitle:@"开始收作业(5s 自动更新)" forState:UIControlStateNormal];
    button1.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:button2];
    button2.frame = CGRectMake(50, 170, 200, 50);
    [button2 addTarget:self action:@selector(button2DidSelect) forControlEvents:UIControlEventTouchUpInside];
    [button2 setTitle:@"开始收作业(后端通知更新)" forState:UIControlStateNormal];
    button2.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:button3];
    button3.frame = CGRectMake(50, 240, 200, 50);
    [button3 addTarget:self action:@selector(button3DidSelect) forControlEvents:UIControlEventTouchUpInside];
    [button3 setTitle:@"手动结束所有" forState:UIControlStateNormal];
    button3.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)button1DidSelect {
    
    NSInteger count = self.idDic.count;
    count ++;
    [self.idDic setObject:@(0).stringValue forKey:@(count).stringValue];
    [self startTimer];
}

- (void)button2DidSelect {
    [self endTimer];
    NSInteger count = self.idDic.count;
    count ++;
    [self.idDic setObject:@(0).stringValue forKey:@(count).stringValue];
    [self refreshByTimer];
}

- (void)button3DidSelect {
    
    NSArray *keys = self.idDic.allKeys;
    for (NSString *idStr in keys) {
        if (@available(iOS 16.2, *)) {
            [[TestLAManager sharedInstance] stopActivityWithIdString:idStr];
        }
    }
    [self.idDic removeAllObjects];
}

#pragma mark - Timer
- (void)startTimer {
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(refreshByTimer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
}

- (void)endTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)refreshByTimer {
    NSArray *keys = self.idDic.allKeys;
    for (NSString *idStr in keys) {
        NSInteger step = [[self.idDic objectForKey:idStr] integerValue];
        [self updateFlowWithStep:step idStr:idStr];
        step ++;
        [self.idDic setObject:@(step).stringValue forKey:idStr];
    }
}

- (void)updateFlowWithStep:(NSInteger)step idStr:(NSString *)idStr {
    
    NSInteger count = idStr.integerValue;
    
    TestLADataModel *model = [[TestLADataModel alloc] init];
    model.idString = idStr;
    model.nameDes = @"作业收录情况";
    
    if (step <= self.allStudentCount) {
        NSLog(@"---更新人数");
        model.completedNum = step;
        model.notCompletedNum = self.allStudentCount - model.completedNum;
        model.contentDes = [NSString stringWithFormat:@"作业进度(%@/%@)", @(model.completedNum), @(self.allStudentCount).stringValue];
        if (step == self.allStudentCount) {
            model.progressStatus = 1;
        } else {
            model.progressStatus = 0;//进行中
        }
    } else if (step < self.allStudentCount + 3) {
        NSLog(@"---更新状态");
        model.completedNum = self.allStudentCount;
        model.notCompletedNum = self.allStudentCount - model.completedNum;
        model.contentDes = [NSString stringWithFormat:@"作业进度(%@/%@)", @(model.completedNum), @(self.allStudentCount).stringValue];
        model.progressStatus = step - self.allStudentCount + 1;//关闭 + 失败
    } else {
        model = nil;
    }
    if (model) {
        NSLog(@"imagename:%@", [model statusIconName]);
        if (step == 0) {
            if (@available(iOS 16.2, *)) {
                [[TestLAManager sharedInstance] startActivityWithDataModel:model];
                [TestLAManager sharedInstance].pushTokenDidUpdate = ^(NSString * _Nonnull tokenStr, NSData * _Nonnull tokenData) {
                    NSLog(@"swift token :%@", tokenStr);
                };
            }
        } else {
            if (@available(iOS 16.2, *)) {
                [[TestLAManager sharedInstance] updateActivityWithDataModel:model];
            }
        }

    } else {
        if (@available(iOS 16.2, *)) {
            [[TestLAManager sharedInstance] stopActivityWithIdString:idStr];
        }
    }
}
@end
