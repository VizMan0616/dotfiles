return function(_, opts)
  opts.git = { enable = true, ignore = false }
  opts.filters = { dotfiles = false }
end
