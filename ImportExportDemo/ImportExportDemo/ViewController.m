//
//  ViewController.m
//  ImportExportDemo
//
//  Created by jason on 15/9/8.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //添加预览通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(previewFunctionWithNotification:) name:PreviewDocumentNotifierName object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    //移除所有通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  导出方法
 *
 *  @param sender button
 */
- (IBAction)exportFunction:(UIButton *)button
{
    
}

/**
 *  导入方法
 *
 *  @param sender button
 */
- (IBAction)importFunction:(UIButton *)button
{
    
}

#pragma mark - 预览方法
/**
 *  预览方法，通过预览按钮触发
 *
 *  @param button button
 */
- (IBAction)previewFunctionWithButton:(UIButton *)button
{
    NSURL *documentURL = [self getDocumentURL];
    
    [self handleDocumentPreviewURL:documentURL];
}

/**
 *  预览方法，通过通知触发
 *
 *  @param notification 通知
 */
- (void)previewFunctionWithNotification:(NSNotification *)notification
{
    NSURL *documentURL = [notification object];
#if 1
    //TODO
    //打不开，Couldn't issue file extension for path: /private/var/mobile/Containers/Data/Application/707E3759-D1F3-40C2-ADF5-E9BA25AA145D/Documents/Inbox/The Swift Programming Language 中文版 - v1.1-7.pdf
    
    [self handleDocumentPreviewURL:documentURL];
    return;
    
    //一种处理方式：先看看文件是不是真的不存在
    NSString *documentPath = [documentURL absoluteString];
    NSLog(@"documentPath: %@", documentPath);
    //file:///private/var/mobile/Containers/Data/Application/5E97630A-62EF-48AE-A1B9-F38C65828F50/Documents/Inbox/The%20Swift%20Programming%20Language%20%E4%B8%AD%E6%96%87%E7%89%88%20-%20v1.1-15.pdf
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:documentPath]) {
        NSLog(@"文件真的存在呢");
    } else {
        NSLog(@"文件竟然真的不存在");
    }
    
    
    //TODO
    //一种处理方式：取出文件名字以及后缀，自己找路径，结果没找到
    NSString *tmpPath = [documentURL absoluteString];
    
    // 从路径中获得完整的文件名（带后缀）
    NSString *tmpCompleteDocumentName = [tmpPath lastPathComponent];
    //转码
    tmpCompleteDocumentName = [ViewController globalUTF8DecodeWithString:tmpCompleteDocumentName];
    NSLog(@"tmpCompleteDocumentName: %@", tmpCompleteDocumentName);
    
    // 获得文件名（不带后缀）
    NSString *tmpDocumentName = [tmpCompleteDocumentName stringByDeletingPathExtension];
    //转码
    tmpDocumentName = [ViewController globalUTF8DecodeWithString:tmpDocumentName];
    NSLog(@"tmpDocumentName: %@", tmpDocumentName);
    
    // 获得文件的后缀名（不带'.'）
    NSString *tmpExtension = [tmpPath pathExtension];
    
    documentURL = [[NSBundle mainBundle] URLForResource:tmpDocumentName withExtension:tmpExtension];
    
    
    //TODO
    //一种处理方式：拼出文件路径
    NSString *filePath = [ViewController getDocumentSavedDirPathWithNeedToCreate:YES];
    filePath = [filePath stringByAppendingPathComponent:tmpCompleteDocumentName];
    NSLog(@"final filePath: %@", filePath);
    
    //判断该文件是否存在，若文件不存在就复制文件到指定目录
    if (![fileManager fileExistsAtPath:filePath]) {
        //复制文件到指定目录
        [fileManager copyItemAtPath:documentPath toPath:filePath error:nil];
    }
    
    
    documentURL = [NSURL fileURLWithPath:filePath];
    NSLog(@"final documentURL: %@", documentURL);
    
    [self handleDocumentPreviewURL:documentURL];
    
#else
    CGFloat tmpWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat tmpHeight = [[UIScreen mainScreen] bounds].size.height;
    UIWebView *tmpWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, tmpWidth, tmpHeight)];
    tmpWebView.scalesPageToFit = YES;
    [self.view addSubview:tmpWebView];
    NSURLRequest *tmpRequest = [NSURLRequest requestWithURL:documentURL];
    [tmpWebView loadRequest:tmpRequest];
#endif
}

#pragma mark - 打开方法，选择应用打开
/**
 *  打开方法，选择应用打开
 *
 *  @param button button
 */
- (IBAction)openFunction:(UIButton *)button
{
    NSURL *documentURL = [self getDocumentURL];
    
    if (documentURL) {
        NSLog(@"选择应用打开");
        [self initDocumentInteractionControllerWithURL:documentURL];
        
        [self.documentInteractionController presentOpenInMenuFromRect:button.frame inView:self.view animated:YES];
        
        
    } else {
        NSLog(@"没有找到文件");
    }
}

#pragma mark - 初始化documentInteractionController
/**
 *  初始化documentInteractionController
 *
 *  @param documentURL documentURL
 */
- (void)initDocumentInteractionControllerWithURL:(NSURL *)documentURL
{
    if (self.documentInteractionController) {
        self.documentInteractionController.URL = documentURL;
    } else {
        //初始化documentInteractionController
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:documentURL];
        
        self.documentInteractionController.delegate = self;
    }
}

#pragma mark - 获取DocumentURL
/**
 *  获取DocumentURL
 *
 *  此处获取到项目内置的PDF文档的地址URL
 *
 *  @return DocumentURL
 */
- (NSURL *)getDocumentURL
{
    NSURL *tmpDocumentURL = [[NSBundle mainBundle] URLForResource:@"The Swift Programming Language 中文版 - v1.1" withExtension:@"pdf"];
    NSLog(@"tmpDocumentURL: %@", tmpDocumentURL);
    return tmpDocumentURL;
}

/**
 *  预览文档的方法
 *
 *  @param documentURL documentURL
 */
- (void)handleDocumentPreviewURL:(NSURL *)documentURL
{
    if (documentURL) {
        NSLog(@"预览文档");
        
        [self initDocumentInteractionControllerWithURL:documentURL];
        
        [self.documentInteractionController presentPreviewAnimated:YES];
    } else {
        NSLog(@"没有找到文件");
    }
}

#pragma mark - UIDocumentInteractionControllerDelegate
/**
 *  请求获得一个用于显示（预览）文档的view controller
 *
 *  点击后暂时不会有任何效果，因为UIDocumentInteractionController类并不是UIViewController的子类，而是继承自NSObject。我们需要通知document interaction controller使用哪个view controller进行文档预览
 */
-(UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    NSLog(@"UTI: %@", controller.UTI);
    return self;
}

#pragma mark - 获取文件存储目录路径
#define DocumentSavedDirName @"Inbox"
+ (NSString *)getDocumentSavedDirPathWithNeedToCreate:(BOOL)needCreate
{
    NSString *tmpCacheDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                     NSUserDomainMask,
                                                                     YES)
                                 objectAtIndex:0];
    
    NSString *documentSavedDirPath = [tmpCacheDirPath stringByAppendingPathComponent:DocumentSavedDirName];
    
    if (needCreate) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager createDirectoryAtPath:documentSavedDirPath withIntermediateDirectories:YES attributes:nil error:nil]) {
            return nil;
        }
        
        BOOL isDirectory = YES;
        if (![fileManager fileExistsAtPath:documentSavedDirPath isDirectory:&isDirectory] && !isDirectory) {
            return nil;
        }
    }
    return documentSavedDirPath;
}


#pragma mark -- utf8转码
//该函数用于对url字符串进行utf8转码
+(NSString *)globalUTF8EncodeWithString:(NSString *)srcString
{
    return [srcString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark -- 过滤特殊符号
//该函数用于对url字符串进行无效符号的过滤
+(NSString *)parseURLToFilterInvalidSymbolWithString:(NSString *)srcString
{
    return (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(nil,                                    (CFStringRef)srcString, nil,                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}

#pragma mark -- utf8解码
+(NSString *)globalUTF8DecodeWithString:(NSString *)encodeStr
{
    return [NSString stringWithString:[encodeStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}
@end
