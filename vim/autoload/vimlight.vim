" vimlight: clang semantic highlighter for vim
" vim: noet ts=4 sw=4 sts=0
"
" Copyright: (C) 2014 eXerigumo Clanjor(哆啦比猫/兰威举) <cjxgm@126.com>
"   License: The MIT Licence with modification. see LICENSE for details.

" run only once
if exists("g:loaded_vimlight")
	finish
endif
let g:loaded_vimlight = 1

lua <<END
	local root = vim.eval[[expand("<sfile>:h:h")]]
	package.cpath = ("%s;%s/lib/?.so"):format(package.cpath, root)

	vimlight = {}	-- global variable intentionally
	local vl = vimlight
	vl.engine = require 'vimlight_engine'

	vl.engine.init(root .. "/etc/hlgroup.vimlight")
	vl.done = true
	vl.modified = true

	vl.default_options = {
		c = "-std=gnu11 -Wall -Wextra",
		cpp = "-std=gnu++14 -Wall -Wextra",
	}

	vl.apply = function(this)
		if this.done then return end
		local result
		while true do
			result = this.engine.get()
			if result == nil then break end
			for _,cmd in ipairs(result) do
				vim.command(cmd)
			end
			this.done = true
		end
		return this.done
	end

	vl.finish = function(this)
		while not this.done do
			this:apply()
		end
	end

	vl.update = function(this)
		if this.done then
			this.done = false
			this.modified = false
			local src = vim.eval("join(getline(1, '$'), '\n')")
			this.engine.request(src)
		end
	end

	vl.modify = function(this)
		this.modified = true
	end

	vl.rename = function(this)
		local file = vim.eval("expand('%')")
		local ft = vim.eval("&ft")
		if file == "" then file = "source." .. ft end
		this.file = file
	end

	vl.reoption = function(this)
		local opt = vim.eval([[ exists("b:vimlight_option") ? b:vimlight_option : "" ]])
		if opt == "" then opt = nil end
		local ft = vim.eval("&ft")
		local default = this.default_options[ft] or ""
		this.option = opt or default or ""
	end

	vl.setup = function(this)
		this.engine.setup(this.file, this.option)
	end

	vl.leave = function(this)
		this.engine.exit()
	end
END

function vimlight#update()
	if &ft != "cpp" && &ft != "c"
		return
	endif
lua <<END
	vimlight:apply()
	if vimlight.modified then
		vimlight:update()
	end
END
endf

function vimlight#modify()
	lua vimlight:modify()
	call vimlight#update()
endf

function vimlight#enter()
	if &ft != "cpp" && &ft != "c"
		return
	endif

	syn match cppFunction "\zs\w\+\ze\s*("
	hi def link cppFunction Function
	syn match cppBinNumber "0b[01]\+"
	hi def link cppBinNumber cNumber
	syn match cppNamespaceSep "::"
	hi def link cppNamespaceSep Special

	lua vimlight:rename()
	lua vimlight:reoption()
	lua vimlight:setup()
	call vimlight#modify()
endf

function vimlight#finish()
	lua vimlight:finish()
endf

function vimlight#leave()
	lua vimlight:leave()
endf


" user function
function vimlight#option(opt)
	let b:vimlight_option = a:opt
	lua vimlight:reoption()
	lua vimlight:setup()
	call vimlight#modify()
endf

" user function
function vimlight#default_option()
	unlet! b:vimlight_option
	lua vimlight:reoption()
	lua vimlight:setup()
	call vimlight#modify()
endf

au VimLeave	* call vimlight#leave()

