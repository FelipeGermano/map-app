# Map Editor App

O **Map Editor App** é uma aplicação desenvolvida em Flutter que permite aos usuários criar, editar, visualizar e exportar geometrias (pontos, linhas e polígonos) em um mapa interativo. A aplicação suporta a importação e exportação de dados no formato CSV e inclui funcionalidades para gerenciamento e organização de geometrias.

## Funcionalidades

- **Adição de geometrias**: Criação de pontos, linhas e polígonos diretamente no mapa interativo.
- **Exportação para CSV**: Exporta os dados das geometrias criadas para um arquivo CSV.
- **Importação de CSV**: Importa geometrias de arquivos CSV.
- **Filtragem por tipo**: Filtra a lista de geometrias por tipo (Ponto, Linha, Polígono ou Todos).
- **Exclusão de geometrias**: Remove geometrias específicas da lista.
- **Visualização detalhada**: Move o mapa para a geometria selecionada na lista.

## Tecnologias Utilizadas

- **Flutter**: Framework principal para o desenvolvimento do aplicativo.
- **flutter_map**: Biblioteca para renderização de mapas interativos.
- **latlong2**: Biblioteca para manipulação de coordenadas geográficas.
- **file_picker**: Biblioteca para importação e exportação de arquivos.
- **csv**: Biblioteca para manipulação de arquivos CSV.

## Como Usar

### Pré-requisitos

- Flutter instalado na máquina. [Instruções de instalação](https://flutter.dev/docs/get-started/install)

### Execução do Projeto

1. Clone este repositório:
   ```bash
   git clone https://github.com/seu-usuario/map-editor-app.git
   ```

2. Navegue até o diretório do projeto:
   ```bash
   cd map-editor-app
   ```

3. Instale as dependências:
   ```bash
   flutter pub get
   ```

4. Execute o aplicativo:
   ```bash
   flutter run
   ```

### Utilização

1. **Adicionar geometrias**:
   - Toque no mapa para adicionar um ponto.
   - Escolha o tipo de geometria (Ponto, Linha, Polígono) e insira um nome.
   - Para linhas e polígonos, continue tocando no mapa para adicionar mais coordenadas. Finalize clicando no botão de finalização.

2. **Exportar geometrias**:
   - Clique no botão de exportação (ícone de download) para salvar as geometrias em um arquivo CSV.

3. **Importar geometrias**:
   - Clique no botão de importação (ícone de upload) e selecione um arquivo CSV.

4. **Filtrar geometrias**:
   - Use o menu suspenso acima da lista para filtrar geometrias por tipo.

5. **Excluir geometrias**:
   - Clique no ícone de exclusão na lista para remover uma geometria específica.

## Estrutura do CSV

O arquivo CSV deve conter as seguintes colunas:

| Name       | Type       | Coordinates                                   |
|------------|------------|----------------------------------------------|
| Nome do objeto | Tipo de geometria (Ponto, Linha, Polígono) | Lista JSON com pares latitude/longitude |

Exemplo:
```csv
Name,Type,Coordinates
Ponto 1,Ponto,"[[0,0]]"
Linha 1,Linha,"[[0,0],[1,1],[2,2]]"
Polígono 1,Polígono,"[[0,0],[1,1],[1,0],[0,0]]"
```

![screenshot](https://cloud.screenpresso.com/LWZzsE9Lttus/geo_original.gif)
