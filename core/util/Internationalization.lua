local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local insert = table.insert
local unpack = table.unpack or unpack

---语言文本记录表
---@type table<string, table<string, string>>
local langData = {}

---语言文本格式化记录表
---@type table<string, table<string, table<number, string>>
local langFormatData = {}

---默认语言排序队列，按顺序查找
---@type table<number, string>
local default = {}

---当前使用的语言
local current = ""

---@class lstg.Internationalization : plus.Class @i18n
---@return lstg.Internationalization
local lib = {}

---```
---设置默认语言
---未找到目标语言的目标文本时会以此队列按顺序查找
---```
---@param lang string
function lib:SetDefaultLanguage(lang, ...)
    default = { lang, ... }
end

---设置当前使用的语言
---@param lang string
function lib:SetLanguage(lang)
    current = lang
end

---获取当前使用的语言
---@return string
function lib:GetLanguage()
    return current
end

---插入语言文本
---@param key string @语言文本标识
---@param lang string @目标语言
---@param text string @文本内容
function lib:SetLanguageString(key, lang, text)
    langData[key] = langData[key] or {}
    langData[key][lang] = text
end

---获取语言文本
---@param key string @语言文本标识
---@param lang string @目标语言
---@return string
---@overload fun(key:string):string
function lib:GetLanguageString(key, lang)
    local data = langData[key]
    if data then
        lang = lang or self:GetLanguage()
        if data[lang] then
            return data[lang]
        else
            for _, l in ipairs(default) do
                if data[l] then
                    return data[l]
                end
            end
        end
    end
    return ""
end

---```
---设置语言文本参数格式化顺序
---在读取格式化文本时会自动取对应的参数按顺序进行format
---```
function lib:SetLanguageStringFormat(key, lang, ...)
    langFormatData[key] = langFormatData[key] or {}
    langFormatData[key][lang] = { ... }
end

---获取语言文本
---@param key string @语言文本标识
---@param data table<string, boolean|number|string> @语言文本标识
---@param lang string @目标语言
---@return string
---@overload fun(key:string, data:table<string, boolean|number|string>):string
function lib:GetLanguageFormatString(key, data, lang)
    lang = lang or self:GetLanguage()
    local str = self:GetLanguageString(key, lang)
    local param = {}
    for _, p in ipairs(langFormatData[key] and langFormatData[key][lang] or {}) do
        insert(param, tostring(data[p]))
    end
    return str:format(unpack(param))
end

---从文件中读取语言定义
---@param data lstg.Internationalization.LoadData @语言数据
function lib:LoadFromData(data)
    assert(data.id, "Language data must have its language id")
    if data.data then
        for k, v in pairs(data.data) do
            self:SetLanguageString(k, data.id, v)
        end
    end
    if data.format then
        for k, v in pairs(data.format) do
            self:SetLanguageString(k, data.id, v)
        end
    end
end

---@class lstg.Internationalization.LoadData
local languageLoadData = {
    ---语言
    id = "",
    ---语言文本
    ---@type table<string, table<string, string>>
    data = {},
    ---语言格式
    ---@type table<string, table<string, table<number, string>>
    format = {}
}

lib:LoadFromData({
    id = "eng",
    data = {
        ["LanguageName"] = "English",
    }
})

return lib