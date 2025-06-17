local Utils = {}

Utils.Animation = require("utils.animation")
Utils.Game = require("utils.game")
Utils.Camera = require("utils.camera")
Utils.UIManager = require("utils.uiManager")

Utils.Functions = {
    randomWeighted = function (weights,items)
        if #weights ~= #items then
            error("Weights and items must have the same length")
        end

        local total_weight = 0
        for _, weight in pairs(weights) do
            total_weight = total_weight + weight
        end

        if total_weight <= 0 or total_weight ~= 1.0 then
            error("Weights must sum to 1.0")
        end
        
        -- if you create a list of items based on their weights
        -- you get a list of items where each item appears n-times
        -- where n is the weight of that item multiplied by 100
        -- this is a simple way to implement weighted random selection
        -- e.g.: if weights = {a=0.5, b=0.3, c=0.2} and items = {a, b, c}
        -- then the list will be with 50 'a's, 30 'b's and 20 'c's
        -- this is not the most efficient way to do it, but it is simple and works for small lists
        local list = {}
        for _, item in ipairs(items) do
            local n = weights[item] * 100
            for i = 1, n do 
                table.insert(list, item)
            end
        end
        return list[math.random(1, #list)]
    end
}

return Utils