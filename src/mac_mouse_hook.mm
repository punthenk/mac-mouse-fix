#import <Cocoa/Cocoa.h>

#include "mac_mouse_hook.h"

static id g_monitor = nil;
static long long g_fixed_count = 0;

static NSEvent *remove_control_flag(NSEvent *event) {
	NSEventModifierFlags flags = event.modifierFlags;
	if ((flags & NSEventModifierFlagControl) == 0) {
		return event;
	}

	NSEvent *fixed = [NSEvent mouseEventWithType:event.type
	                                    location:event.locationInWindow
	                               modifierFlags:(flags & ~NSEventModifierFlagControl)
	                                   timestamp:event.timestamp
	                                windowNumber:event.windowNumber
	                                     context:nil
	                                 eventNumber:event.eventNumber
	                                  clickCount:event.clickCount
	                                    pressure:event.pressure];
	if (fixed == nil) {
		return event;
	}

	g_fixed_count++;
	return fixed;
}

bool mac_mouse_hook_install() {
	if (g_monitor != nil) {
		return true;
	}
	if (![NSThread isMainThread]) {
		NSLog(@"[MacMouseFix] install() moet op de main thread worden aangeroepen.");
		return false;
	}

	NSEventMask mask = NSEventMaskLeftMouseDown | NSEventMaskLeftMouseUp;

	g_monitor = [NSEvent addLocalMonitorForEventsMatchingMask:mask
	                                                  handler:^NSEvent *(NSEvent *event) {
		                                                  return remove_control_flag(event);
	                                                  }];
	return g_monitor != nil;
}

void mac_mouse_hook_uninstall() {
	if (g_monitor != nil) {
		[NSEvent removeMonitor:g_monitor];
		g_monitor = nil;
	}
}

bool mac_mouse_hook_is_installed() {
	return g_monitor != nil;
}

long long mac_mouse_hook_fixed_count() {
	return g_fixed_count;
}
