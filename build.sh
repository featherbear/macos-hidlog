#!/bin/sh
zig build-exe app.zig -framework CoreGraphics -framework CoreFoundation -O ReleaseSmall -femit-bin=out/hidlog  # -femit-asm 