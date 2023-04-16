const std = @import("std");
const c = @cImport({
    @cInclude("SDL.h");
});


const WINDOW_WIDTH = 800;
const WINDOW_HEIGHT = 600;
const PROJ_SIZE = 50;
const PROJ_SPEED: f32 = 400;
const FPS = 60;
const DELTA_TIME_SEC: f32 = 1.0 / @intToFloat(f32, FPS);

const BAR_LEN = 100;
const BAR_THICKNESS: f32 = 10;
const BAR_Y: f32 = WINDOW_HEIGHT - BAR_THICKNESS - 100;

const Point = struct {
    proj_x: f32,
    proj_y: f32
};

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

    var proj_x: f32 = 100;
    var proj_y: f32 = 100;
    var dx:f32 = 1;
    var dy:f32 = 1;

    var bar_x: f32 = 100;

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
        
        var proj_nx = proj_x + dx * PROJ_SPEED * DELTA_TIME_SEC;

        if (proj_nx < 0 or proj_nx + PROJ_SIZE > WINDOW_WIDTH) {
            dx *= -1;
            proj_nx = proj_x + dx * PROJ_SPEED * DELTA_TIME_SEC;
        }

        var proj_ny = proj_y + dy * PROJ_SPEED * DELTA_TIME_SEC;

        if (proj_ny < 0 or proj_ny + PROJ_SIZE > WINDOW_HEIGHT) {
            dy *= -1;
            proj_ny = proj_y + dy * PROJ_SPEED * DELTA_TIME_SEC;
        }

        proj_x = proj_nx;
        proj_y = proj_ny;
        

        _ = c.SDL_SetRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0xFF);
        
        const proj_rect = c.SDL_Rect {
            .x = @floatToInt(i32, proj_x),
            .y = @floatToInt(i32, proj_y),
            .w = PROJ_SIZE,
            .h = PROJ_SIZE
        };

        _ = c.SDL_RenderFillRect(renderer, &proj_rect);

        _ = c.SDL_SetRenderDrawColor(renderer, 0xFF, 0, 0, 0xFF);
        const bar_rect = c.SDL_Rect {
            .x = @floatToInt(i32, bar_x),
            .y = BAR_Y - BAR_THICKNESS / 2,
            .w = BAR_LEN,
            .h = BAR_THICKNESS
        };

        _ = c.SDL_RenderFillRect(renderer, &bar_rect);
        
        c.SDL_RenderPresent(renderer);
        c.SDL_Delay(1000 / FPS);

    }
}

