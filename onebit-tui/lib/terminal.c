// Real terminal implementation for POSIX systems (macOS/Linux)
// Provides raw mode, non-blocking input, and ANSI escape sequences

#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <string.h>
#include <errno.h>
#include <sys/select.h>
#include <time.h>

// Terminal state structure
typedef struct {
    struct termios orig_termios;
    int raw_mode;
    int width;
    int height;
} Terminal;

// Event structure
typedef struct {
    int type; // 0=none, 1=key, 2=mouse, 3=resize
    int key_code;
    int modifiers;
    int mouse_x;
    int mouse_y;
    int mouse_button;
} Event;

// Buffer structure
typedef struct {
    int width;
    int height;
    char* data;
} Buffer;

// Global terminal instance for signal handling
static Terminal* global_term = NULL;

// Restore terminal on exit
static void restore_terminal() {
    if (global_term && global_term->raw_mode) {
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &global_term->orig_termios);
        printf("\033[?1049l"); // Exit alternate screen
        printf("\033[?25h");   // Show cursor
        fflush(stdout);
    }
}

// Initialize terminal in raw mode
void* zig_terminal_init() {
    Terminal* term = malloc(sizeof(Terminal));
    if (!term) return NULL;
    
    // Save original terminal settings
    if (tcgetattr(STDIN_FILENO, &term->orig_termios) == -1) {
        free(term);
        return NULL;
    }
    
    // Set up cleanup on exit
    global_term = term;
    atexit(restore_terminal);
    
    // Enable raw mode
    struct termios raw = term->orig_termios;
    raw.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
    raw.c_oflag &= ~(OPOST);
    raw.c_cflag |= (CS8);
    raw.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
    raw.c_cc[VMIN] = 0;
    raw.c_cc[VTIME] = 1;
    
    if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) == -1) {
        free(term);
        return NULL;
    }
    
    term->raw_mode = 1;
    
    // Enter alternate screen and hide cursor
    printf("\033[?1049h"); // Enter alternate screen
    printf("\033[?25l");   // Hide cursor
    fflush(stdout);
    
    // Get terminal size
    struct winsize ws;
    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) == 0) {
        term->width = ws.ws_col;
        term->height = ws.ws_row;
    } else {
        term->width = 80;
        term->height = 24;
    }
    
    return term;
}

// Cleanup terminal
void zig_terminal_deinit(void* term_ptr) {
    Terminal* term = (Terminal*)term_ptr;
    if (!term) return;
    
    if (term->raw_mode) {
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &term->orig_termios);
        printf("\033[?1049l"); // Exit alternate screen
        printf("\033[?25h");   // Show cursor
        fflush(stdout);
    }
    
    if (global_term == term) {
        global_term = NULL;
    }
    
    free(term);
}

// Get terminal dimensions
void zig_terminal_get_size(void* term_ptr, int* width, int* height) {
    Terminal* term = (Terminal*)term_ptr;
    if (!term) {
        *width = 80;
        *height = 24;
        return;
    }
    
    struct winsize ws;
    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) == 0) {
        term->width = ws.ws_col;
        term->height = ws.ws_row;
    }
    
    *width = term->width;
    *height = term->height;
}

// Create a buffer
void* zig_buffer_create(int width, int height) {
    Buffer* buf = malloc(sizeof(Buffer));
    if (!buf) return NULL;
    
    buf->width = width;
    buf->height = height;
    buf->data = calloc(width * height * 20, 1); // Space for ANSI codes
    
    return buf;
}

// Free buffer
void zig_buffer_free(void* buffer_ptr) {
    Buffer* buf = (Buffer*)buffer_ptr;
    if (!buf) return;
    
    free(buf->data);
    free(buf);
}

// Write character to buffer
void zig_buffer_write_char(void* buffer_ptr, int x, int y, int ch,
                           int fg_r, int fg_g, int fg_b,
                           int bg_r, int bg_g, int bg_b,
                           int style) {
    // For now, directly write to terminal
    printf("\033[%d;%dH", y + 1, x + 1); // Move cursor (1-indexed)
    printf("\033[38;2;%d;%d;%dm", fg_r, fg_g, fg_b); // Set foreground color
    printf("\033[48;2;%d;%d;%dm", bg_r, bg_g, bg_b); // Set background color
    
    // Apply styles
    if (style & 1) printf("\033[1m");  // Bold
    if (style & 2) printf("\033[2m");  // Dim
    if (style & 4) printf("\033[3m");  // Italic
    if (style & 8) printf("\033[4m");  // Underline
    
    // Print character
    if (ch < 128) {
        putchar(ch);
    } else {
        // Handle Unicode (simplified)
        putchar(ch);
    }
    
    printf("\033[0m"); // Reset
    fflush(stdout);
}

// Write string to buffer
void zig_buffer_write_string(void* buffer_ptr, int x, int y, const char* text,
                             int fg_r, int fg_g, int fg_b,
                             int bg_r, int bg_g, int bg_b,
                             int style) {
    printf("\033[%d;%dH", y + 1, x + 1);
    printf("\033[38;2;%d;%d;%dm", fg_r, fg_g, fg_b);
    printf("\033[48;2;%d;%d;%dm", bg_r, bg_g, bg_b);
    
    if (style & 1) printf("\033[1m");
    if (style & 2) printf("\033[2m");
    if (style & 4) printf("\033[3m");
    if (style & 8) printf("\033[4m");
    
    printf("%s", text);
    printf("\033[0m");
    fflush(stdout);
}

// Render buffer to terminal
void zig_buffer_render(void* term_ptr, void* buffer_ptr) {
    // In this simple implementation, we write directly
    // A real implementation would do double buffering
    fflush(stdout);
}

// Static event storage
static Event last_event = {0};

// Poll for events (non-blocking)
void* zig_terminal_poll_event(void* term_ptr) {
    Terminal* term = (Terminal*)term_ptr;
    if (!term) return &last_event;
    
    // Check if input is available
    fd_set rfds;
    struct timeval tv;
    
    FD_ZERO(&rfds);
    FD_SET(STDIN_FILENO, &rfds);
    
    tv.tv_sec = 0;
    tv.tv_usec = 0;
    
    int retval = select(STDIN_FILENO + 1, &rfds, NULL, NULL, &tv);
    
    if (retval <= 0) {
        last_event.type = 0; // No event
        return &last_event;
    }
    
    // Read input
    char buf[32];
    int nread = read(STDIN_FILENO, buf, sizeof(buf));
    
    if (nread <= 0) {
        last_event.type = 0;
        return &last_event;
    }
    
    // Parse input
    last_event.type = 1; // Key event
    last_event.modifiers = 0;
    
    if (nread == 1) {
        // Single character
        last_event.key_code = buf[0];
        
        // Check for Ctrl combinations
        if (buf[0] >= 1 && buf[0] <= 26) {
            last_event.modifiers = 2; // Ctrl
            last_event.key_code = 'a' + buf[0] - 1;
        }
    } else if (nread >= 3 && buf[0] == 27 && buf[1] == '[') {
        // Escape sequence
        switch (buf[2]) {
            case 'A': last_event.key_code = 0x26; break; // Up arrow
            case 'B': last_event.key_code = 0x28; break; // Down arrow
            case 'C': last_event.key_code = 0x27; break; // Right arrow
            case 'D': last_event.key_code = 0x25; break; // Left arrow
            default: last_event.key_code = buf[2]; break;
        }
    } else if (nread == 1 && buf[0] == 27) {
        // ESC key
        last_event.key_code = 27;
    }
    
    return &last_event;
}

// Get event type
int zig_event_get_type(void* event_ptr) {
    Event* evt = (Event*)event_ptr;
    return evt ? evt->type : 0;
}

// Get key event data
void zig_event_get_key(void* event_ptr, int* key_code, int* modifiers) {
    Event* evt = (Event*)event_ptr;
    if (!evt) {
        key_code[0] = 0;
        modifiers[0] = 0;
        return;
    }
    key_code[0] = evt->key_code;
    modifiers[0] = evt->modifiers;
}

// Get mouse event data
void zig_event_get_mouse(void* event_ptr, int* x, int* y, int* button) {
    Event* evt = (Event*)event_ptr;
    if (!evt) {
        x[0] = 0;
        y[0] = 0;
        button[0] = 0;
        return;
    }
    x[0] = evt->mouse_x;
    y[0] = evt->mouse_y;
    button[0] = evt->mouse_button;
}
// Helper functions for MoonBit FFI
int terminal_get_last_key() {
    return last_event.key_code;
}

int terminal_get_last_modifiers() {
    return last_event.modifiers;
}

int terminal_get_last_mouse_x() {
    return last_event.mouse_x;
}

int terminal_get_last_mouse_y() {
    return last_event.mouse_y;
}

int terminal_get_last_mouse_button() {
    return last_event.mouse_button;
}

// Poll event and return type
int terminal_poll_event(void* term_ptr, int timeout_ms) {
    Terminal* term = (Terminal*)term_ptr;
    if (!term) return 0;
    
    // Check if input is available
    fd_set rfds;
    struct timeval tv;
    
    FD_ZERO(&rfds);
    FD_SET(STDIN_FILENO, &rfds);
    
    tv.tv_sec = timeout_ms / 1000;
    tv.tv_usec = (timeout_ms % 1000) * 1000;
    
    int retval = select(STDIN_FILENO + 1, &rfds, NULL, NULL, &tv);
    
    if (retval <= 0) {
        last_event.type = 0; // No event
        return 0;
    }
    
    // Read input
    char buf[32];
    int nread = read(STDIN_FILENO, buf, sizeof(buf));
    
    if (nread <= 0) {
        last_event.type = 0;
        return 0;
    }
    
    // Simple key parsing
    last_event.type = 1; // Key event
    last_event.key_code = buf[0];
    last_event.modifiers = 0;
    
    // Check for escape sequences
    if (buf[0] == '\033' && nread > 1) {
        if (buf[1] == '[') {
            // ANSI escape sequence
            if (nread > 2) {
                switch (buf[2]) {
                    case 'A': last_event.key_code = 1000; break; // Up
                    case 'B': last_event.key_code = 1001; break; // Down
                    case 'C': last_event.key_code = 1002; break; // Right
                    case 'D': last_event.key_code = 1003; break; // Left
                }
            }
        }
    }
    
    return last_event.type;
}

// Write buffer at position
// Write string to terminal
void terminal_write(void* term_ptr, const char* data) {
    printf("%s", data);
    fflush(stdout);
}

void terminal_write_buffer(void* term_ptr, const char* buffer, int x, int y, int width, int height) {
    Terminal* term = (Terminal*)term_ptr;
    if (!term) return;
    
    // Just write the buffer content for now
    printf("%s", buffer);
}
