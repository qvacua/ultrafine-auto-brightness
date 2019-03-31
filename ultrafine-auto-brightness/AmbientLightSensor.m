/**
 * Tae Won Ha - http://taewon.de - @hataewon
 * See LICENSE
 *
 * Slightly modified version of https://bugzilla.mozilla.org/show_bug.cgi?id=793728#attach_664102
 */

#import <mach/mach.h>
#import <IOKit/IOKitLib.h>
#import "AmbientLightSensor.h"
#import "logger.h"

@implementation AmbientLightSensor {
  io_connect_t _dataPort;
}

- (instancetype)init {
  self = [super init];
  if (self == nil) {return nil;}

  kern_return_t kr;
  io_service_t serviceObject;

  serviceObject = IOServiceGetMatchingService(
      kIOMasterPortDefault,
      IOServiceMatching("AppleLMUController")
  );
  if (!serviceObject) {
    self = nil;
    return nil;
  }

  kr = IOServiceOpen(serviceObject, mach_task_self(), 0, &_dataPort);
  IOObjectRelease(serviceObject);
  if (kr != KERN_SUCCESS) {
    os_log_error(logger, "IOServiceOpen error: %{public}d", kr);
    self = nil;
    return nil;
  }

  return self;
}

- (NSUInteger)currentValue {
  kern_return_t kr;
  uint32_t outputs = 2;
  uint64_t values[outputs];

  kr = IOConnectCallMethod(
      _dataPort,
      0,
      NULL,
      0,
      NULL,
      0,
      values,
      &outputs,
      NULL,
      0
  );
  if (kr == KERN_SUCCESS) {
    return values[0];
  }

  return INVALID_BRIGHTNESS_VALUE;
}

@end
