//
//  ViewController.m
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "ViewController.h"
#import "IBTWKWebViewController.h"
#import "IBTJSBWebViewDemoController.h"
#import "IBTMacro.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *arrDemos;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"IBTWeb Demos";
    
    self.arrDemos =
    @[
       @[ @"WebView ibtjsbridge Demo",
          @"WebView webviewjsbridge Demo",
          @"WebView 2.0 AllInOne Demo",
          @"WebView 模块 Demo - Push In",
          @"WebView 模块 Demo - Push In (DisableGoback)",
          @"WebView 模块 Demo - Present",
          @"WebView 模块 Demo - Present (DisableGoback)",
          ],
       ];
    
    UITableView *tableV = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [tableV registerClass:[UITableViewCell class] forCellReuseIdentifier:@"id"];
    tableV.delegate = self;
    tableV.dataSource = self;
    
    [self.view addSubview:tableV];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_arrDemos count];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [_arrDemos[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id" forIndexPath:indexPath];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = _arrDemos[ indexPath.section ][ indexPath.row ];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self jumpToJSBridgeDemo];
            break;
        case 1:
            [self jumpToWebViewJSBridgeDemo];
            break;
        case 2:
            [self jumpToWebViewAllInOneDemo];
            break;
        case 3:
            [self jumpToWebViewDemo:YES disableGoback:NO];
            break;
        case 4:
            [self jumpToWebViewDemo:YES disableGoback:YES];
            break;
        case 5:
            [self jumpToWebViewDemo:NO disableGoback:NO];
            break;
        case 6:
            [self jumpToWebViewDemo:NO disableGoback:YES];
            break;
        default:
            break;
    }
}

#pragma mark - Demos

- (void)jumpToJSBridgeDemo {
    
    // 设置 ExtraInfo
    
    NSDictionary *extraInfo =
    @{ @"jsHandles" : @[ @"alert", // JSEventHandle 名， MPWebJSEventHandler_alert
                         @"testCallFromOC", // MPWebJSEventHandler_testCallFromOC
                         @"jsCallQueryAPP",
                         ] };
    
    IBTWebViewPresetUI *presetUI = [[IBTWebViewPresetUI alloc] init];
    presetUI.showCloseButton = YES;
    
    NSURL *localURL =
    [[NSBundle mainBundle] URLForResource:@"IbtjsbridgeDemo" withExtension:@"html"];
    
    IBTWKWebViewController *viewController =
    [[IBTWKWebViewController alloc] initWithUrl:localURL extraInfo:extraInfo presetUI:presetUI];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)jumpToWebViewAllInOneDemo {
    
    NSDictionary *extraInfo =
    @{ @"jsHandles" : @[ @"jsCallAllInOne"
                         ] };
    
    NSURL *localURL =
    [[NSBundle mainBundle] URLForResource:@"2_0AllInOneDemo" withExtension:@"html"];
    
    IBTWebViewPresetUI *presetUI = [[IBTWebViewPresetUI alloc] init];
    presetUI.showCloseButton = YES;
    
    IBTWKWebViewController *viewController =
    [[IBTWKWebViewController alloc] initWithUrl:localURL extraInfo:extraInfo presetUI:presetUI];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)jumpToWebViewJSBridgeDemo {
    
    IBTJSBWebViewDemoController *viewController =
    [[IBTJSBWebViewDemoController alloc] initWithUrl:@"http://xummer26.com/XTest/bridgeDemo"
                                          extraInfo:nil presetUI:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)jumpToWebViewDemo:(BOOL)isPushIn
            disableGoback:(BOOL)disableGoback
{
    
    // 设置 UI
    
    IBTWebViewPresetUI *presetUI = [[IBTWebViewPresetUI alloc] init];
    presetUI.progressBarColor = self.view.window.tintColor;
    presetUI.navigationBarTitle = isPushIn ? @"自定义 Title" : nil;
    //    presetUI.navigationBackName = @"返回";
    presetUI.navigationCloseName = disableGoback ? @"关闭" : nil;
    presetUI.disableGobackMode = disableGoback;
    presetUI.showCloseButton = !disableGoback;
    
    IBTWKWebViewController *viewController =
    [[IBTWKWebViewController alloc] initWithUrl:@"http://xummer26.com" extraInfo:nil presetUI:presetUI];
    
    if (isPushIn) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else {
        UINavigationController *navCtrl =
        [[UINavigationController alloc] initWithRootViewController:viewController];
        [self presentViewController:navCtrl animated:YES completion:^{
            DebugLog(@"1: isViewLoaded:%@, window:%@", @(viewController.isViewLoaded), viewController.view.window);
        }];
        
        DebugLog(@"0: isViewLoaded:%@, window:%@", @(viewController.isViewLoaded), viewController.view.window);
    }
}



@end
