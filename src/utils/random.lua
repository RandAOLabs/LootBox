-- Define the module as a function that takes parameters
local function RandomModule()
    -- Create a local table to hold module functions and data
    local self         = {}

    -- Use the provided parameters or default to an empty string
    self.PaymentToken  = "W3jdK85h1bFzZ7K_IXd0zLxq4RbpxPi0hvqUW6hAdUY"
    self.RandomCost    = "100"
    self.RandomProcess = "vgH7EXVs6-vxxilja6lkBruHlgOkyqddFVg-BVp3eJc"
    self.Providers     =
    "{\"provider_ids\":[\"XUo8jZtUDBFLtp5okR12oLrqIZ4ewNlTpqnqmriihJE\",\"c8Iq4yunDnsJWGSz_wYwQU--O9qeODKHiRdUkQkW2p8\"]}"

    -- Define a method to display the configuration (for demonstration)
    function self.showConfig()
        print("PaymentToken: " .. self.PaymentToken)
        print("RandomCost: " .. self.RandomCost)
        print("RandomProcess: " .. self.RandomProcess)
    end

    -- Method to set the configuration variables
    function self.setConfig(paymentToken, randomCost, randomProcess)
        self.PaymentToken = paymentToken
        self.RandomCost = randomCost
        self.RandomProcess = randomProcess
    end

    -- Method to ensure a process is the RandomProcess
    function self.isRandomProcess(processId)
        return processId == self.RandomProcess
    end

    -- Method to generate a unique callbackId
    function self.generateUUID()
        local random = math.random
        local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"

        return string.gsub(template, "[xy]", function(c)
            local v = (c == "x") and random(0, 15) or random(8, 11)
            return string.format("%x", v)
        end)
    end

    -- Method to send a random request through a token transfer
    function self.requestRandom(callbackId)
        local send = ao.send({
            Target = self.PaymentToken,
            Action = "Transfer",
            Recipient = self.RandomProcess,
            Quantity = self.RandomCost,
            ["X-Providers"] = self.Providers,
            ["X-CallbackId"] = callbackId
        })
        return send
    end

    -- Method to process Random ResponseData
    function self.processRandomResponse(from, data)
        assert(self.isRandomProcess(from), "Failure: message is not from RandomProcess")

        local callbackId = data["callbackId"]
        local entropy    = tonumber(data["entropy"])
        return callbackId, entropy
    end

    -- Method to check the status of a random request via callbackId
    function self.viewRandomStatus(callbackId)
        -- utilizies the receive functionality to await for a response to the query
        local results = ao.send({
            Target = self.RandomProcess,
            Action = "Get-Random-Request-Via-Callback-Id",
            Data = callbackId
        }).receive().Data
        print("Results: " .. tostring(results))
        return results
    end

    -- Return the table so the module can be used
    return self
end

-- Return the function itself as the module
return RandomModule
