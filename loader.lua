-- WIN.LOL - KeyAuth Verification System
-- App: SENTRY

local KeyAuthApp = {
    name = "SENTRY",
    ownerid = "e4NySEKHpw",
    secret = "dd304cd2551d4f8c8c08589c1517ccdb8bf0d0936c26b68f862febf10ab45bb2",
    version = "1.0"
}

-- URL del script principal (CAMBIAR ESTA URL)
local SCRIPT_URL = "https://raw.githubusercontent.com/samxx2205/winlol/refs/heads/main/winlol.lua"

-- URL de tu tienda Komerza (CAMBIAR ESTA URL)
local STORE_URL = "winlol.mykomerza.com"

-- ============================================
-- NO EDITAR DEBAJO DE ESTA LÍNEA
-- ============================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Verificar que la key existe
if not _G.script_key or _G.script_key == "" or _G.script_key == "KEY-AQUI" then
    LocalPlayer:Kick("❌ ERROR: No ingresaste tu licencia\n\n━━━━━━━━━━━━━━━━━━━━━━\n\n🛒 Compra una licencia en:\n" .. STORE_URL .. "\n\n💬 Soporte: discord.gg/TU-DISCORD\n\n━━━━━━━━━━━━━━━━━━━━━━")
    return
end

print("🔐 WIN.LOL - Verificando licencia...")
print("⏳ Por favor espera...")

-- Función para generar HWID
local function getHWID()
    local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    return hwid
end

-- Función para hacer request a KeyAuth
local function KeyAuthRequest(requestType, additionalData)
    additionalData = additionalData or {}
    
    local url = "https://keyauth.win/api/1.2/"
    local params = {
        type = requestType,
        name = KeyAuthApp.name,
        ownerid = KeyAuthApp.ownerid,
        ver = KeyAuthApp.version,
    }
    
    -- Agregar datos adicionales
    for k, v in pairs(additionalData) do
        params[k] = v
    end
    
    -- Construir URL con parámetros
    local queryString = ""
    for key, value in pairs(params) do
        if queryString ~= "" then
            queryString = queryString .. "&"
        end
        queryString = queryString .. key .. "=" .. HttpService:UrlEncode(tostring(value))
    end
    
    local fullUrl = url .. "?" .. queryString
    
    local success, response = pcall(function()
        return game:HttpGetAsync(fullUrl)
    end)
    
    if not success then
        return {success = false, message = "Error de conexión con el servidor"}
    end
    
    local decoded = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    
    if decoded then
        return HttpService:JSONDecode(response)
    else
        return {success = false, message = "Error al procesar respuesta del servidor"}
    end
end

-- Inicializar KeyAuth
local initResponse = KeyAuthRequest("init", {})

if not initResponse or not initResponse.success then
    LocalPlayer:Kick("❌ ERROR DE INICIALIZACIÓN\n\n━━━━━━━━━━━━━━━━━━━━━━\n\nNo se pudo conectar al servidor de licencias.\nIntenta de nuevo en unos momentos.\n\n💬 Soporte: discord.gg/TU-DISCORD\n\n━━━━━━━━━━━━━━━━━━━━━━")
    return
end

print("✓ Conectado al servidor de licencias")

-- Obtener session ID
local sessionid = initResponse.sessionid or ""

if sessionid == "" then
    LocalPlayer:Kick("❌ ERROR DE SESIÓN\n\n━━━━━━━━━━━━━━━━━━━━━━\n\nNo se pudo establecer una sesión.\nIntenta de nuevo.\n\n💬 Soporte: discord.gg/TU-DISCORD\n\n━━━━━━━━━━━━━━━━━━━━━━")
    return
end

-- Verificar la licencia
print("🔑 Verificando key: " .. string.sub(_G.script_key, 1, 8) .. "...")

local hwid = getHWID()
local licenseResponse = KeyAuthRequest("license", {
    key = _G.script_key,
    sessionid = sessionid,
    hwid = hwid
})

-- Verificar respuesta
if licenseResponse and licenseResponse.success then
    print("━━━━━━━━━━━━━━━━━━━━━━")
    print("✅ LICENCIA VÁLIDA")
    print("━━━━━━━━━━━━━━━━━━━━━━")
    
    if licenseResponse.info then
        if licenseResponse.info.username then
            print("👤 Usuario: " .. licenseResponse.info.username)
        end
        if licenseResponse.info.expiry then
            print("⏰ Expira: " .. licenseResponse.info.expiry)
        end
        if licenseResponse.info.subscription then
            print("📦 Plan: " .. licenseResponse.info.subscription)
        end
    end
    
    print("━━━━━━━━━━━━━━━━━━━━━━")
    print("🚀 Cargando WIN.LOL...")
    print("━━━━━━━━━━━━━━━━━━━━━━")
    
    -- Esperar un momento para que el usuario vea el mensaje
    task.wait(1)
    
    -- Cargar el script principal
    local success, error = pcall(function()
        loadstring(game:HttpGet(SCRIPT_URL))()
    end)
    
    if not success then
        LocalPlayer:Kick("❌ ERROR AL CARGAR SCRIPT\n\n━━━━━━━━━━━━━━━━━━━━━━\n\nNo se pudo cargar el script principal.\nContacta con soporte.\n\nError: " .. tostring(error) .. "\n\n💬 Soporte: discord.gg/TU-DISCORD\n\n━━━━━━━━━━━━━━━━━━━━━━")
    end
else
    local errorMsg = "Licencia inválida o expirada"
    
    if licenseResponse and licenseResponse.message then
        errorMsg = licenseResponse.message
    end
    
    LocalPlayer:Kick("❌ LICENCIA INVÁLIDA\n\n━━━━━━━━━━━━━━━━━━━━━━\n\n" .. errorMsg .. "\n\n🛒 Compra/Renueva tu licencia en:\n" .. STORE_URL .. "\n\n💬 Soporte: discord.gg/TU-DISCORD\n\n━━━━━━━━━━━━━━━━━━━━━━")
end