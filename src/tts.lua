local isWeb = love.system.getOS() == "Web"

local eclair_lib
local eclair_initialized = false
local ffi

if not isWeb then
	ffi = require("ffi")

	-- mirrors eclair.h - enum values are compiled into this declaration, so
	-- re-check it against the header whenever eclair is re-copied
	ffi.cdef[[
		typedef enum {
			ECLAIR_OK = 0,
			ECLAIR_ERR_NOT_INITIALIZED,
			ECLAIR_ERR_NO_BACKEND,
			ECLAIR_ERR_INVALID_ARG,
			ECLAIR_ERR_BACKEND_FAILED
		} eclair_error;

		typedef enum {
			ECLAIR_ROUTE_OFF,
			ECLAIR_ROUTE_SCREEN_READER_ONLY,
			ECLAIR_ROUTE_PREFER_SCREEN_READER,
			ECLAIR_ROUTE_SYNTHESIZER_ONLY
		} eclair_route;

		typedef enum {
			ECLAIR_OUTPUT_NONE,
			ECLAIR_OUTPUT_SCREEN_READER,
			ECLAIR_OUTPUT_SYNTHESIZER
		} eclair_output;

		eclair_error eclair_init(void);
		void eclair_shutdown(void);
		eclair_error eclair_speak(const char *utf8, bool interrupt);
		eclair_error eclair_stop(void);
		void eclair_set_route(eclair_route route);
		void eclair_set_rate(float rate);
		void eclair_set_volume(float volume);
		eclair_output eclair_current_output(void);
		const char *eclair_backend_name(void);
		const char *eclair_error_string(eclair_error err);
	]]

	local os_name = love.system.getOS()
	local base = love.filesystem.getSourceBaseDirectory()

	-- How eclair is linked differs per platform:
	--   * Desktop ships it as a shared library, either in an eclair/ folder next
	--     to the executable (matching the layout used when running the .love) or
	--     directly beside it — both are tried so the packaging layout can't
	--     silently break TTS. The bare name goes last so a system-wide copy never
	--     shadows the one we shipped.
	--   * Android loads libeclair.so by name (already loaded via System.loadLibrary
	--     in Eclair.java).
	--   * iOS compiles it into liblove.a, linked into the app binary, so symbols
	--     resolve from the main program (ffi.C) rather than a separate library.
	local candidates = ({
		["OS X"]  = { base .. "/eclair/libeclair.dylib", base .. "/libeclair.dylib" },
		Windows   = { base .. "\\eclair\\eclair.dll", base .. "\\eclair.dll", "eclair" },
		Linux     = { base .. "/eclair/libeclair.so", base .. "/libeclair.so" },
		Android   = { "eclair" },
	})[os_name]

	local errors = {}

	if candidates then
		for _, libname in ipairs(candidates) do
			local ok, lib_or_err = pcall(ffi.load, libname)
			if ok then
				eclair_lib = lib_or_err
				break
			end
			errors[#errors + 1] = tostring(lib_or_err)
		end
	else
		-- iOS: confirm the statically-linked symbol resolves, then use ffi.C.
		local ok, err = pcall(function() local _ = ffi.C.eclair_init end)
		if ok then
			eclair_lib = ffi.C
		else
			errors[#errors + 1] = tostring(err)
		end
	end

	if not eclair_lib then
		print("eclair load failed: " .. table.concat(errors, "; "))
	end

	if eclair_lib then
		local err = eclair_lib.eclair_init()
		eclair_initialized = err == eclair_lib.ECLAIR_OK

		if eclair_initialized then
			-- NULL until a backend is available (Android's synthesizer starts asynchronously)
			local name = eclair_lib.eclair_backend_name()
			print("eclair backend: " .. (name ~= nil and ffi.string(name) or "none yet"))
		else
			print("eclair init failed: " .. ffi.string(eclair_lib.eclair_error_string(err)))
		end
	end
end

function speak(text)
	-- interact with screen reader
	if not isWeb then
		if eclair_lib and eclair_initialized then
			eclair_lib.eclair_speak(text, true)
		else
			print("ECLAIR NOT INITIALIZED")
		end
	end

	print("tts: " .. text)
end

function disableTTS()
	-- keep the screen reader, but never fall back to the synthesizer
	if eclair_lib and eclair_initialized then
		eclair_lib.eclair_set_route(eclair_lib.ECLAIR_ROUTE_SCREEN_READER_ONLY)
	end

	-- send console log to tell template to disable TTS
	print('DISABLE_TTS')
end

function enableTTS()
	-- use the screen reader when one is running, otherwise the synthesizer
	if eclair_lib and eclair_initialized then
		eclair_lib.eclair_set_route(eclair_lib.ECLAIR_ROUTE_PREFER_SCREEN_READER)
	end

	-- send console log to tell template to enable TTS
	print('ENABLE_TTS')
end
