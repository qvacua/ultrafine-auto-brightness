/**
 * Tae Won Ha - http://taewon.de - @hataewon
 * See LICENSE
 *
 * Slightly modified version of https://github.com/kfix/ddcctl/blob/master/ddcctl.m
 */

#import <AppKit/AppKit.h>
#import "UltraFineDisplay.h"
#import "DDC.h"
#import "logger.h"

typedef union descriptor union_desc;

static NSString *EDIDString(char *string) {
  NSString *temp = [[NSString alloc] initWithBytes:string
                                            length:13
                                          encoding:NSASCIIStringEncoding];

  return ([temp rangeOfString:@"\n"].location != NSNotFound)
      ? [temp componentsSeparatedByString:@"\n"][0]
      : temp;
}

@implementation UltraFineDisplay {
}

- (instancetype)init {
  self = [super init];
  if (self == nil) {return nil;}

  for (NSScreen *screen in NSScreen.screens) {
    NSDictionary *description = screen.deviceDescription;
    if (!description[@"NSDeviceIsScreen"]) {continue;}
    CGDirectDisplayID screenNumber = [
        description[@"NSScreenNumber"] unsignedIntValue
    ];
    // Ignore builtin screens
    if (CGDisplayIsBuiltin(screenNumber)) {continue;}

    UInt64 did = (UInt64) screenNumber;
    NSLog(@"I: polling display %llu's EDID", did);

    CGDirectDisplayID cdisplay = (CGDirectDisplayID) did;
    struct EDID edid = {};
    if (!EDIDTest(cdisplay, &edid)) {continue;}

    for (
        union_desc *des = (union_desc *) edid.descriptors;
        des < (union_desc *) (edid.descriptors + sizeof(edid.descriptors));
        des++
        ) {
      switch (des->text.type) {
        case 0xFC: {
          if ([EDIDString(des->text.data) containsString:@"LG UltraFine"]) {
            _displayId = (CGDirectDisplayID) did;
            return self;
          }
          break;
        }

        default:
          break;
      }
    }
  }

  self = nil;
  return nil;
}

- (UInt8)brightness {
  struct DDCReadCommand command;
  command.control_id = BRIGHTNESS;
  command.max_value = 0;
  command.current_value = 0;
  DDCRead(_displayId, &command);

  return command.current_value;
}

- (void)setBrightness:(UInt8)value {
  struct DDCWriteCommand command;
  command.control_id = BRIGHTNESS;
  command.new_value = value;

  os_log_debug(
      logger,
      "Setting VCP control #%{public}u => %{public}u",
      command.control_id, command.new_value
  );

  if (DDCWrite(_displayId, &command)) {return;}

  os_log_error(logger, "Failed to send DDC command!");
}

@end
