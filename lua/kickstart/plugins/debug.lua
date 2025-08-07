return {
  'mfussenegger/nvim-dap',
  lazy = false,

  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
  },

  config = function()
    ---------------------------------------------------------------------------
    -- Key-maps
    ---------------------------------------------------------------------------
    local dap, dapui = require 'dap', require 'dapui'
    local map = function(lhs, fn, desc)
      vim.keymap.set('n', lhs, fn, { desc = desc, silent = true })
    end

    map('<F5>', function()
      dap.continue()
    end, 'DAP: Start/Continue')
    map('<F1>', function()
      dap.step_into()
    end, 'DAP: Step Into')
    map('<F2>', function()
      dap.step_over()
    end, 'DAP: Step Over')
    map('<F3>', function()
      dap.step_out()
    end, 'DAP: Step Out')
    map('<leader>b', function()
      dap.toggle_breakpoint()
    end, 'DAP: Toggle BP')
    map('<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, 'DAP: Conditional BP')
    map('<F7>', function()
      dapui.toggle()
    end, 'DAP-UI: Toggle')
    map('<F8>', function()
      require('dap').up()
    end, 'DAP: Frame ↑ (older)')
    map('<F9>', function()
      require('dap').down()
    end, 'DAP: Frame ↓ (newer)')
    ---------------------------------------------------------------------------
    -- Mason – auto-install the C/C++ adapter
    ---------------------------------------------------------------------------
    require('mason-nvim-dap').setup {
      ensure_installed = { 'cpptools' },
      automatic_installation = true,
    }

    ---------------------------------------------------------------------------
    -- DAP-UI
    ---------------------------------------------------------------------------
    dapui.setup()
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end

    ---------------------------------------------------------------------------
    -- C / C++ – cppdbg adapter (GDB)
    ---------------------------------------------------------------------------
    local adapter_path = vim.fn.stdpath 'data' .. '/mason/bin/OpenDebugAD7'

    dap.adapters.cppdbg = {
      id = 'cppdbg',
      type = 'executable',
      command = adapter_path,
    }

    local cfg = {
      name = 'Launch file',
      type = 'cppdbg',
      request = 'launch',

      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,

      cwd = '${workspaceFolder}',
      stopAtEntry = false,
      MIMode = 'gdb',
      miDebuggerPath = vim.fn.executable 'gdb' == 1 and 'gdb' or '/usr/bin/gdb',
      setupCommands = {
        { text = '-enable-pretty-printing', ignoreFailures = false },
      },
      console = 'integratedTerminal',
    }

    dap.configurations.cpp = { cfg }
    dap.configurations.c = dap.configurations.cpp
  end,
}
