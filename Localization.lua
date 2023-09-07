local System = require("System")
local Localization = {}
local args = {...}
local OE = args[1]

function Localization.getLocalization(LocalizationName)
    return Localization.getSceneLocalizationString(LocalizationName) or Localization.getProjectLocalizationString(LocalizationName) or "$" .. LocalizationName
end
function Localization.getCurrentSceneLocalization()
    return OE.CurrentScene.Localization[System.getUserSettings().localizationLanguage]
end
function Localization.getSceneLocalizationString(tblValue)
    return OE.CurrentScene.Localization[System.getUserSettings().localizationLanguage][tblValue]
end
function Localization.getProjectLocalizationString(tblValue)
    return OE.Project.Localization[System.getUserSettings().localizationLanguage][tblValue]
end
function Localization.getProjectLocalization()
    return OE.Project.Localization[System.getUserSettings().localizationLanguage]
end

return Localization