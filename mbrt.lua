local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ** เพิ่ม: ชื่อไฟล์สำหรับบันทึกคีย์ **
local KEY_FILENAME = "poseidon_scriptz_key.txt" 

-- 1. ตารางสำหรับกำหนด PlaceID และ Loadstring ของสคริปต์
local GameScripts = {
    [71360925634781] = 'loadstring(game:HttpGet("https://cdn.authguard.org/virtual-file/ec37cd7620194ec19f4342d6837931b2"))()',
}

-- 2. Global Variables
_G.key = "" 
_G.checked_key = false

-- ******************************************************
-- *** ฟังก์ชันหลักในการตรวจสอบคีย์และโหลดสคริปต์ ***
-- ******************************************************
local function verify_and_load_script(input_key, show_notifications)
    -- ตรวจสอบว่าคีย์เคยถูกตรวจสอบแล้วหรือไม่ (ป้องกันการตรวจสอบซ้ำ)
    if _G.checked_key == true then
        if show_notifications then
            Rayfield:Notify({Title = "Verification Skipped", Content = "Key is already verified.", Duration = 3,})
        end
        return true
    end
    
    if input_key == "" or not input_key then
        return false -- ไม่มีคีย์ให้ตรวจสอบ
    end
    
    local key_status_raw = game:HttpGet("https://work.ink/_api/v2/token/isValid/" .. input_key)
    
    local is_valid = string.find(key_status_raw, "\"valid\":true", 1, true)
    
    if not is_valid then
        if show_notifications then
            Rayfield:Notify({
                Title = "Verification Failed",
                Content = "Key Incorrect. API Response: " .. key_status_raw,
                Duration = 5,
            })
        end
        -- ลบคีย์ที่บันทึกไว้ถ้าการตรวจสอบล้มเหลว
        pcall(function()
            if isfile and isfile(KEY_FILENAME) and delfile then
                delfile(KEY_FILENAME)
            end
        end)
        return false
    end
    
    -- ** คีย์ถูกต้อง: ดำเนินการโหลดสคริปต์ **
    
    -- บันทึกคีย์ลงในไฟล์
    pcall(function()
        if writefile then
            writefile(KEY_FILENAME, input_key)
        end
    end)
    
    local current_place_id = game.PlaceId
    local script_to_load = GameScripts[current_place_id]

    if script_to_load then
        _G.checked_key = true 
        if show_notifications then
            Rayfield:Notify({Title = "Key Accepted!", Content = "Loading script... Please wait.", Duration = 3,})
        end
        print("Key Verified Successfully!")
        
        local script_code = loadstring(script_to_load)

        if script_code then
            script_code() 
            if show_notifications then
                Rayfield:Notify({Title = "Success!", Content = "Script Loaded Successfully.", Duration = 4,})
            end
        else
            if show_notifications then
                Rayfield:Notify({Title = "Script Load Failed", Content = "There was an error while loading the script.", Duration = 5,})
            end
        end
        return true -- โหลดสำเร็จ
    else
        if show_notifications then
            Rayfield:Notify({
                Title = "Game Mismatch",
                Content = "Unsupported Game: PlaceID " .. game.PlaceId,
                Duration = 5,
            })
        end
        return false -- คีย์ถูกต้องแต่เกมไม่ตรง
    end
end
-- ******************************************************
-- *** สิ้นสุด: ฟังก์ชันหลักในการตรวจสอบคีย์ ***
-- ******************************************************


-- ******************************************************
-- *** ขั้นตอนที่ 1: ตรวจสอบคีย์ที่บันทึกไว้โดยอัตโนมัติ ***
-- ******************************************************
local saved_key
local key_file_exists = false

pcall(function()
    if isfile and isfile(KEY_FILENAME) then
        saved_key = readfile(KEY_FILENAME)
        key_file_exists = true
    end
end)

if key_file_exists and verify_and_load_script(saved_key, false) then
    -- ถ้ามีคีย์และตรวจสอบผ่านแบบ Headless (ไม่แสดงแจ้งเตือน)
    return -- จบการทำงานของสคริปต์ทันที
end


-- ******************************************************
-- *** ขั้นตอนที่ 2: ถ้าตรวจสอบอัตโนมัติล้มเหลว ให้สร้าง GUI ***
-- ******************************************************

-- กำหนดค่า _G.key ให้กับคีย์ที่โหลดมา (ถ้ามี) หรือสตริงว่าง
_G.key = saved_key or "" 

-- 3. สร้างหน้าต่าง (Window)
local Window = Rayfield:CreateWindow({
    Name = "PoseidonScriptz Key System", 
    Color = Color3.fromRGB(48, 48, 48), 
    Keybind = Enum.KeyCode.RightControl 
})

-- 4. สร้างแท็บ (Tab)
local Tab = Window:CreateTab("Key System") 

-- 5. สร้างส่วน (Section)
local Section = Tab:CreateSection("Key Verification")

-- 6. Label สำหรับแสดงสถานะคีย์
local KeyStatusLabel = Tab:CreateLabel("Key Status: " .. (_G.key == "" and "No Key" or _G.key), "key", Color3.fromRGB(200, 200, 200), false)

-- 8. Textbox สำหรับป้อนคีย์ (Key Input)
local KeyInput = Tab:CreateInput({
    Name = "Key Input",
    PlaceholderText = "Enter your key here",
    CurrentValue = _G.key, 
    Callback = function(text)
        _G.key = text
        KeyStatusLabel:Set("Key Status: " .. (_G.key == "" and "No Key" or _G.key))
    end,
})

-- 9. ปุ่มสำหรับคัดลอกลิงก์คีย์ (Copy Key Link)
local Copy = Tab:CreateButton({
    Name = "Copy Key Link",
    Callback = function()
        setclipboard("https://work.ink/28ei/PosiedonScriptz-key-system-1")
        Rayfield:Notify({
            Title = "Link Copied!",
            Content = "The key link has been copied to your clipboard.",
            Duration = 4,
            Image = 4483362458, 
        })
    end,
})

-- 10. ปุ่มสำหรับตรวจสอบคีย์ (Check Key Button)
local Check = Tab:CreateButton({
    Name = "Check Key",
    Callback = function()
        verify_and_load_script(_G.key, true) -- ใช้ฟังก์ชันหลักและแสดงแจ้งเตือน
    end,
})

local discordsection = Tab:CreateSection("PoseidonScriptz Discord")
local discordbutton = Tab:CreateButton({
    Name = "Join Discord",
    Callback = function()
        setclipboard("https://discord.gg/UkceA8DD")
        Rayfield:Notify({
            Title = "Discord Link Copied!",
            Content = "The Discord invite link has been copied to your clipboard.",
            Duration = 4,
            Image = 4483362458, 
        })
    end,
})
