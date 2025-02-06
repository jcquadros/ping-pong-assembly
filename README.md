# Jogo de Ping Pong

Este é o projeto de um jogo de Ping Pong desenvolvido como parte de um trabalho acadêmico. O objetivo é quebrar os blocos do contrincante e não deixar a bolinha sair da tela, evitando que ela ultrapasse as laterais. O jogo inclui diferentes níveis de dificuldade, controles para movimentação das raquetes e uma interface interativa.

## Requisitos

- **DOSBox**: Para rodar o jogo, você precisará do emulador DOSBox. Você pode baixá-lo [aqui](https://www.dosbox.com/download.php?main=1).
- **Compilador**: O compilador necessário está disponível para download [aqui](https://drive.google.com/file/d/1H2dDpJVOVY9q51c2a-zEuPpt85fl0K4_/view?usp=sharing).

## Instruções de Instalação

1. **Instale o DOSBox**: Baixe e instale o DOSBox a partir do link fornecido.
2. **Clone o repositório**: Faça o clone deste repositório para o seu computador.
3. **Monte o diretório no DOSBox**:
    - Abra o DOSBox.
    - No terminal do DOSBox, digite o seguinte comando para montar o diretório onde o repositório foi clonado:
        ```
        mount C 'diretório do repositório clonado'
        ```
    - Monte a unidade com o comando:
        ```
        C:
        ```
4. **Extraia o compilador**:
    - Extraia o arquivo ZIP do compilador dentro da pasta do repositório clonado.
5. **Compile o jogo (opcional)**:
    - No terminal do DOSBox, dentro do diretório do repositório, execute o comando:
        ```
        make
        ```
6. **Execute o jogo**
    - Caso nao queira compilar o jogo o arquivo executável já se encontra no repositório. Para executar o jogo basta executar o comando:
    ```
    main
    ```

## Como Jogar

### Tela Inicial
1. Ao iniciar o jogo, a tela inicial permitirá ao usuário selecionar a **dificuldade**:
    - **Fácil**
    - **Médio**
    - **Difícil**
2. Use as setas do teclado para selecionar a dificuldade e pressione **Enter** para iniciar o jogo.

### Controles
- **Raquete do Jogador 1**: Use as teclas **W** (subir) e **S** (descer).
- **Raquete do Jogador 2**: Use as teclas **Seta para cima** (subir) e **Seta para baixo** (descer).
- **Pausar o Jogo**: Pressione **P** para pausar o jogo em qualquer momento. Para retomar, pressione **P** novamente.
- **Finalizar o Jogo**: Pressione **Q** para sair do jogo. Será exibido um menu perguntando se deseja confirmar a saída.

### Regras do Jogo
- A bolinha se move com ângulos de 45 graus e não retorna à direção que vem.
- A tela contém duas linhas para limitar o movimento vertical da bolinha, além de 5 blocos a serem protegidos pelas raquetes de cada jogador.
- O objetivo é não deixar a bolinha sair da tela pelas laterais. Caso a bolinha saia, o jogo terminará com a mensagem "Game Over" e uma opção de **reiniciar** ou **sair**:
  - **Pressione Y** para reiniciar a partida.
  - **Pressione N** para sair do jogo.

### Finalizando o Jogo
- Após a bolinha sair da tela ou em qualquer outro momento, o jogo exibirá uma tela de "Game Over" perguntando se deseja reiniciar ou sair.

