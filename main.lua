--[[***************************************************************************************************************
    Autor: Gabriel Augusto de Lima Maia
    Data: 07/12/2024
    Curso: Engenharia da Computação - CEFET-MG
    Descrição: Implementar uma solução funcional para organizar inventários no Minecraft sem utilizar estruturas
    de dados avançadas, como HashMap, limitando-se apenas às listas padrão da linguagem.
***************************************************************************************************************--]]

--[[**************************************************************************************************************
                                      Declaração de Variáveis Globais
****************************************************************************************************************]] 
--- Lista dos baús
local chests = {}
--- lista que guarda os itens não completos, seu slot e bau
local itensNaoCompletos = {} -- Lista de itens não completos
--- Marca o inicio da contagem do tempo
local startTime = os.time()
--- Abre o arquivo de log para salvar a saída
local logFile = fs.open("saida.txt", "w")


--[[**************************************************************************************************************
                                            Funções
****************************************************************************************************************]]

---Redefine a função `print` para registrar mensagens em um arquivo de log.
---
---Essa função substitui a função padrão print de Lua. Em vez de exibir os valores
---na tela, ela grava os valores em um arquivo de log. Cada argumento é convertido
---em texto (usando tostring) e separado por tabulação (\t), garantindo que os dados 
---fiquem organizados. Após todos os valores serem escritos, a função adiciona uma 
---nova linha ao final do arquivo e usa flush() para salvar os dados no disco 
---imediatamente.
---
---Parâmetros:
---
---@param ... (vararg): Uma quantidade variável de argumentos que serão exibidos e 
---registrados no arquivo de log.
---
---Observação:
---A variável `logFile` deve ser um manipulador de arquivo válido que suporte 
---os métodos `write` (para escrever no arquivo) e `flush` (para garantir que 
---os dados sejam salvos imediatamente no disco).
function print(...)
    local args = {...}
    for i, v in ipairs(args) do
        logFile.write(tostring(v) .. "\t")
    end
    logFile.write("\n")
    logFile.flush()
end

--- Captura erros usando pcall para salvar no arquivo também
local status, err = pcall(function()


    ---Function: procurarItensNaoCompletos
    ---
    ---Description: Procura por itens incompletos em uma lista de baús e adiciona-os a uma lista de 
    ---itens incompletos.
    --- 
    ---Parameters:
    ---@param chests (table): Uma tabela contendo os baús a serem verificados.
    ---        
    ---Returns: Nada
    ---        
    ---Details:
    ---- Itera sobre cada baú na lista fornecida.
    ---- Para cada baú, itera sobre cada slot e item no baú.
    ---- Obtém os detalhes completos do item no slot atual.
    ---- Verifica se o item é incompleto (quantidade menor que o limite do slot).
    ---- Adiciona os itens incompletos a uma lista chamada `itensNaoCompletos`.
    ---- Imprime no console os detalhes dos itens incompletos encontrados.
    local function procurarItensNaoCompletos(chests)
        for _, chest in ipairs(chests) do
            for slot, item in pairs(chest.list()) do
                -- Busca detalhes completos do item
                local itemDetail = chest.getItemDetail(slot) -- Detalhes do item
                if itemDetail and itemDetail.count < itemDetail.maxCount then -- Verifica se o item é incompleto
                    table.insert(itensNaoCompletos, {chest = chest, slot = slot, item = item, itemDetail = itemDetail}) -- Adiciona à lista de itens incompletos
                    print("Item incompleto: " .. itemDetail.displayName .. " " .. itemDetail.count .. " limite: " .. itemDetail.maxCount)
                end
            end
            sleep(10)
        end
    end

    ---Esta função compara dois itens utilizando as possíveis formas de 
    ---diferenciação comuns no Minecraft e nos mods. São verificadas as 
    ---seguintes características dos itens:
    ---- `displayName`: O nome exibido do item.
    ---- `name`: O identificador interno do item.
    ---- `nbt`: Dados adicionais do item, conhecidos como NBT (Tag Baseada em Nome).
    ---
    ---A função retorna `true` se todas as características forem iguais e 
    ---`false` caso contrário.
    ---
    ---Parâmetros:
    ---@param item1 (table): Uma tabela contendo os detalhes do primeiro item.
    ---@param item2 (table): Uma tabela contendo os detalhes do segundo item.
    ---
    ---Retorno:
    ---@return boolean: `true` se os dois itens forem considerados iguais, `false` caso contrário.
    ---
    ---Observação:<br>
    ---Não tenho certeza se esta função cobre todas as formas que os mods utilizam
    ---para diferenciar itens. Pode ser que mods novos adicionem outras formas de 
    ---diferenciação, fazendo com que a função apresente falsos positivos.
    local function verificarIgualidade(item1, item2)
        if item1.itemDetail.displayName == item2.itemDetail.displayName and
        item1.itemDetail.name == item2.itemDetail.name and
        item1.itemDetail.nbt == item2.itemDetail.nbt then
            return true
        end
        return false
    end



    ---Descrição: Verifica se há itens duplicados na lista de itens incompletos e mantém apenas os itens duplicados na lista.
    ---
    ---Parâmetros: Nenhum <br>
    ---Retorno: Nenhum
    ---
    ---Detalhes:
    ---- Itera sobre a lista de itens incompletos (itensNaoCompletos).
    ---- Para cada item, verifica se existe outro item com o mesmo nome (displayName) mas em um slot diferente.
    ---- Se encontrar um item duplicado, adiciona-o à lista de itens para manter (itensParaManter).
    ---- Atualiza a lista de itens incompletos (itensNaoCompletos) com apenas os itens duplicados.
    ---- Imprime no console uma mensagem indicando o item duplicado encontrado, incluindo seu nome, quantidade, slot e baú.
    local function conferirItensNaoCompletos()
        
        -- Itera sobre a lista de itens incompletos
        ::repete::
        for i, item in ipairs(itensNaoCompletos) do
            local temIgual = false
            for j, item2 in ipairs(itensNaoCompletos) do
                if i ~= j and verificarIgualidade(item, item2) then
                    temIgual = true
                end
                if j == #itensNaoCompletos then
                    if temIgual == false then
                        table.remove(itensNaoCompletos, i)
                        goto repete
                    end
                end
            end
            sleep(10)
        end

        print("Tamanho da lista de itens incompletos depois da seleção: " .. #itensNaoCompletos)
    end
    
    ---Transfere itens entre dois baús, completando stacks incompletos.<br>
    ---Parâmetros: Nenhum.<br>
    ---Retorno: Nenhum.<br>
    ---
    ---Detalhes:
    ---- Verifica se há itens incompletos na lista `itensNaoCompletos`.
    ---- Faz uma cópia da tabela `itensNaoCompletos` para `itensNaoFinalizados`.
    ---- Itera sobre a lista de itens incompletos e verifica se o item já foi finalizado.
    ---- Se o item não foi finalizado, itera sobre a lista de itens não finalizados.
    ---- Verifica se o nome do item é igual e o slot é diferente.
    ---- Calcula a quantidade que falta para completar o stack.
    ---- Transfere a quantidade necessária de itens entre os baús.
    ---- Adiciona o item à lista de itens finalizados e remove da lista de itens não finalizados.
    ---- Imprime mensagens de log detalhando a transferência.
    local function transferirItens()
        ::reiniciar::
        -- Verifica se não há itens incompletos
        print("Tamanho da lista de itens incompletos: " .. #itensNaoCompletos)
        if #itensNaoCompletos <= 1 then
            print("Nao ha itens incompletos para transferir.")
            return
        end
        -- Itera sobre a lista de itens incompletos
        
        for i, item in ipairs(itensNaoCompletos) do

                -- Itera sobre a lista de itens incompletos
                for j, item2 in ipairs(itensNaoCompletos) do
                    local msmbs = false

                    if item.chest == item2.chest and item.slot == item2.slot then
                        msmbs = true -- Verifica se é o mesmo bau e slot
                    end

                    if msmbs == false and verificarIgualidade(item,item2) and item.itemDetail.count < item.itemDetail.maxCount and item.itemDetail.count > 0 then -- Verifica se o nome é igual e o slot é diferente
                        local qntfalta = item.itemDetail.maxCount - item.itemDetail.count -- Calcula a quantidade que falta para completar o stack
                        local qntTrans = 0 -- Quantidade a ser transferida

                        if item2.itemDetail.count > qntfalta then -- Verifica se a quantidade do item2 é maior que a quantidade que falta

                            item.chest.pullItems(peripheral.getName(item2.chest), item2.slot, qntfalta, item.slot) -- Transfere a quantidade que falta
                            item.itemDetail = item.chest.getItemDetail(item.slot) -- Atualiza os detalhes do item
                            item2.itemDetail = item2.chest.getItemDetail(item2.slot) -- Atualiza os detalhes do item2
                            qntTrans = qntfalta
                            table.remove(itensNaoCompletos, i) -- Remove o item da lista de itens incompletos
                            print("Transferindo " .. qntTrans .. " " .. item.itemDetail.displayName .. " do bau " .. peripheral.getName(item2.chest) .. " slot ".. item2.slot .." para o bau " .. peripheral.getName(item.chest) .. " slot ".. item.slot)
                            goto reiniciar

                        elseif item2.itemDetail.count < qntfalta then 
                            qntTrans = item2.itemDetail.count  
                            local falta = qntfalta - item2.itemDetail.count
                            item.chest.pullItems(peripheral.getName(item2.chest), item2.slot, qntfalta, item.slot)
                            item.itemDetail = item.chest.getItemDetail(item.slot) -- Atualiza os detalhes do item
                            item2.itemDetail = item2.chest.getItemDetail(item2.slot) -- Atualiza os detalhes do item2
                            table.remove(itensNaoCompletos, j) -- Remove o item da lista de itens incompletos 
                            print("Transferindo " .. qntTrans .. " " .. item.itemDetail.displayName .. " do bau " .. peripheral.getName(item2.chest) .. " slot ".. item2.slot .. " para o bau " .. peripheral.getName(item.chest) .. " slot ".. item.slot .. " falta " .. falta)
                            goto reiniciar

                        else
                            item.chest.pullItems(peripheral.getName(item2.chest), item2.slot, qntfalta, item.slot) -- Transfere a quantidade que falta
                            item.itemDetail = item.chest.getItemDetail(item.slot) -- Atualiza os detalhes do item
                            item2.itemDetail = item2.chest.getItemDetail(item2.slot) -- Atualiza os detalhes do item2
                            qntTrans = qntfalta
                            table.remove(itensNaoCompletos, i) -- Remove o item da lista de itens incompletos
                            table.remove(itensNaoCompletos, j) -- Remove o item da lista de itens incompletos
                            print("Transferindo " .. qntTrans .. " " .. item.itemDetail.displayName .. " do bau " .. peripheral.getName(item2.chest) .. " slot ".. item2.slot .." para o bau " .. peripheral.getName(item.chest) .. " slot ".. item.slot)
                            goto reiniciar
                        end    
                    end
                end   
                sleep(10)
        end
    end


--[[**************************************************************************************************************
                                      Sript Principal ("Main")
****************************************************************************************************************]]
--[[ 
        Este script realiza várias operações relacionadas a periféricos no ambiente Minecraft, usando o mod 
        Computercraft e seus periféricos, especialmente voltadas para baús e manipulação de itens.

        As principais operações incluem:
        1. Iterar sobre os periféricos conectados para encontrar baús.
        2. Procurar itens incompletos dentro dos baús.
        3. Verificar itens incompletos duplicados.
        4. Transferir itens para completá-los.
        5. Registrar o tempo gasto em cada operação e o tempo total de execução.

        Funções utilizadas:
        - peripheral.getNames(): Obtém os nomes de todos os periféricos conectados.
        - peripheral.hasType(name, "minecraft:chest"): Verifica se o periférico é um baú.
        - peripheral.wrap(name): Associa o periférico a uma variável para operações subsequentes.
        - procurarItensNaoCompletos(chests): Procura itens incompletos nos baús fornecidos.
        - conferirItensNaoCompletos(): Verifica se existem itens incompletos duplicados.
        - transferirItens(): Transfere itens entre baús para completá-los.

        Variáveis principais:
        - inicioPerifericos: Tempo de início da busca pelos periféricos.
        - tempoPerifericos: Tempo gasto na busca pelos periféricos.
        - inicioContagem: Tempo de início da contagem de itens incompletos.
        - tempoContagem: Tempo gasto para contar os itens.
        - inicioConferir: Tempo de início da verificação de itens duplicados incompletos.
        - tempoConferir: Tempo gasto na verificação de itens.
        - inicioTransferencia: Tempo de início da transferência de itens.
        - tempoTransferencia: Tempo gasto na transferência de itens.
        - endTime: Tempo final de execução do script.
        - tempoExecucao: Tempo total de execução do script.

        Tratamento de Erros:
        - Se um erro ocorrer durante a execução, ele será registrado em um arquivo de log.

        Observação:
        - O tempo total de execução é dividido por 20, possivelmente devido à relação 
        com o *tick rate* do Minecraft, onde 20 ticks equivalem a 1 segundo no jogo.
    --]]
    
    -- Loop que percorre todos os nomes dos periféricos conectados ao computador do Computercraft
    -- e se o nome do periferico for "minecraft:chest", ele embrulha com a função peripheral.wrap
    -- em uma tabela com nome chests.
    -- obs: caso esteja usando outro mod com baú, procure saber o nome do baú desse mod
    local inicioPerifericos = os.time()
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.hasType(name, "minecraft:chest") then
            table.insert(chests, peripheral.wrap(name))
        end
    end

    local tempoPerifericos = os.time() - inicioPerifericos
    print("Tempo de busca dos perifericos: " .. tempoPerifericos .. " segundos")

    
    -- Chama a Função que Procura por itens incompletos em uma lista de baús e para adicionar-los a uma lista de 
    -- itens incompletos
    local inicioContagem = os.time()
    procurarItensNaoCompletos(chests)

    local tempoContagem = os.time() - inicioContagem
    print("Tempo de contagem dos itens: " .. tempoContagem .. " segundos")

    -- Verifica se há itens duplicados na lista de itens incompletos e mantém apenas os itens duplicados na lista.
    local inicioConferir = os.time()
    conferirItensNaoCompletos()
    local tempoConferir = os.time() - inicioConferir
    print("Tempo de conferir itens: " .. tempoConferir .. " segundos")

    -- itera dentro da lista itens não completos e vai completando os itens
    local inicioTransferencia = os.time()
    transferirItens()
    local tempoTransferencia = os.time() - inicioTransferencia
    print("Tempo de transferencia dos itens: " .. tempoTransferencia .. " segundos")


    -- Calcula o tempo de execução
    local endTime = os.time()
    local tempoExecucao = endTime - startTime / 20
    print("Tempo de execucao: " .. tempoExecucao .. " segundos")
end)

-- Salva o erro, caso exista
if not status then
    logFile.write("Erro encontrado: " .. err .. "\n")
end

-- Fecha o arquivo de log
logFile.close()

--[[

Problema:

No ComputerCraft, a função os.time() não é confiável para medir o tempo de execução do programa, 
pois ela não representa o tempo real, mas sim o tempo simulado dentro do jogo. Esse comportamento 
pode levar a resultados incorretos, como valores negativos ou tempos inconsistentes, especialmente 
se o servidor estiver sobrecarregado, se o jogo estiver com lag ou se o tempo do jogo estiver pausado.

Um exemplo típico de erro ocorre quando o programa registra um tempo negativo, mesmo após a execução 
de uma operação que durou vários minutos no jogo, como uma operação de transferência de itens. 
Isso acontece porque a função os.time() não considera as condições do servidor ou do jogo, 
resultando em cálculos errôneos.

Possível Solução:

Uma alternativa mais confiável para medir o tempo no ComputerCraft é utilizar a função os.clock(). 
Esta função retorna o tempo de CPU consumido pelo programa desde o início da execução, em segundos 
com precisão decimal. Ao contrário de os.time(), os.clock() não é afetada por variações no tempo 
do jogo, tornando-a uma melhor opção para medir a duração de operações dentro do ComputerCraft.

Mas como essa é uma solução que foi me passada pelo ChatGPT, não sei se essa função existe e se
ela funciona como descrito.

Como Aplicar:

    Substitua todas as chamadas para os.time() por os.clock().
    Use string.format("%.2f", valor) para formatar o tempo de execução com precisão de 2 casas decimais, 
    tornando os resultados mais legíveis e consistentes.
    Com essa abordagem, o tempo de execução será mais estável e não sofrerá interferências de lag ou 
    outras condições de desempenho do servidor.
    
]]
