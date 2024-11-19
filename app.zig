const std = @import("std");

const c = @cImport({
    @cInclude("CoreGraphics/CoreGraphics.h");
    @cInclude("Carbon/Carbon.h");
    @cInclude("os/log.h");
});

const keyboard = @import("keyboard.zig");

var lastX: f64 = undefined;
var lastY: f64 = undefined;

var modifierFlags = keyboard.ModifierFlags{ .shift = false, .control = false, .option = false, .command = false, .caps = false, .function = false };

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
            const keycode = c.CGEventGetIntegerValueField(event, c.kCGKeyboardEventKeycode);
            std.debug.print("DBG: Key press {s}\n", .{keyboard.virtKeyCodeToKeyboard(keycode, modifierFlags)});
        },

        c.kCGEventFlagsChanged => {
            const flags = c.CGEventGetFlags(event);
            modifierFlags.shift = (flags & c.kCGEventFlagMaskShift) != 0;
            modifierFlags.control = (flags & c.kCGEventFlagMaskControl) != 0;
            modifierFlags.option = (flags & c.kCGEventFlagMaskAlternate) != 0;
            modifierFlags.command = (flags & c.kCGEventFlagMaskCommand) != 0;
            modifierFlags.caps = (flags & c.kCGEventFlagMaskAlphaShift) != 0;
            modifierFlags.function = (flags & c.kCGEventFlagMaskSecondaryFn) != 0;
            std.debug.print("DBG: Key modifiers {}\n", .{modifierFlags});
        },

        else => {
            std.debug.print("DBG: unknown event {}\n", .{eventType});
        },
    }

    return event;
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
