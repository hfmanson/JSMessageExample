//
//  ViewController.m
//  JSMessageExample
//
//  Created by Joshua Kehn on 10/27/14.
//  Copyright (c) 2014 KEHN. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (NSString*) appBundleIndexFile:(NSString*)fileName inFolder:(NSString*)folderName
{
    return [[NSBundle mainBundle] pathForResource:fileName ofType:@"" inDirectory:folderName];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // First create a WKWebViewConfiguration object so we can add a controller
    // pointing back to this ViewController.
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]
                                             init];
    WKUserContentController *controller = [[WKUserContentController alloc]
                                           init];

    // Add a script handler for the "observe" call. This is added to every frame
    // in the document (window.webkit.messageHandlers.NAME).
    [controller addScriptMessageHandler:self name:@"observe"];
    configuration.userContentController = controller;

    // Initialize the WKWebView with the current frame and the configuration
    // setup above
    if (self.webView == nil) {
        self.webView = [[WKWebView alloc] initWithFrame:self.view.frame
                        configuration:configuration];
        self.webView.navigationDelegate = self;
        self.webView.UIDelegate = self;
        [self.view addSubview:self.webView];
    }
    
    NSString* indexFilePath = [self appBundleIndexFile:@"index.html" inFolder:@"html"];
    [self.webView
     loadFileURL:[NSURL fileURLWithPath:indexFilePath]
     allowingReadAccessToURL:[NSURL fileURLWithPath:[indexFilePath stringByDeletingLastPathComponent]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Nothing else happens here
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {

    // Check to make sure the name is correct
    if ([message.name isEqualToString:@"observe"]) {
        // Log out the message received
        NSLog(@"Received event %@", message.body);

        // Then pull something from the device using the message body
        NSString *version = [[UIDevice currentDevice] valueForKey:message.body];

        // Execute some JavaScript using the result
        NSString *exec_template = @"set_answer(\"received: %@\");";
        NSString *exec = [NSString stringWithFormat:exec_template, version];
        [_webView evaluateJavaScript:exec completionHandler:nil];
    }
}

#pragma mark WKNavigationDelegate

- (void)webView:(WKWebView*)webView didFailNavigation:(WKNavigation*)navigation withError:(NSError*)error
{
    [self webView:webView didFailProvisionalNavigation:navigation withError:error];
}

- (void)webView:(WKWebView*)webView didFailProvisionalNavigation:(WKNavigation*)navigation
      withError:(NSError*)error
{
    __weak __typeof(self) weakSelf = self;
    
    UIAlertController* alertController = [UIAlertController  alertControllerWithTitle:@"Load Failed"  message:[error localizedDescription]  preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }]];
    [weakSelf presentViewController:alertController animated:YES completion:nil];
}

#pragma mark WKUIDelegate

- (void)webView:(WKWebView*)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo*)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

@end
