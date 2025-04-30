# Ferramenta de Avaliação de Usabilidade

Esta aplicação web permite aos usuários avaliar a usabilidade de algum software (drRacket) com base nas 10 heurísticas de usabilidade de Nielsen. A aplicação coleta as avaliações dos usuários e exibe estatísticas agregadas e visualizações dos resultados da avaliação.

## Funcionalidades

- **Formulário de Avaliação**: Os usuários podem avaliar a usabilidade de software em uma escala de 1 a 10 para cada uma das 10 heurísticas de usabilidade de Nielsen
- **Visualização de Resultados**: Gráfico interativo que exibe dados agregados de avaliação
- **Painel de Estatísticas**: Mostra o número total de avaliações e a classificação média geral

## Pré-requisitos

Para executar esta aplicação, você precisará de:

- [Racket](https://racket-lang.org/) (versão 8.0 ou superior recomendada)
- Os seguintes pacotes Racket:
  - `web-server` (incluído na instalação padrão do Racket)
  - `db` (para funcionalidade de banco de dados SQLite)

## Instalação

1. Clone este repositório ou baixe o código-fonte:

```bash
git clone https://github.com/maiconda/usabilidade-nielsen-racket
```

2. Instale os pacotes necessários:

```bash
raco pkg install db
```

## Estrutura do Projeto

A aplicação consiste nos seguintes arquivos:

- `main.rkt` - O ponto de entrada principal da aplicação
- `frontend.rkt` - Interface web (templates HTML, manipulação de páginas)
- `backend.rkt` - Operações de banco de dados e processamento de dados
- `data.db` - Arquivo de banco de dados SQLite (criado automaticamente)

## Executando a Aplicação

1. Entre na raíz do projeto:

```bash
cd usabilidade-nielsen-racket
```

2. Execute o programa principal:

```bash
racket main.rkt
```

3. Abra seu navegador web e acesse:

```
http://localhost:8000/
```

O servidor continuará em execução até que você encerre o processo (pressionando Ctrl+C no terminal).

## Páginas da Aplicação

- **Página Inicial** (`/`): Visão geral com estatísticas atuais
- **Formulário de Avaliação** (`/form`): Formulário de entrada para os usuários avaliarem
- **Resultados** (`/chart`): Representação visual dos dados de avaliação

## Banco de Dados

A aplicação utiliza SQLite para armazenar dados de avaliação. O arquivo de banco de dados (`data.db`) é criado automaticamente no diretório do projeto na primeira vez que você executa a aplicação.

## Notas de Desenvolvimento

- O frontend é construído usando Bootstrap 5.3.0 para design responsivo
- Os gráficos são criados usando Chart.js 3.9.1
- A aplicação usa a biblioteca web-server/dispatch do Racket para roteamento de URL

## Como Funciona a Avaliação

1. Os usuários avaliam cada uma das 10 heurísticas de usabilidade de Nielsen em uma escala de 1 a 10
2. As avaliações são armazenadas no banco de dados SQLite
3. A aplicação calcula médias e exibe estatísticas
4. Um gráfico de área polar visualiza as pontuações médias em todas as heurísticas
