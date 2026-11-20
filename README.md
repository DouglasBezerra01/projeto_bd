# projeto_bd
Repositório para o projeto da disciplina de Banco de Dados

## Executar o site

O site consulta os registros diretamente do banco SQLite por meio de uma API local.
Com Python 3 instalado e o arquivo `clinica.db` na raiz do projeto, execute:

```powershell
python server.py
```

Depois, acesse http://127.0.0.1:8001. Mantenha o servidor em execução enquanto usa o site. A API abre o banco em modo somente leitura e não requer dependências externas.
