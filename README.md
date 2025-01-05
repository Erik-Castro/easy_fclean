# Documentação do Script `easy_fclean.sh`

## Nome
`easy_fclean.sh`

## Versão
- 0.1.0-alpha
- 0.1.3-beta

## Descrição
O `easy_fclean.sh` é uma ferramenta de linha de comando projetada para a exclusão segura de arquivos e diretórios. Ele faz parte do conjunto de ferramentas `easy_tools`, focado em segurança e manipulação de dados. O script permite a remoção de arquivos e diretórios de forma segura, utilizando múltiplas threads e sobrescrevendo os dados antes da exclusão.

## Uso
```bash
easy_fclean.sh [opções] <diretório>
```

## Opções
- `-t <número>`: Define o número de threads para processamento paralelo. Padrão: 2
- `-o <número>`: Define o número de sobrescrições para o comando `shred`. Padrão: 33
- `-y`: Assume "sim" para a confirmação de exclusão, suprimindo a solicitação de confirmação.
- `-h`: Exibe a ajuda do script.

## Recursos
- Apaga arquivos e diretórios recursivamente usando múltiplas threads.
- Sobrescreve arquivos utilizando o comando `shred` com um número configurável de sobrescrições.
- Permite a remoção segura de subdiretórios e diretórios principais.

## Dependências
- `shred`: Necessário para a sobrescrita segura de arquivos.
- Compatível com sistemas Unix/Linux.

## Autor
Erik Castro

## Projeto
easy_tools

## Licença
MIT

## Data de Criação: `24/12/2024`
## Data da última modificação: `05/01/2025`

## Funcionamento
1. **Configurações Padrão**: O script inicia com configurações padrão para o número de threads e sobrescrições.
2. **Exibição de Ajuda**: A função `show_help` exibe as opções disponíveis e como usar o script.
3. **Log de Mensagens**: A função `log_message` permite registrar mensagens de log com diferentes níveis de verbosidade.
4. **Remoção Segura**: A função `remove_securely` é responsável por encontrar e sobrescrever arquivos, além de remover subdiretórios recursivamente.
5. **Processamento de Opções**: O script processa as opções de linha de comando e verifica se um diretório ou arquivo foi fornecido.
6. **Confirmação de Exclusão**: Se a opção `-y` não for utilizada, o script solicitará confirmação antes de prosseguir com a exclusão.
7. **Execução**: O script chama a função de remoção segura e exibe o tempo total de execução ao final.

## Exemplo de Uso
Para remover um diretório chamado `meu_diretorio` com 4 threads e 10 sobrescrições:
```bash
./easy_fclean.sh -t 4 -o 10 meu_diretorio
```

## Observações
- O uso do script deve ser feito com cautela, pois a exclusão de arquivos e diretórios é irreversível.
- Certifique-se de ter backups dos dados importantes antes de executar o script.
