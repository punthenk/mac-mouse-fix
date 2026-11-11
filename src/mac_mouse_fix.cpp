#include "mac_mouse_fix.h"

#include "mac_mouse_hook.h"

using namespace godot;

void MacMouseFix::_bind_methods() {
	ClassDB::bind_method(D_METHOD("install"), &MacMouseFix::install);
	ClassDB::bind_method(D_METHOD("uninstall"), &MacMouseFix::uninstall);
	ClassDB::bind_method(D_METHOD("is_installed"), &MacMouseFix::is_installed);
	ClassDB::bind_method(D_METHOD("get_fixed_count"), &MacMouseFix::get_fixed_count);
}

bool MacMouseFix::install() {
	return mac_mouse_hook_install();
}

void MacMouseFix::uninstall() {
	mac_mouse_hook_uninstall();
}

bool MacMouseFix::is_installed() const {
	return mac_mouse_hook_is_installed();
}

int64_t MacMouseFix::get_fixed_count() const {
	return mac_mouse_hook_fixed_count();
}
