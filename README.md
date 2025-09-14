# kipu-bank-module

# Objetivos do Exame

    Aplicar conceitos centrais de Solidity aprendidos em aula.

    Seguir padrões de segurança.

    Usar comentários e uma estrutura limpa para melhorar a legibilidade e a manutenibilidade do contrato.

    Implantar um contrato inteligente totalmente funcional em uma testnet.

    Criar um repositório no GitHub que documente e apresente seu projeto.

# Descrição da Tarefa e Requisitos
Sua tarefa é recriar o contrato inteligente KipuBank com funcionalidade completa e documentação conforme descrito abaixo.

# Funcionalidades do KipuBank:

    Usuários podem depositar tokens nativos (ETH) em um cofre pessoal.

    Usuários podem sacar fundos de seu cofre, mas apenas até um limite fixo por transação, representado por uma variável imutável.

    O contrato impõe um limite global de depósitos (bankCap), definido durante a implantação.

    Interações internas e externas devem seguir boas práticas de segurança e instruções revert com erros personalizados claros, caso as condições não sejam atendidas.

    Eventos devem ser emitidos tanto em depósitos quanto em saques bem-sucedidos.

    O contrato deve registrar o número de depósitos e saques.

    O contrato deve ter pelo menos uma função external, uma private e uma view.

# Práticas de Segurança a Seguir:

    Usar erros personalizados em vez de mensagens require.

    Respeitar o padrão checks-effects-interactions e convenções de nomenclatura.

    Usar modifiers quando apropriado para validar lógica.

    Tratar transferências nativas com segurança.

    Manter variáveis de estado limpas, legíveis e bem comentadas.

    Adicionar comentários NatSpec para cada função, erro e variável de estado.

    Aplicar convenções de nomenclatura adequadas.
