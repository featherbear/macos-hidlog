const std = @import("std");

const c = @cImport({
    @cInclude("CoreGraphics/CoreGraphics.h");
    @cInclude("os/log.h");
});

var lastX: f64 = undefined;
var lastY: f64 = undefined;

fn callback(eventTap: c.CGEventTapProxy, eventType: c.CGEventType, event: c.CGEventRef, userInfo: ?*anyopaque) callconv(.C) c.CGEventRef {
    _ = eventTap;
    _ = userInfo;

    // https://developer.apple.com/documentation/coregraphics/cgeventtype

    switch (eventType) {
        c.kCGEventTapDisabledByTimeout => {
            std.debug.print("DBG: timeout\n", .{});
            //   CGEventTapEnable(self.eventTap, true);
        },

        c.kCGEventMouseMoved => {
            const location = c.CGEventGetLocation(event);
            if (lastX == location.x and lastY == location.y) {
                return event;
            }
            lastX = location.x;
            lastY = location.y;
            std.debug.print("DBG: mouse move x={d} y={d}\n", .{ location.x, location.y });
        },

        c.kCGEventLeftMouseDown => {
            const location = c.CGEventGetLocation(event);
            std.debug.print("DBG: left mouse down x={d} y={d}\n", .{ location.x, location.y });
        },

        c.kCGEventRightMouseDown => {
            const location = c.CGEventGetLocation(event);
            std.debug.print("DBG: right mouse down x={d} y={d}\n", .{ location.x, location.y });
        },

        c.kCGEventKeyDown => {
            // std.debug.print("DBG: keyDown {}\n", .{c.CGEventGetIntegerValueField(event, c.kCGKeyboardEventKeycode)});
        },

        c.kCGEventFlagsChanged => {
            // std.debug.print("DBG: flags {}\n", .{c.CGEventGetFlags(event)});
        },

        else => {
            std.debug.print("DBG: unknown event {}\n", .{eventType});
        },
    }

    return event;
}

fn aaa() void {
    // func getFrontmostApplication() -> NSRunningApplication? {
    //     return NSWorkspace.shared.frontmostApplication
    // }

}

pub fn main() void {
    // https://developer.apple.com/documentation/coregraphics/cgeventtype
    const event =
        // Mouse Events
        c.CGEventMaskBit(c.kCGEventMouseMoved) | c.CGEventMaskBit(c.kCGEventLeftMouseDown) | c.CGEventMaskBit(c.kCGEventRightMouseDown) |
        // Keyboard Events
        c.CGEventMaskBit(c.kCGEventKeyDown) | c.CGEventMaskBit(c.kCGEventFlagsChanged);

    const eventTap = c.CGEventTapCreate(c.kCGHIDEventTap, c.kCGTailAppendEventTap, c.kCGEventTapOptionListenOnly, event, callback, null);
    if (eventTap == null) {
        std.debug.print("Sad\n", .{});
        return;
    }

    std.debug.print("Starting event loop...\n", .{});

    const source = c.CFMachPortCreateRunLoopSource(null, eventTap, 0);
    c.CFRunLoopAddSource(c.CFRunLoopGetCurrent(), source, c.kCFRunLoopCommonModes);
    c.CFRelease(source);

    c.CGEventTapEnable(eventTap, true);

    c.CFRunLoopRun();
    // Keystroke receiving
}
