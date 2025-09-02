// C wrapper that provides a simpler interface for MoonBit FFI
// This converts between MoonBit int handles and Yoga pointers

#include <yoga/Yoga.h>
#include <stdlib.h>

// We'll use a simple handle system to convert between ints and pointers
// In production, this should use a proper handle table
static YGNodeRef* node_handles = NULL;
static YGConfigRef* config_handles = NULL;
static int node_handle_count = 0;
static int config_handle_count = 0;
static int node_handle_capacity = 0;
static int config_handle_capacity = 0;

// Helper to grow handle arrays
static void ensure_node_capacity(int index) {
    if (index >= node_handle_capacity) {
        int new_capacity = (index + 1) * 2;
        node_handles = (YGNodeRef*)realloc(node_handles, new_capacity * sizeof(YGNodeRef));
        for (int i = node_handle_capacity; i < new_capacity; i++) {
            node_handles[i] = NULL;
        }
        node_handle_capacity = new_capacity;
    }
}

static void ensure_config_capacity(int index) {
    if (index >= config_handle_capacity) {
        int new_capacity = (index + 1) * 2;
        config_handles = (YGConfigRef*)realloc(config_handles, new_capacity * sizeof(YGConfigRef));
        for (int i = config_handle_capacity; i < new_capacity; i++) {
            config_handles[i] = NULL;
        }
        config_handle_capacity = new_capacity;
    }
}

// Config functions
extern "C" int yoga_config_new_wrapper() {
    int handle = config_handle_count++;
    ensure_config_capacity(handle);
    config_handles[handle] = YGConfigNew();
    return handle;
}

extern "C" void yoga_config_free_wrapper(int handle) {
    if (handle >= 0 && handle < config_handle_capacity && config_handles[handle]) {
        YGConfigFree(config_handles[handle]);
        config_handles[handle] = NULL;
    }
}

// Node functions
extern "C" int yoga_node_new_wrapper() {
    int handle = node_handle_count++;
    ensure_node_capacity(handle);
    node_handles[handle] = YGNodeNew();
    return handle;
}

extern "C" int yoga_node_new_with_config_wrapper(int config_handle) {
    int handle = node_handle_count++;
    ensure_node_capacity(handle);
    if (config_handle >= 0 && config_handle < config_handle_capacity) {
        node_handles[handle] = YGNodeNewWithConfig(config_handles[config_handle]);
    } else {
        node_handles[handle] = YGNodeNew();
    }
    return handle;
}

extern "C" void yoga_node_free_wrapper(int handle) {
    if (handle >= 0 && handle < node_handle_capacity && node_handles[handle]) {
        YGNodeFree(node_handles[handle]);
        node_handles[handle] = NULL;
    }
}

// Layout calculation
extern "C" void yoga_node_calculate_layout_wrapper(int handle, float width, float height, int direction) {
    if (handle >= 0 && handle < node_handle_capacity && node_handles[handle]) {
        YGNodeCalculateLayout(node_handles[handle], width, height, (YGDirection)direction);
    }
}

// Get layout results
extern "C" float yoga_node_layout_get_left_wrapper(int handle) {
    if (handle >= 0 && handle < node_handle_capacity && node_handles[handle]) {
        return YGNodeLayoutGetLeft(node_handles[handle]);
    }
    return 0.0f;
}

extern "C" float yoga_node_layout_get_top_wrapper(int handle) {
    if (handle >= 0 && handle < node_handle_capacity && node_handles[handle]) {
        return YGNodeLayoutGetTop(node_handles[handle]);
    }
    return 0.0f;
}

extern "C" float yoga_node_layout_get_width_wrapper(int handle) {
    if (handle >= 0 && handle < node_handle_capacity && node_handles[handle]) {
        return YGNodeLayoutGetWidth(node_handles[handle]);
    }
    return 0.0f;
}

extern "C" float yoga_node_layout_get_height_wrapper(int handle) {
    if (handle >= 0 && handle < node_handle_capacity && node_handles[handle]) {
        return YGNodeLayoutGetHeight(node_handles[handle]);
    }
    return 0.0f;
}

// Style setters (simplified - add more as needed)
extern "C" void yoga_node_style_set_width_wrapper(int handle, float width) {
    if (handle >= 0 && handle < node_handle_capacity && node_handles[handle]) {
        YGNodeStyleSetWidth(node_handles[handle], width);
    }
}

extern "C" void yoga_node_style_set_height_wrapper(int handle, float height) {
    if (handle >= 0 && handle < node_handle_capacity && node_handles[handle]) {
        YGNodeStyleSetHeight(node_handles[handle], height);
    }
}

extern "C" void yoga_node_style_set_flex_direction_wrapper(int handle, int direction) {
    if (handle >= 0 && handle < node_handle_capacity && node_handles[handle]) {
        YGNodeStyleSetFlexDirection(node_handles[handle], (YGFlexDirection)direction);
    }
}

extern "C" void yoga_node_style_set_justify_content_wrapper(int handle, int justify) {
    if (handle >= 0 && handle < node_handle_capacity && node_handles[handle]) {
        YGNodeStyleSetJustifyContent(node_handles[handle], (YGJustify)justify);
    }
}

extern "C" void yoga_node_style_set_align_items_wrapper(int handle, int align) {
    if (handle >= 0 && handle < node_handle_capacity && node_handles[handle]) {
        YGNodeStyleSetAlignItems(node_handles[handle], (YGAlign)align);
    }
}

// Tree operations
extern "C" void yoga_node_insert_child_wrapper(int parent_handle, int child_handle, int index) {
    if (parent_handle >= 0 && parent_handle < node_handle_capacity && node_handles[parent_handle] &&
        child_handle >= 0 && child_handle < node_handle_capacity && node_handles[child_handle]) {
        YGNodeInsertChild(node_handles[parent_handle], node_handles[child_handle], index);
    }
}

extern "C" void yoga_node_remove_child_wrapper(int parent_handle, int child_handle) {
    if (parent_handle >= 0 && parent_handle < node_handle_capacity && node_handles[parent_handle] &&
        child_handle >= 0 && child_handle < node_handle_capacity && node_handles[child_handle]) {
        YGNodeRemoveChild(node_handles[parent_handle], node_handles[child_handle]);
    }
}

extern "C" int yoga_node_get_child_count_wrapper(int handle) {
    if (handle >= 0 && handle < node_handle_capacity && node_handles[handle]) {
        return YGNodeGetChildCount(node_handles[handle]);
    }
    return 0;
}