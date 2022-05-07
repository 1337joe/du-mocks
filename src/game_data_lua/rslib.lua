--- The renderscript library is defined by a Lua file within your Dual Universe installation, view it at:
-- <code>...\Dual Universe\Game\data\lua\rslib.lua</code>
--
-- To use it, simply import it using:
--
-- <code>local rslib = require('rslib')</code>
--
-- then call methods as:
--
-- <code>rslib.drawQuickText("Hello World")</code>
--
-- @module game_data_lua.rslib

local rslib = { version = "1.1" }

--- Draw a full-screen image loaded from the given url.
-- @tparam string url The url to load the image from.
function rslib.drawQuickImage (url)
end

--- Draw a string of text with line breaks and word wrapping in the center of the screen. Options may contain any of
-- the following:
-- <ul>
--   <li><span class="parameter">textColor</span> (<span class="type">table</span>) Four-component RGBA table; e.g. red
--     is <code>{1, 0, 0, 1}</code>.</li>
--   <li><span class="parameter">bgColor</span> (<span class="type">table</span>) Three-component RGB table for
--     background color.</li>
--   <li><span class="parameter">fontName</span> (<span class="type">string</span>) Name of font (see render script
--     docs).</li>
--   <li><span class="parameter">fontSize</span> (<span class="type">int</span>) Size of font, in vertical pixels.</li>
--   <li><span class="parameter">lineSpacing</span> (<span class="type">float</span>) Spacing from one baseline to the
--     next.</li>
--   <li><span class="parameter">wrapWidth</span> (<span class="type">float</span>) Total width of the text region, as
--     a fraction of screen width.</li>
-- @tparam string text The text to display.
-- @tparam table options The options to use.
function rslib.drawQuickText (text, options)
end

--- Draw a small render cost profiler at the bottom-left of the screen to show the current render cost of the screen
-- versus the maximum allowed cost.
--
-- NOTE: displays render cost at the time of the function call, so you must call at the end of your script to see the
-- total cost!
function rslib.drawRenderCost ()
end

--- Break the given text into a table of strings such that each element takes no more than <code>maxWidth</code>
-- horizontal pixels when rendered with the given font.
-- @tparam int font The id of the font to use.
-- @tparam string text The text to split.
-- @tparam float maxWidth The max number of horizontal pixels before the string is split onto another line.
function rslib.getTextWrapped (font, text, maxWidth)
end

--- Draw a grid on the screen.
-- @tparam float size The size of the grid square.
-- @tparam float opacity The opacity of the grid lines [0..1].
function rslib.drawGrid (size, opacity)
end

--- Like Lua print, but uses @{renderScript.logMessage} to print to the in-game Lua chat window.
--
-- NOTE: Only visible if 'enable logging' is on for this screen!
-- @param ... The items to print.
function rslib.print (...)
end

--- Pretty print, like @{print}, except using @{toString} to see tables.
-- @param ... The items to print.
function rslib.pprint (...)
end

--- Like Lua tostring, but recursively stringifies tables.
-- @param x The item to print.
function rslib.toString (x)
end

return rslib
