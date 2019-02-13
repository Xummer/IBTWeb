# IBTWKWebView JavaScript 与 Objective-C 互相调用使用文档

注：以下 Objective-C 简称为 OC，JavaScript 简称为 JS.

## WebViewJavascriptBridge 使用说明

基于 `IBTJSBridge` 添加别名适配三方库 `WebViewJavascriptBridge` 的方式

### HTML/JS 端使用步骤

#### 调用 OC 方法的步骤
- **步骤零：在 OC 端注册 JSHandle**
- **步骤一：添加对 WebViewJavascriptBridge 注入成功的事件监听 WebViewJavascriptBridgeReady.**
- **步骤二：在 WebViewJavascriptBridgeReady 完成回调里实现具体调用 WebViewJavascriptBridge 的方法.**

    例子：监听 `WebViewJavascriptBridgeReady` 事件
    
    ```js
    var readyFunc = function onBridgeReady(bridge) {
        // 添加具体 WebViewJavascriptBridgeReady 调用逻辑
    }
    
    function setupWebViewJavascriptBridge(callback) {
          if (window.WebViewJavascriptBridge) { callback(WebViewJavascriptBridge); }
          else {
            document.addEventListener("WebViewJavascriptBridgeReady", function() {
              callback(WebViewJavascriptBridge);
            }, false);
          }
    }
    
    setupWebViewJavascriptBridge(readyFunc);
    ```   

- **步骤三：调用 WebViewJavascriptBridge 的 callHandler 方法**
    WebViewJavascriptBridge 的 `callHandler` 方法是 IBTJSBridge 的 `invoke` 方法的别名，调用方式和参数与 `invoke` 方法一致.
    `invoke` 方法的参数请参看本文档的 "IBTJSBridge 提供给 JavaScript 的基础方法".
    
    例子： 调用 OC 中名为 "openUrlByExtBrowser" 的接口
    
    ```js
    var readyFunc = function onBridgeReady(bridge) {
        bridge.callHandler('openUrlByExtBrowser',{
              "url" : "http://www.2345.org",
          },function(res){
            // returned result
        });
    }
    ```
    
#### 注册 Event 给 OC 调用的步骤

- **步骤一：调用 WebViewJavascriptBridge 的 registerHandler 方法**
    WebViewJavascriptBridge 的 `registerHandler` 方法是 IBTJSBridge 的 `on` 方法的别名，调用方式和参数与 `on` 方法一致.
    `on` 方法的参数请参看本文档的 "IBTJSBridge 提供给 JavaScript 的基础方法".
    
- **步骤二：实现 JS 中的具体逻辑**

例子：在 JS 端注册名为 `callFromOC` 的 Event

```js
var readyFunc = function onBridgeReady(bridge) {
    // 注册给 OC 调用的 Event
    bridge.registerHandler("callFromOC", function(resDict) {
      // resDict { "param" : "value" }
      bridge.callHandler('alert',{
            "msg" : resDict[ "param" ] ? resDict[ "param" ] : "callFromOC(no params)",
        },function(res){
         // returned result
      });
    })
}
```

- **步骤三：在 OC 中调用 [IBTWKWebJSLogicImpl sendEventToJSBridge:params:completionBlock:]**

例子：在 OC 端调用 `callFromOC` 的 JS 方法

```objective-c
[wkWebVC.jsLogicImpl sendEventToJSBridge:@"callFromOC"
                                          params:@{ @"param" : @"I'm the Parameters from OC!!!"}completionBlock:^(id  _Nullable result, NSError * _Nullable error) {
                                              if (result) {
                                                  DebugLog(@"%@", result);
                                              }
                                          }];
```


### 二、Objective-C 端使用步骤

在 OC 端 与 IBTJSBridge 使用说明一致，具体请参看 "IBTJSBridge 使用说明" 的 "二、Objective-C 端使用步骤".

## IBTJSBridge 使用说明

### 一、HTML/JS 端使用步骤

#### 调用 OC 方法的步骤
- **步骤零：在 OC 端注册 JSHandle**
    请查看本文档本章节 "IBTJSBridge 使用说明" "二、Objective-C 端使用步骤" 中的 "JS 调用 OC 方法中注册 JSHandle 步骤". 

- **步骤一：添加对 IBTJSBridge 注入成功的事件监听 IBTJSBridgeReady.**

- **步骤二：在 IBTJSBridgeReady 完成回调里实现具体调用 IBTJSBridge 的方法.**

    例子：监听 `IBTJSBridgeReady` 事件
    
    ```js
    var readyFunc = function onBridgeReady() {
        // 添加具体 IBTJSBridge 调用逻辑
    }
    
    if (typeof IBTJSBridge === "undefined") {
        document.addEventListener('IBTJSBridgeReady', readyFunc, false);
    } else {
        readyFunc();
    }
    ```

- **步骤三：调用 IBTJSBridge 的 invoke 方法**
    
    `invoke` 方法的参数请参看本文档的 "IBTJSBridge 提供给 JavaScript 的基础方法".
    
    例子： 调用 OC 中名为 "openUrlByExtBrowser" 的接口
    
    ```js
    IBTJSBridge.invoke('openUrlByExtBrowser',{
              "url" : "http://www.2345.org",
          },function(res){
           IBTJSBridge.log(res);
        });
    ```



#### 注册 Event 给 OC 调用的步骤

- **步骤一：调用 IBTJSBridge 的 on 方法**
    `on` 方法的参数请参看本文档的 "IBTJSBridge 提供给 JavaScript 的基础方法".
    
- **步骤二：实现 JS 中的具体逻辑**

例子：在 JS 端注册名为 `callFromOC` 的 Event

```js
    // 注册给 OC 调用的 Event
    IBTJSBridge.on("callFromOC", function(resDict) {
      // resDict { "param" : "value" }
      IBTJSBridge.invoke('alert',{
            "msg" : resDict[ "param" ] ? resDict[ "param" ] : "callFromOC(no params)",
        },function(res){
         IBTJSBridge.log(res);
      });
    })
```

- **步骤三：在 OC 中调用 [IBTWKWebJSLogicImpl sendEventToJSBridge:params:completionBlock:]**

例子：在 OC 端调用 `callFromOC` 的 JS 方法

```objective-c
[wkWebVC.jsLogicImpl sendEventToJSBridge:@"callFromOC"
                                          params:@{ @"param" : @"I'm the Parameters from OC!!!"}completionBlock:^(id  _Nullable result, NSError * _Nullable error) {
                                              if (result) {
                                                  DebugLog(@"%@", result);
                                              }
                                          }];
```


### 二、Objective-C 端使用步骤

#### JS 调用 OC 方法中注册 JSHandle 步骤

- **步骤一：实现 JSHandler 类**

    实现继承 `IBTWebJSEventHandlerBase` 并且类名为 `IBTWebJSEventHandler_xxx` 的类, 其中 xxx 为 JS 中调用的接口名;
    
- **步骤二：实现 Protocol 方法**

    在 JSHandler 类中实现 protocol `IBTWebJSEventHandler` 的方法:

    ```objective-c
    - (void)handleJSEvent:(IBTJSEvent *)event
            HandlerFacade:(IBTWebJSEventHandlerFacade *)facade
                ExtraData:(id)data
    ```
    该方法为 JS 调用 `invoke/call` 方法之后在 OC 的调用，可以从 `(IBTJSEvent *)event.params` 取出从 JS 传递过来的参数。
    
- **步骤三： 实现 Objective-C 中的逻辑并回调 JavaScript**

    在该方法中实现具体需要在 OC 中实现的内容，并在完成后调用 `[event endWithError:@"result str"]` 调起 JavaScript 回调, 其中 @"result str" 为 JS `invoke/call` 方法回调的返回值, 请按照 "调用接口说明" 中 "回调" 这一栏中规定的来返回，保证回调返回值的统一性;
    
    PS: 注意，若调用 OC 不是即时能返回结果的，需要先 `Retain` 一下 `IBTWebJSEventHandler_xxx` 类，防止被提前释放导致 JS 的回调无法被调用;
    
- **步骤四：在 IBTWKWebViewController 中注册 JSHandler**

    在 `IBTWKWebViewController` 初始化方法的 `extraInfo` 里传入具体需要注册的 JS 方法名 xxx `@{ "jsHandles": [ "xxx", ]}`
    
    
    #### 例子
    
    - JS 端
        
        ```js
        IBTJSBridge.invoke('openUrlByExtBrowser',{
              "url" : "http://www.2345.org",
          },function(res){
           IBTJSBridge.log(res);
        });
        ```
        
    - OC 端
        
        实现 JS 方法
      	 
        ```objective-c
        #import "IBTWebJSEventHandlerBase.h"
        
        @interface IBTWebJSEventHandler_openUrlByExtBrowser : IBTWebJSEventHandlerBase
        @end
        
        
        @implementation IBTWebJSEventHandler_openUrlByExtBrowser
        
        #pragma mark -  IBTWebJSEventHandler
        
        - (void)handleJSEvent:(IBTJSEvent *)event
                HandlerFacade:(IBTWebJSEventHandlerFacade *)facade
                    ExtraData:(id)data
        {
            NSDictionary *params = event.params;
            if (params &&
                [params[ @"url" ] isKindOfClass:[NSString class]] &&
                [params[ @"url" ] length]) {
                NSURL *url = [NSURL URLWithString:params[ @"url" ]];
                
                if (@available(iOS 10.0, *)) {
                    
                    // 如果使用非即时的回调，如 Block, 需要暂时 Retain self 防止被释放
                    
                    __block id retainedSelf = self;
                    
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                        if (success) {
                            [event endWithError:@"openUrlByExtBrowser:ok"];
                        }
                        else {
                            [event endWithError:@"openUrlByExtBrowser:fail"];
                        }
                        
                        // 释放 retained Self
                        
                        retainedSelf = nil;
                    }];
                }
                else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    BOOL success = [[UIApplication sharedApplication] openURL:url];
        #pragma clang diagnostic pop
                    if (success) {
                        [event endWithError:@"openUrlByExtBrowser:ok"];
                    }
                    else {
                        [event endWithError:@"openUrlByExtBrowser:fail"];
                    }
                }
            }
            else {
                [event endWithError:@"missing auguments"];
            }
        }
        
        @end
        ```
    
        注册 JS 方法
        
        ```objective-c
        NSDictionary *extraInfo = @{ @"jsHandles" : @[ @"openUrlByExtBrowser" ] };
        
        IBTWKWebViewController *viewController =
        [[IBTWKWebViewController alloc] initWithUrl:nil extraInfo:extraInfo presetUI:nil];
        ```
        
### 三、IBTJSBridge 提供给 JavaScript 的基础方法

#### invoke/call

用于调用 OC 中注册的方法

```js
function call(func, params, callback)

function invoke(func, params, callback)
```

例子:

```js
IBTJSBridge.invoke(
    'functionName',                     // 接口名 string
    { "paramsKey" : "paramsValue", },   // 参数字典 object 或者单独的 string 也是支持的
    function(res){}                     // 回调方法 function，其中 res 为返回的字典 object
);
```
##### 调用接口说明

###### 参数

1. `functionName`: 接口名，必须的，`string` 类型，需在 OC 端实现,  `IBTWebJSEventHandler_[functionName]` 具体可参考下面 OC 端使用步骤；
2. `{ "paramsKey" : "paramsValue", }`: 接口的参数，可选的， `object` 类型
3. `function(res){}`: 回调方法，可选的，`function` 类型

###### 回调

接口调用的回调方法分的返回值 `res` 其格式如下：

- 调用成功时："xxx:ok" ，其中 xxx 为调用的接口名

- 用户取消时："xxx:cancel"，其中 xxx 为调用的接口名

- 调用失败时：其值为具体错误信息

#### on 

用于在 JS 中注册 Event 让 OC 来调用

```js
function on(event, callback)
```



#### log

在 OC 端打印 log

```js
IBTJSBridge.log('String/Object to log');
```

## PS：修改说明

### 1.若要在 Web 的 JS 代码未加载前就加载 JSBridge，可做如下修改

```objective-c
#import "IBTWKWebViewController.h"
#import "IBTWKWebJSLogicImpl.h"

@interface IBTWKWebJSLogicImpl (Private)
- (NSString *)getJSBridgeAndPluginStr;
@end

@interface CustomWebViewController: IBTWKWebViewController

@end

@implementation IBTRefreshWebViewController
- (NSString *)getHookScriptStr {
    return [self.jsLogicImpl getJSBridgeAndPluginStr];
}
@end
```

### 2.若要和安卓的三方库 WebViewJavascriptBridge 调用返回值的类型一致为 string，可做如下修改：

```objective-c
// 全局替换 IBTWKWebJSLogicImpl.m 的 2 处内容
mdic[ @"__params" ] = params ?: @{};

// 为
mdic[ @"__params" ] = [params ?: @{} ibt_jsonString];
```

### 3.若要支持 iOS 端三方库 WebViewJavascriptBridge 中 JS 的调用方式，可做如下修改：

可参看工程中的 demo: IBTJSBWebViewDemoController.m/h

```objective-c
#import "IBTJSBWebViewDemoController.h"

#import "IBTWKWebJSLogicImpl.h"

@interface IBTWKWebJSLogicImpl (Private)
- (NSString *)getJSBridgeAndPluginStr;
@end

@interface IBTWebJSBridgeJSLogicImpl: IBTWKWebJSLogicImpl

@end

@implementation IBTWebJSBridgeJSLogicImpl

- (NSString *)getJSBridgeAndPluginStr {
    NSString *js = [super getJSBridgeAndPluginStr];
    
    js =
    [NSString stringWithFormat:@"%@if (typeof window.WebViewJavascriptBridge === 'undefined') { var webjsbridge = { callHandler: IBTJSBridge.call, registerHandler: IBTJSBridge.on } ;try { Object.defineProperty(window, 'WebViewJavascriptBridge', { value: webjsbridge, writable: false}) } catch(sa) {};} var callbacks = window.WVJBCallbacks; delete window.WVJBCallbacks; for (var i=0; i<callbacks.length; i++) { callbacks[i](window.WebViewJavascriptBridge); }", js];
    
    return js;
}

@end

@interface IBTWKWebViewController (Private) <IBTWKWebJSLogicDelegate>
@property (nonatomic, strong, readwrite) IBTWKWebJSLogicImpl *jsLogicImpl;
@end

@interface IBTJSBWebViewDemoController ()

@end

@implementation IBTJSBWebViewDemoController

#pragma mark - IBTWKWebViewDelegate

- (NSString *)getPreInjectScriptStr {
    return @"if (typeof window.WVJBCallbacks === 'undefined'){window.WVJBCallbacks=[]};";
}

#pragma mark - Setter

- (void)setJsLogicImpl:(IBTWKWebJSLogicImpl *)logicImpl {
    IBTWebJSBridgeJSLogicImpl* mlogicImpl = [[IBTWebJSBridgeJSLogicImpl alloc] initWithDelegate:self];
    [super setJsLogicImpl:mlogicImpl];
}

@end
```