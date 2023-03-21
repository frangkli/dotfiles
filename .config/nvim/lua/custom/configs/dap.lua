local dap = require "dap"
require("dapui").setup()
local nvim_dap = require("mason-nvim-dap")

nvim_dap.setup({
  automatic_setup = true,
})

nvim_dap.setup_handlers {
  lldb = function(_)
    dap.adapters.cpp = {
      type = "executable",
      command = "/home/frank/.local/share/nvim/mason/bin/codelldb"
    }
    dap.configurations.cpp = {
      {
        name = "Launch",
        type = "lldb",
        request = "launch",
        program = os.getenv("HOME") .. "/.local/share/nvim/mason/bin/codelldb",
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {},
      }
    }
  end
}
