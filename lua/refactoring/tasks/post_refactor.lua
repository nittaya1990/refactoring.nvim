local Pipeline = require("refactoring.pipeline")
local format = require("refactoring.tasks.format")
local adjust_cursor = require("refactoring.tasks.adjust_cursor").adjust_cursor
local apply_text_edits = require("refactoring.tasks.apply_text_edits")

local M = {}

---@param refactor Refactor
local function success_message(refactor)
    local config = refactor.config:get()
    if refactor.success_message and config.show_success_message then
        vim.notify(refactor.success_message, vim.log.levels.INFO)
    end
    return true, refactor
end

-- TODO: How to save/reformat??? no idea
M.post_refactor = function()
    return Pipeline:from_task(apply_text_edits)
        :add_task(format)
        :add_task(adjust_cursor)
        :add_task(success_message)
end

-- needed when another file is generated
M.no_cursor_post_refactor = function()
    return Pipeline:from_task(apply_text_edits)
        :add_task(format)
        :add_task(
            ---@param refactor Refactor
            ---@return boolean, Refactor
            function(refactor)
                vim.api.nvim_set_current_win(refactor.win)
                return true, refactor
            end
        )
        :add_task(success_message)
end

return M
