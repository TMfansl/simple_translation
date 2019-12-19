//
//  ViewController.m
//  translation
//
//  Created by sl fan on 2019/12/19.
//  Copyright © 2019 sl fan. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <Foundation/Foundation.h>

#define kWid (self.view.frame.size.width)
#define kHei (self.view.frame.size.height)

@interface ViewController ()
@property(nonatomic,strong) NSTextView *in_tx;
@property(nonatomic,strong) NSTextView *op_tx;
@property(nonatomic,copy) NSString *changeString;
//@property(nonatomic,strong) NSURLSessionDownloadTask *downloadTask;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.in_tx = [[NSTextView alloc] initWithFrame:NSRectFromCGRect(CGRectMake(20,kHei-100, kWid-40, 88))];
    [self.view addSubview:self.in_tx];

    self.changeString = @"=en";
    NSButton *button = [[NSButton alloc] initWithFrame:NSRectFromCGRect(CGRectMake(20,kHei-150, 60, 30))];
    [button setButtonType:NSButtonTypeMomentaryLight];
    [button setTitle:self.changeString];
    [self.view addSubview:button];
    
    NSButton *trans = [[NSButton alloc] initWithFrame:NSRectFromCGRect(CGRectMake(100,kHei-150, 60, 30))];
    [trans setButtonType:NSButtonTypeMomentaryPushIn];
    [trans setTitle:@"trans"];
    [self.view addSubview:trans];
    
    NSButton *clear = [[NSButton alloc] initWithFrame:NSRectFromCGRect(CGRectMake(kWid-80,kHei-150, 60, 30))];
    [clear setButtonType:NSButtonTypeMomentaryPushIn];
    [clear setTitle:@"clear"];
    [self.view addSubview:clear];
    
    [button setAction:@selector(button1:)];
    [trans setAction:@selector(trans:)];
    [clear setAction:@selector(clear)];
    
    self.op_tx = [[NSTextView alloc] initWithFrame:NSRectFromCGRect(CGRectMake(20,20, kWid-40, 88))];
    self.op_tx.editable = NO;
    [self.view addSubview:self.op_tx];
}

- (void)button1:(NSButton *)btn{
    //button1
    printf("\nbutton1");
    NSLog(@"request=======%@",self.in_tx.string);
    if ([self.changeString isEqualToString:@"=en"]) {
        self.changeString = @"=zh_cn";
    }else{
        self.changeString = @"=en";
    }
    [btn setTitle:self.changeString];
}

- (void)trans:(NSButton *)button{
    //trans
    printf("\ntrans");
//    NSURLSessionTask *task = [[NSURLSessionTask alloc] init];
//    [self startDownLoadVedioWithString:@"http://fanyi.youdao.com/translate?&doctype=json&type=AUTO&i=name"];

//    [self startDownLoadVedioWithString:@"http://translate.google.cn/translate_a/single?client=gtx&dt=t&dj=1&ie=UTF-8&sl=auto&tl=zh_CN&q=calculate"];
    if (self.in_tx.string.length) {
        NSString *ss = [NSString stringWithFormat:@"http://translate.google.cn/translate_a/single?client=gtx&dt=t&dj=1&ie=UTF-8&sl=auto&tl%@&q=%@",self.changeString,self.in_tx.string];
        [self startDownLoadVedioWithString:ss];
    }
    else
    {
        NSLog(@"null input...");
    }
}

- (void)clear{
    //clear
    printf("\nclear");
    self.in_tx.string = self.op_tx.string = @"";
}

- (void)startDownLoadVedioWithString:(NSString *)urlString{
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//    self.downloadTask = [session downloadTaskWithURL:[NSURL URLWithString:urlString]];
//    [self.downloadTask resume];
    

    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
    
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *sharedSession = [NSURLSession sessionWithConfiguration:configuration];

    NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
//            NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"data=%@",res);
            dispatch_async(dispatch_get_main_queue(), ^{
//                self.op_tx.string = res;
                NSError *err = nil;
                NSDictionary *dictRet = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
                if (!err) {
//                    NSLog(@"%@",dictRet);
                    NSArray *arr = dictRet[@"sentences"];

                    NSDictionary *transDic = arr.firstObject;
                    
                    self.op_tx.string = transDic[@"trans"];
                }
                else
                {
                    self.op_tx.string = err.description;
                }
                
            });
        } else {
            NSLog(@"error=%@",error);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.op_tx.string = error.description;
            });
        }
    }];
    [dataTask resume];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}


@end
