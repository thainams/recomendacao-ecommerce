# recomendacao-ecommerce
A seguir irei compartilhar uma análise de recomendação de produtos onde analisei as compras dentro do site de forma a fornecer insights que podem ser úteis para o time de Marketing conduzir estratégias mais interessantes do ponto de vista de rentabilidade e experiência do usuário.

## Ferramentas utilizadas
[DBeaver](https://dbeaver.io/download/) - Ferramenta de base de dados utilizada para fazer as queries no SQLite.

[Knime Analytics](https://www.knime.com/) - Plataforma em que é possível criar soluções de ciência e análise de dados, dentre elas, a que utilizei no projeto: Regra de Associação Apriori.

[Excel](https://www.microsoft.com/pt-br/microsoft-365/excel) - Software mundialmente conhecido para criação de planilhas eletrônicas, gráficos e que também possui o Power Query para realização de tratamento de dados. Nele eu criei gráficos e utilizei o Power Query.

[Power BI](https://www.microsoft.com/pt-br/power-platform/products/power-bi) - Serviço de visualização de dados desenvolvido pela Microsoft, para este projeto, utilizei para criar um dashboard de Recomendação de Produtos.


## Entendimento do Negócio
O Pão de Mel é um mercado online muito popular. Uma empresa como essa sempre precisa compreender o padrão de consumo de seus clientes para fazer ofertas direcionadas, programas de pontos e várias outras iniciativas para que os clientes tenham maior recorrência de compra.

Desta forma, o time de Análise de Dados foi escalado para analisar as compras do último ano de mais de 200 mil usuários dentro do site de forma a fornecer insights que podem ser úteis para o time de Marketing conduzir estratégias mais interessantes do ponto de vista de rentabilidade e experiência do usuário.

## Entendimento dos Dados
Primeiramente fiz uma limpeza dos dados utilizando o Power Query, após isso criei o dicionário dos dados que serão analisados:

![image](https://github.com/thainams/recomendacao-ecommerce/assets/97771347/526fc240-f209-426d-90ca-10ef166d4621)

### Distribuição das Vendas
![image](https://github.com/thainams/recomendacao-ecommerce/assets/97771347/c2623760-0d02-4ad1-b56e-3fec5429217e)

Os departamentos "beverages, snacks e frozen" possuem a maior parte da distribuição de vendas. Eles correspondem a respectivamente: 16,40%, 15,90% e 11,90% das vendas.

![image](https://github.com/thainams/recomendacao-ecommerce/assets/97771347/66d550f2-d352-475c-bb26-bd4fe1e4aff1)

O dia que possui menos vendas é nas quintas-feiras. E o dia que mais vende é no domingo, que corresponde a 18,51% da distribuição de vendas semanais.

![image](https://github.com/thainams/recomendacao-ecommerce/assets/97771347/a1fd3887-964c-4dc3-86a9-0d62c632a9ff)

47% das vendas ocorrem entre 12:00 e 17:00.

### Ranking do Top 5 Produtos Mais Vendidos por Departamento

![image](https://github.com/thainams/recomendacao-ecommerce/assets/97771347/cc3d7d9a-7083-4247-8f8e-78242630091f)

Os 5 produtos mais vendidos do departamento "beverages".

O restante dos cinco produtos mais comprados de cada departamento está neste [arquivo](https://drive.google.com/file/d/1jwn5K2oJkcLmxRsfUfO_ZpjDAB-bgQcZ/view).

### Concentração de compras por departamento e período do dia
Os departamentos de "beverages, snacks e frozen" são os mais vendidos em qualquer período do dia, a frequência absoluta e relativa pode ser consultada no arquivo abaixo.

![image](https://github.com/thainams/recomendacao-ecommerce/assets/97771347/90212898-9f43-4d6f-9fcf-637e79c65d7a)

![image](https://github.com/thainams/recomendacao-ecommerce/assets/97771347/1d8eb1b3-6eb8-4604-87e8-71800000b5f0)

Aqui tem um exemplo do período da manhã, 211.703 produtos do departamento "beverages" corresponde a 7,27% das vendas no período de 00:00 a 12:00.

O arquivo com todos os departamentos e todos os períodos do dia está [aqui](https://docs.google.com/spreadsheets/d/12Y6wrikDWXmrxHoB70yUl5SkYytPPGyv/edit#gid=782698183).

## Preparação dos Dados
Para realizar a recomendação de produtos, no SQLite criei uma tabela temporária e utilizei o JOIN para criar uma base de dados dos produtos comprados. Posteriormente o resultado da query abaixo foi exportado para o formato de CSV.

```SQL
CREATE TEMPORARY TABLE base_v2 AS 
 SELECT
  bp.product_id AS id_produto,
  bp.product_name AS produto,
  bc.user_id AS id_cliente
 FROM 
  base_produtos bp
 JOIN base_compras bc 
  ON bp.product_id = bc.product_id
```

## Análise
No Knime, utilizei o workflow abaixo. Primeiro importei nele a base que tinha extraído do SQLite. Depois agrupei os itens comprados em uma lista por cliente.

"O KNIME Analytics é uma plataforma amigável para análise de dados, permitindo que você manipule, visualize e explore seus dados através de uma interface gráfica intuitiva. Através de "nodes" que se conectam como peças de um quebra-cabeça, você realiza desde tarefas básicas até análises complexas e modelos de aprendizado de máquina, sem precisar escrever código. Seja iniciante ou especialista, o KNIME te ajuda a extrair insights valiosos dos seus dados, tornando-o uma ferramenta poderosa para diversos setores e áreas de aplicação." Texto gerado pelo Gemini, um grande modelo de linguagem do Google AI, em [02 de junho de 2024].

![image](https://github.com/thainams/recomendacao-ecommerce/assets/97771347/0722f605-a3a9-4cd8-9ade-ae6f3eb9c6de)

Workflow de recomendação de produtos.

![image](https://github.com/thainams/recomendacao-ecommerce/assets/97771347/4c1a2516-b7a4-4a54-896f-c983964d97d3)

Resultado do node "GroupBy".

Depois apliquei a técnica Regra de Associação Apriori, também conhecida como Análise de Cesta de Compras/Recommender Systems. 

É uma técnica que faz a combinação de duas variáveis qualitativas, no caso desse projeto, a combinação de dois produtos (de uma cesta de compras) e calcula a probabilidade de compra atrelada. A porcentagem de "Suporte" significa quantas vezes os 2 produtos aparecem juntos entre as preferências dos clientes. E a porcentagem de "Confiança" significa a chance de o cliente comprar determinado produto, sempre que comprar outro. Assim, temos uma recomendação de produtos de acordo com compras anteriores e descobrimos as tendências mais lucrativas.

Depois foi feito o tratamento final dos dados e o resultado do workflow foi salvo no [Excel](https://docs.google.com/spreadsheets/d/1boZkF4Rlvn1ATEar-FhoRFxAr3TBxeUK/edit#gid=1236487913).

![image](https://github.com/thainams/recomendacao-ecommerce/assets/97771347/af811958-6be1-4784-8f5d-decf238970c3)

Resultado da Análise de Recomendação de Produtos.

É possível buscar insights sobre quais os itens mais recomendados de acordo com a escolha de um produto?

COLOCAR DASHBOARD AQUI

• Dos clientes que compram "soda", 6,47% também compram "blueberries", 5,11% compram "cereal" e 10,40% compram "crunchy oats 'n honey granola bars".
Clientes que possuem um café da manhã equilibrado?

• Dos clientes que compram "pineapple chunks", 11,30% compram "blueberries", 10,80% também compram "boneless skinless chicken breasts", e 6,02% compram "creamy almond butter" e 6,61% compram "berry medley".
Talvez seja um cliente que irá preparar um almoço de peito de frango com abacaxi? E a sobremesa terá mirtilos, manteiga de amêndoa cremosa e frutas vermelhas?

## Implantação

Seguem minhas recomendações:

### 👀O quê?
Utilização do dashboard criado, que demonstra a probabilidade de compra de acordo com a escolha de um produto.

### 🤔Por quê?
Por exemplo, dos clientes que compram o produto "honey nut cherrios", 10,90% compram "blueberries" e 11,10% também compram "100% whole wheat bread". Ou seja, são clientes que estão comprando produtos para o café da manhã? AUMENTO DA PROBABILIDADE (SOMA?)

### 🤨Quem?
Time de Marketing, Time de Experiência do Usuário, Time de Desenvolvedores de Front-End e Back-End.

### ✍🏾Como?
Formação de um grupo de teste e controle. O grupo de teste seria composto por um grupo seleto de clientes que mais compram no site. Esses clientes teriam acesso ao novo site com a recomendação de produtos, que aumentaria a rentabilidade da empresa. O grupo de controle seria formado também por clientes mais frequentes, mas não teriam acesso ao site com a recomendação de produtos, nada iria mudar para eles. O comportamento deles seria um valor final menor de compras comparados aos clientes do grupo de teste.

### 💰Qual o custo?
Contratação temporária de desenvolvedores front-end e back-end. Aumento da carga horária dos times de Marketing e Experiência do Usuário. Criação de escalas para otimizar a produtividade nesse período devido ao aumento de carga horária de trabalho.

## Considerações Finais
No artigo acima fiz uma análise exploratória das vendas da Pão de Mel, verifiquei a distribuição das vendas por departamento, dia da semana, hora do dia e fiz o ranking dos produtos mais vendidos em todos os departamentos. Oferecendo insights importantes para tomada de decisão tanto da parte estratégica quanto do time de Marketing, demonstrei como funciona a Análise de Recomendação de Produtos.
Espero que tenha gostado do meu projeto, qualquer feedback é bem-vindo, estou à disposição por [aqui](https://www.linkedin.com/in/thainaoliveirams/)!
