-- Example usage of the improved Key System

-- Load the KeySystem module
local KeySystem = loadstring(game:HttpGet("https://production--skider.netlify.app/Loader/KeySystem/Source/Library.lua"))()

-- Create a new KeySystem with custom configuration
local myKeySystem = KeySystem.new({
    title = "VIP Hub Access",
    
    -- Custom key validation function
    validateKeyCallback = function(key)
        -- Example key validation logic
        if key == "TEST123" then
            return true, "Key validated successfully!"
        elseif string.len(key) < 5 then
            return false, "Key is too short!"
        else
            -- You could implement API checks here
            -- Example: Check key against a remote database
            
            -- Simulate API request with wait
            wait(1)
            
            -- For demonstration, let's check if key contains "VIP"
            if string.find(key:upper(), "VIP") then
                return true, "Premium access granted!"
            end
            
            return false, "Invalid key!"
        end
    end,
    
    -- Success callback function
    onSuccess = function(key)
        -- What happens when key is valid
        log.console("Access", "Loading VIP features...", "INFO")
        wait(1)
        log.console("Access", "VIP features enabled!", "SUCCESS")
        
        -- Here you would load your actual script functionality
        -- Example: loadstring(game:HttpGet("https://your-script-url.lua"))()
    end,
    
    -- Fail callback function
    onFail = function(key)
        -- What happens when key is invalid
        log.console("Security", "Invalid key attempt logged", "WARNING")
        
        -- Could add rate limiting here
    end,
    
    -- Exit callback function
    exitCallback = function()
        log.console("System", "Goodbye!", "INFO")
        -- Any cleanup code here
    end
})

-- You can also use the global log function anywhere in your code
log.console("Script", "Initialized successfully", "SUCCESS")

-- You can log different types of messages
log.console("Player", "Welcome " .. game.Players.LocalPlayer.Name, "INFO")
log.console("Server", "Connected to game " .. game.PlaceId, "SYSTEM")

-- Show an error example
pcall(function()
    -- Simulate an error
    error("This is a test error")
end)
log.console("Error", "Something went wrong", "ERROR")

-- Example of how to use the log in other scripts
-- Just make sure the KeySystem module is loaded first
local function someFunction()
    log.console("Function", "Processing data...", "INFO")
    -- Do some work
    log.console("Function", "Data processed!", "SUCCESS")
end

someFunction()

-- Yes i Used Ai For This Example
-- Yes I Am Too Lazy To Make My Own Example :lol:
