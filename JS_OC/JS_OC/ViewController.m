//
//  ViewController.m
//  JS_OC
//
//  Created by LiQuan on 16/6/27.
//  Copyright © 2016年 LiQuan. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

//JSContext：给JavaScript提供运行的上下文环境
//JSValue：JavaScript和Objective-C数据和方法的桥梁
//JSManagedValue：管理数据和方法的类
//JSVirtualMachine：处理线程相关，使用较少
//JSExport：这是一个协议，如果采用协议的方法交互，自己定义的协议必须遵守此协议

@protocol JSObjectDelegate  <JSExport>

- (void)share:(NSString *)s;
- (void)callCamera;

@end

@interface ViewController ()<JSObjectDelegate,UIWebViewDelegate>

@property (nonatomic ,strong)JSContext *js;
@property (nonatomic ,strong)UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.webView];
    self.webView.delegate = self;
    NSURL * url = [[NSBundle mainBundle] URLForResource:@"FileAll" withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    NSString * title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = title;
    
    NSString * webUrl = [self.webView stringByEvaluatingJavaScriptFromString:@"doucument.location.href"];
    NSLog(@"webUrl %@",webUrl);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.js = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.js[@"Toyun"] = self;
    self.js.exceptionHandler = ^(JSContext *context, JSValue *exception){
        NSLog(@"exception %@",exception);
    };

}


#pragma mark - JSObjcDelegate

- (void)callCamera {
    NSLog(@"callCamera");
    JSValue *picCallback = self.js[@"picCallback"];
    [picCallback callWithArguments:@[@"photos"]];
}

- (void)share:(NSString *)shareString {
    NSLog(@"share:%@", shareString);
    NSDictionary * dic = [ViewController parseJSONStringToNSDictionary:shareString];
    JSValue *shareCallback = self.js[@"shareCallback"];
    [shareCallback callWithArguments:nil];
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:dic[@"title"] message:dic[@"desc"] preferredStyle:UIAlertControllerStyleAlert];
     [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

/* 拦截协议
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = request.URL.absoluteString;
    if ([url rangeOfString:@"toyun://"].location != NSNotFound) {
        // url的协议头是Toyun
        NSLog(@"callCamera");
        return NO;
    }
    return YES;
}
 */


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIWebView *)webView
{
    if(!_webView)
    {
        _webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    }
    return _webView;
}

+(NSDictionary *)parseJSONStringToNSDictionary:(NSString *)JSONString {
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
    return responseJSON;
}

@end
