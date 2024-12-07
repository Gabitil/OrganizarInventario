# Organizador de Inventário no Minecraft com ComputerCraft (Sem HashMap)

Este programa foi desenvolvido em Lua com o mod ComputerCraft no Minecraft para organizar automaticamente os itens em múltiplos baús conectados. A proposta é transferir itens entre baús de modo a completar os "stacks" (pilhas) incompletas e, assim, otimizar o armazenamento.

# Objetivo

Implementar uma solução funcional para organizar inventários no Minecraft sem utilizar estruturas de dados avançadas, como HashMap, limitando-se apenas às listas padrão da linguagem.

# Funcionamento

O programa realiza as seguintes etapas:

    Identificação dos Baús:
      Percorre todos os periféricos conectados e identifica aqueles que são baús.

    Busca de Itens Incompletos:
      Procura por "stacks" de itens incompletos (quantidade menor que o limite permitido) em todos os baús e os armazena em uma lista de itens incompletos.

    Filtragem de Itens Duplicados:
      Remove itens que não possuem equivalentes (itens iguais em outros slots/baús) da lista de incompletos.

    Transferência de Itens:
      Percorre a lista de itens incompletos e transfere itens entre baús para completar as pilhas.

    Logs Detalhados:
      Durante a execução, todas as ações e informações relevantes (como tempos de execução e transferências realizadas) são salvas em um arquivo de log (saida.txt).

# Complexidade e Limitações

    Complexidade:
      O programa possui complexidade O(n²) devido à necessidade de percorrer repetidamente a lista de itens nos baús para identificar e transferir os itens incompletos.

    Limitação Técnica:
      Em cenários com muitos baús e muitos itens, a demora causada pela complexidade quadrática pode exceder o tempo máximo de execução permitido pelo jogo ou pelo mod. Nesse caso, uma exceção é ativada e o programa é interrompido.

    Funcionamento Ideal:
      Para inventários pequenos, o programa funciona de forma eficiente, organizando os itens conforme esperado.

# Melhorias Futuras

    Uso de Estruturas de Dados Eficientes:
      A substituição das listas padrão por um HashMap ou tabelas indexadas pode reduzir significativamente o tempo de busca e transferência de itens.

    Paralelismo:
      Explorar o suporte a múltiplas threads ou processos no ComputerCraft (quando possível) para otimizar o tempo de execução.

    Melhoria no Tratamento de Erros:
      Adicionar mecanismos robustos para evitar interrupções inesperadas e melhorar a recuperação de falhas.

# Código Fonte

O código implementado está disponível no arquivo principal e pode ser executado no ambiente do ComputerCraft dentro do Minecraft.
