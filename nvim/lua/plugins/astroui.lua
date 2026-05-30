---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    colorscheme = "astrodark",
    highlights = {
      -- STR palette applied over astrodark
      init = {
        -- Base
        Normal          = { bg = "#0e0f11", fg = "#d6d8dc" },
        NormalFloat     = { bg = "#1c1e21", fg = "#d6d8dc" },
        NormalNC        = { bg = "#0e0f11" },
        CursorLine      = { bg = "#1c1e21" },
        CursorLineNr    = { fg = "#2980d4", bold = true },
        LineNr          = { fg = "#4f5258" },
        SignColumn      = { bg = "#0e0f11" },
        ColorColumn     = { bg = "#1c1e21" },
        Visual          = { bg = "#252830" },
        Search          = { bg = "#2980d4", fg = "#0e0f11" },
        IncSearch       = { bg = "#2980d4", fg = "#0e0f11" },

        -- Borders / separators
        WinSeparator    = { fg = "#1c1e21" },
        FloatBorder     = { fg = "#4f5258", bg = "#1c1e21" },

        -- Syntax
        Comment         = { fg = "#4f5258", italic = true },
        ["Function"]    = { fg = "#2980d4" },
        Keyword         = { fg = "#ffb8c6" },
        Statement       = { fg = "#ffb8c6" },
        Conditional     = { fg = "#ffb8c6" },
        Repeat          = { fg = "#ffb8c6" },
        Operator        = { fg = "#8a8d92" },
        String          = { fg = "#a6e3a1" },
        Number          = { fg = "#fab387" },
        Float           = { fg = "#fab387" },
        Boolean         = { fg = "#fab387" },
        Type            = { fg = "#f9e2af" },
        Identifier      = { fg = "#d6d8dc" },
        Special         = { fg = "#89dceb" },
        PreProc         = { fg = "#ffb8c6" },
        Constant        = { fg = "#fab387" },
        Error           = { fg = "#c0392b" },

        -- Statusline
        StatusLine      = { bg = "#1c1e21", fg = "#8a8d92" },
        StatusLineNC    = { bg = "#1c1e21", fg = "#4f5258" },

        -- Completion menu
        Pmenu           = { bg = "#1c1e21", fg = "#d6d8dc" },
        PmenuSel        = { bg = "#2980d4", fg = "#0e0f11" },
        PmenuSbar       = { bg = "#252830" },
        PmenuThumb      = { bg = "#2980d4" },

        -- Diagnostics
        DiagnosticError = { fg = "#c0392b" },
        DiagnosticWarn  = { fg = "#f9e2af" },
        DiagnosticInfo  = { fg = "#2980d4" },
        DiagnosticHint  = { fg = "#8a8d92" },

        -- Tabs / bufferline
        TabLine         = { bg = "#1c1e21", fg = "#4f5258" },
        TabLineSel      = { bg = "#0e0f11", fg = "#d6d8dc" },
        TabLineFill     = { bg = "#1c1e21" },
      },
    },
    icons = {
      LSPLoading1 = "⠋", LSPLoading2 = "⠙", LSPLoading3 = "⠹",
      LSPLoading4 = "⠸", LSPLoading5 = "⠼", LSPLoading6 = "⠴",
      LSPLoading7 = "⠦", LSPLoading8 = "⠧", LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
}
