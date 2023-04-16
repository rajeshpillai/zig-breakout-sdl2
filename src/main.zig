const std = @import("std");
const c = @cImport({
    @cInclude("SDL.h");
});


const FPS: comptime_int = 60;
const WINDOW_WIDTH: comptime_int  = 800;
const WINDOW_HEIGHT: comptime_int = 600;
const PROJ_SIZE = 25;
const PROJ_SPEED: f32 = 400;
const DELTA_TIME_SEC: f32 = 1.0 / @intToFloat(f32, FPS);

const BAR_LEN = 100;
const BAR_THICKNESS: f32 = PROJ_SIZE;
const BAR_Y: f32 = WINDOW_HEIGHT - BAR_THICKNESS - 100;
const BAR_SPEED: f32 = PROJ_SPEED;

const Point = struct {
    proj_x: f32,
    proj_y: f32
};

var quit = false;
var proj_x: f32 = 100;
var proj_y: f32 = 100;
var proj_dx:f32 = 1;
var proj_dy:f32 = 1;
var bar_x: f32 = 100;
var bar_dx: f32 = 0;
var pause = false;


fn render(renderer: *c.SDL_Renderer )  void  {
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
        .y = @floatToInt(i32, BAR_Y - BAR_THICKNESS / 2),
        .w = @floatToInt(i32, BAR_LEN),
        .h = @floatToInt(i32, BAR_THICKNESS)
    };

    _ = c.SDL_RenderFillRect(renderer, &bar_rect);
}

fn update(dt: f32)  void  {
    if (!pause) {
        bar_x += bar_dx *  BAR_SPEED * dt;
        
        var proj_nx = proj_x + proj_dx * PROJ_SPEED * dt;

        if (proj_nx < 0 or proj_nx + PROJ_SIZE > WINDOW_WIDTH) {
            proj_dx *= -1;
            proj_nx = proj_x + proj_dx * PROJ_SPEED * dt;
        }

        var proj_ny = proj_y + proj_dy * PROJ_SPEED * dt;

        if (proj_ny < 0 or proj_ny + PROJ_SIZE > WINDOW_HEIGHT) {
            proj_dy *= -1;
            proj_ny = proj_y + proj_dy * PROJ_SPEED * dt;
        }
        
        proj_x = proj_nx;
        proj_y = proj_ny;
        // Detect bar and proj collision
        if (proj_y + PROJ_SIZE > BAR_Y - BAR_THICKNESS / 2 and proj_y + PROJ_SIZE < BAR_Y + BAR_THICKNESS / 2) {
            if (proj_x + PROJ_SIZE > bar_x and proj_x < bar_x + BAR_LEN) {
                proj_dy *= -1;
                proj_ny = proj_y + proj_dy * PROJ_SPEED * dt;
            }
        }
    }
}


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

    const keyboard = c.SDL_GetKeyboardState(null);

    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.@"type") {
                c.SDL_QUIT => {
                    quit = true;
                },
                c.SDL_KEYDOWN => {
                    switch(event.key.keysym.sym) {
                        ' ' => { pause = !pause; },
                        'a' => { bar_x -= 10; },
                        'd' => { bar_x += 10; },
                        27 => { // QUIT ESC
                            quit = true;
                        },
                        else => {},
                    }
                    
                },
                else => {},
            }
        }

        bar_dx = 0;
        if(keyboard[c.SDL_SCANCODE_A] != 0) {
            bar_x -= 1;
        } 
        
        if (keyboard[c.SDL_SCANCODE_D] != 0) {
            bar_x += 1;
        }
        

        update(DELTA_TIME_SEC);

        _ = c.SDL_SetRenderDrawColor(renderer, 0x18, 0x18, 0x18, 0xFF);
        _ = c.SDL_RenderClear(renderer);

        render(renderer);

        
        c.SDL_RenderPresent(renderer);
        c.SDL_Delay(1000 / FPS);

    }
}

