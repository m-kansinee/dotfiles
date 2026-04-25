-- Custom keymaps
-- LazyVim provides defaults; add/override here

local map = vim.keymap.set

-- Buffer navigation
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Focus Left" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus Down" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus Up" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus Right" })

-- Window resize
map("n", "<C-Left>", "<C-w><", { desc = "Resize Wider" })
map("n", "<C-Right>", "<C-w>>", { desc = "Resize Narrower" })
map("n", "<C-Up>", "<C-w>+", { desc = "Resize Taller" })
map("n", "<C-Down>", "<C-w>-", { desc = "Resize Shorter" })

-- Telescope (LazyVim has these, but ensuring they work)
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help Tags" })
