// Stub implementation for terminal functions
// This allows the MoonBit code to link and run without the full Zig implementation

#include <stdio.h>
#include <stdlib.h>

// Terminal functions
void* zig_terminal_init() {
    printf("[Stub] Terminal initialized\n");
    return (void*)1; // Return non-null pointer
}

void zig_terminal_deinit(void* term) {
    printf("[Stub] Terminal cleanup\n");
}

void zig_terminal_get_size(void* term, int* width, int* height) {
    *width = 80;
    *height = 24;
    printf("[Stub] Terminal size: %dx%d\n", *width, *height);
}

// Buffer functions  
void* zig_buffer_create(int width, int height) {
    printf("[Stub] Buffer created: %dx%d\n", width, height);
    return (void*)2; // Return non-null pointer
}

void zig_buffer_destroy(void* buffer) {
    printf("[Stub] Buffer destroyed\n");
}

void zig_buffer_write_string(void* buffer, int x, int y, const char* text, 
                             int fg_r, int fg_g, int fg_b,
                             int bg_r, int bg_g, int bg_b,
                             int style) {
    printf("[Stub] Write at (%d,%d): %s\n", x, y, text);
}

void zig_buffer_render(void* buffer, void* term) {
    printf("[Stub] Buffer rendered\n");
}

// Event functions
int zig_terminal_poll_event(void* term) {
    return 0; // No event
}

int zig_event_get_type(void* event) {
    return 0;
}

int zig_event_get_key(void* event) {
    return 0;
}

int zig_event_get_mouse_x(void* event) {
    return 0;
}

int zig_event_get_mouse_y(void* event) {
    return 0;
}