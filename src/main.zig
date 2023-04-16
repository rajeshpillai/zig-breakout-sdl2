const std = @import("std");
const c = @cImport({
    @cInclude("SDL.h");
});

pub fn main() !void {
     if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    var window = c.SDL_CreateWindow("Breakout Game", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, 640, 400, 0);
    defer c.SDL_DestroyWindow(window);

    var renderer = c.SDL_CreateRenderer(window, 0, c.SDL_RENDERER_PRESENTVSYNC) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLRendererCreationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    var quit = false;

    const FPS = 60;

    const DELTA_TIME_SEC: f32 = 1.0 / @intToFloat(f32, FPS);
    const SPEED: f32 = 100;

    var x: f32 = 0;
    var y: f32 = 0;

    var dx:f32 = 1;
    var dy:f32 = 1;

    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.@"type") {
                c.SDL_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }

        
        _ = c.SDL_SetRenderDrawColor(renderer, 0x18, 0x18, 0x18, 0xFF);
        _ = c.SDL_RenderClear(renderer);
        

        x += dx * SPEED * DELTA_TIME_SEC;
        y += dy * SPEED * DELTA_TIME_SEC;

        const rect = c.SDL_Rect {
            .x = @floatToInt(i32, x),
            .y = @floatToInt(i32, y),
            .w = 100,
            .h = 100
        };

        _ = c.SDL_SetRenderDrawColor(renderer, 0xFF, 0, 0, 0xFF);
        _ = c.SDL_RenderFillRect(renderer, &rect);
        
        c.SDL_RenderPresent(renderer);
        c.SDL_Delay(1000 / FPS);
        
    }


    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
}

