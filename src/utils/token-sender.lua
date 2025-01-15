local tokenSender = {}

function tokenSender.sendTokens(token, recipient, quantity, note)
    ao.send({
        Target     = token,
        Action     = "Transfer",
        Recipient  = recipient,
        Quantity   = quantity,
        ["X-Note"] = note or "Sending tokens from Random Process"
    })
end

function tokenSender.returnTokens(msg, errMessage)
    tokenSender.sendTokens(msg.From, msg.Sender, msg.Quantity, errMessage)
end

return tokenSender
