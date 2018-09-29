Dot files
=========

Modo de uso
-----------

Inicialmente precisamos configurar a variável que indica onde esta instalado o **dot-files**, adicone a seguinte linha em seu **.bashrc** que esta em seu diretório HOME.

<pre><code>...
EXPORT DOT_FILES_HOME="[path onde foi clonado o dot-files]"
...</code></pre>

O próximo passo é dizer para o bash carregar o nosso ambiente, iremos editar o arquivo .bashrc que esta no home do seu usuário e adicone as seguintes linhas:

<pre><code>...
source ${DOT_FILES_HOME}/settings.sh
source ${DOT_FILES_HOME}/all.sh
...</code></pre>

Desta forma iremos adicionar todas as funcionalidade, ou poderiamos no local do *all.sh* poderiamos ter criado varias linhas informando quais as funções que desejavamos carregar.

Alguns comandos dependem do **sqlite3** veja como instalar este em sua distribuição.

Recentemente foi adicionado uma nova funcionalidade no pacote core, nele foi adicionado um gerenciador de alias, e com isto foi adicionado uma nova tabela na base de dados, para que a mesma seja criada é necessário rodar o comando **___dotdbinit** com a flag ignore, veja como:

<pre><code> $ DOT_IGNORE=1 dotreload</code></pre>

 Com este comando caso você já tivesse o banco de dados iniciado ele irá tentar criar as tabelas novamente caso elas não existão.
