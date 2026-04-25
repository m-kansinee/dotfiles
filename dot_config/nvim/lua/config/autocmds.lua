-- Autocommands

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

augroup("UserConfig", { clear = true })

-- Highlight on yank
autocmd("TextYankPost", {
  group = "UserConfig",
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- Resize splits if window got resized
autocmd("VimResized", {
  group = "UserConfig",
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Close some filetypes with <q>
autocmd("FileType", {
  group = "UserConfig",
  pattern = { "qf", "help", "man", "notify", "lspinfo", "spectre_panel", "startuptime" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Markdown: keep 2-space indent consistent with rest of config
autocmd("FileType", {
  group = "UserConfig",
  pattern = "markdown",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})
