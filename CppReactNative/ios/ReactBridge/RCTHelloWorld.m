#import "RCTHelloWorld.h"

@implementation RCTHelloWorld

RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(sayHello,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
  resolve(@"Hello from Objective-C");
}
@end
