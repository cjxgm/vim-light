#pragma once
// this is a lua library.
// this module implements all the functions exposed to lua.
#include "lua/all.hh"

namespace vimlight
{
	namespace library
	{
		int open(lua::state& s);
	};
};

