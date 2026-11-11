#pragma once

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/core/class_db.hpp>

namespace godot {

class MacMouseFix : public RefCounted {
	GDCLASS(MacMouseFix, RefCounted)

protected:
	static void _bind_methods();

public:
	bool install();
	void uninstall();
	bool is_installed() const;
	int64_t get_fixed_count() const;
};

}
