#pragma once
#include "c.hh"
#include "internal.hh"
#include "location.hh"
#include <utility>

namespace clang
{
	struct diagnostic : public internal::guard<c::diagnostic::type>
	{
		using self_type = diagnostic;
		using super_type = internal::guard<c::diagnostic::type>;

		diagnostic(value_type value) : super_type(value) {}
		diagnostic(self_type&& value) : super_type(std::move(value)) {}
		~diagnostic() override { if (owned) c::diagnostic::dispose(get()); }

		location location() { return c::diagnostic::get_location(get()); }
	};
};

