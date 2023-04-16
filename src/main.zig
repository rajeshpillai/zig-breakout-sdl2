const std = @import("std");
const c = @cImport({
    @cInclude("SDL.h");
});


const WINDOW_WIDTH = 800;
const WINDOW_HEIGHT = 600;
const RECT_SIZE = 50;
const FPS = 60;
const DELTA_TIME_SEC: f32 = 1.0 / @intToFloat(f32, FPS);
const RECT_SPEED: f32 = 400;

pub fn main() !void {
     if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();


    var window = c.SDL_CreateWindow("Breakout Game", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, WINDOW_WIDTH, WINDOW_HEIGHT, 0);
    defer c.SDL_DestroyWindow(window);

    var renderer = c.SDL_CreateRenderer(window, 0, c.SDL_RENDERER_PRESENTVSYNC) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLRendererCreationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    var quit = false;
    var x: f32 = 100;
    var y: f32 = 100;
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
        
        var nx = x + dx * RECT_SPEED * DELTA_TIME_SEC;

        if (nx < 0 or nx + RECT_SIZE > WINDOW_WIDTH) {
            dx *= -1;
            nx = x + dx * RECT_SPEED * DELTA_TIME_SEC;
        }

        var ny = y + dy * RECT_SPEED * DELTA_TIME_SEC;

        if (ny < 0 or ny + RECT_SIZE > WINDOW_HEIGHT) {
            dy *= -1;
            ny = y + dy * RECT_SPEED * DELTA_TIME_SEC;
        }

        x = nx;
        y = ny;
        

        const rect = c.SDL_Rect {
            .x = @floatToInt(i32, x),
            .y = @floatToInt(i32, y),
            .w = RECT_SIZE,
            .h = RECT_SIZE
        };

        _ = c.SDL_SetRenderDrawColor(renderer, 0xFF, 0, 0, 0xFF);
        _ = c.SDL_RenderFillRect(renderer, &rect);
        
        c.SDL_RenderPresent(renderer);
        c.SDL_Delay(1000 / FPS);

    }
}

