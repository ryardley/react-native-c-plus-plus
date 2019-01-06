#import "RCTHelloWorld.h"
#import "HWHelloWorld.h"
@implementation RCTHelloWorld{
  HWHelloWorld *_cppApi;
}
- (RCTHelloWorld *)init
{
  self = [super init];
  _cppApi = [HWHelloWorld create];
  return self;
}
+ (BOOL)requiresMainQueueSetup
{
  return NO;
}
RCT_EXPORT_MODULE();
RCT_REMAP_METHOD(sayHello,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *response = [_cppApi getHelloWorld];
  resolve(response);
}
@end
