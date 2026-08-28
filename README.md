# Template SNES LoROM (PONG)

ROM de 32 KiB para Super Nintendo: LoROM NTSC, sem SRAM, sem áudio e sem chips especiais. Este repositório é um template mínimo verificável. O PONG só entra depois que o cartucho inicializar e permanecer estável.

Assembler: [WLA-DX](https://github.com/vhelin/wla-dx). Emulador de depuração recomendado: [bsnes-plus](https://github.com/devinacker/bsnes-plus).

## Estado atual

Milestone 10 + placar + menu 1P/2P — na tela inicial, Cima/Baixo escolhe **1 JOGADOR** (IA na direita) ou **2 JOGADOR** (joy 2 na direita); Start confirma.

Critério de sucesso: cada gol incrementa o lado certo; em 9 vira 10; o resto do jogo continua estável.

## Compilar

```bash
make toolchain          # uma vez: instala WLA-DX em tools/bin
make                    # tela azul (padrão) → build/pong-blue.sfc e build/pong.sfc
make COLOR=black        # → build/pong-black.sfc
make COLOR=blue
make COLOR=red
make colors             # gera as três ROMs de teste
make verify
```

Cada cor é uma ROM independente. Teste preto, azul e vermelho no emulador e no console real antes de avançar.

## Por que os travamentos anteriores aconteciam

Causas clássicas logo após a tela de start:

- NMI habilitado com vetor inválido ou rotina que não termina em `RTI`
- stack, direct page ou `DBR` não inicializados
- escrita de 16 bits em registrador de 8 bits (`$2100`, `$2118`, `$2122`, `$4300`)
- DMA ou atualização de VRAM fora de Force Blank / VBlank
- `JSL`/`JML` antes de o mapa de bancos estar correto

Este template evita tudo isso de propósito.

## Regras que permanecem

- Código inicial inteiro no banco `$00`
- Sem `JSL`/`JML` até os bancos estarem claros
- NMI só depois do vetor e da rotina existirem
- DMA de PPU só em Force Blank ou no NMI
- Acumulador de 8 bits em toda escrita de hardware
- Force Blank durante inicialização gráfica
- Formato único: LoROM NTSC, 32 KiB

## Próximos milestones (um por vez)

| Commit     | O que fazer |
|------------|-------------|
| `boot`     | Já feito: CPU + vetores + loop |
| `color`    | Já feito: preto / azul / vermelho |
| `vblank`   | Já feito: polling de `$4212`; ainda sem `WAI` e sem NMI |
| `tile`     | Já feito: um tile 8×8, paleta e tilemap manuais; DMA depois |
| `font`     | Já feito: fonte 8×8 mínima (`PONG` / `PRESS START`) |
| `input`    | Já feito: leitura manual; `joy_current` / `joy_previous` / `joy_pressed` |
| `title`    | Já feito: `STATE_TITLE` → `STATE_GAME` só com `joy_pressed & BUTTON_START` |
| `gameplay` | Já feito: sprites parados e loop integer de PONG |
| `nmi`      | Já feito: NMI mínimo; lógica do jogo fora do NMI |
| `dma`      | Já feito: DMA de OAM no NMI e VRAM na init |

Arquitetura prevista:

```text
reset.asm       CPU
vectors.asm     vetores
ppu.asm         PPU, VRAM, CGRAM, OAM
input.asm       controles
title.asm       tela de start
game.asm        lógica do PONG
sprites.asm     buffer OAM
assets.asm      tiles, fonte, paletas
ram.inc         WRAM
hardware.inc    registradores
```

Não comece pela tela de start. Cada milestone precisa ser testada no emulador e no hardware real antes da seguinte.
