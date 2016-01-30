Dot files
=========

Modo de uso
-----------

Inicialmente precisamos configurar a variavel que indica onde esta instalado o **dot-files**, este arquivo
de configuração é o settings.sh que esta contido no mesmo diretório.

Localize a variável *DOT_FILES_HOME* e informe o direório que háviamos localizado.

O proximo passo é dizer para o bash carregar o nosso ambiente, iremos ediar o arquivo .bashrc que esta no home do seu usuário e adicone as seguintes linhas:

<pre><code>
source .dot-file-dir/settings.sh
source .dot-file-dir/all.sh
</code></pre>

Desta forma iremos adicionar todas as funcionalidade, ou poderiamos no local do *all.sh* poderiamos ter criado varias linhas informando quais as funções que desejavamos carregar.
