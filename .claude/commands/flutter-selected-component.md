# Flutter Selected Component

## Description

This command allows you to select a component from a Flutter project and get information about it.

## Usage

1. Primeiro obtenha a localização do componente usando `mcp__dart-mcp-server__get_active_location` para identificar o arquivo e posição atual.
2. Em seguida, use `mcp__dart-mcp-server__hover` passando a URI do arquivo, linha e coluna obtidos no passo anterior para obter as informações detalhados do elemento selecionado (docuentção, tipo, etc).
3. Se disponível `mcp__dart-mcp-server__get_selected_widget` para obeter informações do widget selecionado na aplicação Flutter em execução.
4. Faça uma análise detlhada do elemento selecionado, incluindo:
    - Tipo do elemento
    - Documentação disponível
    - Parâmetros e propriedades
    - Contexto de uso
    - Possíveis problemas ou melhorias  
5. Com base na análise e na solicitação do usuário no chat, execute a ação solicitada (refatoração, correção, melhoria, documentação, etc.).
6. Se necessário, use outras ferramentas MCP do Dart como `mcp__dart-mcp-server__signature_help` para obeter informações adicionais sobre a assinatura da API.
