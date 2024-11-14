# Docker Image Management Script

Este script Bash foi desenvolvido para facilitar o gerenciamento de imagens Docker e sua transferência entre servidores. Com ele, é possível construir, salvar, transferir e importar imagens Docker para servidores locais ou clusters Kubernetes (K8s).

## Funcionalidades

O script oferece um menu interativo com as seguintes opções:

1. **Salvar tar da imagem**  
   Construa uma imagem Docker e salve-a como um arquivo `.tar`.

2. **Enviar tar para os servidores**  
   Envie um arquivo `.tar` de imagem Docker para um ou mais servidores remotos.

3. **Importar tar já no servidor**  
   Importe arquivos `.tar` para um cluster Kubernetes (K8s) ou outro servidor. **(Em construção)**

4. **Sair**  
   Encerra a execução do script.

5. **Sobre**  
   Exibe informações sobre o script.

## Pré-requisitos

- **Docker**: O Docker deve estar instalado e configurado no seu sistema.
- **Acesso SSH**: É necessário ter acesso via SSH aos servidores de destino.
- **Kubernetes (opcional)**: Se você deseja importar imagens para um cluster Kubernetes, é necessário ter o `kubectl` configurado e acesso ao cluster.

## Como usar

1. **Clone ou baixe o script** para o seu sistema local.

2. **Torne o script executável**:
    ```bash
    chmod +x deploy_images.sh
    ```

3. **Execute o script**:
    ```bash
    ./deploy_images.sh
    ```

4. O menu interativo será exibido. Selecione a opção desejada, digitando o número correspondente.

### Exemplo de fluxo:

- Escolha "1" para salvar uma imagem Docker.
- Informe o nome da imagem Docker que deseja criar e o diretório onde deseja salvar o arquivo `.tar`.
- Escolha "2" para enviar o arquivo `.tar` para servidores remotos.
- Forneça o(s) endereço(s) de IP ou hostname(s) do(s) servidor(es) para onde o arquivo será enviado.
- Se você precisar importar o arquivo `.tar` para um cluster Kubernetes, escolha a opção "3" e siga as instruções.

## Estrutura do Script

O script possui as seguintes etapas:

1. **Construção da Imagem Docker**: Utiliza o comando `docker build` para criar a imagem a partir de um `Dockerfile`.
2. **Salvamento da Imagem**: Usa o comando `docker save` para criar um arquivo `.tar` com a imagem.
3. **Envio para Servidores**: Envia o arquivo `.tar` para servidores remotos via `scp` ou outro protocolo de sua escolha.
4. **Importação em Kubernetes**: Caso necessário, utiliza o comando `kubectl` para importar a imagem para um cluster Kubernetes.

## Dependências

- **Docker**: Certifique-se de ter o Docker instalado e em funcionamento.
- **SCP**: Para transferir arquivos via `scp`, você precisará de acesso SSH configurado nos servidores.
- **Kubectl**: Para importar imagens em um cluster Kubernetes.

## Exemplo de Comando para Construir e Salvar uma Imagem

```bash
docker build -t minha-imagem:v1 .
docker save -o minha-imagem-v1.tar minha-imagem:v1
