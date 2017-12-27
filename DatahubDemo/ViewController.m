/*
 *
 * Licensed Materials - Property of Dasudian
 * Copyright Dasudian Technology Co., Ltd. 2017
 */

#import "ViewController.h"
#import "DataHubClient.h"
#import <CoreMotion/CoreMotion.h>

/*  instance id, 标识客户的唯一ID，请联系大数点商务support@dasudian.com获取 */
#define INSTANCE_ID    "your_instanceID"
/*  instance key, 与客户标识相对应的安全密钥，请联系大数点商务support@dasudian.com获取 */
#define INSTANCE_KEY   "your_instanceKey"

/*  大数点IoT DataHub云端地址，请联系大数点商务support@dasudian.com获取 */
#define SERVER_URL      "server.example.com"
/* 设备的名字 */
#define CLIENT_TYPE     "iphone6"
/* 设备的id */
#define CLIENT_ID      "ios-long-run-device"

/* 消息长度, byte */
#define MESSAGE_LEN         (1 * 1024)

/* 消息发送间隔, second */
#define PUBLISH_INTERVAL    (0.1)

#define REMAIN_CHAR_LEN     (300)

#define LOG_FILE_NAME   "app_log.txt"

#define PUBLISH_TOPIC   "behavior"

@interface ViewController ()<DataHubClientDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

/* 主题文本框 */
@property(nonatomic,strong) UITextField * topicInput;
/* 发送消息文本框 */
@property(nonatomic,strong) UITextField * messageInput;
/* 显示日志文本框 */
@property(nonatomic,strong) UITextView * logTextView;
/* 客户端 */
@property(nonatomic,assign) datahub_client client;
/* 日志文件 */
@property(nonatomic,strong) NSString *logFilePath;

@property(nonatomic,strong) CMMotionManager *motionManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[[NSThread alloc]initWithTarget:self selector:@selector(loadMainView:) object:nil] start];
    [[[NSThread alloc]initWithTarget:self selector:@selector(loadMoreData:) object:nil] start];
}

-(void)loadMainView:(id)none
{
    _logTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-20, SCREEN_HEIGHT-10)];
    _logTextView.editable = NO;
    _logTextView.layer.masksToBounds = YES;
    _logTextView.layer.cornerRadius = 5.0;
    _logTextView.layer.borderColor= [UIColor lightGrayColor].CGColor;
    _logTextView.layer.borderWidth = 0.1f;
    [_logTextView setFont:[UIFont systemFontOfSize:17.0]];
    [self.view addSubview:_logTextView];
}

-(void)loadMoreData:(id)none
{
    /*  屏幕常亮 */
    [[UIApplication  sharedApplication]  setIdleTimerDisabled:YES];
    [self setLogFilePath];
    [self initClient];
}

#pragma mark - call lib
-(void)initClient
{
    int ret;
    /* 初始化选项 */
    datahub_options options = DATAHUB_OPTIONS_INITIALIZER;
    /* 设置服务器地址 */
    options.server_url = SERVER_URL;
    options.debug = DATAHUB_TRUE;
    /* 创建客户端 */
    ret = [[DataHubClient shareInstance] datahub_create:&_client instance_id:INSTANCE_ID instance_key:INSTANCE_KEY client_type:CLIENT_TYPE client_id:CLIENT_ID options:&options];
    if (ERROR_NONE != ret) {
        [self recordLog:[NSString stringWithFormat:@"创建客户端失败, %d\n", ret]];
        return;
    }else{
        [self recordLog:@"创建客户端成功\n"];
    }

    [DataHubClient shareInstance].delegate = self;


    /* 使能加速度计和陀螺仪 */
    [self enableAccelerGyro];

    [[[NSThread alloc]initWithTarget:self selector:@selector(publishMessage) object:nil] start];
}

-(void)publishMessage
{
    int ret;

    datahub_message msg = DATAHUB_MESSAGE_INITIALIZER;

    msg.payload_len = MESSAGE_LEN;
    msg.payload = malloc(MESSAGE_LEN);

    /* 发送qos1消息, 超时时间设置为10s */
    while(true) {
        //获取并处理加速度计数据
        CMAccelerometerData *newestAccel = self.motionManager.accelerometerData;
        //获取并处理陀螺仪数据
        CMGyroData *newestGyro = self.motionManager.gyroData;
        //组装为JSON格式的数据
        NSString *str = [NSString stringWithFormat:@"{\"x\": %.04f, \"y\": %.04f, \"z\": %.04f, \"gyro_rotation_x\": %.04f, \"gyro_rotation_y\": %.04f, \"gyro_rotation_z\": %.04f, \"type\": %s, \"sensorid\": %s}", newestAccel.acceleration.x, newestAccel.acceleration.y, newestAccel.acceleration.z, newestGyro.rotationRate.x, newestGyro.rotationRate.y, newestGyro.rotationRate.z,"\"\"","\"ios\""];
//ikkkjj
        //获取二进制数据
        NSData *bytes = [str dataUsingEncoding:NSUTF8StringEncoding];
        msg.payload = (void *)[bytes bytes];
        msg.payload_len = (int)bytes.length;

        ret = [[DataHubClient shareInstance]datahub_sendrequest:&_client topic:PUBLISH_TOPIC msg:&msg data_type:JSON QoS:1 timeout:10];
        if (ERROR_NONE != ret) {
            NSString *str = [NSString stringWithFormat:@"发送消息失败, 错误码为%d\n", ret];
            [self recordLog:str];
        } else {
//            [self recordLog:@"发送消息成功\n"];
        /* 界面展示消息 */
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateUIWithMessage:@"发送消息成功(此消息不写入日志)\n"];
                });
        }

        /* second */
        [NSThread sleepForTimeInterval: PUBLISH_INTERVAL];
    }
}

-(void)destroyClient
{
    /* 销毁客户端并断开连接 */
    [[DataHubClient shareInstance]datahub_destroy:&_client];
}

#pragma mark - DataHubClientDelegate
/* 接收到消息后的回调函数 */
//-(void)messageReceived:(void *)context topic:(char *)topic_name message:(datahub_message *)msg
//{
//    char *buff = malloc(msg->payload_len + 1);
//    if (buff == NULL) {
//        return;
//    }
//    memcpy(buff, msg->payload, msg->payload_len);
//    buff[msg->payload_len] = '\0';
//    NSString *content = [[NSString alloc] initWithCString:buff encoding:NSUTF8StringEncoding];
//    free(buff);
//    
//    [self recordLog:[NSString stringWithFormat:@"接收主题为 %s ;消息为%@\n", topic_name, content]];
//    /* 必须释放内存 */
//    [[DataHubClient shareInstance]datahub_callback_free:topic_name message:msg];
//}
/* 网络连接发生变化的通知函数 */
-(void)connectionStatusChanged:(void *)context isconnected:(int)isconnected
{
    if (isconnected == DATAHUB_TRUE ) {
        [self recordLog:[NSString stringWithFormat:@"连接成功\n"]];
    } else {
        [self recordLog:[NSString stringWithFormat:@"连接断开\n"]];
    }
}

-(void)recordLog:(NSString *)message
{
    /* 获取当前时间 */
    NSString *curTime = [self getCurrentTime];
    /* 日志中保留当前时间的信息 */
    NSString *message_plus_time = [curTime stringByAppendingFormat:@"%s %@", " ", message];

    /* 界面展示消息 */
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUIWithMessage:message_plus_time];
    });
    /* 将消息写入文件 */
    [self writeToFile:message_plus_time];
}

-(NSString *)getCurrentTime
{
    NSDate *curDate = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];

    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:curDate];
}

-(void)updateUIWithMessage:(NSString *)message
{
    _logTextView.text = [_logTextView.text stringByAppendingString:message];

    long pos_end, pos_begin;

    /* 保留最后的REMAIN_CHAR_LEN个字符 */
    pos_end = _logTextView.text.length;
    pos_begin = pos_end > REMAIN_CHAR_LEN ? pos_end - REMAIN_CHAR_LEN : 0;

    /* 找到前面的换行符 */
    int i;
    for(i = pos_begin + 1; i >= 1 ; --i)
    {
        /* 可用于中文 */
        NSString *temp = [_logTextView.text substringWithRange:NSMakeRange(i - 1, 1)];
        if ([temp isEqualToString:@"\n"]) {
            break;
        }
    }
    pos_begin = i;

    /* NSMakeRange(begin, n) 表示从begin开始的n个字符 */
    _logTextView.text = [_logTextView.text substringWithRange:NSMakeRange(pos_begin, pos_end - pos_begin)];

//    [_logTextView scrollRangeToVisible:NSMakeRange(_logTextView.text.length, 1)];
}

-(void)setLogFilePath
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

    _logFilePath = [docPath stringByAppendingPathComponent:@LOG_FILE_NAME]; // 此时仅存在路径，文件并没有真实存在

    printf("logFilePath: %s\n", [_logFilePath UTF8String]);
}

-(void)writeToFile:(NSString *)message
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:_logFilePath ]) {
        [message writeToFile:_logFilePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        printf("file %s not exist, create it and write data %s\n", LOG_FILE_NAME, [message UTF8String]);
    }
    else {
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:_logFilePath];
        [myHandle seekToEndOfFile];
        [myHandle writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
        printf("file %s exist, write data %s\n", LOG_FILE_NAME, [message UTF8String]);
    }
}

- (void)enableAccelerGyro
{
    //初始化全局管理对象
    CMMotionManager *manager = [[CMMotionManager alloc] init];
    self.motionManager = manager;
    //判断加速度计可不可用，判断加速度计是否开启
    if ([manager isAccelerometerAvailable] && ![manager isAccelerometerActive]){
        NSLog(@"正在开启加速度计");
        //告诉manager，更新频率是100Hz
        manager.accelerometerUpdateInterval = 0.01;
        //开始更新，后台线程开始运行。这是Pull方式。
        [manager startAccelerometerUpdates];
    }

    //判断陀螺仪可不可用，判断陀螺仪是否开启
    if ([manager isGyroAvailable] && ![manager isGyroActive]){
        NSLog(@"正在开启陀螺仪");
        //告诉manager，更新频率是100Hz
        manager.gyroUpdateInterval = 0.01;
        //开始更新，后台线程开始运行。这是Pull方式。
        [manager startGyroUpdates];
    }

}

@end
