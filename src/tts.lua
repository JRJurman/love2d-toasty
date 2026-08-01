local isWeb = love.system.getOS() == "Web"

local sral_lib
local sral_initialized = false
local ffi

-- engine bit mask with nothing disabled
local EXCLUDE_NOTHING = 0

if not isWeb then
	ffi = require("ffi")

	ffi.cdef[[
		bool SRAL_Initialize(int engines_exclude);
		void SRAL_Uninitialize(void);
		bool SRAL_Speak(const char* text, bool interrupt);
		bool SRAL_StopSpeech(void);
		bool SRAL_IsSpeaking(void);
		const char* SRAL_GetEngineName(int engine);
		int SRAL_GetCurrentEngine(void);
		int SRAL_GetTTSEngines(void);
		bool SRAL_SetEnginesExclude(int engines_exclude);
	]]

	local os_name = love.system.getOS()
	local base = love.filesystem.getSourceBaseDirectory()

	-- How SRAL is linked differs per platform:
	--   * Desktop ships it as a shared library, either in a sral/ folder next to
	--     the executable (matching the layout used when running the .love) or
	--     directly beside it — both are tried so the packaging layout can't
	--     silently break TTS. The bare name goes last so a system-wide copy never
	--     shadows the one we shipped.
	--   * Android loads libSRAL.so by name (already loaded via System.loadLibrary).
	--   * iOS statically links it into the app binary, so symbols resolve from the
	--     main program (ffi.C) rather than a separate library.
	local candidates = ({
		["OS X"]  = { base .. "/sral/libSRAL.dylib", base .. "/libSRAL.dylib" },
		Windows   = { base .. "\\sral\\SRAL.dll", base .. "\\SRAL.dll", "SRAL" },
		Linux     = { base .. "/sral/libSRAL.so", base .. "/libSRAL.so" },
		Android   = { "SRAL" },
	})[os_name]

	local errors = {}

	if candidates then
		for _, libname in ipairs(candidates) do
			local ok, lib_or_err = pcall(ffi.load, libname)
			if ok then
				sral_lib = lib_or_err
				break
			end
			errors[#errors + 1] = tostring(lib_or_err)
		end
	else
		-- iOS: confirm the statically-linked symbol resolves, then use ffi.C.
		local ok, err = pcall(function() local _ = ffi.C.SRAL_Initialize end)
		if ok then
			sral_lib = ffi.C
		else
			errors[#errors + 1] = tostring(err)
		end
	end

	if not sral_lib then
		print("SRAL load failed: " .. table.concat(errors, "; "))
	end

	if sral_lib then
		sral_initialized = sral_lib.SRAL_Initialize(EXCLUDE_NOTHING)
		print("SRAL engine: " .. ffi.string(sral_lib.SRAL_GetEngineName(sral_lib.SRAL_GetCurrentEngine())))
	end
end

function speak(text)
	-- interact with screen reader
	if not isWeb then
		if sral_lib and sral_initialized then
			sral_lib.SRAL_Speak(text, true)
		else
			print("SRAL NOT INITIALIZED")
		end
	end

	print("tts: " .. text)
end

function disableTTS()
	-- exclude all TTS engines in SRAL
	if sral_lib and sral_initialized then
		sral_lib.SRAL_SetEnginesExclude(sral_lib.SRAL_GetTTSEngines())
	end

	-- send console log to tell template to disable TTS
	print('DISABLE_TTS')
end

function enableTTS()
	-- exclude all TTS engines in SRAL
	if sral_lib and sral_initialized then
		sral_lib.SRAL_SetEnginesExclude(0)
	end

	-- send console log to tell template to disable TTS
	print('ENABLE_TTS')
end
