ALTURA_TELA =480
LARGURA_TELA =320
MAX_METEOROS=10
pause= false
FIM_JOGO=false
METEOROS_ATINGIDOS=0
-- Load some default values for our rectangle.
aviao = {
    src="asset/ship_2.png",
    largura=56,
    altura=64,
    x=LARGURA_TELA/2 -32,
    y=ALTURA_TELA -64,
    tiros={}

}

meteoros = {}--ARRAY DOS meteoros
function criaMeteoro()
    meteoro = {
        x=math.random(0,LARGURA_TELA-32),
        y=-25,
        altura=24,
        largura=20,
        peso=math.random(1,3),
        deslocamento=math.random(-1,1)
    }
    table.insert(meteoros,meteoro)
end
function destroiAviao()
    --audioDestruicao:play()
    aviao.src="asset/explosion.png"
    aviao.img=love.graphics.newImage(aviao.src)
    aviao.largura=70
    aviao.altura=77
end

function trocaMusicaDeFundo()
    --musica:stop()
    --game_over:play()
end

function checaColisaoAviao()
    for i,meteoro in pairs(meteoros) do
        if colisao(aviao.x,aviao.y,aviao.largura,aviao.altura, meteoro.x,meteoro.y,meteoro.largura,meteoro.altura) then
            trocaMusicaDeFundo()
            destroiAviao()
            FIM_JOGO=true
        end
    end
end
function checarColisaoTiro()
    for i= #aviao.tiros,1,-1 do
        local tiro= aviao.tiros[i]
        for j=#meteoros,1,-1 do
            local meteoro= meteoros[j]
            if colisao(tiro.x,tiro.y,tiro.largura,tiro.altura, meteoro.x,meteoro.y,meteoro.largura,meteoro.altura) then
                METEOROS_ATINGIDOS=METEOROS_ATINGIDOS +1
                table.remove(aviao.tiros,i)
                table.remove(meteoros,j)
                --audioDestruicao:play()
                break
            end
        end
    end
end

function checarColisao()
    
    checaColisaoAviao()
    checarColisaoTiro()
    
end

function checaObj()
    if METEOROS_ATINGIDOS >=10 then
        Vencedor=true
    end 
end

function colisao(x1,y1,l1,a1,x2,y2,l2,a2)
    return x2<x1+l1 and
           x1<x2+l2 and
           y2<y1+a1 and
           y1<y2+a2
end

function moveMeteoro()
    for i,meteoro in pairs(meteoros) do
        meteoro.y = meteoro.y + meteoro.peso
        meteoro.x = meteoro.x + meteoro.deslocamento
        if meteoro.y > ALTURA_TELA then
            table.remove(meteoros,i)
        end
        if meteoro.x +meteoro.largura< 0 or meteoro.x>LARGURA_TELA then
            table.remove(meteoros,i)
        end
    end
    
end

function moveaviao(dt)
    if love.keyboard.isDown("d") then
        aviao.x = aviao.x + 200 * dt
    end
    if love.keyboard.isDown("a") then
        aviao.x = aviao.x - 200 * dt
    end
    if love.keyboard.isDown("w") then
        aviao.y = aviao.y - 200 * dt
    end
    if love.keyboard.isDown("s") then
        aviao.y = aviao.y + 200 * dt

    end

    --IA
    -- Limite da Esquerda (não pode ser menor que 0)
    aviao.x = math.max(0, aviao.x)
    
    -- Limite de Cima (não pode ser menor que 0)
    aviao.y = math.max(0, aviao.y)

    -- Limite da Direita (não pode ser maior que a tela - largura do avião)
    aviao.x = math.min(LARGURA_TELA - aviao.largura, aviao.x)
    
    -- Limite de Baixo (não pode ser maior que a tela - altura do avião)
    aviao.y = math.min(ALTURA_TELA - aviao.altura, aviao.y)
end

function removeMeteoro()
    for i=#meteoros,1,-1 do
        if meteoros[i].y > ALTURA_TELA then
            table.remove(meteoros,i)
        end
    end

end

function moveTiros()
    for i= #aviao.tiros,1,-1 do
       if aviao.tiros[i].y >0 then
            aviao.tiros[i].y = aviao.tiros[i].y - aviao.tiros[i].velocidade * love.timer.getDelta()
        else
            table.remove(aviao.tiros,i)
       end
    end
end
function daTeco()
    --Som_tiro:play()
    local tiro = {
        x=aviao.x + aviao.largura/2 -4,
        y=aviao.y +3,
        largura=16,
        altura=16,
        velocidade=300
    }
    table.insert(aviao.tiros,tiro)
end





function love.load()
    love.window.setMode(LARGURA_TELA, ALTURA_TELA,{resizable=false})--tamanho da janela  
    love.window.setTitle("JOGO NOME TECO TECO")--nome da barrinha
    math.randomseed(os.time())--inicializando random com horario do sistema
    background = love.graphics.newImage("asset/background_stars.png")--carregando imagem de background
    aviao.img=love.graphics.newImage(aviao.src)--carregando imagem do aviao
    meteoro_img=love.graphics.newImage("asset/meteor.png")--carregando imagem do meteoro
    tiro_img=love.graphics.newImage("asset/flare.png")
    fontePause = love.graphics.newFont(40)
    --gameover_img=love.graphics.newImage("asset/game_over.png")
    --win_img=love.graphics.newImage("asset/.png")

    --musica = love.audio.newSource("ASSET/Beat-carlin.ogg")
    --musica:setLooping(true)--definindo para repetir a musica
    --musica:play()

    --audioDestruicao= love.audio.newSource("destruicao.wav")

    --game_over= love.audio.newSource("fim_de_jogo.wav")

    -- Som_tiro= love.audio.newSource("fim_de_jogo.wav")
end

-- Increase the size of the rectangle every frame.
function love.update(dt)
    if not FIM_JOGO and not Vencedor then
        if not pause then
            if love.keyboard.isDown("w","s","a","d") then
            moveaviao(dt)
            end
            removeMeteoro()
            if #meteoros < MAX_METEOROS then
                criaMeteoro()
            end
        moveMeteoro()
        moveTiros()
        checarColisao()
        checaObj()
        end
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key =="return" then
        pause=not pause
    elseif key =="space" then
        daTeco()
    elseif key =="r" and FIM_JOGO then

        love.event.quit("restart")
    elseif key =="r" and Vencedor then
        love.event.quit("restart")
    end

end

-- Draw a coloured rectangle.
function love.draw()
    -- In versions prior to 11.0, color component values are (0, 102, 102)
    love.graphics.draw(background,0,0)
    love.graphics.draw(aviao.img,aviao.x,aviao.y)
   for i,meteoro in ipairs(meteoros) do
        love.graphics.draw(meteoro_img,meteoro.x,meteoro.y)
    end
    for k,tiro in ipairs(aviao.tiros) do
        love.graphics.draw(tiro_img,tiro.x,tiro.y)
    end
    if FIM_JOGO then
        -- Pega a fonte grande que você já criou para o PAUSE
        local fonteAntiga = love.graphics.getFont()
        love.graphics.setFont(fontePause) -- Usando a fonte de 40px

        -- Mensagem de Game Over
        local y_centro = (ALTURA_TELA / 2) - (fontePause:getHeight()) -- Um pouco para cima
        love.graphics.printf("GAME OVER", 0, y_centro, LARGURA_TELA, "center")

        -- Mensagem de Reiniciar (usando a fonte padrão, menor)
        love.graphics.setFont(fonteAntiga)
        love.graphics.printf("Aperte 'R' para reiniciar", 0, y_centro + 50, LARGURA_TELA, "center")
        
        elseif pause then
            love.graphics.print("JOGO PAUSADO", LARGURA_TELA/2 -50, ALTURA_TELA/2)
            
            elseif Vencedor then
                love.graphics.print("VOCE VENCEU!", LARGURA_TELA/2 -50, ALTURA_TELA/2)
    end
end