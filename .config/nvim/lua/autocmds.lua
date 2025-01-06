local autocmd = vim.api.nvim_create_autocmd

autocmd({ "VimEnter" }, {
  callback = function (data)
    -- require("nvim-tree.api").tree.open()
    -- buffer is a real file on the disk
    local real_file = vim.fn.filereadable(data.file) == 1

    -- buffer is a [No Name]
    local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

    if not real_file and not no_name then
      return
    end

    -- open the tree, find the file but don't focus it
    require("nvim-tree.api").tree.toggle({ focus = false, find_file = true, })
  end
})
