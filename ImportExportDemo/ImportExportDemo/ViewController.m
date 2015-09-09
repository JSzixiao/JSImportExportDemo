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
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
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

/**
 *  预览方法
 *
 *  @param button button
 */
- (IBAction)previewFunction:(UIButton *)button
{
    NSURL *documentURL = [[NSBundle mainBundle] URLForResource:@"The Swift Programming Language 中文版 - v1.1" withExtension:@"pdf"];
    
    if (documentURL) {
        NSLog(@"预览");
        //初始化documentInteractionController
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:documentURL];
        
        self.documentInteractionController.delegate = self;
        
        [self.documentInteractionController presentPreviewAnimated:YES];
        
        //点击后暂时不会有任何效果，因为UIDocumentInteractionController类并不是UIViewController的子类，而是继承自NSObject。我们需要通知document interaction controller使用哪个view controller进行文档预览
        
    } else {
        NSLog(@"没有找到文件");
    }
    
}

/**
 *  打开方法，在其它应用中打开
 *
 *  @param button button
 */
- (IBAction)openFunction:(UIButton *)button
{
    NSURL *documentURL = [[NSBundle mainBundle] URLForResource:@"The Swift Programming Language 中文版 - v1.1" withExtension:@"pdf"];
    
    if (documentURL) {
        NSLog(@"打开");
        //初始化documentInteractionController
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:documentURL];
        
        self.documentInteractionController.delegate = self;
        
        [self.documentInteractionController presentOpenInMenuFromRect:button.frame inView:self.view animated:YES];
        
        
    } else {
        NSLog(@"没有找到文件");
    }
}


#pragma mark - UIDocumentInteractionControllerDelegate
/**
 *  请求获得一个用于显示（预览）文档的view controller
 */
-(UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    NSLog(@"UTI: %@", controller.UTI);
    return self;
}

@end
