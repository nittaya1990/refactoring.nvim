local utils = require("refactoring.utils")

---@type {region:RefactorRegion, text:string}[]
local changes = {}

---@param region RefactorRegion
---@param text string
local function add_change(region, text)
    table.insert(changes, { region = region, text = text })
end

local function reset()
    changes = {}
end

---@param cursor RefactorPoint
---@return integer
local function get_rows(cursor)
    local add_rows = 0
    for _, edit in pairs(changes) do
        local region = edit.region
        local text = edit.text

        local text_length = #utils.split_string(text, "\n")
        local row_diff = region.end_row - region.start_row

        if region.start_row == region.end_row and text_length > 0 then
            row_diff = row_diff + 1
        end

        if region.start_row < cursor.row then
            local length = text_length - row_diff
            add_rows = add_rows + length
        end
    end
    return add_rows
end

-- cursor is the original cursor before the refactor
---@param refactor Refactor
local function adjust_cursor(refactor)
    local ns = refactor.config:get()._preview_namespace
    if ns then
        reset()
        return true, refactor
    end

    local win = refactor.win
    local cursor = refactor.cursor
    local add_rows = get_rows(cursor)
    local result_row = cursor.row + add_rows

    local col = cursor.col
    if refactor.cursor_col_adjustment ~= nil then
        col = col + refactor.cursor_col_adjustment
    end
    vim.schedule(function()
        vim.api.nvim_set_current_win(win)
        vim.api.nvim_win_set_cursor(win, {
            result_row,
            col,
        })
    end)
    reset()

    return true, refactor
end

return {
    adjust_cursor = adjust_cursor,
    reset = reset,
    add_change = add_change,
}
