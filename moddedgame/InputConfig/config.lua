--all numbers are for 1920/1080 screen
--for example if you have 4k display, 860/540 is still a middle of the screen
--0/0 is top left
--key'number' override default
--
return {
    scrollSpeed = {
        default = {
            type = "osu",
            --type = "ss",
            speed = "27",
        },
        key4 = {
            type = "osu",
            speed = "27",
        },
        key8 = {
            type = "osu",
            speed = "12",
        },
    },

    columnWidth = {
        default = 60,
        --key4 = {140, 100, 100, 140}
        key4 = 120,
        key5 = 120,
        key6 = 100,
        key7 = 90,
        key8 = 80,
    },

    color = {
        --red green blue transparency, from 0 to 1
        default = { 0.071, 0.788, 0.357, 0.5 },
        key8 = {
            { 0.071, 0.271, 0.788, 0.4 },
            { 0.071, 0.573, 0.788, 0.4 },
            { 0.071, 0.788, 0.659, 0.4 },
            { 0.071, 0.788, 0.357, 0.4 },
            { 0.071, 0.788, 0.357, 0.4 },
            { 0.071, 0.788, 0.659, 0.4 },
            { 0.071, 0.573, 0.788, 0.4 },
            { 0.071, 0.271, 0.788, 0.4 },
        }
    },

    scrollDir = "upscroll", --downscroll

    posX = {                --horizontally, position of the left side of the column
        --inline will go from left to right applying width
        default = { "inline", 0 },
        key4 = { "inline", 0 },
        -- split to left and right
        key8 = { 0, 80, 80 * 2, 80 * 3, 1920 - 80 * 4, 1920 - 80 * 3, 1920 - 80 * 2, 1920 - 80 },
        key10 = { 0, 60, 60 * 2, 60 * 3, 60 * 4, 1920 - 60 * 5, 1920 - 60 * 4, 1920 - 60 * 3, 1920 - 60 * 2, 1920 - 60 },
    },

    startPosY = { --vertically
        default = 100, --100%, bottom
        key4 = 100,
        key8 = 96,
        -- key4 = {0, 0, 0, 0,}
    },

    endPosY = { --limit of the displayed columns
        default = 50, --0%, top
        key4 = 0,
        key8 = 70,

        -- key4 = {0, 0, 0, 0,}
    },
}
