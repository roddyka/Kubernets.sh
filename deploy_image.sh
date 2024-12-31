#!/bin/bash

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m' # Sem cor

# Arte ASCII
echo "   #####   ####      #####   ######   ##   ##           #####    #######  ######   ####      #####   ##  ## ";
echo "  ##   ##   ##      ##   ##  # ## #   ##   ##            ## ##    ##   #   ##  ##   ##      ##   ##  ##  ## ";
echo "  #         ##      ##   ##    ##     ##   ##            ##  ##   ## #     ##  ##   ##      ##   ##  ##  ## ";
echo "   #####    ##      ##   ##    ##     #######            ##  ##   ####     #####    ##      ##   ##   #### ";
echo "       ##   ##   #  ##   ##    ##     ##   ##            ##  ##   ## #     ##       ##   #  ##   ##    ## ";
echo "  ##   ##   ##  ##  ##   ##    ##     ##   ##            ## ##    ##   #   ##       ##  ##  ##   ##    ## ";
echo "   #####   #######   #####    ####    ##   ##           #####    #######  ####     #######   #####    #### ";
while true; do
  echo "Escolha uma opção:"
  echo "1. Salvar tar da imagem"
  echo "2. Enviar tar para os servidores"
  echo "3. Importar tar já no servidor"
  echo "4. Sair"
  echo "5. Sobre"
  read -p "Digite sua opção (1-4): " option

  case $option in
       0)
      echo "Procurando por arquivos Dockerfile no diretório atual: $(pwd)"
      # Listando os Dockerfiles encontrados
      mapfile -t dockerfiles < <(find . -name "Dockerfile")
      
      if [ ${#dockerfiles[@]} -eq 0 ]; then
        echo "Nenhum Dockerfile encontrado."
        continue
      fi

      # Listar os Dockerfiles com um ID
      echo "Selecione um Dockerfile pelo número:"
      for i in "${!dockerfiles[@]}"; do
        echo "$((i + 1)). ${dockerfiles[$i]}"
      done

      # Receber a seleção do usuário
      read -p "Digite o número do Dockerfile que deseja usar: " selection
      selected_dockerfile="${dockerfiles[$((selection - 1))]}"

      # Verifica se a seleção é válida
      if [ -f "$selected_dockerfile" ]; then
        read -p "Digite o nome da imagem: " image_name
        read -p "Digite a tag da imagem: " image_tag
        read -p "Digite o diretório para salvar a imagem (pode deixar vazio para o diretório atual): " save_dir

        # Se não for especificado um diretório, usa o atual
        if [ -z "$save_dir" ]; then
          save_dir="."
        fi

        # Realiza o build da imagem Docker
        echo "Construindo a imagem Docker '$image_name:$image_tag' a partir de '$selected_dockerfile'..."
        docker build -t "$image_name:$image_tag" -f "$selected_dockerfile" "$save_dir"

        if [ $? -eq 0 ]; then
          echo "Imagem Docker '$image_name:$image_tag' construída com sucesso!"
        else
          echo "Falha ao construir a imagem Docker."
        fi
      else
        echo "O Dockerfile selecionado não foi encontrado."
      fi
      ;;
   1)
   echo "   ######   ######   ######   ######   ######   ######   ######   ######   ######   ###### ";
  echo " Salvar imagem Docker"
  echo "  ######   ######   ######   ######   ######   ######   ######   ######   ######   ###### ";
     # Listar as imagens Docker disponíveis e armazenar em um array
      echo "Imagens Docker disponíveis:"
      images=($(docker images --format "{{.Repository}}:{{.Tag}}"))  # Armazena as imagens em um array

      if [ ${#images[@]} -eq 0 ]; then
        echo "Nenhuma imagem Docker encontrada."
        continue  # Volta ao menu principal se não houver imagens
      fi

      # Exibe a lista de imagens com identificadores
      for i in "${!images[@]}"; do
        echo "$((i + 1)): ${images[$i]}"
      done

      while true; do
        # Obter o número correspondente à imagem desejada do usuário
        read -p "Digite o número da imagem desejada (1-${#images[@]}): " image_index

        # Verificar se o campo não está vazio
        if [[ -z "$image_index" ]]; then
          echo "O número da imagem é obrigatório. Por favor, forneça novamente."
          continue
        fi

        # Verificar se o número é válido
        if ! [[ "$image_index" =~ ^[0-9]+$ ]] || (( image_index < 1 )) || (( image_index > ${#images[@]} )); then
          echo "Número inválido. Por favor, escolha um número entre 1 e ${#images[@]}."
          continue
        fi

        # Obter o nome completo com tag da imagem escolhida
        image_name="${images[$((image_index - 1))]}"

        # Extrair o nome da imagem sem a tag
        base_image_name="${image_name%%:*}"  # Remove tudo após ':'

        # Obter o caminho desejado para salvar a imagem
        read -p "Digite o caminho para salvar a imagem (ex: /home/user/images/): " save_path

        # Verificar se o caminho não está vazio
        if [[ -z "$save_path" ]]; then
          echo "O caminho para salvar a imagem é obrigatório. Por favor, forneça novamente."
          continue
        fi

        # Salvar a imagem Docker em um arquivo tar
        echo "Salvando a imagem, por favor aguarde..."
        docker save "$image_name" > "$save_path/$base_image_name.tar" &  # Executa em segundo plano
        pid=$!  # Armazena o PID do processo em segundo plano
        # Enquanto o processo estiver em execução, exibe uma barra de loading
        while kill -0 $pid 2>/dev/null; do
          echo -n "."
          sleep 1
        done

        # Aguarda a finalização do processo
        wait $pid
        echo ""
        echo "Imagem salva em $save_path/$base_image_names.tar"
        break  # Sair do loop após salvar a imagem com sucesso
      done

    ;;
2)
echo "   ######   ######   ######   ######   ######   ######   ######   ######   ######   ###### ";
  echo " Enviar imagens para servidores"
  echo "  ######   ######   ######   ######   ######   ######   ######   ######   ######   ###### ";
 # Verificar se existem arquivos .tar na pasta atual
echo "Verificando arquivos tar disponíveis na pasta atual..."
tar_files=(./*.tar)

if [ -e "${tar_files[0]}" ]; then
  echo "Arquivos .tar encontrados na pasta atual:"
  
  # Listar os arquivos com numeração
  for index in "${!tar_files[@]}"; do
    echo "$((index + 1)). $(basename "${tar_files[$index]}")"  # Exibe o nome do arquivo com numeração
  done

  read -p "Escolha o número do arquivo tar que deseja usar (ou 0 para digitar um caminho): " choice

  if [[ "$choice" =~ ^[0-9]+$ && "$choice" -gt 0 && "$choice" -le "${#tar_files[@]}" ]]; then
    # Se o usuário escolher um número válido
    tar_path="${tar_files[$((choice - 1))]}"
  elif [ "$choice" -eq 0 ]; then
    read -p "Digite o caminho da imagem tar a ser enviada (ex: /home/user/images/joomla38174.tar): " tar_path
  else
    echo "Escolha inválida. Operação cancelada."
    exit 1
  fi
else
  read -p "Nenhum arquivo .tar encontrado na pasta atual. Por favor, digite o caminho da imagem tar a ser enviada (ex: /home/user/images/joomla38174.tar): " tar_path
fi

# Iniciar um array para os servidores
servers=()

while true; do
  # Obter os detalhes do servidor
  read -p "Digite o nome do host ou endereço IP do servidor (ou 'sair' para finalizar): " server

  if [[ "$server" == "sair" ]]; then
    break  # Sai do loop se o usuário digitar 'sair'
  elif [[ -z "$server" ]]; then
    echo "O nome do host ou endereço IP é obrigatório. Tente novamente."
    continue
  fi

  # Adiciona o servidor ao array
  servers+=("$server")

  # Perguntar se deseja adicionar mais servidores
  read -p "Deseja adicionar outro servidor? (s/n): " add_more
  if [[ "$add_more" != "s" && "$add_more" != "S" ]]; then
    break  # Sai do loop se o usuário não quiser adicionar mais servidores
  fi
done

# Copiar a imagem para os servidores
for server in "${servers[@]}"; do
  echo "Enviando imagem para $server..."
  
  # Iniciar o envio em segundo plano
  scp "$tar_path" "$server":~/ &  # Executa em segundo plano
  pid=$!  # Armazena o PID do processo em segundo plano

  # Enquanto o processo estiver em execução, exibe uma barra de loading
  while kill -0 $pid 2>/dev/null; do
    echo -n "."
    sleep 1
  done

  # Aguarda a finalização do processo
  wait $pid
  
  # Verifica o status da transferência
  if [ $? -eq 0 ]; then
    echo "OK - Imagem enviada para $server."
  else
    echo "Falha ao enviar para $server."
  fi
done

;;

3)
  echo "   ######   ######   ######   ######   ######   ######   ######   ######   ######   ###### ";
    echo " Importar imagens.tar para k8s"
    echo "  ######   ######   ######   ######   ######   ######   ######   ######   ######   ###### ";

    # Iniciar um array para os servidores
    servers=()

    # Solicitar ao usuário os endereços de IP ou nomes dos servidores
    while true; do
      read -p "Digite o nome do host ou endereço IP do servidor onde deseja importar (ex: server1) (ou 'sair' para finalizar): " server

      if [[ "$server" == "sair" ]]; then
        break  # Sai do loop se o usuário digitar 'sair'
      elif [[ -z "$server" ]]; then
        echo "O nome do host ou endereço IP é obrigatório. Tente novamente."
        continue
      fi

      servers+=("$server")  # Adiciona o servidor ao array

      read -p "Deseja adicionar outro servidor? (s/n): " add_more
      if [[ "$add_more" != "s" && "$add_more" != "S" ]]; then
        break  # Sai do loop se o usuário não quiser adicionar mais servidores
      fi
    done

    # Loop para cada servidor
    for server in "${servers[@]}"; do
      echo "Conectando ao servidor $server para listar arquivos .tar..."

      # Obter lista de arquivos .tar no diretório remoto para este servidor específico
      tar_files=($(ssh "$server" "ls ~/*.tar 2>/dev/null"))

      if [ ${#tar_files[@]} -eq 0 ]; then
        echo "Nenhum arquivo .tar encontrado no servidor $server."
        continue
      fi

      # Listar arquivos encontrados
      echo "Arquivos .tar disponíveis em $server:"
      for i in "${!tar_files[@]}"; do
        echo "$((i+1)). ${tar_files[$i]}"
      done

      # Selecionar a imagem a ser importada
      while true; do
        read -p "Digite o número da imagem que deseja importar no servidor $server: " image_index

        if [[ "$image_index" =~ ^[0-9]+$ ]] && (( image_index >= 1 && image_index <= ${#tar_files[@]} )); then
          image_name="${tar_files[$((image_index-1))]}"
          echo "Você selecionou '$image_name' para o servidor $server."
          read -p "Tem certeza que deseja importar essa imagem? (s/n): " confirm
          if [[ "$confirm" == "s" || "$confirm" == "S" ]]; then
            break
          else
            echo "Importação cancelada para este arquivo."
            continue 2  # Passa para o próximo servidor
          fi
        else
          echo "Opção inválida. Tente novamente."
        fi
      done

      # Importar a imagem selecionada no servidor
      echo "Importando imagem em $server..."
      if ssh "$server" "sudo ctr -n=k8s.io images import '$image_name'"; then
        echo "Importação concluída com sucesso em $server"
      else
        echo "Falha ao importar a imagem em $server"
      fi
    done
    ;;


    4)
      echo "Saindo..."
      break
      ;;

5)
  echo "   ######   ######   ######   ######   ######   ######   ######   ######   ######   ###### ";
  echo " SOBRE"
  echo "  ######   ######   ######   ######   ######   ######   ######   ######   ######   ###### ";
  echo "Descrição do Projeto: Gerenciador de Imagens Docker"
  echo ""
  echo "O Gerenciador de Imagens Docker é uma ferramenta de linha de comando desenvolvida para facilitar a gestão de imagens Docker, permitindo aos usuários listar, salvar e transferir imagens para servidores remotos de forma eficiente."
  echo ""
  echo "Funcionalidades do Projeto:"
  echo "1. Listagem de Imagens Docker: O projeto permite listar todas as imagens Docker disponíveis na máquina local, exibindo seus nomes e tags. O usuário pode selecionar uma imagem específica a ser salva."
  echo "2. Salvar Imagem em Arquivo .tar: O usuário pode salvar a imagem Docker selecionada em um arquivo .tar, que pode ser utilizado para transporte ou armazenamento."
  echo "3. Transferência de Arquivos para Servidores Remotos: O projeto possibilita a transferência do arquivo .tar gerado para um ou mais servidores remotos via scp. O usuário pode adicionar múltiplos servidores e a ferramenta irá transferir a imagem para cada um deles, exibindo uma barra de loading durante o processo."
  echo ""
  echo "Requisitos do Sistema:"
  echo "1. Docker: O Docker deve estar instalado e em execução. O usuário deve ter permissões para executar comandos Docker (é recomendável ser parte do grupo docker)."
  echo "2. SSH e SCP: A máquina do usuário deve ter acesso SSH configurado para se conectar aos servidores remotos. Isso inclui a configuração de chaves SSH, se necessário."
  echo "3. Ambiente Bash: O script é escrito para ser executado em um terminal Bash. O usuário deve ter um ambiente de shell compatível."
  echo "4. Sistema Operacional: O projeto foi testado em ambientes Linux e macOS. O suporte a Windows pode exigir o uso do WSL (Windows Subsystem for Linux) ou uma ferramenta de compatibilidade."
  echo ""
  echo "Como Usar o Projeto:"
  echo "1. Execução do Script: Para iniciar o script, abra um terminal e execute o script Bash criado. Você pode precisar dar permissões de execução ao script usando o comando:"
  echo "   chmod +x seu_script.sh"
  echo "2. Interação com o Usuário: O script guiará o usuário através de prompts interativos, permitindo que ele escolha imagens, defina caminhos e adicione servidores."
  echo "3. Monitoramento de Progresso: Durante o processo de transferência, o usuário verá uma barra de loading que indica o progresso da operação."
  echo ""
  echo "Exemplo de Uso:"
  echo "Após a configuração do ambiente e do Docker, execute o script e siga as instruções na tela. Por exemplo, ao listar imagens, o usuário verá algo como:"
  echo "Imagens Docker disponíveis:"
  echo "1. joomla38174:0.0.1"
  echo "2. nginx:latest"
  echo "3. ubuntu:20.04"
  echo "Escolha o número da imagem que deseja usar (ou 0 para digitar um caminho):"
  echo ""
  echo "Contato: /roddyka no GitHub"
  ;;

    *)
    
      echo "Opção inválida. Tente novamente."
      ;;

      
  esac

  echo ""  # Linha em branco para melhor visualização
done

echo "Processo concluído!"
