/**
 * Tae Won Ha - http://taewon.de - @hataewon
 * See LICENSE
 */

#import <mach/mach.h>
#import <IOKit/IOKitLib.h>
#import <Foundation/Foundation.h>
#import "AmbientLightSensor.h"
#import "UltraFineDisplay.h"
#import "logger.h"

os_log_t logger;

static const int UPDATE_INTERVAL = 1;

static AmbientLightSensor *sensor;
static UltraFineDisplay *display;

static NSUInteger lastSensorValue = 1000000;

static void updateTimerCallBack(
    CFRunLoopTimerRef timer __unused,
    void *info __unused
) {
  @autoreleasepool {
    NSUInteger current = sensor.currentValue;
    if (current == INVALID_BRIGHTNESS_VALUE) {
      os_log_error(logger, "No sensor value");
      return;
    }

    if (current == lastSensorValue) {
      os_log_debug(logger, "Same sensor value");
      return;
    }

    double factor = (double) current / (double) lastSensorValue;
    UInt8 cb = display.brightness;
    UInt8 targetCb = (UInt8) ceil(MAX(MIN(((double) cb * factor), 100.0), 1));

    os_log(
        logger,
        "Sensor value changed with factor %{public}lf. "
        "Changing brightness of display ID %{public}u "
        "from %{public}d to %{public}d",
        factor, display.displayId, cb, targetCb
    );

    display.brightness = targetCb;
    lastSensorValue = current;
  }
}

int main(void) {
  logger = os_log_create(
      "com.qvacua.ultrafile-auto-brightness",
      "general"
  );

  @autoreleasepool {
    display = [UltraFineDisplay new];
    if (display == nil) {
      os_log_error(logger, "Did not find LG UltraFine");
      exit(0);
    }
    os_log(logger, "Found LG UltraFine with ID %{public}u", display.displayId);

    sensor = [AmbientLightSensor new];
    if (sensor == nil) {
      os_log_error(logger, "Did not find ambient light sensor");
      exit(0);
    }
    os_log(logger, "Found ambient light sensor");

    lastSensorValue = sensor.currentValue;
  }

  CFRunLoopTimerRef updateTimer;

  updateTimer = CFRunLoopTimerCreate(
      kCFAllocatorDefault,
      CFAbsoluteTimeGetCurrent() + 0.1,
      UPDATE_INTERVAL,
      0,
      0,
      updateTimerCallBack,
      NULL
  );
  CFRunLoopAddTimer(CFRunLoopGetCurrent(), updateTimer, kCFRunLoopDefaultMode);
  CFRunLoopRun();

  exit(0);
}
