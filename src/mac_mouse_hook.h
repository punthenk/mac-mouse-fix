#pragma once

extern "C" {

bool mac_mouse_hook_install();

void mac_mouse_hook_uninstall();

bool mac_mouse_hook_is_installed();

long long mac_mouse_hook_fixed_count();
}
