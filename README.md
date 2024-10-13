# Dart

Dart is a Neovim plugin designed to create an alternative to marks that allows you to navigate within files in a manner similar to how you navigate files themselves with ThePrimeagen's [Harpoon](https://github.com/ThePrimeagen/harpoon/tree/harpoon2).

I liked the idea of marks, but I didn't like the mental overhead of trying to think of which button to put the mark on as I placed it, and keeping track of where all the marks were in the file.

So instead, I set this up so that when I add a mark, it's simply appended to an array. Then I can setup hotkeys to select indexes, or go to the next or previous index and so on.

## Installation
Installation depends on your chosen package manager. Below is an example for Lazy.

Lazy:
```lua
return {
    "nssteinbrenner/dart",
    branch = "master",
    dependencies = {
        { "nvim-lua/plenary.nvim" },
    },

    config = function()
        -- .setup() is required.
        -- Can be specified with config. Otherwise uses defaults
        local dart = require("dart").setup()
    end,
}
```

## Configuration

Setup keybinds as part of your installation:

```lua
local dart = require("dart").setup()

-- Add to the array of locations
vim.keymap.set("n", "<A-a>", function() dart:list():add() end)
-- Open the UI to manage locations
vim.keymap.set("n", "<A-e>", function() dart.ui:toggle_quick_menu(dart:list()) end)

-- Select Indexes 1-4
vim.keymap.set("n", "<A-h>", function() dart:list():select(1) end)
vim.keymap.set("n", "<A-t>", function() dart:list():select(2) end)
vim.keymap.set("n", "<A-n>", function() dart:list():select(3) end)
vim.keymap.set("n", "<A-s>", function() dart:list():select(4) end)

-- Move to the previous or next index
vim.keymap.set("n", "<A-S-P>", function() dart:list():prev() end)
vim.keymap.set("n", "<A-S-N>", function() dart:list():next() end)
```

Configuration can be passed to the setup function. It is deep merged with the defaults.
See config.lua for the defaults.
For example:
```lua
local dart = require("dart").setup({
    list = {
        max_darts = 69,
    }
)
```

If you dislike how the darts are formatted in the UI, you are able to edit them by supplying custom functions to the configuration.
By default, they are formatted as <Index>: <Row>, <Col>.
The only requirement is that it includes the row and column number, and that those are correctly parsed by the regex_format string so that `local row_num, col_num = line:match(self.config.regex_format)` correctly assigns the row and column number.
Defaults:
```lua
data = {
    -- Current directory name by default.
    -- Hashed to create config filename corresponding to this directory in data dir.
    dir = function()
        return vim.loop.cwd()
    end,

    -- Alternative to use instead of Neovim's data dir.
    base_path = nil,
},
list = {
    -- Maximum number of elements in list.
    -- At max_darts num of elements, index will loop to 1 and overwrite from the start.
    max_darts = 20,

    -- Execute zz on jump to center cursor
    center_cursor_on_jump = true,
},
ui = {
     -- Needs to match the format of the darts in the quick menu
     regex_format = "%d+:%s*(%d+),%s*(%d+)",

     -- Used to determine the format of the darts in the quick menu
     -- Default is: <Index>: <Row>, <Col>
     ---@return string[]
     ---@param list DartList
     format_darts = function(list)
         local contents = {}
         for i = 1, #list.items do
             local entry = (
                 tostring(i) .. ": " .. tostring(list.items[i][1]) .. ", " .. tostring(list.items[i][2])
             )
             table.insert(contents, entry)
         end
         return contents
     end,
}
```

## Usage
You will need to setup your preferred keybinds in order to work with this plugin. See my personal configuration above in the configuration section.

Using the previous example in the configuration section, now you can add wherever your cursor currently is to the array of darts with `Alt-a`.

You can use `Alt-e` to open the UI and edit the darts using normal vim commands like `dd` and `:wq` and so on.

You can use `Alt` with `h`, `t` `n` and `s` to jump to the locations saved in indexes 1, 2, 3 and 4 respectively.

You can use `Alt-Shift-P` you cycle to the previous index and `Alt-Shift-N` to cycle to the next index.

By default, there's a limit of 20 darts maximum. If you go over, it will loop to index 1 and start over again, overwriting them from the beginning of the array.

You can change this with max_darts in the configuration.
