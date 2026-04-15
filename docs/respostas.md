# Respostas Teóricas — SigaEdu

---

## 1. Modelagem e Arquitetura (Teoria)

### SGBD Relacional vs. NoSQL

Um banco relacional como o PostgreSQL faz mais sentido aqui porque os dados acadêmicos têm relacionamentos bem definidos — aluno se matricula em disciplina, disciplina tem professor, professor tem notas. Esse tipo de estrutura é exatamente pra o que o modelo relacional foi feito.

O principal motivo técnico é o ACID. Com ele, se uma operação de matrícula falhar no meio, nada fica pela metade (Atomicidade). As constraints de FK garantem que ninguém lança nota pra uma matrícula que não existe (Consistência). Dois secretários alterando o mesmo registro ao mesmo tempo não corrompem o dado (Isolamento). E depois do COMMIT, o dado não some nem se o servidor cair (Durabilidade).

NoSQL seria útil se os dados fossem desestruturados ou se precisasse escalar horizontalmente de forma absurda — o que não é o caso de um sistema acadêmico.

---

### Por que usar Schemas em vez de tudo no `public`

Schemas funcionam como pastas: você separa o que é do domínio acadêmico (alunos, disciplinas, matrículas) do que é de segurança (usuários do sistema, permissões). Isso deixa o banco organizado e facilita a manutenção.

Além disso, com schemas separados fica muito mais fácil controlar permissões. Dá pra falar "professor_role tem acesso ao schema academico mas não ao seguranca" em uma linha, em vez de ficar controlando tabela por tabela.

Jogar tudo no `public` funciona em projeto de faculdade, mas em ambiente de produção vira bagunça rápido.

---

## 2. Projeto e Normalização

### 1NF
Valores já são atômicos e sem grupos repetidos. A tabela está em 1NF, mas os dados do aluno e da disciplina se repetem em toda linha.

### 2NF
A chave composta é `(ID_Matricula, Cod_Servico_Academico)`. Vários atributos dependem só de metade dela — isso é dependência parcial, viola 2NF.

- `Nome_Usuario`, `Email`, `Endereco`, `Data_Ingresso`, `Matricula_Operador` → dependem só do aluno
- `Nome_Disciplina`, `Carga_H`, `Nome_Docente` → dependem só da disciplina

Solução: separar em `aluno`, `disciplina` e `matricula`.

### 3NF
`Nome_Docente` fica na tabela `disciplina`, mas pertence ao docente — dependência transitiva. Separar em tabela própria resolve. O mesmo vale para `operador_pedagogico`, que atende múltiplos alunos.

---

### Modelo Lógico

```
operador_pedagogico ( matricula_operador PK, nome_operador )

aluno ( id_aluno PK, nome, email, endereco, data_ingresso, matricula_operador FK )

docente ( id_docente PK, nome_docente )

disciplina ( cod_disciplina PK, nome_disciplina, carga_horaria, id_docente FK )

matricula ( id PK, id_aluno FK, cod_disciplina FK, ciclo_calendario, score_final, ativo )
```

> DER disponível em `/docs/DER.md`

---

## 5. Transações e Concorrência

Quando a primeira transação executa o `UPDATE`, o SGBD coloca um **lock exclusivo** naquela linha. A segunda transação fica bloqueada até o `COMMIT` da primeira — só então ela executa, lendo o valor já atualizado.

Isso é o **Isolamento** do ACID em ação. Sem ele, as duas transações leriam o valor original ao mesmo tempo e a segunda sobrescreveria a primeira — perdendo uma alteração. O SGBD garante que isso não aconteça.
