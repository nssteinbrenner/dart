# Dart

Dart is a Neovim plugin designed to create an alternative to buffer local marks similar to what it's like to interact files using ThePrimeagen's [Harpoon](https://github.com/ThePrimeagen/harpoon/tree/harpoon2).

I thought marks were a good idea, but I didn't like the mental overhead of trying to think of which button to put the mark on as I placed it, and keeping track of where all the marks were in the file.

So instead, I set this up so that when I add a mark, it's simply appended to an array. Then I can setup hotkeys to select indexes, or go to the next or previous index and so on.

## Installation

I use Lazy as the package manager. Here is my setup:
```lua
return {
    "nssteinbrenner/dart",
    branch = "master",

    config = function()
        local dart = require("dart")

        -- Add a dart
        vim.keymap.set("n", "<A-a>", function() dart:list():add() end)
        -- Open the UI menu listing all darts
        vim.keymap.set("n", "<A-e>", function() dart.ui:toggle_quick_menu(dart:list()) end)

        -- Jump to indexes 1-4
        vim.keymap.set("n", "<A-h>", function() dart:list():select(1) end)
        vim.keymap.set("n", "<A-t>", function() dart:list():select(2) end)
        vim.keymap.set("n", "<A-n>", function() dart:list():select(3) end)
        vim.keymap.set("n", "<A-s>", function() dart:list():select(4) end)

        -- Jump to the previous and next indexes in the dart list
        vim.keymap.set("n", "<A-S-P>", function() dart:list():prev() end)
        vim.keymap.set("n", "<A-S-N>", function() dart:list():next() end)
    end,
}
```
