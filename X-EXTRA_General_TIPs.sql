----- DICAS T-SQL -----
-- Utilize CAST ao inves de CONVERT quando possivel. 
-- Quando envolve Data/Hora para texto ou vice-versa utilizar CONVERT:
https://www.mssqltips.com/sqlservertip/3018/performance-comparison-of-the-sql-server-parse-cast-convert-and-tryparse-trycast-tryconvert-functions/

-- Opte por Tabela Temporaria ao inves de Variavel tipo tabela
https://comunidadesqlserver.wordpress.com/2014/07/21/tabelas-temporarias-x-variaveis-de-tabela/
https://tcalencar.wordpress.com/2014/08/19/problemas-de-performance-com-tabelas-variaveis/

-- CTE eh para tabelas pequenas
https://docs.microsoft.com/en-us/archive/msdn-magazine/2007/october/data-points-common-table-expressions
https://www.mssqltips.com/sqlservertip/5118/sql-server-cte-vs-temp-table-vs-table-variable-performance-test/

-- Recursividade para tabelas grandes usar CROSS APPLY (CROSS APPLY ou CROSS JOIN sao alternativa para UNPIVOT)
https://www.brentozar.com/archive/2015/06/faster-queries-using-narrow-indexes-and-cross-apply/
https://codingsight.com/advanced-sql-cross-apply-and-outer-apply/
https://sqlsunday.com/2014/03/02/unpivot-using-cross-apply/

-- Evitar Fragmentação do Arquivo de LOG
https://www.devmedia.com.br/casos-do-dia-a-dia-voce-sabia-que-um-arquivo-de-log-do-sql-server-se-fragmenta/18847
https://www.sqlskills.com/blogs/kimberly/8-steps-to-better-transaction-log-throughput/

-- Ao inves de 1000 updates, 1000 inserts, numa mesma tabela considere e teste o uso do MERGE
https://docs.microsoft.com/pt-br/sql/t-sql/statements/merge-transact-sql?view=sql-server-ver15

-- Nem todos os cursores são ruins, o tipo FAST FORWARD eh mais rapido do que CTE
https://stevestedman.com/2015/03/simple-cursor-example-forward_only-vs-fast-forward/
https://www.codemag.com/article/060113

-- Utilize UNION ALL ao inves de UNION quando possivel
http://davebland.com/union-vs-union-all

-- Filtre sempre, primeiro pela condição mais restritiva que trará menos linhas
https://www.mssqltips.com/sqlservertutorial/3201/how-join-order-can-affect-the-query-plan/

-- Seek Predicate versus Predicate
https://www.dirceuresende.com/blog/sql-server-dicas-de-performance-tuning-qual-a-diferenca-entre-seek-predicate-e-predicate/
https://www.sqlshack.com/the-impact-of-residual-predicates-in-a-sql-server-index-seek-operation/
https://sergeyolontsev.com/2016/08/sql-server-query-plans-predicates-vs-seek-predicates/

-- CLR - Common Language Runtime -- Funções não nativas e/ou complexas no WHERE são candidatas a migrar para código CLR
https://www.dirceuresende.com/blog/sql-server-comparacao-de-performance-entre-scalar-function-udf-e-clr-scalar-function/

-- Conversões Implícitas - Evitar !!!
https://www.dirceuresende.com/blog/sql-server-dicas-de-performance-tuning-conversao-implicita-nunca-mais/

-- Evitar Consultas sem definicao do Schema, como : SELECT * FROM tabela
https://books.google.com.br/books?id=y5hCAwAAQBAJ&pg=PT934&lpg=PT934&dq=sql+using+name+resolution+with+no+plans&source=bl&ots=OYNuSqapHE&sig=ACfU3U23AxFvAr4AYhtlhCQ3cYlsG9ix_A&hl=pt-BR&sa=X&ved=2ahUKEwiEnKCM-a7pAhUCA9QKHeDvDskQ6AEwA3oECAYQAQ#v=onepage&q=sql%20using%20name%20resolution%20with%20no%20plans&f=false

-- SARGability
https://imasters.com.br/banco-de-dados/voce-sabe-a-diferenca-entre-uma-consulta-sargable-e-non-sargable
https://www.fabriciolima.net/blog/2017/02/06/video-melhorando-a-performance-de-uma-consulta-com-like-string-alterando-a-collation/
https://support.microsoft.com/en-us/help/322112/comparing-sql-collations-to-windows-collations

--- SQL SERVER – How to Turn On / Enable Instant File Initialization?
https://blog.sqlauthority.com/2018/07/31/sql-server-how-to-turn-on-enable-instant-file-initialization 

----- Outras dicas de otimizacao -----
-- Se a intencao eh remover cursores, basta usar WHILE, TABELA TEMPORARIA, CROSS APPLY,... 

-- Se a consulta tem mais de 7 JOINS, considere usar Tabela Temporaria para as 6 primeiras tabelas
-- e continue a "juntar" as proximas tabelas com a tabela temporária

https://www.varonis.com/blog/sql-server-best-practices-part-configuration/
https://i.dell.com/sites/csdocuments/Shared-Content_data-Sheets_Documents/pt/br/top_10_tips_for_optimizing-final_br.pdf