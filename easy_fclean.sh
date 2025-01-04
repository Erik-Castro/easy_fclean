#!/usr/bin/env bash

# Configurações padrão
THREADS=2
OVERWRITES=33

# Função para exibir a ajuda do script
show_help() {
    echo "Uso: $(basename "$0") [opções] <diretório>"
    echo "Opções:"
    echo "  -t <número>   Número de threads (padrão: $THREADS)"
    echo "  -o <número>   Número de sobrescrições para shred (padrão: $OVERWRITES)"
    echo "  -h            Exibir esta ajuda"
}

# Função para remover arquivos e diretórios de forma segura
remove_securely() {
    local arg="${1-x}"
    local subdir

    # Verifica se o argumento está vazio
    [[ -z "$arg" ]] && exit 2

    # Encontra e sobrescreve arquivos
    find "$arg" -maxdepth 1 -type f | xargs -I {} -P "$THREADS" shred -un "$OVERWRITES" {} || {
        echo "Erro ao sobrescrever arquivos em $arg"
        return 1
    }

    # Remove subdiretórios recursivamente
    while IFS= read -r -d '' subdir; do
        remove_securely "$subdir" || {
            echo "Erro ao remover subdiretório $subdir"
            return 1
        }
    done < <(find "$arg" -maxdepth 1 -type d)

    # Remove o diretório principal
    rm -rf "$arg" || {
        echo "Erro ao remover diretório $arg"
        return 1
    }
}

# Processa as opções de linha de comando
while getopts ":t:o:h" opt; do
    case ${opt} in
    t) THREADS="$OPTARG" ;;    # Define o número de threads
    o) OVERWRITES="$OPTARG" ;; # Define o número de sobrescrições
    h)
        show_help
        exit 0
        ;; # Exibe ajuda
    \?)
        echo "Opção inválida: -$OPTARG" >&2
        exit 1
        ;; # Tratamento de opção inválida
    :)
        echo "Opção -$OPTARG requer um argumento." >&2
        exit 1
        ;; # Tratamento de argumento ausente
    esac
done
shift $((OPTIND - 1)) # Remove as opções processadas da lista de argumentos

# Verifica se um diretório ou arquivo foi fornecido
if [ "$#" -ne 1 ]; then
    echo "Erro: Uso $(basename "$0") <diretório>"
    exit 1
fi

# Se o argumento for um arquivo, sobrescreve e sai
if [[ -f "$1" ]]; then
    shred -un "$OVERWRITES" "$1" || {
        echo "Erro ao sobrescrever o arquivo $1"
        exit 1
    }
    exit 0
fi

# Chama a função para remover o diretório de forma segura
remove_securely "$1" || {
    echo "Erro ao remover o diretório $1"
    exit 1
}
