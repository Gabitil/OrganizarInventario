
local chests = {} -- Lista de baús
local startTime = os.time() -- Marca o início
-- lista que guarda os itens não completos, seu slot e bau
local itensNaoCompletos = {} -- Lista de itens não completos

-- Abre o arquivo de log para salvar a saída
local logFile = fs.open("saida.txt", "w")

-- Redefines the `print` function to log messages to a file.
-- 
-- This function takes any number of arguments, converts them to strings,
-- and writes them to a log file, separated by tabs. Each call to `print`
-- ends with a newline in the log file.
-- 
-- Parameters:
-- ... (vararg): A variable number of arguments to be printed and logged.
-- 
-- Note:
-- The `logFile` variable must be a valid file handle that supports `write`
-- and `flush` methods.
-- Redefine a função `print` para registrar as mensagens no arquivo
function print(...)
    local args = {...}
    for i, v in ipairs(args) do
        logFile.write(tostring(v) .. "\t")
    end
    logFile.write("\n")
    logFile.flush()
end

-- Captura erros usando pcall para salvar no arquivo também
local status, err = pcall(function()

    --[[
        Function: procurarItensNaoCompletos
        Description: Procura por itens incompletos em uma lista de baús e adiciona-os a uma lista de itens incompletos.
        
        Parameters:
            chests (table): Uma tabela contendo os baús a serem verificados.
        
        Returns:
            None
        
        Details:
            - Itera sobre cada baú na lista fornecida.
            - Para cada baú, itera sobre cada slot e item no baú.
            - Obtém os detalhes completos do item no slot atual.
            - Verifica se o item é incompleto (quantidade menor que o limite do slot).
            - Adiciona os itens incompletos a uma lista chamada `itensNaoCompletos`.
            - Imprime no console os detalhes dos itens incompletos encontrados.
    ]]
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

    local function verificarIgualidade(item1, item2)
        if item1.itemDetail.displayName == item2.itemDetail.displayName and item1.itemDetail.name == item2.itemDetail.name and item1.itemDetail.nbt == item2.itemDetail.nbt then
            return true
        end
        return false
    end

    --[[
        Função: conferirItensNaoCompletos
        Descrição: Verifica se há itens duplicados na lista de itens incompletos e mantém apenas os itens duplicados na lista.
        Parâmetros: Nenhum
        Retorno: Nenhum
        Detalhes:
            - Itera sobre a lista de itens incompletos (itensNaoCompletos).
            - Para cada item, verifica se existe outro item com o mesmo nome (displayName) mas em um slot diferente.
            - Se encontrar um item duplicado, adiciona-o à lista de itens para manter (itensParaManter).
            - Atualiza a lista de itens incompletos (itensNaoCompletos) com apenas os itens duplicados.
            - Imprime no console uma mensagem indicando o item duplicado encontrado, incluindo seu nome, quantidade, slot e baú.
    ]]
    local function conferirItensNaoCompletos()
        
        -- Itera sobre a lista de itens incompletos
        ::repete::
        for i, item in ipairs(itensNaoCompletos) do
            local temIgual = false
            -- Verifica se existe um item igual na lista
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

    
    --[[
        Função: transferirItens
        Descrição: Transfere itens entre dois baús, completando stacks incompletos.
        Parâmetros: Nenhum.
        Retorno: Nenhum.
        Detalhes:
            - Verifica se há itens incompletos na lista `itensNaoCompletos`.
            - Faz uma cópia da tabela `itensNaoCompletos` para `itensNaoFinalizados`.
            - Itera sobre a lista de itens incompletos e verifica se o item já foi finalizado.
            - Se o item não foi finalizado, itera sobre a lista de itens não finalizados.
            - Verifica se o nome do item é igual e o slot é diferente.
            - Calcula a quantidade que falta para completar o stack.
            - Transfere a quantidade necessária de itens entre os baús.
            - Adiciona o item à lista de itens finalizados e remove da lista de itens não finalizados.
            - Imprime mensagens de log detalhando a transferência.
    ]]
    --função que recebe dois baús e transfere os itens
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




    --[[
        This script performs several operations related to peripherals in a Minecraft environment.
        
        The main operations include:
        1. Iterating over connected peripherals to find chests.
        2. Searching for incomplete items in the chests.
        3. Checking for duplicate incomplete items.
        4. Transferring items to complete them.
        5. Logging the time taken for each operation and the total execution time.
        
        Functions:
        - peripheral.getNames(): Retrieves the names of all connected peripherals.
        - peripheral.hasType(name, "minecraft:chest"): Checks if the peripheral is a chest.
        - peripheral.wrap(name): Wraps the peripheral for further operations.
        - procurarItensNaoCompletos(chests): Searches for incomplete items in the provided chests.
        - conferirItensNaoCompletos(): Checks for duplicate incomplete items.
        - transferirItens(): Transfers items to complete them.
        
        Variables:
        - inicioPerifericos: Start time for peripheral search.
        - tempoPerifericos: Time taken for peripheral search.
        - inicioContagem: Start time for item search.
        - tempoContagem: Time taken for item search.
        - inicioConferir: Start time for checking items.
        - tempoConferir: Time taken for checking items.
        - inicioTransferencia: Start time for item transfer.
        - tempoTransferencia: Time taken for item transfer.
        - endTime: End time for the entire execution.
        - tempoExecucao: Total execution time.
        
        Error Handling:
        - Logs any errors encountered during execution to a log file.
        
        Note:
        - The total execution time is divided by 20 for some reason, possibly related to the game's tick rate.
    ]]
    -- Itera sobre os perifericos conectados
    local inicioPerifericos = os.time()
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.hasType(name, "minecraft:chest") then
            table.insert(chests, peripheral.wrap(name))
        end
    end

    local tempoPerifericos = os.time() - inicioPerifericos
    print("Tempo de busca dos perifericos: " .. tempoPerifericos .. " segundos")

    local inicioContagem = os.time()
    -- Procura itens não completos
    procurarItensNaoCompletos(chests)

    local tempoContagem = os.time() - inicioContagem
    print("Tempo de contagem dos itens: " .. tempoContagem .. " segundos")

    -- Conferir se tem mais de um item igual incompleto
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
