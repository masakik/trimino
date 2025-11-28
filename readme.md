# Tri-Mos6 Generator (OpenSCAD)

Gerador totalmente paramétrico para peças triangulares para o jogo Trimino.

https://en.wikipedia.org/wiki/Triominoes

- Triângulos equiláteros arredondados
- Numeração automática
- Cavidades ou relevos opcionais
- Chanfros e arredondamentos configuráveis
- Layout de impressão em grade estilo colmeia (hex-grid)
- Seleção de conjuntos de peças via Customizer do OpenSCAD

Projeto 100% em **OpenSCAD**, ideal para quem deseja gerar múltiplos conjuntos de peças de forma automatizada para corte a laser ou impressão 3D.

---

## ✨ Recursos Principais

### 🔺 Geometria Paramétrica
- Triângulo equilátero escalável
- Arredondamento de cantos via `offset()`
- Chanfro opcional
- Furos centrais cilíndricos ou hemisféricos
- Relevo (meia-esfera) opcional no topo

### 🔢 Numeração Automática
Cada peça pode receber um número ou texto com:
- Fonte configurável
- Tamanho ajustável
- Espessura de extrusão
- Offset preciso no centro da peça

### 🧩 Geração de Conjuntos
O módulo `set_of_trimos(trimos)` imprime automaticamente várias peças em:
- Grade horizontal x vertical
- Layout hexagonal com deslocamento da coluna ímpar
- Rotação alternada (180º) conforme necessário

### 🔧 Compatível com o Customizer
Permite escolher:
- Conjunto a ser renderizado
- Tamanho da peça
- Padding (distância real entre peças)
- Opções de chanfro, furo, texto e fontes
