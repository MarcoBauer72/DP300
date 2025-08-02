----- Base de exemplo
USE [10987]
GO

IF (OBJECT_ID('dbo.Vendas') IS NOT NULL) DROP TABLE dbo.Vendas
CREATE TABLE dbo.Vendas (
    Id_Pedido INT IDENTITY(1,1),
    Dt_Pedido DATETIME,
    [Status] INT,
    Quantidade INT,
    Valor NUMERIC(18, 2)
)

INSERT INTO dbo.Vendas ( Dt_Pedido, [Status], Quantidade, Valor )
SELECT
    DATEADD(SECOND, (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * 199999999, '2015-01-01'),
    (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * 9,
    (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * 10,
    0.459485495 * (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * 1999
GO 10000


INSERT INTO dbo.Vendas ( Dt_Pedido, [Status], Quantidade, Valor )
SELECT Dt_Pedido, [Status], Quantidade, Valor FROM dbo.Vendas
GO 9

select count(1) from dbo.Vendas
sp_spaceused 'dbo.Vendas'


Vendas	5120000             	192776 KB	192320 KB	8 KB	448 KB


CREATE CLUSTERED INDEX SK01_Pedidos ON dbo.Vendas(Id_Pedido)
CREATE NONCLUSTERED INDEX SK02_Pedidos ON dbo.Vendas ([Status], Dt_Pedido) INCLUDE(Quantidade, Valor)
GO

Vendas	5120000             	371920 KB	192336 KB	178480 KB	1104 KB

--Seek Predicate é o primeiro filtro que é aplicado aos dados quando o SQL Server executa uma consulta. 
--Por conta disso, o ideal é que os índices sejam criados para priorizar o Seek Predicate nas 
--colunas mais seletivas possíveis (menor quantidade possível de registros para cada valor da coluna), 
--para que o primeiro nível de filtragem retorna a menor quantidade possível de linhas. 
--A operação de Predicate ocorre após o Seek Predicate. Após o primeiro filtro realizado nos dados, 
--o SQL Server irá aplicar os demais filtros da consulta no subconjunto retornado pelo Seek Predicate, ou seja, 
--quanto maior o subconjunto na 2ª etapa, maior o trabalho para o otimizador de consultas, já que no Predicate 
--podem ter filtros que são pesados e não muito seletivos.

--Ah, mas como faço para forçar várias condições no Seek Predicate? Não faz.. rs.. Existe um número bem limitado 
--de operações que podem ser feitas em conjunto dentro do Seek Predicate, como por exemplo, 
--uma operação de range (between ou > valor e < valor) e outra de igualdade (=) podem ser utilizadas 
--junto no Seek Predicate, mas duas operações iguais, sejam elas range ou igualdade, não.


SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Vendas
WHERE Dt_Pedido >= '2019-02-06'
AND Dt_Pedido < '2019-02-09'
AND [Status] < 5

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

-- Anotar Resultado Abaixo
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

(4608 rows affected)
Table 'Vendas'. Scan count 1, logical reads 12389, physical reads 0, read-ahead reads 30, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

(1 row affected)

 SQL Server Execution Times:
   CPU time = 156 ms,  elapsed time = 337 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.




--Analisando o plano de execução superficialmente, não identificamos nada de diferente de uma consulta otimizada..
--Operação de Seek, nenhum Keylookup.. Tudo certo.
--Mas e se a gente analisar mais a fundo ? Bom, não está tão bem assim.. 
--Para retornar 4.608 linhas, eu tive que ler 2.848.260 linhas, mais de 600x.

-- Uma outra forma de visualizar como a consulta está sendo executada no banco, é utilizar o comando SET STATISTICS PROFILE ON
SET STATISTICS PROFILE ON

SELECT *
FROM dbo.Vendas
WHERE Dt_Pedido >= '2019-02-06'
AND Dt_Pedido < '2019-02-09'
AND [Status] < 5

SET STATISTICS PROFILE OFF

-- Como identificar o quão seletivas são as colunas?
-- Observemos o plano de execução e vejamos as condições de Seek Predicate (filtro por Status) e Predicate (filtro por Dt_Pedido). 
-- Será que a coluna Status é mais seletiva que a coluna de Dt_Pedido, ainda mais na consulta acima ? 
-- Vamos descobrir criando estatística para a coluna de Status e analisar o histograma: (* Ou por GROUP BY simples contra cada tabela)

CREATE STATISTICS Vendas_Status ON dbo.Vendas(Status) WITH FULLSCAN
GO

DBCC SHOW_STATISTICS('Vendas', Vendas_Status)
GO


SELECT 1/0.1111111  -- 9 valores distintos de Status com distribuicao media de 550 a 600 mil linhas para cada status


-- Analisando o histograma da coluna Dt_Pedido, para verificar se ela é mais seletiva que a coluna de Status
CREATE STATISTICS Vendas_DtPedido ON dbo.Vendas(Dt_Pedido) WITH FULLSCAN
GO
 
DBCC SHOW_STATISTICS('Vendas', Vendas_DtPedido)
GO

SELECT 1/0.0001 -- 10.000 datas distintas

-- Analisando o histograma da coluna Dt_Pedido, podemos observar que a densidade é muito menor, 
-- com cerca de dezenas de milhares de valores distintos e uma média de 20 a 50 mil registros 
-- para caixa faixa do histograma e uma estimativa de 512 registros por valor distinto, 
-- o que mostra que é uma coluna muito mais seletiva que a coluna Status.

--Observação: Cuidado ao criar estatísticas em tabelas muito grandes, especialmente com a cláusula FULLSCAN. 
--Caso não esteja seguro de utilizar esse comando para analisar no histograma, você pode simplesmente utilizar
--uma consulta como essa SELECT Dt_Pedido, COUNT(*) FROM Vendas GROUP BY Dt_Pedido para conseguir ter uma boa ideia 
--da seletividade das colunas.


-- Exemplo 1 – Range e Range
SELECT Quantidade * Valor
FROM dbo.Vendas
WHERE Dt_Pedido >= '2019-02-06'
AND Dt_Pedido < '2019-02-09'
AND [Status] < 5

-- Embora a operação de leitura seja um Seek, ela ainda pode ser melhorada recriando um índice utilizando 
-- uma abordagem mais seletiva


-- Dropando o índice SK02_Pedidos e inverter as colunas desse índice para fazer com que a operação de Seek Predicate seja feita na coluna Dt_Pedido ao invés da coluna Status
DROP INDEX SK02_Pedidos ON dbo.Vendas
GO

CREATE NONCLUSTERED INDEX SK02_Pedidos ON dbo.Vendas (Dt_Pedido, [Status]) INCLUDE(Quantidade, Valor)
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT Quantidade * Valor
FROM dbo.Vendas
WHERE Dt_Pedido >= '2019-02-06'
AND Dt_Pedido < '2019-02-09'
AND [Status] < 5

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

-- O tempo de CPU caiu drasticamente assim como o numero de leituras logicas

-- Exemplo 2 – Range e Igualdade
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT Quantidade * Valor
FROM dbo.Vendas
WHERE Dt_Pedido > '2019-02-06'
AND Dt_Pedido < '2019-02-09'
AND [Status] = 5

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

-- O plano ficou bem parecido com o plano anterior, mesmo alterando o filtro de status.
-- Mas agora vem a pergunta: Dá pra melhorar ainda mais essa consulta ?
-- A resposta é Sim.. Vamos voltar o índice para a condição anterior
DROP INDEX SK02_Pedidos ON dbo.Vendas
GO

CREATE NONCLUSTERED INDEX SK02_Pedidos ON dbo.Vendas ([Status], Dt_Pedido) INCLUDE(Quantidade, Valor)
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT Quantidade * Valor
FROM dbo.Vendas
WHERE Dt_Pedido > '2019-02-06'
AND Dt_Pedido < '2019-02-09'
AND [Status] = 5

SET STATISTICS IO OFF;
SET STATISTICS TIME ON;


-- Com o índice antigo, a consulta ficou ainda melhor e mais seletiva! 
-- Para Performance, tudo tem que ser testado e avaliado.. 
-- Neste caso, uma das 2 consultas ficará prejudicada pela alteração no índice, 
-- ou você pode ter os 2 índices criados (consumindo o dobro de espaço em disco) e forçar o melhor índice para cada situação.

-- *** É importante salientar que a criação de índices deve ser muito bem pensada, porque não se deveria ficar criando 
-- índice pra qualquer consulta do banco. Índices ocupam espaço e deixam operações de escritas mais lentas e complexas 
-- para o SQL Server, então devem ser criados quando necessário.



--- EXTRA:
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT Quantidade * Valor
FROM dbo.Vendas WITH (INDEX(SK02_Pedidos))
WHERE Dt_Pedido > '2019-02-06'
AND Dt_Pedido < '2019-02-09'
AND [Status] = 5

SELECT Quantidade * Valor
FROM dbo.Vendas WITH (INDEX(SK03_Pedidos))
WHERE Dt_Pedido > '2019-02-06'
AND Dt_Pedido < '2019-02-09'
AND [Status] = 5

SET STATISTICS IO OFF;
SET STATISTICS TIME ON;