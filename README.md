<h1 align="center">Exibir Versão das Libs de Arquivos .JAR via Menu de Contexto</h1>

---

# Visão Geral

Este repositório permite adicionar uma opção ao menu de contexto do Windows (menu do botão direito) para arquivos `.jar`, intitulada **"Exibir versão das libs"**. Ao selecioná-la, um script PowerShell será executado para listar as bibliotecas incluídas no `.jar` e suas respectivas versões.

---

# Estrutura dos Arquivos

* `adicionar_exibir_versoes.reg` — Adiciona a opção ao menu de contexto do Windows
* `exibir_versoes.ps1` — Script que extrai as bibliotecas e exibe as versões

Esses arquivos devem estar localizados em:

```
C:/vr/scripts/
```

---

# Passo a Passo de Instalação

## 1. Clonar o Repositório

```bash
git clone git@github.com:Felipe-Salome/VRLookVersion.git
```

## 2. Mover os Arquivos para o Diretório Correto

Coloque os dois arquivos no seguinte caminho:

```
C:/vr/scripts/
```

> Crie os diretórios se eles ainda não existirem.

## 3. Permitir Execução de Scripts PowerShell

Abra o PowerShell como Administrador e execute:

```powershell
Set-ExecutionPolicy RemoteSigned
```

Responda com `S` para confirmar.

## 4. Adicionar ao Registro do Windows

Dê um **duplo clique** no arquivo:

```
C:/vr/scripts/adicionar_exibir_versoes.reg
```

Confirme quando solicitado para adicionar a chave ao registro.

---

# Como Usar

1. Clique com o botão direito em um arquivo `.jar`
2. Selecione **"Exibir versão das libs"**
3. Uma janela do PowerShell será aberta exibindo as versões das bibliotecas extraídas

---

# Considerações de Segurança

* Altere o script `ps1` conforme o padrão de empacotamento das suas bibliotecas.
* Não execute scripts de fontes desconhecidas.
* Edite o `.reg` caso altere o caminho do script PowerShell.

---

# Licença

Este projeto é distribuído sob a licença [MIT](LICENSE).

---

# Autor

Felipe de Sousa Salomé
