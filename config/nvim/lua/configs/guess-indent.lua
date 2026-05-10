return function ()
  require('guess-indent').setup {
    filetype_exclude = {  -- A list of filetypes for which the auto command gets disabled
      "netrw",
      "tutor",
    },
    buftype_exclude = {  -- A list of buffer types for which the auto command gets disabled
      "help",
      "nofile",
      "terminal",
      "prompt",
    },
  }
end
