local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local CollectionService = game:GetService("CollectionService")
local player = Players.LocalPlayer

-- ==================== CONFIGURAÇÃO RÁPIDA ====================
-- true = mostra a aba "Caminho T" (use só para editar a rota; o auto farm usa a rota salva/padrão mesmo com a aba escondida)
local MOSTRAR_ABA_CAMINHO = false
local MOSTRAR_ABA_TEMPO = false

local PANICO = {epoca = 0}   -- botão de pânico (cancela o ciclo do auto farm em andamento)
local ANTILAG = {}           -- anti-lag / modo economia

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

if CoreGui:FindFirstChild("UltimateEggHubAutoCollect") then
    CoreGui.UltimateEggHubAutoCollect:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltimateEggHubAutoCollect"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

local guiWidth = isMobile and 340 or 600
local guiHeight = isMobile and 420 or 440
local sidebarWidth = isMobile and 90 or 150

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, guiWidth, 0, guiHeight)
mainFrame.Position = UDim2.new(0.5, -guiWidth/2, 0.5, -guiHeight/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(80, 140, 255)
UIStroke.Transparency = 0.4
UIStroke.Thickness = 1.8
UIStroke.Parent = mainFrame

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 14)

local topBarCover = Instance.new("Frame")
topBarCover.Size = UDim2.new(1, 0, 0, 10)
topBarCover.Position = UDim2.new(0, 0, 1, -10)
topBarCover.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
topBarCover.BorderSizePixel = 0
topBarCover.Parent = topBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -120, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = isMobile and "⚡ SHARK-MENU-PET  [ATUALIZADO] 2.0" or "⚡ SHARK-MENU-PET  [ATUALIZADO] 2.0"
titleLabel.TextColor3 = Color3.fromRGB(220, 230, 255)
titleLabel.TextSize = isMobile and 13 or 12
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 28, 0, 28)
minimizeButton.Position = UDim2.new(1, -68, 0, 6)
minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 130, 246)
minimizeButton.Text = "−"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 20
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Parent = topBar
Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0, 7)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Position = UDim2.new(1, -34, 0, 6)
closeButton.BackgroundColor3 = Color3.fromRGB(235, 60, 60)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = topBar
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 7)

closeButton.MouseButton1Click:Connect(function()
    if PANICO.parar then pcall(PANICO.parar, false) end
    if ANTILAG.restaurar then pcall(ANTILAG.restaurar) end
    screenGui:Destroy()
end)

local panicButton = Instance.new("TextButton")
panicButton.Size = UDim2.new(0, 28, 0, 28)
panicButton.Position = UDim2.new(1, -102, 0, 6)
panicButton.BackgroundColor3 = Color3.fromRGB(200, 70, 20)
panicButton.Text = "🛑"
panicButton.TextColor3 = Color3.fromRGB(255, 255, 255)
panicButton.TextSize = 14
panicButton.Font = Enum.Font.GothamBold
panicButton.Parent = topBar
Instance.new("UICorner", panicButton).CornerRadius = UDim.new(0, 7)
panicButton.MouseButton1Click:Connect(function()
    if PANICO.parar then PANICO.parar(true) end
end)

local floatingBtn = Instance.new("TextButton")
floatingBtn.Size = UDim2.new(0, 58, 0, 58)
floatingBtn.Position = UDim2.new(0, 20, 0.7, 0)
floatingBtn.BackgroundColor3 = Color3.fromRGB(60, 130, 246)
floatingBtn.Text = "⚡"
floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingBtn.TextSize = 26
floatingBtn.Font = Enum.Font.GothamBold
floatingBtn.Visible = false
floatingBtn.Active = true
floatingBtn.Draggable = true
floatingBtn.Parent = screenGui
Instance.new("UICorner", floatingBtn).CornerRadius = UDim.new(1, 0)

local floatStroke = Instance.new("UIStroke")
floatStroke.Color = Color3.fromRGB(255, 255, 255)
floatStroke.Thickness = 2
floatStroke.Transparency = 0.3
floatStroke.Parent = floatingBtn

-- Botão de pânico flutuante (aparece quando o menu está minimizado)
local floatPanic = Instance.new("TextButton")
floatPanic.Size = UDim2.new(0, 44, 0, 44)
floatPanic.Position = UDim2.new(0, 27, 0.7, 66)
floatPanic.BackgroundColor3 = Color3.fromRGB(200, 70, 20)
floatPanic.Text = "🛑"
floatPanic.TextColor3 = Color3.fromRGB(255, 255, 255)
floatPanic.TextSize = 20
floatPanic.Font = Enum.Font.GothamBold
floatPanic.Visible = false
floatPanic.Active = true
floatPanic.Draggable = true
floatPanic.Parent = screenGui
Instance.new("UICorner", floatPanic).CornerRadius = UDim.new(1, 0)
floatPanic.MouseButton1Click:Connect(function()
    if PANICO.parar then PANICO.parar(true) end
end)

minimizeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    floatingBtn.Visible = true
    floatPanic.Visible = true
end)

floatingBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    floatingBtn.Visible = false
    floatPanic.Visible = false
end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, sidebarWidth, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local uiLayoutTabs = Instance.new("UIListLayout")
uiLayoutTabs.FillDirection = Enum.FillDirection.Vertical
uiLayoutTabs.SortOrder = Enum.SortOrder.LayoutOrder
uiLayoutTabs.Padding = UDim.new(0, 5)
uiLayoutTabs.Parent = sidebar

local paddingSidebar = Instance.new("UIPadding")
paddingSidebar.PaddingTop = UDim.new(0, 10)
paddingSidebar.PaddingLeft = UDim.new(0, 6)
paddingSidebar.PaddingRight = UDim.new(0, 6)
paddingSidebar.Parent = sidebar

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -(sidebarWidth + 10), 1, -48)
contentContainer.Position = UDim2.new(0, sidebarWidth + 5, 0, 44)
contentContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
contentContainer.BorderSizePixel = 0
contentContainer.Parent = mainFrame
Instance.new("UICorner", contentContainer).CornerRadius = UDim.new(0, 10)

local pages = {}
local function criarPagina(nome)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 4
    page.Visible = false
    page.Parent = contentContainer

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = page
    pages[nome] = page
    return page
end

local paginaAuto = criarPagina("Auto")
local paginaOvos = criarPagina("Ovos")
local paginaBase = criarPagina("Base")
local paginaCaminho = criarPagina("Caminho")
local paginaTempo = criarPagina("Tempo")
local paginaFly = criarPagina("Fly")
local paginaSpeed = criarPagina("Speed")
local paginaESP = criarPagina("ESP")
local paginaPlayers = criarPagina("Players")
local paginaExtras = criarPagina("Extras")

local tweenInfoAnim = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function criarBotaoTab(nome, paginaAlvo)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, isMobile and 34 or 32)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 35)
    btn.Text = nome
    btn.TextColor3 = Color3.fromRGB(160, 165, 190)
    btn.TextSize = isMobile and 10 or 11
    btn.Font = Enum.Font.GothamMedium
    btn.TextWrapped = true
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseEnter:Connect(function()
        if paginaAlvo.Visible == false then
            TweenService:Create(btn, tweenInfoAnim, {BackgroundColor3 = Color3.fromRGB(34, 34, 48), TextColor3 = Color3.fromRGB(210, 220, 245)}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if paginaAlvo.Visible == false then
            TweenService:Create(btn, tweenInfoAnim, {BackgroundColor3 = Color3.fromRGB(24, 24, 35), TextColor3 = Color3.fromRGB(160, 165, 190)}):Play()
        end
    end)

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        for _, b in pairs(sidebar:GetChildren()) do
            if b:IsA("TextButton") then 
                TweenService:Create(b, tweenInfoAnim, {BackgroundColor3 = Color3.fromRGB(24, 24, 35), TextColor3 = Color3.fromRGB(160, 165, 190)}):Play()
            end
        end
        paginaAlvo.Visible = true
        TweenService:Create(btn, tweenInfoAnim, {BackgroundColor3 = Color3.fromRGB(60, 130, 246), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)
    return btn
end

local bAuto = criarBotaoTab(isMobile and "🤖 Farm" or "🤖 Auto Farm", paginaAuto)
criarBotaoTab(isMobile and "🥚 Ovos" or "🥚 Ovos Manual", paginaOvos)
criarBotaoTab(isMobile and "🏡 Base" or "🏡 Minha Base", paginaBase)
if MOSTRAR_ABA_CAMINHO then
    criarBotaoTab(isMobile and "🛤️ Caminho" or "🛤️ Caminho T", paginaCaminho)
end
if MOSTRAR_ABA_TEMPO then
    criarBotaoTab(isMobile and "⏱️ Tempo" or "⏱️ Tempo Ovo", paginaTempo)
end
criarBotaoTab("✈️ Fly", paginaFly)
criarBotaoTab(isMobile and "⚡ Speed" or "⚡ Velocidade", paginaSpeed)
criarBotaoTab("👁️ ESP", paginaESP)
criarBotaoTab("👥 Players", paginaPlayers)
criarBotaoTab(isMobile and "⚙️ Extra" or "⚙️ Extras", paginaExtras)

paginaAuto.Visible = true
bAuto.BackgroundColor3 = Color3.fromRGB(60, 130, 246)
bAuto.TextColor3 = Color3.fromRGB(255, 255, 255)

-- ==================== FUNÇÕES GERAIS ====================
local function encontrarMinhaBase()
    local plots = workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            if plot:FindFirstChild("Owner") and plot.Owner.Value == player then
                return plot
            elseif plot.Name:lower():find(player.Name:lower(), 1, true) then
                return plot
            end
        end
        if #plots:GetChildren() > 0 then return plots:GetChildren()[1] end
    end
    return nil
end

local MULTIPLICADORES_VALOR = {K = 1e3, M = 1e6, B = 1e9, T = 1e12}

-- Lê só a letra que vem logo depois do número (ex: 2.5T, 300M, 1.2B).
-- Letras de outras palavras ("Mythic", "Rare Egg", "5 MIN") são ignoradas.
local function extrairTextoValor(texto)
    if not texto then return 0, "" end
    texto = texto:upper()
    -- "1,5T" (vírgula decimal) vira "1.5T"; outras vírgulas (milhar) são removidas
    texto = texto:gsub("(%d),(%d%d?)(%s*[KMBT])%f[%A]", "%1.%2%3")
    texto = texto:gsub(",", "")

    local numStr, sufixo = texto:match("(%d[%d%.]*)%s*([KMBT])%f[%A]")
    if numStr then
        numStr = numStr:gsub("%.+$", "")
        local num = tonumber(numStr)
        if num then
            return num * MULTIPLICADORES_VALOR[sufixo], sufixo
        end
    end

    -- Sem sufixo válido: valor puro (ex: "$500"), sem letra
    local puro = texto:match("[%d%.]+")
    local num = puro and tonumber(puro) or 0
    return num, ""
end

local function letraPorValor(num)
    if num >= 1e12 then return "T"
    elseif num >= 1e9 then return "B"
    elseif num >= 1e6 then return "M"
    elseif num >= 1e3 then return "K" end
    return ""
end

-- Converte número em texto curto: 2500000000000 -> "2.5T", 300000000 -> "300M"
local function formatarValor(num)
    if not num or num <= 0 then return "?" end
    local faixas = {{1e12, "T"}, {1e9, "B"}, {1e6, "M"}, {1e3, "K"}}
    for _, f in ipairs(faixas) do
        if num >= f[1] then
            local txt = string.format("%.2f", num / f[1]):gsub("0+$", ""):gsub("%.$", "")
            return txt .. f[2]
        end
    end
    return string.format("%g", num)
end

local function limparTextoRico(t)
    return (t:gsub("<[^>]+>", ""))
end

local function coletarTextosDe(raiz, saida)
    for _, d in ipairs(raiz:GetDescendants()) do
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            if d.Text and d.Text ~= "" then table.insert(saida, limparTextoRico(d.Text)) end
        elseif d:IsA("ProximityPrompt") then
            if d.ObjectText ~= "" then table.insert(saida, d.ObjectText) end
            if d.ActionText ~= "" then table.insert(saida, d.ActionText) end
        end
    end
end

local function contarPartesOvo(raiz, limite)
    local n = 0
    for _, d in ipairs(raiz:GetDescendants()) do
        if d:IsA("BasePart") and d.Name:lower():find("egg") then
            n += 1
            if n >= limite then return n end
        end
    end
    return n
end

-- Entre vários textos, escolhe o que realmente parece um valor (número + K/M/B/T)
local function melhorValorEmTextos(textos)
    local reservaTxt, reservaNum
    for _, txt in ipairs(textos) do
        local num, letra = extrairTextoValor(txt)
        if letra ~= "" then return txt, num, letra end
        if not reservaTxt and num > 0 and txt:find("%$") then
            reservaTxt, reservaNum = txt, num
        end
    end
    if reservaTxt then return reservaTxt, reservaNum, "" end
    return nil
end

local function valorPorAtributo(inst)
    local ok, attrs = pcall(function() return inst:GetAttributes() end)
    if not ok or not attrs then return nil end
    for nome, v in pairs(attrs) do
        local n = tostring(nome):lower()
        if type(v) == "number" and v > 0 and (n:find("value") or n:find("price") or n:find("cost") or n:find("worth") or n:find("valor") or n:find("preco")) then
            return v
        end
    end
    return nil
end

-- Descobre o valor do ovo. Ordem de busca:
-- 1) textos dentro do modelo  2) textos nos pais (se só tiver 1 ovo ali)
-- 3) nome do ovo              4) atributos numéricos
-- Retorna: texto original, valor numérico, letra
local function lerValorDoModelo(modelo, parte)
    local raiz = (modelo and modelo ~= workspace) and modelo or parte
    if not raiz then return "Normal", 0, "" end

    local textos = {}
    coletarTextosDe(raiz, textos)
    local t, n, l = melhorValorEmTextos(textos)
    if t then return t, n, l end

    local atual = raiz.Parent
    local niveis = 0
    while atual and atual ~= workspace and niveis < 3 do
        if contarPartesOvo(atual, 2) > 1 then break end
        textos = {}
        coletarTextosDe(atual, textos)
        t, n, l = melhorValorEmTextos(textos)
        if t then return t, n, l end
        atual = atual.Parent
        niveis += 1
    end

    for _, nomeTxt in ipairs({raiz.Name, parte and parte.Name or ""}) do
        local num, letra = extrairTextoValor(nomeTxt)
        if letra ~= "" then return nomeTxt, num, letra end
    end

    for _, inst in ipairs({raiz, parte}) do
        if inst then
            local v = valorPorAtributo(inst)
            if v then return formatarValor(v), v, letraPorValor(v) end
        end
    end

    return "Normal", 0, ""
end

local function obterTempoTimerPorValor(valorNum)
    if valorNum >= 2.5e12 then return 35
    elseif valorNum >= 1e12 then return 15
    elseif valorNum >= 210e9 then return 20
    elseif valorNum >= 2e9 then return 45
    elseif valorNum >= 300e6 then return 35
    elseif valorNum >= 8e6 then return 32
    elseif valorNum >= 1e6 then return 30
    end
    return 30
end

-- Lê o tempo RESTANTE real do ovo (mesmo cálculo do Timer do jogo)
-- TextLabel com tag "Timer" + filho StartTime + Attribute Duration (minutos)
-- restante = Duration*60 - (ServerTimeNow - StartTime)
-- Extrai segundos de textos tipo "14.9s", "14s", "0:15", "00:15"
local function parseSegundosDeTexto(txt)
    if not txt or txt == "" then return nil end
    txt = tostring(txt):gsub("<[^>]+>", ""):gsub("%s+", "")
    local dec = txt:match("(%d+%.%d+)s")
    if dec then
        local n = tonumber(dec)
        if n and n > 0 and n <= 180 then return n end
    end
    local int = txt:match("(%d+)s")
    if int then
        local n = tonumber(int)
        if n and n > 0 and n <= 180 then return n end
    end
    local m, s = txt:match("(%d+):(%d%d)")
    if m and s then
        local n = tonumber(m) * 60 + tonumber(s)
        if n > 0 and n <= 600 then return n end
    end
    return nil
end

-- Ignora timers de loja/comida/restock — só ovo na mão / quebrar
local function textoETimerLixo(txt)
    if not txt then return false end
    local t = tostring(txt):lower()
    if t:find("restock") or t:find("reabastec") then return true end
    if t:find("food") or t:find("comida") then return true end
    if t:find("stock") or t:find("reset") or t:find("shop") or t:find("loja") then return true end
    return false
end

--[[
  Score do timer do ovo na mão (barra vermelha "O ovo vai quebrar").
  Preferir: nome Timer + texto puro "5.9s" + valor típico de ovo (≤45s).
  Evitar: 50s/60s fixos, TimeLeft, comida, restock.
]]
local function scoreTimerOvo(inst, texto, segundos)
    if not segundos or segundos <= 0 or segundos > 90 then return 0 end
    if textoETimerLixo(texto) then return 0 end
    local nome = (inst and inst.Name or ""):lower()
    if textoETimerLixo(nome) then return 0 end
    if nome:find("restock") or nome:find("stock") or nome:find("food") then return 0 end
    if nome:find("timeleft") or nome == "timeleft" then return 0 end

    local score = 5
    local tlimpo = tostring(texto or ""):gsub("<[^>]+>", ""):gsub("%s+", "")

    -- barra vermelha: texto exatamente "11.3s" / "5.9s"
    if tlimpo:match("^%d+%.%d+s$") then
        score += 60
    elseif tlimpo:match("^%d+s$") then
        score += 25
    end

    if nome == "timer" then
        score += 40
    elseif nome:find("timer") then
        score += 15
    end

    -- valores típicos do ovo na mão (tabela 15–45s, e o restante decrescendo)
    if segundos > 0 and segundos <= 45 then
        score += 35
    elseif segundos > 45 and segundos <= 55 then
        score += 5
    else
        -- 60s / 50s costumam ser outros UI
        score -= 50
    end

    -- "1m 12s" / minutos = não é a barra do ovo
    if tostring(texto or ""):lower():find("m") then
        score -= 60
    end

    return score
end

local _timerCacheVal, _timerCacheAt = nil, 0

local function lerTimerRestanteReal()
    local agora = os.clock()
    if agora - _timerCacheAt < 0.3 and _timerCacheVal ~= nil then
        return _timerCacheVal > 0 and _timerCacheVal or nil
    end

    local melhor, melhorScore = nil, 0
    local pg = player:FindFirstChild("PlayerGui")
    if pg then
        for _, d in ipairs(pg:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                if d.Visible ~= false then
                    local txt = d.Text
                    local n = parseSegundosDeTexto(txt)
                    if n then
                        local sc = scoreTimerOvo(d, txt, n)
                        if sc > melhorScore then
                            melhorScore = sc
                            melhor = n
                        end
                    end
                end
            end
        end
    end

    if melhorScore < 30 then
        pcall(function()
            local basket = player:FindFirstChild("Basket")
            if not basket then return end
            local st = workspace:GetServerTimeNow()
            for _, egg in ipairs(basket:GetChildren()) do
                local untilAttr = egg:GetAttribute("VolcanoUntil")
                if type(untilAttr) == "number" then
                    local r = untilAttr - st
                    if r > 0.3 and r < 90 then
                        melhor = r
                        melhorScore = 30
                        break
                    end
                end
            end
        end)
    end

    local result = (melhorScore >= 30) and melhor or nil
    _timerCacheVal = result or -1
    _timerCacheAt = agora
    return result
end


local function acionarProximityPrompt(parteOvo)
    task.spawn(function()
        pcall(function()
            local raiz = parteOvo:FindFirstAncestorOfClass("Model")
            if not raiz or raiz == workspace then raiz = parteOvo end
            local prompt = raiz:FindFirstChildWhichIsA("ProximityPrompt", true)
            if not prompt then return end
            local holdOriginal = prompt.HoldDuration
            prompt.HoldDuration = 0
            if fireproximityprompt then
                fireproximityprompt(prompt)
            else
                prompt:InputHoldBegin()
                prompt:InputHoldEnd()
            end
            task.delay(0.1, function()
                if prompt and prompt.Parent then prompt.HoldDuration = holdOriginal end
            end)
        end)
    end)
end

local VirtualInputManager = game:GetService("VirtualInputManager")
local function apertarTecla1DuasVezes()
    pcall(function()
        task.wait(0.15)
        for _ = 1, 2 do
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
            task.wait(0.2)
        end
    end)
end

local flySpeed = 320
local walkSpeedDesejada = 16
local noclipAtivo = true
local boostModo = 0
local boostCFrameAtivo = false
local estadoNoclip = {manual = false, fly = false, auto = false, ultimoMov = 0, estavaLigado = false}
local modoIniciante = false
local cooldownIniciante = 0
local jaTentouColocar = false

local noclipCache = {t = 0, partes = {}}
local nomesPet = {"mount", "pet", "ride", "cav", "fenix", "fênix", "phoenix", "dragon", "horse"}

local function modeloEhDoJogador(m)
    local nome = m.Name:lower()
    if nome:find(player.Name:lower(), 1, true) then return true end
    for _, n in ipairs(nomesPet) do
        if nome:find(n, 1, true) then return true end
    end
    local dono = m:GetAttribute("Owner") or m:GetAttribute("OwnerId") or m:GetAttribute("OwnerName") or m:GetAttribute("Player")
    if dono and (dono == player.Name or dono == player.UserId or dono == player.DisplayName) then return true end
    return false
end

local function juntarPartes(modelo, destino)
    for _, part in ipairs(modelo:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(destino, part)
        end
    end
end

local function reconstruirNoclipCache()
    local lista = {}
    local char = player.Character
    local rp = char and char:FindFirstChild("HumanoidRootPart")
    if char then juntarPartes(char, lista) end
    if rp then
        pcall(function()
            for _, part in ipairs(rp:GetConnectedParts(true)) do
                table.insert(lista, part)
            end
        end)
    end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") then
            if obj ~= char and modeloEhDoJogador(obj) then juntarPartes(obj, lista) end
        elseif obj:IsA("Folder") then
            for _, filho in ipairs(obj:GetChildren()) do
                if filho:IsA("Model") and filho ~= char and modeloEhDoJogador(filho) then
                    juntarPartes(filho, lista)
                end
            end
        end
    end
    noclipCache.partes = lista
    noclipCache.t = os.clock()
end

local movimentoInfo = {ativo = false, dist = 0}

local function restaurarColisaoECorrigirChao()
    local char = player.Character
    if not char then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
    end

    local rp = char:FindFirstChild("HumanoidRootPart")
    if rp then
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Exclude
        local result = workspace:Raycast(rp.Position + Vector3.new(0, 12, 0), Vector3.new(0, -60, 0), params)
        if result then
            local targetY = result.Position.Y + 3.2
            if rp.Position.Y < targetY - 0.5 then
                rp.CFrame = CFrame.new(rp.Position.X, targetY, rp.Position.Z) * (rp.CFrame - rp.CFrame.Position)
            end
        end
    end
    estadoNoclip.ultimoMov = 0
end

RunService.Stepped:Connect(function()
    if movimentoInfo.ativo then estadoNoclip.ultimoMov = os.clock() end
    local deveAtravessar = estadoNoclip.manual or estadoNoclip.fly or estadoNoclip.auto
        or (os.clock() - estadoNoclip.ultimoMov) < 0.8

    if estadoNoclip.estavaLigado and not deveAtravessar then
        local c = player.Character
        if c then
            for _, part in ipairs(c:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
    estadoNoclip.estavaLigado = deveAtravessar

    if noclipAtivo and deveAtravessar then
        if os.clock() - noclipCache.t > 0.12 then
            reconstruirNoclipCache()
        end
        for _, part in ipairs(noclipCache.partes) do
            if part and part.Parent then
                part.CanCollide = false
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and not boostCFrameAtivo and hum.WalkSpeed ~= walkSpeedDesejada then
        hum.WalkSpeed = walkSpeedDesejada
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if boostModo == 0 then return end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local rp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not rp then return end
    local dir = hum.MoveDirection
    if dir.Magnitude < 0.1 then return end
    if walkSpeedDesejada - hum.WalkSpeed <= 0 then return end
    dir = dir.Unit
    if boostModo == 1 then
        local v = rp.AssemblyLinearVelocity
        rp.AssemblyLinearVelocity = Vector3.new(dir.X * walkSpeedDesejada, v.Y, dir.Z * walkSpeedDesejada)
    else
        rp.CFrame = rp.CFrame + dir * (walkSpeedDesejada - hum.WalkSpeed) * dt
    end
end)

player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local h = char:FindFirstChildOfClass("Humanoid")
    if h and not boostCFrameAtivo then h.WalkSpeed = walkSpeedDesejada end
end)

local movimentoAtual = 0

local function correrAteManual(posicaoAlvo, callback)
    movimentoAtual += 1
    local meuId = movimentoAtual
    local nomeBind = "EggHubManual" .. meuId
    local destino = (posicaoAlvo + Vector3.new(0, 3, 0)).Position
    local inicio = os.clock()
    local terminou = false

    local function finalizar()
        if terminou then return end
        terminou = true
        pcall(function() RunService:UnbindFromRenderStep(nomeBind) end)
        if meuId == movimentoAtual then
            movimentoInfo.ativo = false
            restaurarColisaoECorrigirChao()
        end
    end

    movimentoInfo.ativo = true
    RunService:BindToRenderStep(nomeBind, Enum.RenderPriority.Last.Value, function(dt)
        if meuId ~= movimentoAtual then finalizar() return end
        if os.clock() - inicio > 30 then finalizar() return end

        local char = player.Character
        local rp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not rp then return end

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end

        rp.Anchored = false
        if hum then
            hum.Sit = false
            hum.PlatformStand = true
        end

        local delta = destino - rp.Position
        movimentoInfo.dist = delta.Magnitude
        local passo = flySpeed * math.min(dt, 0.1)

        rp.AssemblyLinearVelocity = Vector3.zero
        rp.AssemblyAngularVelocity = Vector3.zero

        if delta.Magnitude <= passo then
            rp.CFrame = CFrame.new(destino) * (rp.CFrame - rp.CFrame.Position)
            finalizar()
            if callback then task.spawn(callback) end
        else
            rp.CFrame = rp.CFrame + delta.Unit * passo
        end
    end)
end

local function moverAutoIda(posicaoAlvo, callback, velOverride)
    movimentoAtual += 1
    local meuId = movimentoAtual
    local nomeBind = "EggHubAutoIda" .. meuId
    local destino = (posicaoAlvo + Vector3.new(0, 3, 0)).Position
    local inicio = os.clock()
    local terminou = false

    local function finalizar()
        if terminou then return end
        terminou = true
        pcall(function() RunService:UnbindFromRenderStep(nomeBind) end)
        if meuId == movimentoAtual then
            movimentoInfo.ativo = false
            restaurarColisaoECorrigirChao()
        end
    end

    movimentoInfo.ativo = true
    RunService:BindToRenderStep(nomeBind, Enum.RenderPriority.Last.Value, function(dt)
        if meuId ~= movimentoAtual then finalizar() return end
        if os.clock() - inicio > 25 then finalizar() return end

        local char = player.Character
        local rp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not rp then return end

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end

        rp.Anchored = false
        if hum then
            hum.Sit = false
            hum.PlatformStand = true
        end

        local delta = destino - rp.Position
        movimentoInfo.dist = delta.Magnitude
        local passo = (velOverride or flySpeed) * math.min(dt, 0.1)

        rp.AssemblyLinearVelocity = Vector3.zero
        rp.AssemblyAngularVelocity = Vector3.zero

        if delta.Magnitude <= passo then
            rp.CFrame = CFrame.new(destino) * (rp.CFrame - rp.CFrame.Position)
            finalizar()
            if callback then task.spawn(callback) end
        else
            rp.CFrame = rp.CFrame + delta.Unit * passo
        end
    end)
end

-- Volta à base recalculando velocidade pelo timer REAL a cada ~0.25s
-- Prioridade: chegar ANTES de o ovo explodir (não deixar estourar no caminho)
local function moverAutoVoltaPorValor(posicaoAlvo, tempoTotalOvo, callback)
    movimentoAtual += 1
    local meuId = movimentoAtual
    local nomeBind = "EggHubAutoVoltaValor" .. meuId
    local destino = (posicaoAlvo + Vector3.new(0, 3, 0)).Position
    local inicio = os.clock()
    local terminou = false
    local ultimoRefresh = 0
    local tempoOrcamento = math.max(tempoTotalOvo or 20, 2)
    local velocidadeAtual = 300

    local function finalizar()
        if terminou then return end
        terminou = true
        pcall(function() RunService:UnbindFromRenderStep(nomeBind) end)
        if meuId == movimentoAtual then
            movimentoInfo.ativo = false
            restaurarColisaoECorrigirChao()
        end
    end

    local function recalcularVelocidade(dist)
        -- Invalida cache e lê barra vermelha AO VIVO
        _timerCacheAt = 0
        _timerCacheVal = nil
        local real = lerTimerRestanteReal()
        local restante
        if real and real > 0.5 then
            restante = real
            tempoOrcamento = real
        else
            -- fallback: o que ainda sobra do orçamento inicial desde o início do movimento
            local gasto = os.clock() - inicio
            restante = math.max(tempoOrcamento - gasto, 0.8)
        end

        -- Margem menor quando o tempo está crítico
        local margem = (restante <= 10) and 0.4 or 1.0
        local tempoUtil = math.max(restante - margem, 0.35)

        local vel = dist / tempoUtil
        -- Timer baixo → velocidade bem mais alta para não explodir no caminho
        local velMax = 900
        local velMin = 180
        if restante <= 5 then
            velMin = 900
            velMax = 2000  -- emergência (~5s ou menos)
        elseif restante <= 8 then
            velMin = 700
            velMax = 1600  -- urgente
        elseif restante <= 12 then
            velMin = 450
            velMax = 1200
        elseif restante <= 20 then
            velMin = 280
            velMax = 950
        else
            velMax = 750
        end
        velocidadeAtual = math.clamp(vel, velMin, velMax)
        movimentoInfo.dist = dist
    end

    movimentoInfo.ativo = true
    RunService:BindToRenderStep(nomeBind, Enum.RenderPriority.Last.Value, function(dt)
        if meuId ~= movimentoAtual then finalizar() return end
        if os.clock() - inicio > 50 then finalizar() return end

        local char = player.Character
        local rp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not rp then return end

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end

        rp.Anchored = false
        if hum then
            hum.Sit = false
            hum.PlatformStand = true
        end

        local delta = destino - rp.Position
        local dist = delta.Magnitude
        movimentoInfo.dist = dist

        local agora = os.clock()
        if agora - ultimoRefresh >= 0.25 or ultimoRefresh == 0 then
            recalcularVelocidade(dist)
            ultimoRefresh = agora
        end

        local passo = velocidadeAtual * math.min(dt, 0.1)

        rp.AssemblyLinearVelocity = Vector3.zero
        rp.AssemblyAngularVelocity = Vector3.zero

        if dist <= math.max(passo, 4) then
            rp.CFrame = CFrame.new(destino) * (rp.CFrame - rp.CFrame.Position)
            finalizar()
            if callback then task.spawn(callback) end
        else
            rp.CFrame = rp.CFrame + delta.Unit * passo
        end
    end)
end

local function correrAteChaoAuto(posicaoAlvo, callback)
    movimentoAtual += 1
    local meuId = movimentoAtual
    local nomeBind = "EggHubAutoWalk" .. meuId
    local destino = Vector3.new(posicaoAlvo.X, posicaoAlvo.Y, posicaoAlvo.Z)
    local inicio = os.clock()
    local terminou = false

    local function finalizar()
        if terminou then return end
        terminou = true
        pcall(function() RunService:UnbindFromRenderStep(nomeBind) end)
        pcall(function()
            local c = player.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h then h:Move(Vector3.zero, false) end
        end)
        if meuId == movimentoAtual then
            movimentoInfo.ativo = false
            restaurarColisaoECorrigirChao()
        end
    end

    movimentoInfo.ativo = true
    RunService:BindToRenderStep(nomeBind, Enum.RenderPriority.Character.Value, function(dt)
        if meuId ~= movimentoAtual then finalizar() return end
        if os.clock() - inicio > 40 then finalizar() return end

        local char = player.Character
        local rp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not rp or not hum then finalizar() return end

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end

        local destinoPlano = Vector3.new(destino.X, rp.Position.Y, destino.Z)
        local delta = destinoPlano - rp.Position
        movimentoInfo.dist = delta.Magnitude

        if delta.Magnitude <= 4 or hum.Health <= 0 then
            finalizar()
            if callback then task.spawn(callback) end
        else
            hum:ChangeState(Enum.HumanoidStateType.Running)
            hum:Move(delta.Unit, false)
        end
    end)
end

local basePosSalva = nil
local uiRef = {}
local function setStatus(t)
    if uiRef.status then uiRef.status.Text = t end
    if uiRef.statusAuto then uiRef.statusAuto.Text = t end
end

local function obterAlvoBase()
    if basePosSalva then
        return CFrame.new(basePosSalva)
    end
    local base = encontrarMinhaBase()
    if not base then return nil end
    local pBase = (base:IsA("BasePart") and base)
        or base:FindFirstChild("BasePart")
        or base:FindFirstChild("Core")
        or base:FindFirstChildWhichIsA("BasePart", true)
    if pBase and pBase:IsA("BasePart") then
        return pBase.CFrame + Vector3.new(0, pBase.Size.Y / 2 + 2, 0)
    end
    return nil
end

local function voltarParaCasaManual300M()
    local alvo = obterAlvoBase()
    if not alvo then 
        setStatus("⚠️ Base não encontrada! Salve a posição primeiro.")
        return 
    end

    local char = player.Character
    local rp = char and char:FindFirstChild("HumanoidRootPart")
    if not rp then return end

    local destino = alvo.Position
    local direcao = (rp.Position - destino)
    direcao = Vector3.new(direcao.X, 0, direcao.Z)
    
    local pontoParada
    if direcao.Magnitude > 300 then
        pontoParada = destino + direcao.Unit * 300
    else
        pontoParada = destino + Vector3.new(0, 0, 300)
    end

    setStatus("🏡 Voltando voando a 300m da base...")
    correrAteManual(CFrame.new(pontoParada), function()
        setStatus("✅ Chegou a 300 metros da base!")
    end)
end

-- ==================== RADAR ====================
local radarAlvo = nil
local radarNome = ""
local radarBotoes = {}

local radarFrame = Instance.new("Frame")
radarFrame.Size = UDim2.new(1, 0, 1, 0)
radarFrame.BackgroundTransparency = 1
radarFrame.Visible = false
radarFrame.ZIndex = 50
radarFrame.Parent = screenGui

local radarSeta = Instance.new("TextLabel")
radarSeta.Size = UDim2.new(0, 32, 0, 32)
radarSeta.AnchorPoint = Vector2.new(0.5, 0.5)
radarSeta.BackgroundTransparency = 1
radarSeta.Text = "➤"
radarSeta.TextColor3 = Color3.fromRGB(255, 220, 60)
radarSeta.TextStrokeTransparency = 0
radarSeta.TextSize = 28
radarSeta.Font = Enum.Font.GothamBold
radarSeta.ZIndex = 51
radarSeta.Parent = radarFrame

local radarTexto = Instance.new("TextLabel")
radarTexto.Size = UDim2.new(0, 150, 0, 28)
radarTexto.AnchorPoint = Vector2.new(0.5, 0)
radarTexto.BackgroundTransparency = 1
radarTexto.TextColor3 = Color3.fromRGB(255, 255, 255)
radarTexto.TextStrokeTransparency = 0
radarTexto.TextSize = 11
radarTexto.Font = Enum.Font.GothamBold
radarTexto.TextWrapped = true
radarTexto.ZIndex = 51
radarTexto.Parent = radarFrame

local function pararRadar()
    radarAlvo = nil
    radarFrame.Visible = false
    for b in pairs(radarBotoes) do
        if b and b.Parent then b.BackgroundColor3 = Color3.fromRGB(70, 70, 120) end
    end
end

RunService.RenderStepped:Connect(function()
    if not radarAlvo then return end
    if not radarAlvo.Parent then pararRadar() return end

    local cam = workspace.CurrentCamera
    local char = player.Character
    local rp = char and char:FindFirstChild("HumanoidRootPart")
    if not cam or not rp then return end

    local pos = radarAlvo.Position
    local dist = (pos - rp.Position).Magnitude
    local tela = cam.ViewportSize
    local centro = tela / 2
    local v, naTela = cam:WorldToViewportPoint(pos)

    radarFrame.Visible = true
    local posSeta

    if naTela and v.Z > 0 then
        posSeta = Vector2.new(v.X, v.Y - 25)
        radarSeta.Rotation = 90
    else
        local rel = cam.CFrame:PointToObjectSpace(pos)
        local dir = Vector2.new(rel.X, -rel.Y)
        if dir.Magnitude < 0.001 then dir = Vector2.new(0, -1) end
        dir = dir.Unit
        local margemX, margemY = centro.X - 40, centro.Y - 60
        local escala = math.min(
            margemX / math.max(math.abs(dir.X), 0.0001),
            margemY / math.max(math.abs(dir.Y), 0.0001)
        )
        posSeta = centro + dir * escala
        radarSeta.Rotation = math.deg(math.atan2(dir.Y, dir.X))
    end

    radarSeta.Position = UDim2.fromOffset(posSeta.X, posSeta.Y)
    radarTexto.Position = UDim2.fromOffset(posSeta.X, posSeta.Y + 18)
    radarTexto.Text = string.format("%s\n%d studs", radarNome, math.floor(dist))
end)

-- ==================== CAMINHO T ====================
local HttpService = game:GetService("HttpService")
local ARQUIVO_CAMINHO = "UltimateEggHub_CaminhoT.json"
local CAMINHO_PADRAO = {
    Vector3.new(-4850.83, 41254.26, -3834.04),
    Vector3.new(-4937.82, 41286.73, -3688.99),
    Vector3.new(-4964.13, 41285.95, -3651.60),
    Vector3.new(-5015.83, 41275.87, -3565.76),
    Vector3.new(-5029.42, 41264.75, -3488.69),
    Vector3.new(-4936.71, 41211.90, -3380.16),
    Vector3.new(-4956.17, 41208.31, -3316.93),
    Vector3.new(-5083.29, 41174.27, -3316.45),
    Vector3.new(-5142.49, 41166.17, -3279.70),
    Vector3.new(-5057.68, 41139.95, -3225.81),
    Vector3.new(-5049.64, 41090.65, -3220.94),
    Vector3.new(-4960.68, 41051.43, -3416.43),
    Vector3.new(-4897.30, 41026.37, -3439.43),
    Vector3.new(-4896.60, 41004.09, -3485.67),
    Vector3.new(-4933.18, 40973.61, -3566.94),
    Vector3.new(-5074.18, 40935.56, -3675.96),
    Vector3.new(-5186.23, 40920.30, -3668.08),
    Vector3.new(-5244.72, 40915.34, -3644.11),
    Vector3.new(-5303.43, 40917.89, -3600.22),
    Vector3.new(-5102.46, 41562.70, -3414.29),
}
local caminhoT = {}
local caminhoModoAndar = false
local caminhoVoltaInvertida = true
local VEL_CAMINHO_VOLTA = 650
local caminhoPausa = 0.5
local labelCaminhoInfo = nil

local pastaMarcas = Instance.new("Folder")
pastaMarcas.Name = "EggHubMarcasCaminho"
pastaMarcas.Parent = workspace.CurrentCamera or workspace

local function salvarCaminhoArquivo()
    pcall(function()
        if not writefile then return end
        local dados = {}
        for _, v in ipairs(caminhoT) do
            table.insert(dados, {x = v.X, y = v.Y, z = v.Z})
        end
        writefile(ARQUIVO_CAMINHO, HttpService:JSONEncode(dados))
    end)
end

local function carregarCaminhoArquivo()
    pcall(function()
        if not (readfile and isfile and isfile(ARQUIVO_CAMINHO)) then return end
        local dados = HttpService:JSONDecode(readfile(ARQUIVO_CAMINHO))
        caminhoT = {}
        for _, v in ipairs(dados) do
            table.insert(caminhoT, Vector3.new(v.x, v.y, v.z))
        end
    end)
    if #caminhoT == 0 and #CAMINHO_PADRAO > 0 then
        for _, v in ipairs(CAMINHO_PADRAO) do table.insert(caminhoT, v) end
    end
end

local function redesenharMarcas()
    pastaMarcas:ClearAllChildren()
    for i, pos in ipairs(caminhoT) do
        local marca = Instance.new("Part")
        marca.Shape = Enum.PartType.Ball
        marca.Size = Vector3.new(2, 2, 2)
        marca.Anchored = true
        marca.CanCollide = false
        marca.CanQuery = false
        marca.CanTouch = false
        marca.Material = Enum.Material.Neon
        marca.Color = Color3.fromRGB(255, 220, 60)
        marca.Transparency = 0.3
        marca.Position = pos
        marca.Parent = pastaMarcas

        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 30, 0, 30)
        bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.AlwaysOnTop = true
        bb.Parent = marca

        local num = Instance.new("TextLabel")
        num.Size = UDim2.new(1, 0, 1, 0)
        num.BackgroundTransparency = 1
        num.Text = tostring(i)
        num.TextColor3 = Color3.fromRGB(255, 255, 255)
        num.TextStrokeTransparency = 0
        num.TextSize = 16
        num.Font = Enum.Font.GothamBold
        num.Parent = bb
    end
    if labelCaminhoInfo then
        labelCaminhoInfo.Text = "📍 Pontos: " .. #caminhoT
    end
end

-- Último ponto = vulcão; pontos 1..n-1 = caverna
-- ESPERA_VULCAO agora é só uma ESTIMATIVA do tempo que o ovo fica na lava (usada em cálculo de velocidade).
-- A espera real no vulcão termina quando o ovo volta pra mão com o timer.
local ESPERA_VULCAO = 9
local TIMEOUT_VOLTA_LAVA = 30  -- segurança: se o ovo não voltar em 30s, cancela a espera

local function pontosCaverna()
    local r = {}
    local n = #caminhoT
    local fim = (n >= 2) and (n - 1) or n
    for i = 1, fim do table.insert(r, caminhoT[i]) end
    return r
end

local function pontosCavernaInvertidos()
    local r = {}
    local n = #caminhoT
    local fim = (n >= 2) and (n - 1) or n
    for i = fim, 1, -1 do table.insert(r, caminhoT[i]) end
    return r
end

local function pontoVulcao()
    if #caminhoT >= 2 then return caminhoT[#caminhoT] end
    return nil
end

-- Compat: caminho inteiro invertido (sem separar vulcão)
local function pontosInvertidos()
    return pontosCavernaInvertidos()
end

local LIMITE_CAMINHO = 2.5e12
local PRAZO_CAVERNA = 20
local function ovoPrecisaCaminho(letra, vNum)
    return letra == "T" and (vNum or 0) >= LIMITE_CAMINHO and #caminhoT > 0
end

local function comprimentoRota(origem, pontos)
    local total, atual = 0, origem
    for _, p in ipairs(pontos) do
        total += (p - atual).Magnitude
        atual = p
    end
    return total
end

local function seguirPontos(pontos, callback, rapido)
    local velVolta = (type(rapido) == "number") and rapido or VEL_CAMINHO_VOLTA
    local i = 0
    local epoca = PANICO.epoca
    local pausa = rapido and 0.1 or caminhoPausa
    local function proximo()
        if epoca ~= PANICO.epoca then return end
        i += 1
        if i > #pontos then
            if callback then task.spawn(callback) end
            return
        end
        local ponto = pontos[i]
        local function chegou()
            if pausa > 0 then task.wait(pausa) end
            proximo()
        end
        if caminhoModoAndar and not rapido then
            correrAteChaoAuto(ponto, chegou)
        else
            moverAutoIda(CFrame.new(ponto - Vector3.new(0, 3, 0)), chegou, rapido and velVolta or nil)
        end
    end
    proximo()
end

-- Move UM item específico para o chão no vulcão
local function jogarItemNoChao(item, destino)
    if not item or not item.Parent then return end
    pcall(function()
        if item:IsA("Tool") then
            pcall(function() item.CanBeDropped = true end)
        end
        local handle = item:IsA("Tool") and (item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true))
            or (item:IsA("Model") and item:FindFirstChildWhichIsA("BasePart", true))
            or (item:IsA("BasePart") and item)

        item.Parent = workspace

        if handle and handle:IsA("BasePart") and destino then
            handle.Anchored = false
            handle.CanCollide = true
            handle.CFrame = CFrame.new(destino + Vector3.new(0, 3, 0))
            handle.AssemblyLinearVelocity = Vector3.new(0, -5, 0)
            handle.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end

-- SOMENTE o que está equipado na mão (character)
local function obterFerramentaNaMao()
    local char = player.Character
    if not char then return nil end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Model") then
            local n = item.Name:lower()
            if n:find("egg") or n:find("ovo") then
                return item
            end
        end
    end
    return nil
end

-- Referência do último ovo que o script REALMENTE detectou ter pego (Tool/Model novo ou item novo no Basket)
local ultimoOvoPego = nil

-- Ovo equipado: o mesmo item que foi detectado na coleta, ou Tool/Model com "egg"/"ovo" no nome
local function ovoEquipado()
    local char = player.Character
    if not char then return false end
    local ref = ultimoOvoPego and ultimoOvoPego.item
    if ref and ref.Parent and ref:IsDescendantOf(char) then return true end
    for _, it in ipairs(char:GetChildren()) do
        if it:IsA("Tool") or it:IsA("Model") then
            local n = it.Name:lower()
            if n:find("egg") or n:find("ovo") then return true end
        end
    end
    return false
end

-- Confere se há ovo na mão: ovo equipado, barra vermelha do timer ou ovo no Basket
-- (NÃO conta qualquer Tool equipada, só o ovo)
local function temOvoNaMao()
    if ovoEquipado() then return true end
    _timerCacheAt = 0
    _timerCacheVal = nil
    if lerTimerRestanteReal() then return true end
    local ok, tem = pcall(function()
        local basket = player:FindFirstChild("Basket")
        if not basket then return false end
        local ref = ultimoOvoPego and ultimoOvoPego.item
        for _, filho in ipairs(basket:GetChildren()) do
            local n = filho.Name:lower()
            if filho == ref or n:find("egg") or n:find("ovo") then
                return true
            end
        end
        return false
    end)
    return ok and tem == true
end

-- Drop no vulcão: usa o mesmo fluxo do LocalScript DropEgg do jogo
-- Remote: VolcanoDip | Botão: PlayerGui.Main.ActionsHolder.DropEggVolcanoButton | Tecla: G
local function dispararVolcanoDip()
    local ok = false

    -- 1) Net:RemoteEvent("VolcanoDip") — exatamente como o DropEgg do jogo
    pcall(function()
        local RS = game:GetService("ReplicatedStorage")
        local packages = RS:FindFirstChild("packages") or RS:WaitForChild("packages", 2)
        if packages then
            local NetMod = packages:FindFirstChild("Net")
            if NetMod then
                local Net = require(NetMod)
                local remote = Net:RemoteEvent("VolcanoDip")
                if remote then
                    remote:FireServer()
                    ok = true
                    setStatus("🌋 VolcanoDip:FireServer() via Net")
                end
            end
        end
    end)

    -- 2) Fallback: achar RemoteEvent chamado VolcanoDip em qualquer lugar
    if not ok then
        pcall(function()
            for _, d in ipairs(game:GetDescendants()) do
                if d:IsA("RemoteEvent") and d.Name == "VolcanoDip" then
                    d:FireServer()
                    ok = true
                    setStatus("🌋 VolcanoDip:FireServer() direto")
                    break
                end
            end
        end)
    end

    return ok
end

-- Ativa SÓ DropEggVolcanoButton (sem mouse = não desmonta pet)
local function clicarBotaoDropEggVolcano()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return false end
    local main = pg:FindFirstChild("Main")
    if not main then return false end
    local holder = main:FindFirstChild("ActionsHolder")
    local volcanoBtn = holder and holder:FindFirstChild("DropEggVolcanoButton")
    if not volcanoBtn or not volcanoBtn:IsA("GuiButton") then
        return false
    end
    pcall(function() volcanoBtn.Visible = true end)
    local done = false
    pcall(function()
        if typeof(firesignal) == "function" then
            firesignal(volcanoBtn.Activated)
            done = true
        end
    end)
    pcall(function()
        if typeof(getconnections) == "function" then
            for _, c in ipairs(getconnections(volcanoBtn.Activated)) do
                pcall(function()
                    if c.Fire then c:Fire() elseif c.Function then c.Function() end
                end)
                done = true
            end
        end
    end)
    pcall(function() volcanoBtn:Activate() done = true end)
    if done then setStatus("🌋 DropEggVolcanoButton (1x, sem mouse)") end
    return done
end

--[[
  Solta ovo no vulcão UMA vez:
  - VolcanoDip:FireServer() (principal)
  - Se falhar: Activate no DropEggVolcanoButton
  Sem mouse na tela, sem tecla G (evita desmontar pet)
]]
local function soltarOvoNaMao(posVulcao)
    local char = player.Character
    if not char then return false end

    -- Sem ovo na mão não há o que soltar
    if not temOvoNaMao() then
        setStatus("⚠️ Sem ovo na mão — não vai soltar")
        return false
    end

    local rp = char:FindFirstChild("HumanoidRootPart")
    local destino = posVulcao or (rp and rp.Position)

    if rp and destino then
        pcall(function()
            rp.CFrame = CFrame.new(destino + Vector3.new(0, 3, 0))
            rp.AssemblyLinearVelocity = Vector3.zero
            rp.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    task.wait(0.6)

    setStatus("🌋 VolcanoDip 1x (sem spam)...")
    local okRemote = dispararVolcanoDip()
    task.wait(0.2)

    if not okRemote then
        clicarBotaoDropEggVolcano()
        task.wait(0.1)
    end

    setStatus("🌋 Dip enviado")
    return true
end

-- ===== Espera inteligente no vulcão =====
-- O ovo está "na lava" enquanto algum ovo do Basket tem VolcanoUntil no futuro.
local function ovoEstaNaLava()
    local emLava = false
    pcall(function()
        local basket = player:FindFirstChild("Basket")
        if not basket then return end
        local st = workspace:GetServerTimeNow()
        for _, egg in ipairs(basket:GetChildren()) do
            local u = egg:GetAttribute("VolcanoUntil")
            if type(u) == "number" and (u - st) > 0.2 then
                emLava = true
                return
            end
        end
    end)
    return emLava
end

-- Lê SÓ a barra vermelha do timer na tela (não usa o VolcanoUntil do Basket)
local function lerBarraTimerGui()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local melhor, melhorScore = nil, 0
    for _, d in ipairs(pg:GetDescendants()) do
        if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Visible ~= false then
            local txt = d.Text
            local n = parseSegundosDeTexto(txt)
            if n then
                local sc = scoreTimerOvo(d, txt, n)
                if sc > melhorScore then
                    melhorScore = sc
                    melhor = n
                end
            end
        end
    end
    return (melhorScore >= 30) and melhor or nil
end

-- Ovo voltou da lava = não está mais na lava E (barra do timer visível OU ovo equipado)
local function ovoVoltouDaLava()
    if ovoEstaNaLava() then return false end
    if lerBarraTimerGui() then return true end
    return ovoEquipado()
end

-- Fica parado no vulcão até o ovo voltar pra mão com timer.
-- Retorna true se o ovo voltou; false se foi cancelado (pânico) ou deu timeout.
local function esperarOvoVoltarDaLava(epoca, posVulcao)
    local function segurar()
        local c = player.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if r and posVulcao then
            r.CFrame = CFrame.new(posVulcao + Vector3.new(0, 5, 0))
            r.AssemblyLinearVelocity = Vector3.zero
            r.AssemblyAngularVelocity = Vector3.zero
        end
    end

    -- Fase 1: espera o ovo SAIR da mão (entrar na lava), no máximo 3s
    setStatus("🌋 Aguardando o ovo entrar na lava...")
    local t0 = os.clock()
    while os.clock() - t0 < 3 do
        if epoca ~= PANICO.epoca then return false end
        segurar()
        local saiu = ovoEstaNaLava() or not (lerBarraTimerGui() or ovoEquipado())
        if saiu then break end
        task.wait(0.15)
    end

    -- Fase 2: espera o ovo VOLTAR pra mão com o timer
    setStatus("⏳ Vulcão: esperando o ovo voltar pra mão (timer)...")
    local t1 = os.clock()
    while os.clock() - t1 < TIMEOUT_VOLTA_LAVA do
        if epoca ~= PANICO.epoca then return false end
        segurar()
        if ovoVoltouDaLava() then
            task.wait(0.15) -- confirma que não foi só um instante
            if ovoVoltouDaLava() then return true end
        end
        task.wait(0.15)
    end
    return false
end


-- Após pegar o ovo T: volta caverna (19→1) → vulcão → solta → espera ovo voltar → callback
local function cicloVoltaComVulcao(origemPos, epoca, aoTerminar)
    local rota = pontosCavernaInvertidos()
    local vulcao = pontoVulcao()
    local dist = comprimentoRota(origemPos, rota)
    local orcamento = math.max(PRAZO_CAVERNA - 4 - (#rota * 0.1) - (vulcao and ESPERA_VULCAO or 0), 3)
    local velRota = math.clamp(dist / orcamento, 450, 950)

    local function irAoVulcaoESoltar()
        if epoca ~= PANICO.epoca then return end
        if not vulcao then
            if aoTerminar then task.spawn(aoTerminar, false) end
            return
        end
        setStatus("🌋 Indo ao vulcão...")
        moverAutoIda(CFrame.new(vulcao), function()
            if epoca ~= PANICO.epoca then return end

            -- Chega e estabiliza no vulcão antes de soltar
            local char = player.Character
            local rp = char and char:FindFirstChild("HumanoidRootPart")
            if rp then
                rp.CFrame = CFrame.new(vulcao + Vector3.new(0, 4, 0))
                rp.AssemblyLinearVelocity = Vector3.zero
                rp.AssemblyAngularVelocity = Vector3.zero
            end
            task.wait(0.35)

            movimentoInfo.ativo = true
            setStatus("🌋 Soltando ovo na lava...")
            local soltou = soltarOvoNaMao(vulcao)

            if not soltou then
                movimentoInfo.ativo = false
                if aoTerminar then task.spawn(aoTerminar, false) end
                return
            end

            local voltou = esperarOvoVoltarDaLava(epoca, vulcao)
            movimentoInfo.ativo = false

            if epoca ~= PANICO.epoca then return end
            if voltou then
                setStatus("✅ Ovo de volta com timer — indo pra base...")
            else
                setStatus("⚠️ Ovo não voltou da lava (timeout) — seguindo mesmo assim")
            end
            if aoTerminar then task.spawn(aoTerminar, voltou) end
        end, 750)
    end

    if #rota == 0 then
        irAoVulcaoESoltar()
    else
        setStatus("🛤️ Saindo da caverna (volta invertida)...")
        seguirPontos(rota, irAoVulcaoESoltar, velRota)
    end
end

local function novoBotaoCaminho(texto, cor, altura, aoClicar)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, altura)
    b.BackgroundColor3 = cor
    b.Text = texto
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = isMobile and 10 or 11
    b.Font = Enum.Font.GothamBold
    b.Parent = paginaCaminho
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function() aoClicar(b) end)
    return b
end

local tituloCaminho = Instance.new("TextLabel")
tituloCaminho.Size = UDim2.new(1, 0, 0, 22)
tituloCaminho.BackgroundTransparency = 1
tituloCaminho.Text = "🛤️ Caminho especial para ovos T"
tituloCaminho.TextColor3 = Color3.fromRGB(160, 190, 255)
tituloCaminho.TextSize = 11
tituloCaminho.Font = Enum.Font.GothamBold
tituloCaminho.TextXAlignment = Enum.TextXAlignment.Left
tituloCaminho.Parent = paginaCaminho

labelCaminhoInfo = Instance.new("TextLabel")
labelCaminhoInfo.Size = UDim2.new(1, 0, 0, 30)
labelCaminhoInfo.BackgroundTransparency = 1
labelCaminhoInfo.TextColor3 = Color3.fromRGB(200, 210, 240)
labelCaminhoInfo.TextSize = 10
labelCaminhoInfo.Font = Enum.Font.Gotham
labelCaminhoInfo.TextWrapped = true
labelCaminhoInfo.TextXAlignment = Enum.TextXAlignment.Left
labelCaminhoInfo.Parent = paginaCaminho

novoBotaoCaminho("📍 Adicionar ponto", Color3.fromRGB(46, 160, 67), 34, function()
    local char = player.Character
    local rp = char and char:FindFirstChild("HumanoidRootPart")
    if not rp then return end
    table.insert(caminhoT, rp.Position)
    salvarCaminhoArquivo()
    redesenharMarcas()
end)

novoBotaoCaminho("↩️ Remover último", Color3.fromRGB(210, 130, 40), 30, function()
    table.remove(caminhoT)
    salvarCaminhoArquivo()
    redesenharMarcas()
end)

novoBotaoCaminho("🗑️ Limpar", Color3.fromRGB(200, 60, 60), 30, function()
    caminhoT = {}
    salvarCaminhoArquivo()
    redesenharMarcas()
end)

novoBotaoCaminho("▶️ Testar caminho (só ida caverna)", Color3.fromRGB(60, 130, 246), 30, function()
    local caverna = pontosCaverna()
    if #caverna == 0 then return end
    if labelCaminhoInfo then labelCaminhoInfo.Text = "▶️ Testando ida 1→" .. #caverna .. "..." end
    seguirPontos(caverna, function()
        if labelCaminhoInfo then labelCaminhoInfo.Text = "✅ Ida da caverna concluída!" end
    end)
end)

novoBotaoCaminho("🌋 Testar caminho COMPLETO (vulcão)", Color3.fromRGB(220, 90, 30), 36, function()
    if #caminhoT < 2 then
        if labelCaminhoInfo then labelCaminhoInfo.Text = "⚠️ Precisa de pelo menos 2 pontos (caverna + vulcão)!" end
        return
    end
    local epocaTeste = PANICO.epoca
    local caverna = pontosCaverna()
    local nCav = #caverna
    if labelCaminhoInfo then
        labelCaminhoInfo.Text = "🌋 Teste completo: ida 1→" .. nCav .. " → volta → vulcão → soltar → ovo volta → base"
    end
    setStatus("🌋 Teste: indo pela caverna (1→" .. nCav .. ")...")

    seguirPontos(caverna, function()
        if epocaTeste ~= PANICO.epoca then return end
        setStatus("🌋 Teste: voltando pela caverna...")
        if labelCaminhoInfo then labelCaminhoInfo.Text = "↩️ Voltando " .. nCav .. "→1..." end

        cicloVoltaComVulcao(caverna[#caverna] or player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or Vector3.zero, epocaTeste, function(passouVulcao)
            if epocaTeste ~= PANICO.epoca then return end
            local alvoBase = obterAlvoBase()
            if not alvoBase then
                setStatus("⚠️ Base não encontrada! Salve a base na aba Base.")
                if labelCaminhoInfo then labelCaminhoInfo.Text = "⚠️ Salve a base para testar a volta final" end
                return
            end
            -- Compensa o tempo do vulcão: orçamento menor → velocidade maior
            local tempoCompensado = math.max(PRAZO_CAVERNA - ESPERA_VULCAO, 8)
            if passouVulcao then
                tempoCompensado = math.max(tempoCompensado * 0.75, 5)
            end
            setStatus("🏡 Teste: voltando à base mais rápido...")
            moverAutoVoltaPorValor(alvoBase, tempoCompensado, function()
                setStatus("✅ Teste completo finalizado!")
                if labelCaminhoInfo then
                    labelCaminhoInfo.Text = "✅ Teste completo OK (caverna + vulcão + base)"
                end
            end)
        end)
    end)
end)


novoBotaoCaminho("📋 Copiar caminho (Lua)", Color3.fromRGB(30, 140, 160), 32, function()
    if #caminhoT == 0 then
        if labelCaminhoInfo then labelCaminhoInfo.Text = "⚠️ Nenhum ponto para copiar!" end
        return
    end
    local linhas = {"{"}
    for i, v in ipairs(caminhoT) do
        local virgula = (i < #caminhoT) and "," or ""
        table.insert(linhas, string.format(
            "    Vector3.new(%.2f, %.2f, %.2f)%s",
            v.X, v.Y, v.Z, virgula
        ))
    end
    table.insert(linhas, "}")
    local texto = table.concat(linhas, "\n")
    local ok = pcall(function()
        if setclipboard then
            setclipboard(texto)
        elseif toclipboard then
            toclipboard(texto)
        else
            error("sem clipboard")
        end
    end)
    if ok then
        if labelCaminhoInfo then
            labelCaminhoInfo.Text = "📋 Caminho copiado! (" .. #caminhoT .. " pontos) — cole no script ou no Discord"
        end
    else
        print("[EggHub] Caminho T (cole daqui se o clipboard falhar):\n" .. texto)
        if labelCaminhoInfo then
            labelCaminhoInfo.Text = "⚠️ Clipboard indisponível — veja o console (F9) para copiar"
        end
    end
end)

novoBotaoCaminho("📋 Copiar caminho (JSON)", Color3.fromRGB(30, 120, 140), 30, function()
    if #caminhoT == 0 then
        if labelCaminhoInfo then labelCaminhoInfo.Text = "⚠️ Nenhum ponto para copiar!" end
        return
    end
    local dados = {}
    for _, v in ipairs(caminhoT) do
        table.insert(dados, {
            x = tonumber(string.format("%.2f", v.X)),
            y = tonumber(string.format("%.2f", v.Y)),
            z = tonumber(string.format("%.2f", v.Z)),
        })
    end
    local texto = HttpService:JSONEncode(dados)
    local ok = pcall(function()
        if setclipboard then
            setclipboard(texto)
        elseif toclipboard then
            toclipboard(texto)
        else
            error("sem clipboard")
        end
    end)
    if ok then
        if labelCaminhoInfo then
            labelCaminhoInfo.Text = "📋 JSON copiado! (" .. #caminhoT .. " pontos)"
        end
    else
        print("[EggHub] Caminho T JSON:\n" .. texto)
        if labelCaminhoInfo then
            labelCaminhoInfo.Text = "⚠️ Clipboard indisponível — veja o console (F9) para copiar"
        end
    end
end)

novoBotaoCaminho("🕹️ Modo: VOANDO", Color3.fromRGB(140, 50, 200), 30, function(b)
    caminhoModoAndar = not caminhoModoAndar
    b.Text = caminhoModoAndar and "🕹️ Modo: ANDANDO" or "🕹️ Modo: VOANDO"
end)

novoBotaoCaminho("🔁 Volta invertida: SIM", Color3.fromRGB(140, 50, 200), 30, function(b)
    caminhoVoltaInvertida = not caminhoVoltaInvertida
    b.Text = caminhoVoltaInvertida and "🔁 Volta invertida: SIM" or "🔁 Volta invertida: NÃO"
end)

paginaCaminho.CanvasSize = UDim2.new(0, 0, 0, 620)
paginaCaminho.AutomaticCanvasSize = Enum.AutomaticSize.Y
carregarCaminhoArquivo()
redesenharMarcas()

-- ==================== ABA AUTO FARM ====================
local labelAutoTitulo = Instance.new("TextLabel")
labelAutoTitulo.Size = UDim2.new(1, 0, 0, 20)
labelAutoTitulo.BackgroundTransparency = 1
labelAutoTitulo.Text = "🤖 Auto Farm"
labelAutoTitulo.TextColor3 = Color3.fromRGB(160, 190, 255)
labelAutoTitulo.TextSize = 12
labelAutoTitulo.Font = Enum.Font.GothamBold
labelAutoTitulo.TextXAlignment = Enum.TextXAlignment.Left
labelAutoTitulo.Parent = paginaAuto

local btnModoIniciante = Instance.new("TextButton")
btnModoIniciante.Size = UDim2.new(1, 0, 0, 36)
btnModoIniciante.BackgroundColor3 = Color3.fromRGB(140, 50, 200)
btnModoIniciante.Text = "🐣 Modo Iniciante: DESLIGADO"
btnModoIniciante.TextColor3 = Color3.fromRGB(255, 255, 255)
btnModoIniciante.TextSize = isMobile and 11 or 12
btnModoIniciante.Font = Enum.Font.GothamBold
btnModoIniciante.Parent = paginaAuto
Instance.new("UICorner", btnModoIniciante).CornerRadius = UDim.new(0, 8)

btnModoIniciante.MouseButton1Click:Connect(function()
    modoIniciante = not modoIniciante
    if modoIniciante then
        btnModoIniciante.Text = "🐣 Modo Iniciante: LIGADO"
        btnModoIniciante.BackgroundColor3 = Color3.fromRGB(46, 160, 67)
    else
        btnModoIniciante.Text = "🐣 Modo Iniciante: DESLIGADO"
        btnModoIniciante.BackgroundColor3 = Color3.fromRGB(140, 50, 200)
    end
end)

local avisoIniciante = Instance.new("TextLabel")
avisoIniciante.Size = UDim2.new(1, 0, 0, 52)
avisoIniciante.BackgroundColor3 = Color3.fromRGB(40, 50, 30)
avisoIniciante.BackgroundTransparency = 0.2
avisoIniciante.Text = "🐣 Modo Iniciante: SALVE A BASE primeiro!\nPega ovos fracos → tenta colocar → tenta ABRIR ovos → tenta colocar de novo"
avisoIniciante.TextColor3 = Color3.fromRGB(180, 230, 140)
avisoIniciante.TextSize = 10
avisoIniciante.Font = Enum.Font.Gotham
avisoIniciante.TextWrapped = true
avisoIniciante.Parent = paginaAuto
Instance.new("UICorner", avisoIniciante).CornerRadius = UDim.new(0, 8)

-- ==================== FILTROS + PRIORIDADE ====================
local FIL = {
    letras = {M = false, B = false, T = false},
    faixas = {},          -- [id] = true
    exatos = {},          -- ["2.5T"] = true
    prioridade = "MAIOR", -- MAIOR | MENOR | PERTO
    visuais = {},
    visuaisExatos = {},
}

local FAIXAS = {
    {id = "BAIXO", nome = "< 1K / sem valor", min = -1,    max = 1e3},
    {id = "K",     nome = "K (mil)",          min = 1e3,   max = 1e6},
    {id = "1M",    nome = "1M – 7.9M",        min = 1e6,   max = 8e6},
    {id = "8M",    nome = "8M – 299M",        min = 8e6,   max = 300e6},
    {id = "300M",  nome = "300M – 1.9B",      min = 300e6, max = 2e9},
    {id = "2B",    nome = "2B – 209B",        min = 2e9,   max = 210e9},
    {id = "210B",  nome = "210B – 999B",      min = 210e9, max = 1e12},
    {id = "1T",    nome = "1T – 2.4T",        min = 1e12,  max = 2.5e12},
    {id = "2.5T",  nome = "2.5T +",           min = 2.5e12, max = math.huge},
}

function FIL.nenhum()
    return not (FIL.letras.M or FIL.letras.B or FIL.letras.T)
        and next(FIL.faixas) == nil
        and next(FIL.exatos) == nil
end

-- O ovo passa se bater com QUALQUER filtro marcado (letra, faixa ou valor exato)
function FIL.passa(num, letra)
    if FIL.nenhum() then return true end
    num = num or 0
    if letra and letra ~= "" and FIL.letras[letra] then return true end
    for _, f in ipairs(FAIXAS) do
        if FIL.faixas[f.id] and num >= f.min and num < f.max then return true end
    end
    if num > 0 and FIL.exatos[formatarValor(num)] then return true end
    return false
end

local COR_OFF = Color3.fromRGB(34, 34, 48)
local COR_ON = Color3.fromRGB(60, 130, 246)

local btnFiltros = Instance.new("TextButton")
btnFiltros.Size = UDim2.new(1, 0, 0, 32)
btnFiltros.BackgroundColor3 = Color3.fromRGB(40, 70, 140)
btnFiltros.Text = "🎚️ Filtros de ovos  ▼"
btnFiltros.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFiltros.TextSize = 12
btnFiltros.Font = Enum.Font.GothamBold
btnFiltros.Parent = paginaAuto
Instance.new("UICorner", btnFiltros).CornerRadius = UDim.new(0, 8)

local labelFiltroAuto = Instance.new("TextLabel")
labelFiltroAuto.Size = UDim2.new(1, 0, 0, 30)
labelFiltroAuto.BackgroundTransparency = 1
labelFiltroAuto.Text = "🎯 Pegando: Todas"
labelFiltroAuto.TextColor3 = Color3.fromRGB(200, 210, 240)
labelFiltroAuto.TextSize = 11
labelFiltroAuto.Font = Enum.Font.GothamBold
labelFiltroAuto.TextWrapped = true
labelFiltroAuto.TextXAlignment = Enum.TextXAlignment.Left
labelFiltroAuto.Parent = paginaAuto

local painelFiltros = Instance.new("Frame")
painelFiltros.Size = UDim2.new(1, 0, 0, 0)
painelFiltros.AutomaticSize = Enum.AutomaticSize.Y
painelFiltros.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
painelFiltros.Visible = false
painelFiltros.Parent = paginaAuto
Instance.new("UICorner", painelFiltros).CornerRadius = UDim.new(0, 8)

do
    local lp = Instance.new("UIListLayout")
    lp.SortOrder = Enum.SortOrder.LayoutOrder
    lp.Padding = UDim.new(0, 6)
    lp.Parent = painelFiltros
    local pp = Instance.new("UIPadding")
    pp.PaddingTop = UDim.new(0, 6)
    pp.PaddingBottom = UDim.new(0, 6)
    pp.PaddingLeft = UDim.new(0, 6)
    pp.PaddingRight = UDim.new(0, 6)
    pp.Parent = painelFiltros
end

local function tituloPainel(texto, ordem)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 16)
    l.LayoutOrder = ordem
    l.BackgroundTransparency = 1
    l.Text = texto
    l.TextColor3 = Color3.fromRGB(160, 190, 255)
    l.TextSize = 11
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = painelFiltros
    return l
end

local function novaGrade(ordem)
    local g = Instance.new("Frame")
    g.Size = UDim2.new(1, 0, 0, 0)
    g.AutomaticSize = Enum.AutomaticSize.Y
    g.LayoutOrder = ordem
    g.BackgroundTransparency = 1
    g.Parent = painelFiltros
    local gl = Instance.new("UIGridLayout")
    gl.CellSize = UDim2.new(0.5, -3, 0, 28)
    gl.CellPadding = UDim2.new(0, 6, 0, 5)
    gl.SortOrder = Enum.SortOrder.LayoutOrder
    gl.Parent = g
    return g
end

local function criarToggle(pai, texto, ordem, lerEstado, aoClicar, listaVisuais)
    local btn = Instance.new("TextButton")
    btn.LayoutOrder = ordem
    btn.BackgroundColor3 = COR_OFF
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(160, 165, 190)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.TextWrapped = true
    btn.Parent = pai
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local function visual()
        local ligado = lerEstado()
        btn.BackgroundColor3 = ligado and COR_ON or COR_OFF
        btn.TextColor3 = ligado and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 165, 190)
    end
    table.insert(listaVisuais, visual)
    visual()

    btn.MouseButton1Click:Connect(function()
        aoClicar()
        FIL.atualizar()
    end)
    return btn
end

function FIL.atualizar()
    for _, f in ipairs(FIL.visuais) do f() end
    for _, f in ipairs(FIL.visuaisExatos) do f() end

    local partes = {}
    for _, l in ipairs({"M", "B", "T"}) do
        if FIL.letras[l] then table.insert(partes, "Todos " .. l) end
    end
    for _, f in ipairs(FAIXAS) do
        if FIL.faixas[f.id] then table.insert(partes, f.nome) end
    end
    local exatos = {}
    for k in pairs(FIL.exatos) do table.insert(exatos, k) end
    table.sort(exatos)
    for _, k in ipairs(exatos) do table.insert(partes, k) end

    labelFiltroAuto.Text = (#partes == 0) and "🎯 Pegando: Todas"
        or ("🎯 Pegando: " .. table.concat(partes, " + "))
end

-- 1) Limpar tudo
local btnLimparFiltros = Instance.new("TextButton")
btnLimparFiltros.Size = UDim2.new(1, 0, 0, 28)
btnLimparFiltros.LayoutOrder = 1
btnLimparFiltros.BackgroundColor3 = Color3.fromRGB(200, 90, 50)
btnLimparFiltros.Text = "🧹 Limpar filtros (pegar todas)"
btnLimparFiltros.TextColor3 = Color3.fromRGB(255, 255, 255)
btnLimparFiltros.TextSize = 11
btnLimparFiltros.Font = Enum.Font.GothamBold
btnLimparFiltros.Parent = painelFiltros
Instance.new("UICorner", btnLimparFiltros).CornerRadius = UDim.new(0, 8)
btnLimparFiltros.MouseButton1Click:Connect(function()
    FIL.letras.M, FIL.letras.B, FIL.letras.T = false, false, false
    FIL.faixas = {}
    FIL.exatos = {}
    FIL.atualizar()
end)

-- 2) Por letra
tituloPainel("Por letra (todos os ovos daquela letra)", 2)
local gradeLetras = novaGrade(3)
for i, letra in ipairs({"M", "B", "T"}) do
    criarToggle(gradeLetras, "Todos " .. letra, i,
        function() return FIL.letras[letra] end,
        function() FIL.letras[letra] = not FIL.letras[letra] end,
        FIL.visuais)
end

-- 3) Por faixa de valor
tituloPainel("Por faixa de valor", 4)
local gradeFaixas = novaGrade(5)
for i, f in ipairs(FAIXAS) do
    criarToggle(gradeFaixas, f.nome, i,
        function() return FIL.faixas[f.id] == true end,
        function() FIL.faixas[f.id] = (not FIL.faixas[f.id]) or nil end,
        FIL.visuais)
end

-- 4) Valores exatos encontrados no mapa
tituloPainel("Valores exatos (ovos que existem no mapa agora)", 6)
local btnEscanearValores = Instance.new("TextButton")
btnEscanearValores.Size = UDim2.new(1, 0, 0, 28)
btnEscanearValores.LayoutOrder = 7
btnEscanearValores.BackgroundColor3 = Color3.fromRGB(46, 120, 90)
btnEscanearValores.Text = "🔍 Escanear valores do mapa"
btnEscanearValores.TextColor3 = Color3.fromRGB(255, 255, 255)
btnEscanearValores.TextSize = 11
btnEscanearValores.Font = Enum.Font.GothamBold
btnEscanearValores.Parent = painelFiltros
Instance.new("UICorner", btnEscanearValores).CornerRadius = UDim.new(0, 8)

FIL.gradeExatos = novaGrade(8)
FIL.btnEscanear = btnEscanearValores
btnEscanearValores.MouseButton1Click:Connect(function()
    if FIL.escanear then FIL.escanear() end
end)

-- Abrir / fechar o painel
local filtrosJaEscaneou = false
btnFiltros.MouseButton1Click:Connect(function()
    painelFiltros.Visible = not painelFiltros.Visible
    btnFiltros.Text = painelFiltros.Visible and "🎚️ Filtros de ovos  ▲" or "🎚️ Filtros de ovos  ▼"
    if painelFiltros.Visible and not filtrosJaEscaneou and FIL.escanear then
        filtrosJaEscaneou = true
        pcall(FIL.escanear)
    end
end)

-- Prioridade
local ROTULOS_PRIORIDADE = {
    MAIOR = "📈 Prioridade: MAIOR valor primeiro",
    MENOR = "📉 Prioridade: MENOR valor primeiro",
    PERTO = "📍 Prioridade: MAIS PERTO primeiro",
}
local ORDEM_PRIORIDADE = {"MAIOR", "MENOR", "PERTO"}

local btnPrioridade = Instance.new("TextButton")
btnPrioridade.Size = UDim2.new(1, 0, 0, 32)
btnPrioridade.BackgroundColor3 = Color3.fromRGB(110, 70, 180)
btnPrioridade.Text = ROTULOS_PRIORIDADE.MAIOR
btnPrioridade.TextColor3 = Color3.fromRGB(255, 255, 255)
btnPrioridade.TextSize = 11
btnPrioridade.Font = Enum.Font.GothamBold
btnPrioridade.Parent = paginaAuto
Instance.new("UICorner", btnPrioridade).CornerRadius = UDim.new(0, 8)

btnPrioridade.MouseButton1Click:Connect(function()
    for i, modo in ipairs(ORDEM_PRIORIDADE) do
        if modo == FIL.prioridade then
            FIL.prioridade = ORDEM_PRIORIDADE[(i % #ORDEM_PRIORIDADE) + 1]
            break
        end
    end
    btnPrioridade.Text = ROTULOS_PRIORIDADE[FIL.prioridade]
end)

FIL.atualizar()

local autoColetaAtivo = false
local farmOcupado = false  -- trava o loop enquanto um ciclo (vulcão/base) roda
local btnAutoColeta = Instance.new("TextButton")
btnAutoColeta.Size = UDim2.new(1, 0, 0, 38)
btnAutoColeta.BackgroundColor3 = Color3.fromRGB(140, 50, 200)
btnAutoColeta.Text = "🤖 Auto Farm: DESLIGADO"
btnAutoColeta.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAutoColeta.TextSize = 13
btnAutoColeta.Font = Enum.Font.GothamBold
btnAutoColeta.Parent = paginaAuto
Instance.new("UICorner", btnAutoColeta).CornerRadius = UDim.new(0, 8)

btnAutoColeta.MouseButton1Click:Connect(function()
    autoColetaAtivo = not autoColetaAtivo
    estadoNoclip.auto = autoColetaAtivo
    if autoColetaAtivo then
        btnAutoColeta.Text = "🤖 Auto Farm: LIGADO"
        btnAutoColeta.BackgroundColor3 = Color3.fromRGB(46, 160, 67)
    else
        btnAutoColeta.Text = "🤖 Auto Farm: DESLIGADO"
        btnAutoColeta.BackgroundColor3 = Color3.fromRGB(140, 50, 200)
    end
end)

-- Opção: após pegar o ovo, passar no vulcão antes da base
local jogarNoVulcao = false
local btnJogarVulcao = Instance.new("TextButton")
btnJogarVulcao.Size = UDim2.new(1, 0, 0, 36)
btnJogarVulcao.BackgroundColor3 = Color3.fromRGB(140, 50, 200)
btnJogarVulcao.Text = "🌋 Jogar no vulcão: DESLIGADO"
btnJogarVulcao.TextColor3 = Color3.fromRGB(255, 255, 255)
btnJogarVulcao.TextSize = isMobile and 11 or 12
btnJogarVulcao.Font = Enum.Font.GothamBold
btnJogarVulcao.Parent = paginaAuto
Instance.new("UICorner", btnJogarVulcao).CornerRadius = UDim.new(0, 8)

local avisoVulcao = Instance.new("TextLabel")
avisoVulcao.Size = UDim2.new(1, 0, 0, 48)
avisoVulcao.BackgroundColor3 = Color3.fromRGB(40, 30, 20)
avisoVulcao.BackgroundTransparency = 0.2
avisoVulcao.Text = "🌋 LIGADO: pega o ovo → vai RÁPIDO ao vulcão → solta só o da mão → espera o ovo VOLTAR pra mão com o timer → base mais rápida. Precisa do último ponto do Caminho T = vulcão."
avisoVulcao.TextColor3 = Color3.fromRGB(255, 200, 140)
avisoVulcao.TextSize = 10
avisoVulcao.Font = Enum.Font.Gotham
avisoVulcao.TextWrapped = true
avisoVulcao.Parent = paginaAuto
Instance.new("UICorner", avisoVulcao).CornerRadius = UDim.new(0, 8)

btnJogarVulcao.MouseButton1Click:Connect(function()
    jogarNoVulcao = not jogarNoVulcao
    if jogarNoVulcao then
        btnJogarVulcao.Text = "🌋 Jogar no vulcão: LIGADO"
        btnJogarVulcao.BackgroundColor3 = Color3.fromRGB(46, 160, 67)
        if not pontoVulcao() then
            setStatus("⚠️ Jogar no vulcão ligado, mas falta o ponto do vulcão no Caminho T!")
        end
    else
        btnJogarVulcao.Text = "🌋 Jogar no vulcão: DESLIGADO"
        btnJogarVulcao.BackgroundColor3 = Color3.fromRGB(140, 50, 200)
    end
end)

paginaAuto.CanvasSize = UDim2.new(0, 0, 0, 380)
paginaAuto.AutomaticCanvasSize = Enum.AutomaticSize.Y
do
    local layoutAuto = paginaAuto:FindFirstChildOfClass("UIListLayout")
    if layoutAuto then layoutAuto.SortOrder = Enum.SortOrder.LayoutOrder end
end

-- Status + contadores na aba Auto
local statusAuto = Instance.new("TextLabel")
statusAuto.Size = UDim2.new(1, 0, 0, 34)
statusAuto.BackgroundTransparency = 1
statusAuto.Text = "Status: aguardando..."
statusAuto.TextColor3 = Color3.fromRGB(255, 200, 100)
statusAuto.TextSize = 11
statusAuto.Font = Enum.Font.Gotham
statusAuto.TextWrapped = true
statusAuto.TextXAlignment = Enum.TextXAlignment.Left
statusAuto.Parent = paginaAuto
uiRef.statusAuto = statusAuto

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, 0, 0, 22)
statsLabel.BackgroundTransparency = 1
statsLabel.TextColor3 = Color3.fromRGB(160, 190, 255)
statsLabel.TextSize = 11
statsLabel.Font = Enum.Font.GothamBold
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Parent = paginaAuto

local stats = {pegos = 0, falhas = 0, retentativas = 0}
local function atualizarStats()
    statsLabel.Text = string.format("📊 Pegos: %d  |  Falhas: %d  |  Retentativas: %d",
        stats.pegos, stats.falhas, stats.retentativas)
end
atualizarStats()

local btnZerarStats = Instance.new("TextButton")
btnZerarStats.Size = UDim2.new(1, 0, 0, 26)
btnZerarStats.BackgroundColor3 = Color3.fromRGB(24, 24, 35)
btnZerarStats.Text = "🔄 Zerar contadores"
btnZerarStats.TextColor3 = Color3.fromRGB(200, 205, 225)
btnZerarStats.TextSize = 11
btnZerarStats.Font = Enum.Font.GothamMedium
btnZerarStats.Parent = paginaAuto
Instance.new("UICorner", btnZerarStats).CornerRadius = UDim.new(0, 8)
btnZerarStats.MouseButton1Click:Connect(function()
    stats.pegos, stats.falhas, stats.retentativas = 0, 0, 0
    atualizarStats()
end)

-- ==================== CONFIRMAÇÃO DE COLETA (anti-falha) ====================
local MAX_TENTATIVAS_PEGAR = 3      -- quantas vezes tenta pegar o mesmo ovo
local ESPERA_CONFIRMAR = 1.2        -- segundos esperando confirmar cada tentativa
local TEMPO_IGNORAR_OVO = 20        -- segundos ignorando um ovo que falhou

local ovosIgnorados = setmetatable({}, {__mode = "k"})

local function ignorarOvoTemporariamente(modelo, segundos)
    if modelo then ovosIgnorados[modelo] = os.clock() + (segundos or TEMPO_IGNORAR_OVO) end
end

local function ovoEstaIgnorado(modelo)
    local ate = ovosIgnorados[modelo]
    if not ate then return false end
    if os.clock() >= ate then
        ovosIgnorados[modelo] = nil
        return false
    end
    return true
end

local function contarItensCarregados()
    local n = 0
    local char = player.Character
    local bp = player:FindFirstChildOfClass("Backpack")
    if char then n += #char:GetChildren() end
    if bp then n += #bp:GetChildren() end
    return n
end

-- Foto do estado da mão ANTES de tentar pegar (pra detectar o que MUDOU)
local function tirarFotoMao()
    local foto = {tools = {}, basketSet = {}, timer = false}
    local char = player.Character
    if char then
        for _, it in ipairs(char:GetChildren()) do
            if it:IsA("Tool") or it:IsA("Model") then foto.tools[it] = true end
        end
    end
    local basket = player:FindFirstChild("Basket")
    if basket then
        for _, c in ipairs(basket:GetChildren()) do foto.basketSet[c] = true end
    end
    foto.timer = lerBarraTimerGui() ~= nil
    return foto
end

-- Só é "pego" se apareceu algo NOVO comparando com a foto. Retorna: pegou, item
local function detectarOvoNovo(foto, parteOvo)
    local char = player.Character
    if char then
        if parteOvo and parteOvo.Parent and parteOvo:IsDescendantOf(char) then
            return true, parteOvo:FindFirstAncestorOfClass("Tool") or parteOvo.Parent
        end
        for _, it in ipairs(char:GetChildren()) do
            if not foto.tools[it] then
                if it:IsA("Tool") then return true, it end
                if it:IsA("Model") then
                    local n = it.Name:lower()
                    if n:find("egg") or n:find("ovo") then return true, it end
                end
            end
        end
    end
    local basket = player:FindFirstChild("Basket")
    if basket then
        for _, c in ipairs(basket:GetChildren()) do
            if not foto.basketSet[c] then return true, c end
        end
    end
    if not foto.timer and lerBarraTimerGui() then return true, nil end
    return false
end

-- Retorna: pegou (bool), momento em que a tentativa bem-sucedida começou (os.clock)
local function pegarOvoComConfirmacao(parteOvo, modelo, maxTentativas)
    maxTentativas = maxTentativas or MAX_TENTATIVAS_PEGAR
    for tentativa = 1, maxTentativas do
        local foto = tirarFotoMao()
        local inicioTentativa = os.clock()
        acionarProximityPrompt(parteOvo)

        local limite = os.clock() + ESPERA_CONFIRMAR
        while os.clock() < limite do
            task.wait(0.1)
            local pegou, item = detectarOvoNovo(foto, parteOvo)
            if pegou then
                ultimoOvoPego = {item = item}
                stats.pegos += 1
                atualizarStats()
                setStatus("✅ Ovo pego com sucesso (tentativa " .. tentativa .. "/" .. maxTentativas .. ")")
                return true, inicioTentativa
            end
        end

        if tentativa < maxTentativas then
            stats.retentativas += 1
            atualizarStats()
            setStatus("🔁 Não confirmou a coleta, tentando de novo (" .. tentativa .. "/" .. maxTentativas .. ")...")
        end
    end
    stats.falhas += 1
    atualizarStats()
    return false, os.clock()
end

local function pegarOvosAutoLista()
    local lista = {}
    local jaAdicionado = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("egg") then
            if not obj.Name:lower():match("^workspace") and not obj.Parent.Name:lower():match("^workspace") then
                local estaEmBase = false
                local paiAtual = obj.Parent
                while paiAtual and paiAtual ~= workspace do
                    if paiAtual.Name:lower():find("plot") or paiAtual.Name:lower():find("base") then
                        estaEmBase = true
                        break
                    end
                    paiAtual = paiAtual.Parent
                end

                if not estaEmBase then
                    local modelo = obj.Parent
                    if not jaAdicionado[modelo] and not ovoEstaIgnorado(modelo) and not obj:IsDescendantOf(game.ReplicatedStorage) then
                        jaAdicionado[modelo] = true
                        local _, valorNum, letraOvo = lerValorDoModelo(modelo, obj)

                        if FIL.passa(valorNum, letraOvo) then
                            local charJ = player.Character
                            local rpJ = charJ and charJ:FindFirstChild("HumanoidRootPart")
                            local dist = rpJ and (obj.Position - rpJ.Position).Magnitude or 0
                            table.insert(lista, {parte = obj, modelo = modelo, nome = modelo.Name, vNum = valorNum, letra = letraOvo, dist = dist})
                        end
                    end
                end
            end
        end
    end

    if modoIniciante or FIL.prioridade == "MENOR" then
        table.sort(lista, function(a, b) return a.vNum < b.vNum end)
    elseif FIL.prioridade == "PERTO" then
        table.sort(lista, function(a, b)
            if math.abs(a.dist - b.dist) < 1 then return a.vNum > b.vNum end
            return a.dist < b.dist
        end)
    else
        table.sort(lista, function(a, b) return a.vNum > b.vNum end)
    end
    return lista
end

-- Função que só abre ovos (ignora crescimento e purchase)
local function isPromptDeAbrir(prompt)
    local nome = (prompt.Name or ""):lower()
    local obj = (prompt.ObjectText or ""):lower()
    local act = (prompt.ActionText or ""):lower()
    local texto = nome .. " " .. obj .. " " .. act

    -- Bloqueia crescimento e purchase
    if texto:find("grow") or texto:find("cresc") or texto:find("buy") or texto:find("purchase") or texto:find("comprar") or texto:find("robux") then
        return false
    end

    -- Só aceita se for claramente abrir
    if texto:find("open") or texto:find("hatch") or texto:find("abrir") or texto:find("chocar") or texto:find("quebra") then
        return true
    end

    return false
end

local function tentarAbrirOvosDaBase()
    local base = encontrarMinhaBase()
    if not base then return false end
    local abriuAlgum = false
    pcall(function()
        for _, desc in ipairs(base:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and isPromptDeAbrir(desc) then
                if fireproximityprompt then
                    fireproximityprompt(desc)
                    abriuAlgum = true
                    task.wait(0.15)
                end
            end
        end
    end)
    return abriuAlgum
end

local function tentarColocarOvo()
    apertarTecla1DuasVezes()
    task.wait(0.4)
end

task.spawn(function()
    while screenGui.Parent do
        task.wait(2.3)

        if modoIniciante and os.clock() < cooldownIniciante then
            continue
        end

        if autoColetaAtivo and not movimentoInfo.ativo and not farmOcupado then
            pcall(function()
                if modoIniciante and not basePosSalva then
                    setStatus("⚠️ MODO INICIANTE: Salve a base primeiro na aba Base!")
                    return
                end

                local lista = pegarOvosAutoLista()
                if #lista == 0 then return end

                local melhorOvo = lista[1]
                if not (melhorOvo and melhorOvo.parte and melhorOvo.parte.Parent) then return end
                farmOcupado = true
                local epocaCiclo = PANICO.epoca

                local timerDoOvo = obterTempoTimerPorValor(melhorOvo.vNum)
                local precisaCaminho = ovoPrecisaCaminho(melhorOvo.letra, melhorOvo.vNum)

                local function pegarEVoltar()
                    local pegou, tPegou = pegarOvoComConfirmacao(melhorOvo.parte, melhorOvo.modelo)
                    if epocaCiclo ~= PANICO.epoca then return end

                    if not pegou then
                        -- Falhou todas as tentativas: ignora esse ovo por um tempo e escolhe outro
                        ignorarOvoTemporariamente(melhorOvo.modelo, TEMPO_IGNORAR_OVO)
                        setStatus("⚠️ Não conseguiu pegar " .. tostring(melhorOvo.nome) .. ". Tentando outro ovo...")
                        if precisaCaminho then
                            -- Está dentro da caverna: sai pelo caminho de volta (sem vulcão)
                            seguirPontos(pontosCavernaInvertidos(), function()
                                farmOcupado = false
                            end, 650)
                        else
                            farmOcupado = false
                        end
                        return
                    end

                    local alvoBase = obterAlvoBase()
                    if not alvoBase then
                        setStatus("⚠️ Base não encontrada!")
                        farmOcupado = false
                        return
                    end

                    -- aoChegarBase: colocar ovo / modo iniciante
                    local function aoChegarBase()
                        if epocaCiclo ~= PANICO.epoca then return end
                        if not jaTentouColocar then
                            jaTentouColocar = true

                            -- 1. Tenta colocar
                            tentarColocarOvo()
                            task.wait(0.8)

                            if modoIniciante then
                                -- 2. Tenta ABRIR apenas (ignora crescimento)
                                local abriu = tentarAbrirOvosDaBase()
                                task.wait(1)

                                -- 3. Se abriu, tenta colocar de novo
                                if abriu then
                                    tentarColocarOvo()
                                    task.wait(0.6)
                                end
                            end

                            cooldownIniciante = os.clock() + 11
                            jaTentouColocar = false
                        end
                        farmOcupado = false
                    end

                    -- Volta à base pela velocidade do timer REAL do ovo (Tag "Timer" do jogo)
                    -- Fallback: tabela por valor.
                    local function irParaBase(passouPeloVulcao)
                        local decorrido = os.clock() - tPegou
                        -- Sempre relê a barra vermelha agora
                        _timerCacheAt = 0
                        _timerCacheVal = nil
                        local real = lerTimerRestanteReal()
                        local restante

                        if real and real > 0.8 then
                            restante = real
                            setStatus(string.format(
                                "🏡 Base TIMER REAL %.1fs (velocidade ao vivo)%s",
                                restante, passouPeloVulcao and " [pós-lava]" or ""
                            ))
                        elseif passouPeloVulcao then
                            -- Pós-lava sem barra ainda: original − 5
                            restante = math.max(timerDoOvo - 5, 4)
                            setStatus(string.format(
                                "🏡 Base estimado pós-lava %ds (sem barra ainda)",
                                restante
                            ))
                        else
                            restante = math.max(timerDoOvo - decorrido, 3)
                            setStatus(string.format(
                                "🏡 Base estimado %.0fs (ovo %ds − %.0fs)",
                                restante, timerDoOvo, decorrido
                            ))
                        end

                        -- moverAutoVoltaPorValor recalcula pelo timer real a cada 0.25s
                        moverAutoVoltaPorValor(alvoBase, restante, aoChegarBase)
                    end

                    -- Vulcão: ida rápida → dip → espera o ovo VOLTAR pra mão com timer → base pelo timer REAL
                    local function irAoVulcaoDepoisBase()
                        local vulcao = pontoVulcao()
                        if not (jogarNoVulcao and vulcao) then
                            irParaBase(false)
                            return
                        end

                        setStatus("🌋 Levando ovo ao vulcão (rápido)...")
                        moverAutoIda(CFrame.new(vulcao), function()
                            if epocaCiclo ~= PANICO.epoca then return end

                            local char = player.Character
                            local rp = char and char:FindFirstChild("HumanoidRootPart")
                            if rp then
                                rp.CFrame = CFrame.new(vulcao + Vector3.new(0, 5, 0))
                                rp.AssemblyLinearVelocity = Vector3.zero
                                rp.AssemblyAngularVelocity = Vector3.zero
                            end
                            task.wait(0.3)

                            -- Sem ovo na mão no vulcão: não solta nada, vai direto pra base
                            if not temOvoNaMao() then
                                setStatus("⚠️ Sem ovo na mão no vulcão — indo direto pra base")
                                irParaBase(false)
                                return
                            end

                            movimentoInfo.ativo = true
                            setStatus("🌋 Soltando ovo na lava...")
                            local soltou = soltarOvoNaMao(vulcao)

                            if not soltou then
                                movimentoInfo.ativo = false
                                irParaBase(false)
                                return
                            end

                            -- Espera o ovo voltar pra mão com o timer (em vez de segundos fixos)
                            local voltou = esperarOvoVoltarDaLava(epocaCiclo, vulcao)

                            if epocaCiclo ~= PANICO.epoca then
                                farmOcupado = false
                                movimentoInfo.ativo = false
                                return
                            end

                            movimentoInfo.ativo = false

                            if not voltou then
                                if not temOvoNaMao() then
                                    setStatus("⚠️ Ovo não voltou da lava — cancelando ciclo")
                                    farmOcupado = false
                                    return
                                end
                                setStatus("⚠️ Timeout esperando timer, mas há ovo na mão — indo à base...")
                            else
                                setStatus("✅ Ovo voltou com timer — indo à base...")
                            end
                            irParaBase(true)
                        end, 900)
                    end

                    -- Depois de pegar: se não tiver ovo na mão, cancela; senão sai da caverna e vai ao vulcão/base
                    local function aposPegarOvo()
                        -- Sem ovo na mão: cancela o ciclo (não faz caminho nem vulcão à toa)
                        if not temOvoNaMao() then
                            stats.falhas += 1
                            atualizarStats()
                            ignorarOvoTemporariamente(melhorOvo.modelo, TEMPO_IGNORAR_OVO)
                            setStatus("⚠️ Sem ovo na mão — cancelando ciclo")
                            if precisaCaminho then
                                seguirPontos(pontosCavernaInvertidos(), function()
                                    farmOcupado = false
                                end, 650)
                            else
                                farmOcupado = false
                            end
                            return
                        end

                        if precisaCaminho and caminhoVoltaInvertida then
                            local rota = pontosCavernaInvertidos()
                            if #rota > 0 then
                                local dist = comprimentoRota(melhorOvo.parte.Position, rota)
                                local orcamento = math.max(PRAZO_CAVERNA - 4 - (#rota * 0.1), 3)
                                local velRota = math.clamp(dist / orcamento, 450, 950)
                                setStatus("🛤️ Saindo da caverna...")
                                seguirPontos(rota, function()
                                    if epocaCiclo ~= PANICO.epoca then return end
                                    irAoVulcaoDepoisBase()
                                end, velRota)
                            else
                                irAoVulcaoDepoisBase()
                            end
                        else
                            irAoVulcaoDepoisBase()
                        end
                    end

                    aposPegarOvo()
                end

                local function irAoOvo()
                    moverAutoIda(melhorOvo.parte.CFrame, pegarEVoltar)
                end

                if precisaCaminho then
                    -- Ida só pela caverna (pontos 1..n-1); último ponto = vulcão
                    local caverna = pontosCaverna()
                    if #caverna > 0 then
                        seguirPontos(caverna, irAoOvo)
                    else
                        irAoOvo()
                    end
                else
                    irAoOvo()
                end
            end)
        end
    end
end)

-- ==================== ABA OVOS MANUAL ====================
local btnAtualizar = Instance.new("TextButton")
btnAtualizar.Size = UDim2.new(1, 0, 0, 32)
btnAtualizar.BackgroundColor3 = Color3.fromRGB(50, 130, 246)
btnAtualizar.Text = "🔄 Escanear Ovos"
btnAtualizar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAtualizar.TextSize = 11
btnAtualizar.Font = Enum.Font.GothamBold
btnAtualizar.Parent = paginaOvos
Instance.new("UICorner", btnAtualizar).CornerRadius = UDim.new(0, 8)

local containerOvos = Instance.new("ScrollingFrame")
containerOvos.Size = UDim2.new(1, 0, 1, -38)
containerOvos.Position = UDim2.new(0, 0, 0, 38)
containerOvos.BackgroundTransparency = 1
containerOvos.CanvasSize = UDim2.new(0, 0, 0, 0)
containerOvos.Parent = paginaOvos
Instance.new("UIListLayout", containerOvos).Padding = UDim.new(0, 5)

local function pegarOvosLivresListaGeral()
    local lista = {}
    local jaAdicionado = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("egg") then
            if not obj.Name:lower():match("^workspace") and not obj.Parent.Name:lower():match("^workspace") then
                local estaEmBase = false
                local paiAtual = obj.Parent
                while paiAtual and paiAtual ~= workspace do
                    if paiAtual.Name:lower():find("plot") or paiAtual.Name:lower():find("base") then
                        estaEmBase = true
                        break
                    end
                    paiAtual = paiAtual.Parent
                end

                if not estaEmBase then
                    local modelo = obj.Parent
                    if not jaAdicionado[modelo] and not obj:IsDescendantOf(game.ReplicatedStorage) then
                        jaAdicionado[modelo] = true
                        local valorTexto, valorNum, letraOvo = lerValorDoModelo(modelo, obj)
                        table.insert(lista, {parte = obj, nome = modelo.Name, vStr = valorTexto, vNum = valorNum, letra = letraOvo})
                    end
                end
            end
        end
    end
    table.sort(lista, function(a, b) return a.vNum > b.vNum end)
    return lista
end

FIL.escanear = function()
    local chaves, valores = {}, {}
    for k in pairs(FIL.exatos) do
        chaves[k] = true
        valores[k] = (extrairTextoValor(k))
    end

    local ok, lista = pcall(pegarOvosLivresListaGeral)
    if ok and lista then
        for _, item in ipairs(lista) do
            if item.vNum and item.vNum > 0 then
                local k = formatarValor(item.vNum)
                chaves[k] = true
                valores[k] = item.vNum
            end
        end
    end

    local ordenadas = {}
    for k in pairs(chaves) do table.insert(ordenadas, k) end
    table.sort(ordenadas, function(a, b) return (valores[a] or 0) > (valores[b] or 0) end)

    for _, b in ipairs(FIL.gradeExatos:GetChildren()) do
        if b:IsA("TextButton") then b:Destroy() end
    end
    FIL.visuaisExatos = {}

    for i, k in ipairs(ordenadas) do
        if i > 24 then break end
        criarToggle(FIL.gradeExatos, "💰 " .. k, i,
            function() return FIL.exatos[k] == true end,
            function() FIL.exatos[k] = (not FIL.exatos[k]) or nil end,
            FIL.visuaisExatos)
    end

    FIL.btnEscanear.Text = "🔍 Escanear valores do mapa (" .. #ordenadas .. " encontrados)"
    FIL.atualizar()
end

local function carregarOvosManual()
    for _, child in ipairs(containerOvos:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local lista = pegarOvosLivresListaGeral()

    for _, item in ipairs(lista) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 34)
        card.BackgroundColor3 = Color3.fromRGB(24, 24, 35)
        card.Parent = containerOvos
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -140, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.BackgroundTransparency = 1
        local textoValor = (item.vNum and item.vNum > 0) and formatarValor(item.vNum) or "sem valor"
        lbl.Text = "💰 " .. textoValor .. "  |  " .. item.nome
        lbl.TextWrapped = false
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.TextColor3 = Color3.fromRGB(220, 225, 240)
        lbl.TextSize = 10
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = card

        local btnRadar = Instance.new("TextButton")
        btnRadar.Size = UDim2.new(0, 32, 0, 26)
        btnRadar.Position = UDim2.new(1, -130, 0, 4)
        btnRadar.BackgroundColor3 = (radarAlvo == item.parte) and Color3.fromRGB(230, 170, 30) or Color3.fromRGB(60, 60, 90)
        btnRadar.Text = "🎯"
        btnRadar.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnRadar.TextSize = 13
        btnRadar.Font = Enum.Font.GothamBold
        btnRadar.Parent = card
        Instance.new("UICorner", btnRadar).CornerRadius = UDim.new(0, 6)
        radarBotoes[btnRadar] = true

        btnRadar.MouseButton1Click:Connect(function()
            if radarAlvo == item.parte then
                pararRadar()
            else
                pararRadar()
                radarAlvo = item.parte
                radarNome = item.nome
                btnRadar.BackgroundColor3 = Color3.fromRGB(230, 170, 30)
            end
        end)

        local btnColetar = Instance.new("TextButton")
        btnColetar.Size = UDim2.new(0, 90, 0, 26)
        btnColetar.Position = UDim2.new(1, -95, 0, 4)
        btnColetar.BackgroundColor3 = Color3.fromRGB(46, 160, 67)
        btnColetar.Text = "⚡ Ir"
        btnColetar.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnColetar.TextSize = 11
        btnColetar.Font = Enum.Font.GothamBold
        btnColetar.Parent = card
        Instance.new("UICorner", btnColetar).CornerRadius = UDim.new(0, 6)

        local ultimoClique = 0
        btnColetar.MouseButton1Click:Connect(function()
            if os.clock() - ultimoClique < 1 then return end
            ultimoClique = os.clock()
            if item.parte and item.parte.Parent then
                local function irEPegar()
                    correrAteManual(item.parte.CFrame, function()
                        task.spawn(function()
                            local pegou = pegarOvoComConfirmacao(item.parte, item.parte.Parent)
                            if not pegou then
                                setStatus("⚠️ Não conseguiu pegar o ovo. Tente de novo.")
                            end
                        end)
                    end)
                end
                if ovoPrecisaCaminho(item.letra, item.vNum) then
                    local caverna = pontosCaverna()
                    if #caverna > 0 then
                        seguirPontos(caverna, irEPegar)
                    else
                        irEPegar()
                    end
                else
                    irEPegar()
                end
            end
        end)
    end
    containerOvos.CanvasSize = UDim2.new(0, 0, 0, #lista * 38)
end

btnAtualizar.MouseButton1Click:Connect(carregarOvosManual)
carregarOvosManual()

-- ==================== MARCADOR DO OVO MAIS VALIOSO ====================
local MELHOR = {ativo = true, alvo = nil, highlight = nil, billboard = nil}

do
    local melhorFrame = Instance.new("Frame")
    melhorFrame.Size = UDim2.new(1, 0, 1, 0)
    melhorFrame.BackgroundTransparency = 1
    melhorFrame.Visible = false
    melhorFrame.ZIndex = 48
    melhorFrame.Parent = screenGui

    local melhorSeta = Instance.new("TextLabel")
    melhorSeta.Size = UDim2.new(0, 36, 0, 36)
    melhorSeta.AnchorPoint = Vector2.new(0.5, 0.5)
    melhorSeta.BackgroundTransparency = 1
    melhorSeta.Text = "➤"
    melhorSeta.TextColor3 = Color3.fromRGB(255, 140, 0)
    melhorSeta.TextStrokeTransparency = 0
    melhorSeta.TextSize = 32
    melhorSeta.Font = Enum.Font.GothamBold
    melhorSeta.ZIndex = 49
    melhorSeta.Parent = melhorFrame

    local melhorTexto = Instance.new("TextLabel")
    melhorTexto.Size = UDim2.new(0, 170, 0, 32)
    melhorTexto.AnchorPoint = Vector2.new(0.5, 0)
    melhorTexto.BackgroundTransparency = 1
    melhorTexto.TextColor3 = Color3.fromRGB(255, 200, 80)
    melhorTexto.TextStrokeTransparency = 0
    melhorTexto.TextSize = 11
    melhorTexto.Font = Enum.Font.GothamBold
    melhorTexto.TextWrapped = true
    melhorTexto.ZIndex = 49
    melhorTexto.Parent = melhorFrame

    -- Rótulo na aba Auto (fica no topo)
    local labelMelhorOvo = Instance.new("TextLabel")
    labelMelhorOvo.Size = UDim2.new(1, 0, 0, 34)
    labelMelhorOvo.LayoutOrder = -5
    labelMelhorOvo.BackgroundColor3 = Color3.fromRGB(45, 35, 15)
    labelMelhorOvo.BackgroundTransparency = 0.2
    labelMelhorOvo.Text = "⭐ Maior ovo: procurando..."
    labelMelhorOvo.TextColor3 = Color3.fromRGB(255, 210, 120)
    labelMelhorOvo.TextSize = 11
    labelMelhorOvo.Font = Enum.Font.GothamBold
    labelMelhorOvo.TextWrapped = true
    labelMelhorOvo.Parent = paginaAuto
    Instance.new("UICorner", labelMelhorOvo).CornerRadius = UDim.new(0, 8)
    labelAutoTitulo.LayoutOrder = -10

    local function limparMarcas()
        if MELHOR.highlight then MELHOR.highlight:Destroy() MELHOR.highlight = nil end
        if MELHOR.billboard then MELHOR.billboard:Destroy() MELHOR.billboard = nil end
    end

    MELHOR.limpar = function()
        limparMarcas()
        MELHOR.alvo = nil
        melhorFrame.Visible = false
        labelMelhorOvo.Text = MELHOR.ativo and "⭐ Maior ovo: procurando..." or "⭐ Marcador do maior ovo: DESLIGADO"
    end

    local function definirAlvo(item)
        limparMarcas()
        MELHOR.alvo = {parte = item.parte, nome = item.nome, vNum = item.vNum}

        local adornee = item.parte.Parent
        if not (adornee and adornee:IsA("Model")) then adornee = item.parte end

        local hl = Instance.new("Highlight")
        hl.Name = "MelhorOvoHighlight"
        hl.FillColor = Color3.fromRGB(255, 170, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.4
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = adornee
        hl.Parent = screenGui
        MELHOR.highlight = hl

        local bb = Instance.new("BillboardGui")
        bb.Name = "MelhorOvoRotulo"
        bb.Size = UDim2.new(0, 170, 0, 44)
        bb.StudsOffset = Vector3.new(0, 6, 0)
        bb.AlwaysOnTop = true
        bb.Adornee = item.parte
        bb.Parent = screenGui

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = "⭐ " .. formatarValor(item.vNum) .. "\n" .. tostring(item.nome)
        txt.TextColor3 = Color3.fromRGB(255, 210, 80)
        txt.TextStrokeTransparency = 0
        txt.TextSize = 16
        txt.Font = Enum.Font.GothamBold
        txt.TextWrapped = true
        txt.Parent = bb
        MELHOR.billboard = bb
    end

    -- Posição da seta na tela (na frente do ovo, ou na borda apontando a direção)
    local function posicaoSeta(posMundo)
        local cam = workspace.CurrentCamera
        if not cam then return nil end
        local centro = cam.ViewportSize / 2
        local v, naTela = cam:WorldToViewportPoint(posMundo)
        if naTela and v.Z > 0 then
            return Vector2.new(v.X, v.Y - 45), 90
        end
        local rel = cam.CFrame:PointToObjectSpace(posMundo)
        local dir = Vector2.new(rel.X, -rel.Y)
        if dir.Magnitude < 0.001 then dir = Vector2.new(0, -1) end
        dir = dir.Unit
        local margemX, margemY = centro.X - 40, centro.Y - 60
        local escala = math.min(
            margemX / math.max(math.abs(dir.X), 0.0001),
            margemY / math.max(math.abs(dir.Y), 0.0001)
        )
        return centro + dir * escala, math.deg(math.atan2(dir.Y, dir.X))
    end

    local ultimoTexto = 0
    local conexaoSeta = RunService.RenderStepped:Connect(function()
        local alvo = MELHOR.alvo
        if not MELHOR.ativo or not alvo then
            melhorFrame.Visible = false
            return
        end
        local parte = alvo.parte
        local char = player.Character
        if not parte or not parte.Parent or not parte:IsDescendantOf(workspace)
            or (char and parte:IsDescendantOf(char)) then
            MELHOR.limpar()
            return
        end
        local rp = char and char:FindFirstChild("HumanoidRootPart")
        if not rp then return end

        local dist = (parte.Position - rp.Position).Magnitude
        local pos, rot = posicaoSeta(parte.Position)
        if not pos then return end

        melhorFrame.Visible = true
        melhorSeta.Position = UDim2.fromOffset(pos.X, pos.Y)
        melhorSeta.Rotation = rot
        melhorTexto.Position = UDim2.fromOffset(pos.X, pos.Y + 20)
        melhorTexto.Text = string.format("⭐ %s\n%d studs", formatarValor(alvo.vNum), math.floor(dist))

        if os.clock() - ultimoTexto > 0.3 then
            ultimoTexto = os.clock()
            labelMelhorOvo.Text = string.format("⭐ Maior ovo: %s | %s | %d studs",
                formatarValor(alvo.vNum), tostring(alvo.nome), math.floor(dist))
        end
    end)
    screenGui.Destroying:Connect(function() conexaoSeta:Disconnect() end)

    -- Procura o ovo mais valioso do mapa a cada 3s (empate: o mais perto)
    task.spawn(function()
        while screenGui.Parent do
            if MELHOR.ativo then
                local ok, lista = pcall(pegarOvosLivresListaGeral)
                local melhor
                if ok and lista then
                    local char = player.Character
                    local rp = char and char:FindFirstChild("HumanoidRootPart")
                    local function dist(it)
                        return rp and (it.parte.Position - rp.Position).Magnitude or 0
                    end
                    for _, it in ipairs(lista) do
                        if it.parte and it.parte.Parent and it.vNum and it.vNum > 0 then
                            if not melhor or it.vNum > melhor.vNum
                                or (it.vNum == melhor.vNum and dist(it) < dist(melhor)) then
                                melhor = it
                            end
                        end
                    end
                end
                if melhor then
                    if not MELHOR.alvo or MELHOR.alvo.parte ~= melhor.parte then
                        definirAlvo(melhor)
                    else
                        MELHOR.alvo.vNum = melhor.vNum
                    end
                elseif MELHOR.alvo then
                    MELHOR.limpar()
                end
            end
            task.wait(3)
        end
    end)

    -- Botão liga/desliga (aba ESP)
    local lyESP = paginaESP:FindFirstChildOfClass("UIListLayout")
    if lyESP then lyESP.SortOrder = Enum.SortOrder.LayoutOrder end

    local btnMelhor = Instance.new("TextButton")
    btnMelhor.Size = UDim2.new(1, 0, 0, 38)
    btnMelhor.LayoutOrder = 10
    btnMelhor.BackgroundColor3 = Color3.fromRGB(46, 160, 67)
    btnMelhor.Text = "⭐ Marcar ovo mais valioso: LIGADO"
    btnMelhor.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnMelhor.TextSize = 12
    btnMelhor.Font = Enum.Font.GothamBold
    btnMelhor.TextWrapped = true
    btnMelhor.Parent = paginaESP
    Instance.new("UICorner", btnMelhor).CornerRadius = UDim.new(0, 8)

    btnMelhor.MouseButton1Click:Connect(function()
        MELHOR.ativo = not MELHOR.ativo
        btnMelhor.Text = MELHOR.ativo and "⭐ Marcar ovo mais valioso: LIGADO" or "⭐ Marcar ovo mais valioso: DESLIGADO"
        btnMelhor.BackgroundColor3 = MELHOR.ativo and Color3.fromRGB(46, 160, 67) or Color3.fromRGB(140, 50, 200)
        MELHOR.limpar()
    end)
end

-- ==================== ABA EXTRAS (ANTI-LAG) ====================
do
    local Lighting = game:GetService("Lighting")
    local EFEITOS = {
        ParticleEmitter = true, Trail = true, Beam = true, Smoke = true, Fire = true, Sparkles = true,
        BloomEffect = true, BlurEffect = true, ColorCorrectionEffect = true,
        DepthOfFieldEffect = true, SunRaysEffect = true,
    }

    ANTILAG.salvos = setmetatable({}, {__mode = "k"})
    ANTILAG.ativo = false
    ANTILAG.economia = false
    ANTILAG.conexao = nil
    ANTILAG.originais = {}

    local function reduzir(inst)
        if EFEITOS[inst.ClassName] and ANTILAG.salvos[inst] == nil then
            local ok, valor = pcall(function() return inst.Enabled end)
            if ok then
                ANTILAG.salvos[inst] = valor
                pcall(function() inst.Enabled = false end)
            end
        end
    end

    ANTILAG.ligar = function()
        if ANTILAG.ativo then return end
        ANTILAG.ativo = true
        local o = {}
        ANTILAG.originais = o

        pcall(function()
            o.sombras = Lighting.GlobalShadows
            Lighting.GlobalShadows = false
        end)
        pcall(function()
            local r = settings().Rendering
            o.qualidade = r.QualityLevel
            r.QualityLevel = Enum.QualityLevel.Level01
        end)
        pcall(function()
            local t = workspace:FindFirstChildOfClass("Terrain")
            if t then
                o.agua = {t.WaterWaveSize, t.WaterWaveSpeed, t.WaterReflectance}
                t.WaterWaveSize = 0
                t.WaterWaveSpeed = 0
                t.WaterReflectance = 0
            end
        end)

        ANTILAG.conexao = workspace.DescendantAdded:Connect(reduzir)
        task.spawn(function()
            local n = 0
            for _, d in ipairs(workspace:GetDescendants()) do
                if not ANTILAG.ativo then return end
                reduzir(d)
                n += 1
                if n % 400 == 0 then task.wait() end
            end
            for _, d in ipairs(Lighting:GetDescendants()) do reduzir(d) end
        end)
    end

    ANTILAG.desligar = function()
        if not ANTILAG.ativo then return end
        ANTILAG.ativo = false
        if ANTILAG.conexao then ANTILAG.conexao:Disconnect() ANTILAG.conexao = nil end

        for inst, valor in pairs(ANTILAG.salvos) do
            pcall(function() inst.Enabled = valor end)
            ANTILAG.salvos[inst] = nil
        end

        local o = ANTILAG.originais or {}
        pcall(function()
            if o.sombras ~= nil then Lighting.GlobalShadows = o.sombras end
        end)
        pcall(function()
            if o.qualidade ~= nil then settings().Rendering.QualityLevel = o.qualidade end
        end)
        pcall(function()
            local t = workspace:FindFirstChildOfClass("Terrain")
            if t and o.agua then
                t.WaterWaveSize, t.WaterWaveSpeed, t.WaterReflectance = o.agua[1], o.agua[2], o.agua[3]
            end
        end)
        ANTILAG.originais = {}
    end

    -- Desliga o desenho 3D (a tela fica preta, o menu continua aparecendo)
    ANTILAG.setEconomia = function(ligar)
        local ok = pcall(function() RunService:Set3dRenderingEnabled(not ligar) end)
        if ok then ANTILAG.economia = ligar end
        return ok
    end

    ANTILAG.restaurar = function()
        ANTILAG.desligar()
        if ANTILAG.economia then ANTILAG.setEconomia(false) end
    end

    screenGui.Destroying:Connect(function() pcall(ANTILAG.restaurar) end)

    -- Interface
    local function tituloExtras(texto)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 20)
        l.BackgroundTransparency = 1
        l.Text = texto
        l.TextColor3 = Color3.fromRGB(160, 190, 255)
        l.TextSize = 11
        l.Font = Enum.Font.GothamBold
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = paginaExtras
    end

    local function descricaoExtras(texto, altura)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, altura or 44)
        l.BackgroundTransparency = 1
        l.Text = texto
        l.TextColor3 = Color3.fromRGB(170, 175, 195)
        l.TextSize = 10
        l.Font = Enum.Font.Gotham
        l.TextWrapped = true
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Top
        l.Parent = paginaExtras
    end

    local function botaoExtras(texto)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 36)
        b.BackgroundColor3 = Color3.fromRGB(140, 50, 200)
        b.Text = texto
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.TextSize = 12
        b.Font = Enum.Font.GothamBold
        b.TextWrapped = true
        b.Parent = paginaExtras
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        return b
    end

    local lyExtras = paginaExtras:FindFirstChildOfClass("UIListLayout")
    if lyExtras then lyExtras.SortOrder = Enum.SortOrder.LayoutOrder end
    paginaExtras.AutomaticCanvasSize = Enum.AutomaticSize.Y

    tituloExtras("🚀 Desempenho (celular)")

    local btnAntiLag = botaoExtras("🚀 Anti-lag: DESLIGADO")
    descricaoExtras("Desliga partículas, rastros, brilho e efeitos de tela, sombras e ondas da água, e baixa a qualidade gráfica. Ao desligar, tudo volta como estava.", 54)
    btnAntiLag.MouseButton1Click:Connect(function()
        if ANTILAG.ativo then ANTILAG.desligar() else ANTILAG.ligar() end
        btnAntiLag.Text = ANTILAG.ativo and "🚀 Anti-lag: LIGADO" or "🚀 Anti-lag: DESLIGADO"
        btnAntiLag.BackgroundColor3 = ANTILAG.ativo and Color3.fromRGB(46, 160, 67) or Color3.fromRGB(140, 50, 200)
    end)

    local btnEconomia = botaoExtras("🔋 Modo economia (desliga o 3D): DESLIGADO")
    descricaoExtras("A tela do jogo fica preta e o menu continua funcionando. Economiza muita bateria e FPS enquanto o auto farm roda. As marcações 3D (destaque e rótulo do maior ovo) somem, mas a seta na tela continua.", 66)
    btnEconomia.MouseButton1Click:Connect(function()
        local ok = ANTILAG.setEconomia(not ANTILAG.economia)
        if not ok then
            btnEconomia.Text = "🔋 Modo economia: não suportado neste executor"
            return
        end
        btnEconomia.Text = ANTILAG.economia and "🔋 Modo economia (desliga o 3D): LIGADO" or "🔋 Modo economia (desliga o 3D): DESLIGADO"
        btnEconomia.BackgroundColor3 = ANTILAG.economia and Color3.fromRGB(46, 160, 67) or Color3.fromRGB(140, 50, 200)
    end)
end

-- ==================== ABA BASE ====================
local statusBase = Instance.new("TextLabel")
statusBase.Size = UDim2.new(1, 0, 0, 40)
statusBase.BackgroundTransparency = 1
statusBase.Text = "⚠️ IMPORTANTE: Salve a base antes de usar o Modo Iniciante!"
statusBase.TextColor3 = Color3.fromRGB(255, 200, 100)
statusBase.TextSize = 11
statusBase.Font = Enum.Font.Gotham
statusBase.TextWrapped = true
statusBase.TextXAlignment = Enum.TextXAlignment.Left
statusBase.Parent = paginaBase
uiRef.status = statusBase

local btnSalvarBase = Instance.new("TextButton")
btnSalvarBase.Size = UDim2.new(1, 0, 0, 38)
btnSalvarBase.BackgroundColor3 = Color3.fromRGB(46, 160, 67)
btnSalvarBase.Text = "📍 SALVAR BASE ATUAL (obrigatório)"
btnSalvarBase.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSalvarBase.TextSize = 12
btnSalvarBase.Font = Enum.Font.GothamBold
btnSalvarBase.Parent = paginaBase
Instance.new("UICorner", btnSalvarBase).CornerRadius = UDim.new(0, 8)

btnSalvarBase.MouseButton1Click:Connect(function()
    local char = player.Character
    local rp = char and char:FindFirstChild("HumanoidRootPart")
    if rp then
        basePosSalva = rp.Position
        statusBase.Text = "✅ Base salva com sucesso! Agora pode usar o Modo Iniciante."
        statusBase.TextColor3 = Color3.fromRGB(100, 255, 140)
    end
end)

local btnIrBase = Instance.new("TextButton")
btnIrBase.Size = UDim2.new(1, 0, 0, 38)
btnIrBase.BackgroundColor3 = Color3.fromRGB(210, 130, 40)
btnIrBase.Text = "🏡 Voltar pra Base (300m)"
btnIrBase.TextColor3 = Color3.fromRGB(255, 255, 255)
btnIrBase.TextSize = 12
btnIrBase.Font = Enum.Font.GothamBold
btnIrBase.Parent = paginaBase
Instance.new("UICorner", btnIrBase).CornerRadius = UDim.new(0, 8)

btnIrBase.MouseButton1Click:Connect(function()
    voltarParaCasaManual300M()
end)

RunService.Heartbeat:Connect(function()
    if movimentoInfo.ativo then
        statusBase.Text = string.format("🏃 Distância: %d studs", math.floor(movimentoInfo.dist))
        statusBase.TextColor3 = Color3.fromRGB(180, 190, 220)
    end
end)

-- ==================== ABA FLY ====================
local function criarTituloFly(texto)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.Text = texto
    l.TextColor3 = Color3.fromRGB(160, 190, 255)
    l.TextSize = 11
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = paginaFly
    return l
end

criarTituloFly("🕊️ Velocidade do Fly")
local flyBotoes = {}
local function addFlyBtn(nome, val)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 30)
    b.BackgroundColor3 = (val == flySpeed) and Color3.fromRGB(60, 130, 246) or Color3.fromRGB(24, 24, 35)
    b.Text = nome .. " (" .. val .. ")"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 11
    b.Font = Enum.Font.GothamMedium
    b.Parent = paginaFly
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    flyBotoes[b] = val

    b.MouseButton1Click:Connect(function()
        flySpeed = val
        for btn, v in pairs(flyBotoes) do
            btn.BackgroundColor3 = (v == val) and Color3.fromRGB(60, 130, 246) or Color3.fromRGB(24, 24, 35)
        end
    end)
end

addFlyBtn("Lento", 80)
addFlyBtn("Normal", 180)
addFlyBtn("Rápido", 300)
addFlyBtn("Máximo", 500)

criarTituloFly("🛸 Fly Livre")
local freeFlyAtivo = false
local btnFreeFly = Instance.new("TextButton")
btnFreeFly.Size = UDim2.new(1, 0, 0, 34)
btnFreeFly.BackgroundColor3 = Color3.fromRGB(140, 50, 200)
btnFreeFly.Text = "✈️ Fly Livre: DESLIGADO"
btnFreeFly.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFreeFly.TextSize = 12
btnFreeFly.Font = Enum.Font.GothamBold
btnFreeFly.Parent = paginaFly
Instance.new("UICorner", btnFreeFly).CornerRadius = UDim.new(0, 8)

local freeFlySpeed = 60
local flyConnection = nil

btnFreeFly.MouseButton1Click:Connect(function()
    freeFlyAtivo = not freeFlyAtivo
    estadoNoclip.fly = freeFlyAtivo
    if freeFlyAtivo then
        btnFreeFly.Text = "✈️ Fly Livre: LIGADO"
        btnFreeFly.BackgroundColor3 = Color3.fromRGB(46, 160, 67)
        
        local cam = workspace.CurrentCamera
        flyConnection = RunService.RenderStepped:Connect(function(dt)
            local char = player.Character
            local rp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not rp or not hum then return end
            
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end

            rp.Anchored = false
            hum.PlatformStand = true
            
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                local camCFrame = cam.CFrame
                local direcaoMovimento = (camCFrame.RightVector * moveDir.X + camCFrame.LookVector * moveDir.Z)
                direcaoMovimento = Vector3.new(direcaoMovimento.X, camCFrame.LookVector.Y * moveDir.Z, direcaoMovimento.Z).Unit
                
                rp.CFrame = rp.CFrame + direcaoMovimento * (freeFlySpeed * dt)
                rp.AssemblyLinearVelocity = Vector3.zero
            else
                rp.AssemblyLinearVelocity = Vector3.zero
            end
        end)
    else
        btnFreeFly.Text = "✈️ Fly Livre: DESLIGADO"
        btnFreeFly.BackgroundColor3 = Color3.fromRGB(140, 50, 200)
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        restaurarColisaoECorrigirChao()
    end
end)

paginaFly.CanvasSize = UDim2.new(0, 0, 0, 260)

-- ==================== ABA SPEED ====================
local function criarTituloSpeed(texto)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.Text = texto
    l.TextColor3 = Color3.fromRGB(160, 190, 255)
    l.TextSize = 11
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = paginaSpeed
    return l
end

criarTituloSpeed("🏃 Velocidade de Andar")
local walkBotoes = {}

local function addVelBtn(nome, val)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 30)
    b.BackgroundColor3 = (val == walkSpeedDesejada) and Color3.fromRGB(60, 130, 246) or Color3.fromRGB(24, 24, 35)
    b.Text = nome .. " (" .. val .. ")"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 11
    b.Font = Enum.Font.GothamMedium
    b.Parent = paginaSpeed
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    walkBotoes[b] = val

    b.MouseButton1Click:Connect(function()
        walkSpeedDesejada = val
        local char = player.Character
        local h = char and char:FindFirstChildOfClass("Humanoid")
        if h and not boostCFrameAtivo then h.WalkSpeed = walkSpeedDesejada end
        for btn, v in pairs(walkBotoes) do
            btn.BackgroundColor3 = (v == walkSpeedDesejada) and Color3.fromRGB(60, 130, 246) or Color3.fromRGB(24, 24, 35)
        end
    end)
end

addVelBtn("Normal", 16)
addVelBtn("Rápido", 50)
addVelBtn("Super", 120)
addVelBtn("Ultra", 250)
addVelBtn("Máximo", 500)

local btnNoclipManual = Instance.new("TextButton")
btnNoclipManual.Size = UDim2.new(1, 0, 0, 32)
btnNoclipManual.BackgroundColor3 = Color3.fromRGB(140, 50, 200)
btnNoclipManual.Text = "🧱 Noclip: DESLIGADO"
btnNoclipManual.TextColor3 = Color3.fromRGB(255, 255, 255)
btnNoclipManual.TextSize = 12
btnNoclipManual.Font = Enum.Font.GothamBold
btnNoclipManual.Parent = paginaSpeed
Instance.new("UICorner", btnNoclipManual).CornerRadius = UDim.new(0, 8)

btnNoclipManual.MouseButton1Click:Connect(function()
    estadoNoclip.manual = not estadoNoclip.manual
    btnNoclipManual.Text = estadoNoclip.manual and "🧱 Noclip: LIGADO" or "🧱 Noclip: DESLIGADO"
    btnNoclipManual.BackgroundColor3 = estadoNoclip.manual and Color3.fromRGB(46, 160, 67) or Color3.fromRGB(140, 50, 200)
    if not estadoNoclip.manual then
        restaurarColisaoECorrigirChao()
    end
end)

paginaSpeed.CanvasSize = UDim2.new(0, 0, 0, 280)

-- ==================== ABA ESP ====================
local btnESP = Instance.new("TextButton")
btnESP.Size = UDim2.new(1, 0, 0, 38)
btnESP.BackgroundColor3 = Color3.fromRGB(140, 50, 200)
btnESP.Text = "👁️ Ativar / Desativar ESP"
btnESP.TextColor3 = Color3.fromRGB(255, 255, 255)
btnESP.TextSize = 13
btnESP.Font = Enum.Font.GothamBold
btnESP.Parent = paginaESP
Instance.new("UICorner", btnESP).CornerRadius = UDim.new(0, 8)

local espAtivo = false
btnESP.MouseButton1Click:Connect(function()
    espAtivo = not espAtivo
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local highlight = p.Character:FindFirstChild("ESPHighlight")
            if espAtivo then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ESPHighlight"
                    highlight.FillColor = Color3.fromRGB(255, 50, 50)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Parent = p.Character
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end)

-- ==================== ABA PLAYERS ====================
local containerPlayers = Instance.new("ScrollingFrame")
containerPlayers.Size = UDim2.new(1, 0, 1, 0)
containerPlayers.BackgroundTransparency = 1
containerPlayers.CanvasSize = UDim2.new(0, 0, 0, 0)
containerPlayers.Parent = paginaPlayers
Instance.new("UIListLayout", containerPlayers).Padding = UDim.new(0, 5)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= player then
        local pCard = Instance.new("Frame")
        pCard.Size = UDim2.new(1, 0, 0, 34)
        pCard.BackgroundColor3 = Color3.fromRGB(24, 24, 35)
        pCard.Parent = containerPlayers
        Instance.new("UICorner", pCard).CornerRadius = UDim.new(0, 8)

        local pLbl = Instance.new("TextLabel")
        pLbl.Size = UDim2.new(1, -90, 1, 0)
        pLbl.Position = UDim2.new(0, 8, 0, 0)
        pLbl.BackgroundTransparency = 1
        pLbl.Text = "👤 " .. p.Name
        pLbl.TextColor3 = Color3.fromRGB(220, 225, 240)
        pLbl.TextSize = 11
        pLbl.Font = Enum.Font.Gotham
        pLbl.TextXAlignment = Enum.TextXAlignment.Left
        pLbl.Parent = pCard

        local btnIrP = Instance.new("TextButton")
        btnIrP.Size = UDim2.new(0, 75, 0, 26)
        btnIrP.Position = UDim2.new(1, -82, 0, 4)
        btnIrP.BackgroundColor3 = Color3.fromRGB(60, 130, 246)
        btnIrP.Text = "Ir"
        btnIrP.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnIrP.TextSize = 11
        btnIrP.Font = Enum.Font.GothamBold
        btnIrP.Parent = pCard
        Instance.new("UICorner", btnIrP).CornerRadius = UDim.new(0, 6)

        btnIrP.MouseButton1Click:Connect(function()
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                correrAteManual(p.Character.HumanoidRootPart.CFrame, nil)
            end
        end)
    end
end

-- ==================== ABA TEMPO OVO (timer real do jogo) ====================
do
    paginaTempo.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local tituloTempo = Instance.new("TextLabel")
    tituloTempo.Size = UDim2.new(1, 0, 0, 22)
    tituloTempo.BackgroundTransparency = 1
    tituloTempo.Text = "⏱️ Timer do ovo (tempo real do jogo)"
    tituloTempo.TextColor3 = Color3.fromRGB(160, 190, 255)
    tituloTempo.TextSize = 12
    tituloTempo.Font = Enum.Font.GothamBold
    tituloTempo.TextXAlignment = Enum.TextXAlignment.Left
    tituloTempo.Parent = paginaTempo

    local descTempo = Instance.new("TextLabel")
    descTempo.Size = UDim2.new(1, 0, 0, 40)
    descTempo.BackgroundTransparency = 1
    descTempo.Text = "Só o timer do ovo na mão (barra vermelha).\nRestock, comida e resets ficam ocultos."
    descTempo.TextColor3 = Color3.fromRGB(160, 165, 185)
    descTempo.TextSize = 10
    descTempo.Font = Enum.Font.Gotham
    descTempo.TextWrapped = true
    descTempo.TextXAlignment = Enum.TextXAlignment.Left
    descTempo.Parent = paginaTempo

    local displayPrincipal = Instance.new("TextLabel")
    displayPrincipal.Size = UDim2.new(1, 0, 0, 70)
    displayPrincipal.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
    displayPrincipal.Text = "—:—\nSem timer ativo"
    displayPrincipal.TextColor3 = Color3.fromRGB(100, 220, 140)
    displayPrincipal.TextSize = 22
    displayPrincipal.Font = Enum.Font.GothamBold
    displayPrincipal.TextWrapped = true
    displayPrincipal.Parent = paginaTempo
    Instance.new("UICorner", displayPrincipal).CornerRadius = UDim.new(0, 10)

    local listaTimers = Instance.new("TextLabel")
    listaTimers.Size = UDim2.new(1, 0, 0, 160)
    listaTimers.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    listaTimers.Text = "Nenhum Timer tag encontrado..."
    listaTimers.TextColor3 = Color3.fromRGB(200, 205, 220)
    listaTimers.TextSize = 11
    listaTimers.Font = Enum.Font.Gotham
    listaTimers.TextWrapped = true
    listaTimers.TextXAlignment = Enum.TextXAlignment.Left
    listaTimers.TextYAlignment = Enum.TextYAlignment.Top
    listaTimers.Parent = paginaTempo
    Instance.new("UICorner", listaTimers).CornerRadius = UDim.new(0, 8)
    local padLista = Instance.new("UIPadding")
    padLista.PaddingTop = UDim.new(0, 6)
    padLista.PaddingLeft = UDim.new(0, 8)
    padLista.PaddingRight = UDim.new(0, 8)
    padLista.Parent = listaTimers

    local function fmtMS(seg)
        if not seg then return "—:—" end
        if seg < 90 then
            return string.format("%.1fs", seg)
        end
        seg = math.max(0, math.floor(seg + 0.5))
        local m = math.floor(seg / 60)
        local s = seg % 60
        return string.format("%02d:%02d", m, s)
    end

    local function coletarTimersDetalhados()
        local itens = {}
        local pg = player:FindFirstChild("PlayerGui")
        if pg then
            for _, d in ipairs(pg:GetDescendants()) do
                if d:IsA("TextLabel") or d:IsA("TextButton") then
                    if d.Visible == false then continue end
                    local n = parseSegundosDeTexto(d.Text)
                    if not n then continue end
                    local sc = scoreTimerOvo(d, d.Text, n)
                    if sc < 40 then continue end -- só barra do ovo
                    table.insert(itens, {
                        nome = d.Name,
                        restante = n,
                        texto = d.Text,
                        fonte = "PlayerGui",
                        score = sc,
                    })
                end
            end
        end
        pcall(function()
            local basket = player:FindFirstChild("Basket")
            if not basket then return end
            local st = workspace:GetServerTimeNow()
            for _, egg in ipairs(basket:GetChildren()) do
                local untilAttr = egg:GetAttribute("VolcanoUntil")
                if type(untilAttr) == "number" then
                    local r = untilAttr - st
                    if r > 0.3 and r < 120 then
                        table.insert(itens, {
                            nome = "Basket ovo",
                            restante = r,
                            fonte = "VolcanoUntil",
                            score = 25,
                        })
                    end
                end
            end
        end)
        table.sort(itens, function(a, b)
            return (a.score or 0) > (b.score or 0)
        end)
        return itens
    end

    local accTempo = 0
    RunService.Heartbeat:Connect(function(dt)
        if not screenGui.Parent then return end
        -- só atualiza a aba se ela estiver visível (economiza CPU)
        if not paginaTempo.Visible then return end
        accTempo += dt
        if accTempo < 0.4 then return end
        accTempo = 0

        local itens = coletarTimersDetalhados()
        local linhas = {}
        local melhor = itens[1]

        for i, it in ipairs(itens) do
            if i > 5 then break end -- no máximo 5 linhas
            table.insert(linhas, string.format(
                "• %s  %s  \"%s\"",
                tostring(it.nome):sub(1, 20),
                fmtMS(it.restante),
                tostring(it.texto or ""):sub(1, 10)
            ))
        end

        if melhor and melhor.restante then
            local mostrar = melhor.restante
            displayPrincipal.Text = fmtMS(mostrar) .. "\novo na mão (barra vermelha)"
            if mostrar <= 8 then
                displayPrincipal.TextColor3 = Color3.fromRGB(255, 90, 90)
            elseif mostrar <= 20 then
                displayPrincipal.TextColor3 = Color3.fromRGB(255, 200, 80)
            else
                displayPrincipal.TextColor3 = Color3.fromRGB(100, 220, 140)
            end
        else
            displayPrincipal.Text = "—:—\nSem ovo na mão / sem barra"
            displayPrincipal.TextColor3 = Color3.fromRGB(160, 165, 180)
        end

        if #linhas == 0 then
            listaTimers.Text = "Nenhum timer de ovo. Pegue um ovo — a barra vermelha aparece aqui."
        else
            listaTimers.Text = table.concat(linhas, "\n")
        end
    end)
end


-- ==================== PÂNICO ====================
PANICO.parar = function(voltarBase)
    PANICO.epoca += 1

    -- Auto farm
    autoColetaAtivo = false
    farmOcupado = false
    estadoNoclip.auto = false
    btnAutoColeta.Text = "🤖 Auto Farm: DESLIGADO"
    btnAutoColeta.BackgroundColor3 = Color3.fromRGB(140, 50, 200)

    -- Qualquer movimento em andamento (eles se encerram sozinhos no próximo frame)
    movimentoAtual += 1
    movimentoInfo.ativo = false
    pcall(pararRadar)

    -- Fly livre
    if freeFlyAtivo then
        freeFlyAtivo = false
        estadoNoclip.fly = false
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        btnFreeFly.Text = "✈️ Fly Livre: DESLIGADO"
        btnFreeFly.BackgroundColor3 = Color3.fromRGB(140, 50, 200)
    end

    -- Noclip manual
    estadoNoclip.manual = false
    btnNoclipManual.Text = "🧱 Noclip: DESLIGADO"
    btnNoclipManual.BackgroundColor3 = Color3.fromRGB(140, 50, 200)

    -- Personagem de volta ao normal
    local char = player.Character
    local rp = char and char:FindFirstChild("HumanoidRootPart")
    if rp then
        rp.Anchored = false
        rp.AssemblyLinearVelocity = Vector3.zero
        rp.AssemblyAngularVelocity = Vector3.zero
    end
    restaurarColisaoECorrigirChao()

    setStatus("🛑 PÂNICO: tudo parado")

    if voltarBase then
        task.delay(0.4, function()
            pcall(voltarParaCasaManual300M)
        end)
    end
end


print("Ultimate Egg Hub - Versão Final (Iniciante corrigido + sem purchase + Radar + Confirmação de coleta + Contadores + Leitura de valor corrigida + Filtros + Prioridade + Marcador do maior ovo + Pânico + Anti-lag + Checagem de ovo na mão + Espera do ovo voltar da lava)")