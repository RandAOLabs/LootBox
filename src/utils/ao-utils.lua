--- Helper function to send a response
local function sendResponse(target, action, data)
    return {
        Target = target,
        Action = action,
        Data = json.encode(data)
    }
end

--- Helper function to send an error message
local function sendError(target, message)
    ao.send(sendResponse(target, "Error", {
        message = message
    }))
end

--- Helper function to wrap handlers to catch errors before computation
local function wrapHandler(handlerFn)
    return function(msg)
        local success = xpcall(
            function()
                return handlerFn(msg)
            end,
            errorHandler
        )
        if not success then
            if msg.Sender == nil then
                ao.send(sendResponse(msg.From, "Error", {
                    message = "An unexpected error occurred. Please try again later."
                }))
            else
                ao.send(sendResponse(msg.Sender, "Error", {
                    message = "An unexpected error occurred. Please try again later."
                }))
            end
        end
    end
end

return {
    wrapHandler = wrapHandler,
    sendResponse = sendResponse,
    sendError = sendError
}
