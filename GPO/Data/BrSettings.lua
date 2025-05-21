return {
    Enabled = true,

    Chest = {
        Enabled = true,
        TextSize = 14,
        OutlineEnabled = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        MaxDistance = 200,

        RarityFilter = {
            Common = false,
            Uncommon = false,
            Rare = true,
            Legendary = true,
            Mythic = true,
        },

        Colors = {
            Common = Color3.fromRGB(150, 150, 150),
            Uncommon = Color3.fromRGB(0, 255, 0),
            Rare = Color3.fromRGB(0, 120, 255),
            Legendary = Color3.fromRGB(255, 215, 0),
            Mythic = Color3.fromRGB(255, 0, 0),
            Default = Color3.fromRGB(255, 255, 255)
        },

        ShowDistance = true,
        DisplayFormat = "%s\n%dm"
    },

    Item = {
        Enabled = true,
        TextSize = 16,
        OutlineEnabled = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        MaxDistance = 800,

        RarityFilter = {
            Common = false,
            Uncommon = false,
            Rare = true,
            Legendary = true,
            Mythic = true,
            Collectable = true,
            Unknown = true
        },

        Colors = {
            Common = Color3.fromRGB(200, 200, 200),
            Uncommon = Color3.fromRGB(100, 255, 100),
            Rare = Color3.fromRGB(100, 180, 255),
            Legendary = Color3.fromRGB(255, 235, 100),
            Mythic = Color3.fromRGB(255, 100, 100),
            Collectable = Color3.fromRGB(255, 100, 255),
            Unknown = Color3.fromRGB(100, 255, 255),
            Default = Color3.fromRGB(255, 255, 255)
        },

        ShowDistance = true,
        ShowRarity = true,
        DisplayFormat = "%s [%s]\n%dm"
    },

    ScanRefreshRate = 1.0,
    Debug = false
}
