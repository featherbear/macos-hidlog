const std = @import("std");

const c = @cImport({
    @cInclude("CoreGraphics/CoreGraphics.h");
});

fn b(eventTap: c.CGEventTapProxy, eventType: c.CGEventType, event: c.CGEventRef, userInfo: ?*anyopaque) callconv(.C) c.CGEventRef {
    _ = eventTap;
    _ = userInfo;

    // https://developer.apple.com/documentation/coregraphics/cgeventtype

    switch (eventType) {
        c.kCGEventTapDisabledByTimeout => {
            std.debug.print("DBG: timeout\n", .{});
            //   CGEventTapEnable(self.eventTap, true);
        },

        c.kCGEventMouseMoved => {
            std.debug.print("DBG: mouse move\n", .{});
        },

        c.kCGEventLeftMouseDown => {
            std.debug.print("DBG: left mouse down\n", .{});
        },

        c.kCGEventRightMouseDown => {
            std.debug.print("DBG: right mouse down\n", .{});
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

    const eventTap = c.CGEventTapCreate(c.kCGHIDEventTap, c.kCGTailAppendEventTap, c.kCGEventTapOptionListenOnly, event, b, null);
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
