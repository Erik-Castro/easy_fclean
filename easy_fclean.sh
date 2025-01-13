#!/usr/bin/env bash
# ==============================================================================
# Nome: easy_fclean.sh
# Versão: 0.1.0-alpha
# Versáo: 0.1.3-beta
# Descrição: Ferramenta para exclusão segura de arquivos e diretórios.
#            Parte do conjunto de ferramentas 'easy_tools' para segurança e
#            manipulação de dados.
# 
# Uso: easy_remove.sh [opções] <diretório>
# 
# Opções:
#   -t <número>   Define o número de threads para processamento paralelo.
#                 Padrão: 2
#   -o <número>   Define o número de sobrescrições para o comando 'shred'.
#                 Padrão: 08
#   -h            Exibe esta ajuda.
# 
# Recursos:
# - Permite apagar arquivos e diretórios recursivamente usando múltiplas threads.
# - Sobrescreve arquivos usando o 'shred' com um número configurável de sobrescrições.
# - Remoção segura de subdiretórios e diretórios principais.
# 
# Dependências:
# - 'shred' para sobrescrita segura.
# - Compatível com sistemas Unix/Linux.
# 
# Autor: Erik Castro
# Projeto: easy_tools
# Licença: MIT
# Data: $(date "+%d/%m/%Y")
# ==============================================================================

# Configurações padrão
THREADS=2
OVERWRITES=8
export ASSUME_YES=0
ini_t=$(date '+%s')
Sub_dir=0
VERBOSITY=0

# Função para exibir a ajuda do script
show_help() {
    echo "Uso: $(basename "$0") [opções] <diretório>"
    echo "Opções:"
    echo "  -t <número>   Número de threads (padrão: $THREADS)"
    echo "  -o <número>   Número de sobrescrições para shred (padrão: $OVERWRITES)"
    echo "  -y            Assume yes to exclusion"
    echo "  -h            Exibir esta ajuda"
    echo "  -v           exibir verbosidafe"
}

# Logverbose
log_message() {
    local level="$1"
    shift

    if (( VERBOSITY >= level )); then
	echo "$@"
    fi
}

# Função para remover arquivos e diretórios de forma segura
remove_securely() {
    local arg="${1-x}"
    local subdir
    local flag

    # Verifica se o argumento está vazio
    [[ -z "$arg" ]] && exit 2

    # Log nivel 1
    log_message 1 "Removing files from: \"$arg\""

    # Verbosidade no shred
    if (( VERBOSITY >= 3 )); then
	flag="-v"
    fi

    # Encontra e sobrescreve arquivos
    find "$arg" -maxdepth 1 -type f -print0 | xargs -0 -I {} -P "$THREADS" shred "$flag" -un "$OVERWRITES" {} || {
        echo "Erro ao sobrescrever arquivos em $arg"
        return 1
    }

    # Log nivel 1
    log_message 1 "Search to sub-directories!"

    # Remove subdiretórios recursivamente
    while IFS= read -r -d '' subdir; do

	# Log nivel 2
	log_message 2 "Removing files from sub-directories: ${subdir}!"

        remove_securely "$subdir" || {
            echo "Erro ao remover subdiretório $subdir"
            return 1
        }

	# Conta directorios
	((Sub_dir++))

	# Log nivel 3
	log_message 3 "sub-directories removed ${Sub_dir}"
    done < <(find "$arg" -maxdepth 1 -type d ! -path "$arg" -print0)

    # Remove o diretório principal
    rm -rf "$arg" || {
        echo "Erro ao remover diretório $arg"
        return 1
    }

    return 0
}

# Processa as opções de linha de comando
while getopts ":t:o:yvh" opt; do
    case ${opt} in
    t) THREADS="$OPTARG" ;;    # Define o número de threads
    o) OVERWRITES="$OPTARG" ;; # Define o número de sobrescrições
    y) ASSUME_YES=1 ;; # suprime confimação de exclusão
    h)
        show_help
        exit 0
        ;; # Exibe ajuda
    v) ((VERBOSITY++)) ;;
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

# Valida se o arquivo existe
if [[ ! -f ${1-x} ]]; then
    echo "O arquivo ou diretório: \"${1}\", não existe."
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

if [[ "$ASSUME_YES" -eq 0 ]]; then
    read -r -p "Tem certeze que deseja prosseguir: [y,N] " option </dev/tty

    # Se a opção não for válida, encerra a execução
    if [[ ! $option =~ ^(y|Y|s|S|yes|YES|sim|SIM)$ ]]; then
	echo "Encerrando a execução..."
	exit 1
    fi

    # Se a opção for válida, define ASSUME_YES como 1
    ASSUME_YES=1
fi

# Chama a função para remover o diretório de forma segura
remove_securely "$1" || {
    echo "Erro ao remover o diretório $1"
    exit 1
}

[[ "$?" -eq 0 ]] && {
    total_time=$(echo "scale=3; $(date "+%s") - $ini_t" | bc);
    echo "Total time of execution: ${total_time}."

    [[ $Sub_dir -gt 0 ]] && {

	echo "${Sub_dir} sub-folders has been deleted!"
    }
    exit 0
}
