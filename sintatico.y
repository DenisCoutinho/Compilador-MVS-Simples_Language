%{
/*+−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
|          UNIFAL − Universidade Federal de Alfenas.
|            BACHARELADO EM CIENCIA DA COMPUTACAO.
| Trabalho..: Funcao com retorno
| Disciplina: Teoria de Linguagens e Compiladores
| Professor.: Luiz Eduardo da Silva
| Aluno.....: Denis Mendes Coutinho
| Data......: 17/02/2023
+−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−*/

#include "lexico.c"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "utils.c"

//#define DEBUG(x) x

int conta = 0;                      //contador de deslocamento de variaveis
int rotulo = 0;                     //contador de rotulos
int tipo;                           //tipo da variavel
int mecanismo = -1;                 //mecanismo de passagem apenas por valor
char cat;                           //categoria da variavel
char escopoVar = 'G';               //escopo da variavel
int npar = 0;                       //numero de parametros
int nvarl = 0;                      //numero de variaveis locais
int nvarg = 0;                      //numero de variaveis globais
int tamtab = 0;                     //tamanho da tabela de simbolos

%}

%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_IDENTIF
%token T_LEIA
%token T_ESCREVA
%token T_ENQTO
%token T_FACA
%token T_FIMENQTO
%token T_ATE
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ATRIB
%token T_VEZES
%token T_DIV
%token T_MAIS
%token T_MENOS
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E
%token T_OU
%token T_NAO
%token T_V
%token T_F
%token T_NUMERO
%token T_ABRE
%token T_FECHA
%token T_INTEIRO
%token T_LOGICO
%token T_RETORNE
%token T_FUNC
%token T_FIMFUNC

%start programa

%left T_E T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV


%%


programa
  : cabecalho                           
      { 
          fprintf (yyout,"\tINPP\n");                        //inicia programa principal
      }
    variaveis 
    rotinas
    T_INICIO lista_comandos {escopoVar = 'L';} T_FIM 
      {
          mostra_tabela();                                  //mostra a tabela de simbolos
              if(nvarg > 0)                                 //se tiver variaveis globais
                    fprintf (yyout,"\tDMEM\t%d\n", nvarg);  //desaloca variaveis globais
          fprintf (yyout,"\tFIMP\n");                       //finaliza programa principal
      }
  ;

cabecalho
    : 
    T_PROGRAMA T_IDENTIF
    ;

rotinas
    : 
      {
          fprintf (yyout,"\tDSVS\tL%d\n", rotulo);  //desvia para o inicio do programa principal
          empilha(rotulo, 'r');                     //empilha rotulo do programa principal 
      }                             
    lista_funcoes
      {                                      
          int r = desempilha();                    //desempilha rotulo do programa principal
          fprintf (yyout,"L%d\tNADA\n", r);        //rotulo do programa principal
      }
    ;


lista_funcoes
    : funcao lista_funcoes
    | funcao
    ;


funcao
    : T_FUNC tipo T_IDENTIF
        {
            rotulo++;                               //incrementa o rotulo
            npar = 0;                               //zera o numero de parametros
            cat = 'F';                              //categoria funcao
            strcpy(elem_tab.id, atomo);             //copia nome da funcao para tabela de simbolos
            elem_tab.desloca = conta;               //deslocamento da funcao
            elem_tab.tipo = tipo;                   //tipo da funcao
            elem_tab.escopo = escopoVar;            //escopo da funcao
            elem_tab.cat = cat;                     //categoria da funcao
            elem_tab.rotulo = rotulo;               //rotulo da funcao
            elem_tab.mec = mecanismo;               //mecanismo de passagem da funcao
            insere_simbolo(elem_tab);               //insere funcao na tabela de simbolos       
            conta++;                                //incrementa o contador de deslocamento
            tamtab++;                               //incrementa o tamanho da tabela de simbolos
            escopoVar = 'L';                        //escopo da funcao local                  
            fprintf (yyout,"L%d\tENSP\n",rotulo);   //rotulo da funcao e empilha
        }
                                            
      T_ABRE lista_parametros T_FECHA 
        {
            TabSimb[tamtab-1-npar].desloca = -3 - npar;                                //deslocamento do primeiro parametro
            TabSimb[tamtab-1-npar].npar = npar;                                        //numero de parametros da funcao
            lista l;                                                                   //lista de parametros
            l = inicia();                                                              //inicia lista de parametros
            int aux = npar;                                                            //auxiliar para percorrer a tabela de simbolos
            for(; aux > 0; aux--)                                                      //percorre a tabela de simbolos para inserir parametros na lista de parametros
            {
                TabSimb[tamtab-aux].desloca = -2 -aux;                                 //deslocamento dos parametros da funcao                               
                l = insere_lista(l,TabSimb[tamtab-aux].tipo,TabSimb[tamtab-aux].mec);  //insere parametros na lista de parametros
            }
            TabSimb[tamtab-1-npar].listapar = l;                                       //lista de parametros da funcao
            conta = 0;                                                                 //zera o contador de deslocamento
            mostra_tabela();                                                           //mostra a tabela de simbolos
            mecanismo = -1;                                                            //zera o mecanismo de passagem
        }

      variaveis T_INICIO lista_comandos T_FIMFUNC
        {
            tamtab = remove_tabela(nvarl,npar);             //remove a tabela de simbolos da funcao                                  
            escopoVar = 'G';                                //escopo da funcao global          
                if (nvarl > 0)                              //se tiver variaveis locais
                    fprintf (yyout,"\tDMEM\t%d\n",nvarl);   //desaloca variaveis locais
            fprintf (yyout,"\tRTSP\t%d\n",npar);            //retira parametros da pilha
        }
    ;
                                                                              
lista_parametros
    : 
    | lista_parametros parametros;

parametros
    : mecanismo tipo T_IDENTIF
        {
            strcpy(elem_tab.id, atomo);  //copia nome do parametro para tabela de simbolos
            cat = 'P';                   //categoria parametro
            elem_tab.desloca = conta;    //deslocamento do parametro
            elem_tab.tipo = tipo;        //tipo do parametro
            elem_tab.escopo = escopoVar; //escopo do parametro
            elem_tab.mec = mecanismo;    //mecanismo de passagem do parametro
            elem_tab.cat = cat;          //categoria do parametro
            elem_tab.rotulo = -1;        //rotulo do parametro
            elem_tab.listapar = NULL;    //lista de parametros do parametro
            npar++;                      //incrementa o numero de parametros
            insere_simbolo(elem_tab);    //insere o nome da funcao na tabela
            conta++;                     //incrementa o contador de deslocamento
            tamtab++;                    //incrementa o tamanho da tabela de simbolos
        }
    ;

mecanismo
    : 
    { mecanismo = VAL; }
    ;

variaveis
    :  
    | declaracao_variaveis
        {
            mostra_tabela();                              //mostra a tabela de simbolos
                if(escopoVar == 'L')                      //se o escopo for local
                    fprintf (yyout,"\tAMEM\t%d\n",nvarl); //aloca variaveis locais
                else
                    fprintf (yyout,"\tAMEM\t%d\n",nvarg); //aloca variaveis globais
        }
    ;

declaracao_variaveis
    : tipo lista_variaveis declaracao_variaveis      
    | tipo  lista_variaveis
    ;

tipo
    : T_LOGICO
      { tipo = LOG; }
     | T_INTEIRO 
      { tipo = INT; }
    ;

lista_variaveis
    : lista_variaveis T_IDENTIF
        { 
          strcpy(elem_tab.id, atomo);         //copia nome da variavel para tabela de simbolos
          cat = 'V';                          //categoria variavel
          elem_tab.desloca = conta;           //deslocamento da variavel
          elem_tab.tipo = tipo;               //tipo da variavel
          elem_tab.escopo = escopoVar;        //escopo da variavel
          elem_tab.cat = cat;                 //categoria da variavel
          elem_tab.mec = mecanismo;           //mecanismo de passagem da variavel
          elem_tab.rotulo = -1;               //rotulo da variavel
          elem_tab.listapar = NULL;           //lista de parametros da variavel
          insere_simbolo(elem_tab);           //insere o nome da funcao na tabela
          if(escopoVar =='L')                 //se o escopo for local
              nvarl++;                        //incrementa o numero de variaveis locais 
              conta++;                        //incrementa o contador de deslocamento
              tamtab++;                       //incrementa o tamanho da tabela de simbolos
          if(escopoVar == 'G' && cat == 'V')  //se o escopo for global e a categoria for variavel
              nvarg++;                        //incrementa o numero de variaveis globais
          }
    | T_IDENTIF
        { 
          strcpy(elem_tab.id, atomo);         //copia nome da variavel para tabela de simbolos
          cat = 'V';                          //categoria variavel
          elem_tab.desloca = conta;           //deslocamento da variavel
          elem_tab.tipo = tipo;               //tipo da variavel
          elem_tab.escopo = escopoVar;        //escopo da variavel
          elem_tab.cat = cat;                 //categoria da variavel
          elem_tab.mec = mecanismo;           //mecanismo de passagem da variavel
          elem_tab.rotulo = -1;               //rotulo da variavel
          elem_tab.listapar = NULL;           //lista de parametros da variavel
          insere_simbolo(elem_tab);           //insere o nome da funcao na tabela
          if(escopoVar=='L')                  //se o escopo for local
              nvarl++;                        //incrementa o numero de variaveis locais
              conta++;                        //incrementa o contador de deslocamento
          if(escopoVar == 'G' && cat == 'V')  //se o escopo for global e a categoria for variavel
              nvarg++;                        //incrementa o numero de variaveis globais
              tamtab++;                       //incrementa o tamanho da tabela de simbolos
          }
    ;

lista_comandos
    :  /*vazio*/
    | comando lista_comandos
    ;

comando
    : entrada_saida 
    | repeticao 
    | selecao 
    | atribuicao
    | retorno;

retorno
    : T_RETORNE expressao
        {
            if(TabSimb[tamtab-1].tipo != tipo)                              //se o tipo de retorno for diferente do tipo da funcao
                yyerror("Tipo de retorno incompativel!");                   //gera erro
            fprintf (yyout,"\tARZL\t%d\n",TabSimb[tamtab-1-npar].desloca);  //armazena para variavel local com deslocamento do parametro
            fprintf (yyout,"\tRTSP\t%d\n",npar);                            //retorna do sub-programa com o numero de parametros
        }
    ;

entrada_saida
    : leitura
    | escrita
    ;

leitura
    : T_LEIA T_IDENTIF
        { 
          fprintf (yyout,"\tLEIA\n");                                 //gera codigo para leitura
          int pos = busca_simboloID(atomo);                           //busca o nome da variavel na tabela de simbolos
          if(pos == -1)                                               //se nao encontrar
              yyerror("Variavel nao declarada!");                     //gera erro
          if(TabSimb[pos].cat == 'P' && TabSimb[pos].mec == VAL)      //se a categoria for parametro e o mecanismo de passagem for por valor
              fprintf (yyout,"\tARZL\t%d\n", TabSimb[pos].desloca);   //ARZL para parametro por referencia
          else
              fprintf (yyout,"\tARZG\t%d\n", TabSimb[pos].desloca);   //ARZG para variavel global
        }
    ;

escrita
    : T_ESCREVA expressao
        { 
          fprintf (yyout,"\tESCR\n");   //gera codigo para escrita
          desempilha();                 //desempilha o tipo da expressao
        }
    ;

repeticao
    : T_ENQTO
        { 
          rotulo++;                              //incrementa o rotulo
          fprintf (yyout,"L%d\tNADA\n", rotulo); //gera rotulo para o enqto
          empilha(rotulo,'r');                   //empilha o rotulo e o tipo
        }
    expressao T_FACA 
        {
          int t1 = desempilha();                     //desempilha o tipo da expressao
          if(t1 != LOG)                              //se o tipo for diferente de logico
              yyerror("Incompatibilidade de tipos"); //gera erro
          rotulo++;                                  //incrementa o rotulo
          fprintf (yyout,"\tDSVF\tL%d\n", rotulo);   //gera codigo para desvio se falso
          empilha(rotulo,'r');                       //empilha o rotulo e o tipo
        }
    lista_comandos T_FIMENQTO
        { 
          int r1 = desempilha();                    //desempilha o rotulo
          int r2 = desempilha();                    //desempilha o rotulo
          fprintf (yyout,"\tDSVS\tL%d\n", r2);      //gera codigo para desvio se verdadeiro
          fprintf (yyout,"L%d\tNADA\n", r1);        //gera rotulo para o fim do enqto
        } 
    ;

selecao
    : T_SE expressao T_ENTAO          
        { 
            //DEBUG(mostrapilha("selecao:T_ENTAO");)   //mostra pilha de tipos para debug
            int t1 = desempilha();                     //desempilha o tipo da expressao
            if(t1 != LOG)                              //se o tipo for diferente de logico
                yyerror("Incompatibilidade de tipos"); //gera erro
            rotulo++;                                  //incrementa o rotulo
            fprintf (yyout,"\tDSVF\tL%d\n", rotulo);   //gera codigo para desvio se falso
            empilha(rotulo,'r');                       //empilha o rotulo e o tipo
        }                      

    lista_comandos T_SENAO
        { 
            int r = desempilha();                     //desempilha o rotulo
            rotulo++;                                 //incrementa o rotulo
            fprintf (yyout,"\tDSVS\tL%d\n", rotulo);  //gera codigo para desvio se verdadeiro
            fprintf (yyout,"L%d\tNADA\n", r);         //gera rotulo para o senao
            empilha(rotulo,'r');                      //empilha o rotulo e o tipo
        }

    lista_comandos T_FIMSE
        { 
            int r=desempilha();                       //desempilha o rotulo
            fprintf (yyout,"L%d\tNADA\n", r);         //gera rotulo para o fim do se
        }
    ;

atribuicao
    : T_IDENTIF
        { 
            int pos = busca_simboloID(atomo);        //busca o nome da variavel na tabela de simbolos
            if(pos == -1)                            //se nao encontrar
                yyerror("Variavel nao declarada!");  //gera erro
            empilha(TabSimb[pos].desloca,'e');       //empilha o deslocamento e o tipo
            empilha(TabSimb[pos].tipo,'t');          //empilha o tipo
            empilha(TabSimb[pos].rotulo,'r');        //empilha o rotulo e o tipo
        }


      T_ATRIB expressao
        { 
            int texp = desempilha();                                                                //desempilha o tipo da expressao
            int rt = desempilha();                                                                  //desempilha o rotulo
            int tvar = desempilha();                                                                //desempilha o tipo da variavel
            int end = desempilha();                                                                 //desempilha o deslocamento
            if(texp != tvar)                                                                        //se o tipo da expressao for diferente do tipo da variavel
                yyerror("Incompatibilidade de tipos atrib: T_ATRIB");                               //gera erro
            int pos = busca_simboloDesRt(end,rt);                                                   //busca o deslocamento e o rotulo na tabela de simbolos
            if(TabSimb[pos].mec == VAL || TabSimb[pos].escopo == 'L' || TabSimb[pos].cat == 'F')    //se o mecanismo de passagem for por valor ou variavel local ou nome de funcao
                fprintf (yyout,"\tARZL\t%d\n", end);                                                //ARZL para parametro por valor ou variavel local ou nome de funcao
            else
                fprintf (yyout,"\tARZG\t%d\n", end);                                                //ARZG para variavel global
        }
    ;   

expressao
    : expressao T_VEZES expressao
        { 
            int t1 = desempilha();                      //desempilha o tipo 1 da expressao
            int t2 = desempilha();                      //desempilha o tipo 2 da expressao
            if( t1 != INT || t2 != INT)                 //se o tipo for diferente de inteiro
                yyerror("Incompatibilidade de tipos!"); //gera erro
            fprintf (yyout,"\tMULT\n");                 //gera codigo para multiplicacao
            empilha(INT,'t');                           //empilha o tipo inteiro
        }

    | expressao T_DIV expressao
        {
            int t1 = desempilha();                      //desempilha o tipo 1 da expressao
            int t2 = desempilha();                      //desempilha o tipo 2 da expressao
            if( t1 != INT || t2 != INT)                 //se o tipo for diferente de inteiro
                yyerror("Incompatibilidade de tipos!"); //gera erro
            fprintf (yyout,"\tDIVI\n");                 //gera codigo para divisao
            empilha(INT,'t');                           //empilha o tipo inteiro
        }

    | expressao T_MAIS expressao
        { 
            int t1 = desempilha();                      //desempilha o tipo 1 da expressao
            int t2 = desempilha();                      //desempilha o tipo 2 da expressao
            if( t1 != INT || t2 != INT)                 //se o tipo for diferente de inteiro
                yyerror("Incompatibilidade de tipos!"); //gera erro
            fprintf (yyout,"\tSOMA\n");                 //gera codigo para soma
            empilha(INT,'t'); }                         //empilha o tipo inteiro

    | expressao T_MENOS expressao
        {
            int t1 = desempilha();                      //desempilha o tipo 1 da expressao
            int t2 = desempilha();                      //desempilha o tipo 2 da expressao
            if( t1 != INT || t2 != INT)                 //se o tipo for diferente de inteiro
                yyerror("Incompatibilidade de tipos!"); //gera erro
            fprintf (yyout,"\tSUBT\n");                 //gera codigo para subtracao
            empilha(INT,'t');                           //empilha o tipo inteiro
        }

      | expressao T_MAIOR expressao
        { 
            int t1 = desempilha();                      //desempilha o tipo 1 da expressao
            int t2 = desempilha();                      //desempilha o tipo 2 da expressao
            if( t1 != INT || t2 != INT)                 //se o tipo for diferente de inteiro
                yyerror("Incompatibilidade de tipos!"); //gera erro
            fprintf (yyout,"\tCMMA\n");                 //gera codigo para comparacao maior
            empilha(LOG,'t');                           //empilha o tipo logico
        }   

      | expressao T_MENOR expressao
        {
            int t1 = desempilha();                      //desempilha o tipo 1 da expressao
            int t2 = desempilha();                      //desempilha o tipo 2 da expressao
            if( t1 != INT || t2 != INT)                 //se o tipo for diferente de inteiro
                yyerror("Incompatibilidade de tipos!"); //gera erro
            fprintf (yyout,"\tCMME\n");                 //gera codigo para comparacao menor
            empilha(LOG,'t');                           //empilha o tipo logico
        }

      | expressao T_IGUAL expressao 
        {
            int t1 = desempilha();                      //desempilha o tipo 1 da expressao
            int t2 = desempilha();                      //desempilha o tipo 2 da expressao
            if( t1 != INT || t2 != INT)                 //se o tipo for diferente de inteiro
                yyerror("Incompatibilidade de tipos!"); //gera erro
            fprintf (yyout,"\tCMIG\n");                 //gera codigo para comparacao igual
            empilha(LOG,'t');                           //empilha o tipo logico
        }        
      | expressao T_E expressao
        {
            int t1 = desempilha();                      //desempilha o tipo 1 da expressao
            int t2 = desempilha();                      //desempilha o tipo 2 da expressao
            if( t1 != LOG || t2 != LOG)                 //se o tipo for diferente de logico
                yyerror("Incompatibilidade de tipos!"); //gera erro
            fprintf (yyout,"\tCONJ\n");                 //gera codigo para conjuncao
            empilha(LOG,'t');                           //empilha o tipo logico
        }

      | expressao T_OU expressao 
        {
            int t1 = desempilha();                      //desempilha o tipo 1 da expressao
            int t2 = desempilha();                      //desempilha o tipo 2 da expressao
            if( t1 != LOG || t2 != LOG)                 //se o tipo for diferente de logico
                yyerror("Incompatibilidade de tipos!"); //gera erro
            fprintf (yyout,"\tDISJ\n");                 //gera codigo para disjuncao
            empilha(LOG,'t');                           //empilha o tipo logico
        }
      |  termo
      ;
      
argumentos
    : 
    | {} 
    lista_argumentos
      {} 
    ;

lista_argumentos
    : lista_argumentos argumento
    | argumento
    ;

argumento
    : expressao
    ; 

termo
    : T_IDENTIF
        { 
            int pos = busca_simbolo(atomo, escopoVar);                     //busca o simbolo na tabela de simbolos
            if(pos == -1)
                yyerror("Variavel nao declarada!");                        //se nao encontrar o simbolo, gera erro
            if(TabSimb[pos].escopo == 'L' && TabSimb[pos].mec == VAL)      // se a vaiavel for local e passada por valor
            {
               fprintf (yyout,"\tCRVL\t%d \n", TabSimb[pos].desloca);      //gera codigo para carregar o valor da variavel local
               empilha(TabSimb[pos].tipo,'t');                             //empilha o tipo da variavel local
            }
            else
            {
                fprintf (yyout,"\tCRVG\t%d \n", TabSimb[pos].desloca); //gera codigo para carregar o valor da variavel global
                empilha(TabSimb[pos].tipo,'t');                        //empilha o tipo da variavel global
            }
        }

      | T_NUMERO
          {
              fprintf (yyout,"\tCRCT\t%s\n", atomo);      //gera codigo para carregar o valor do numero
              empilha(INT,'t');                           //empilha o tipo inteiro
          } 
      | T_V
          { 
              int t1 = desempilha();                      //desempilha o tipo 1 da expressao
              if(t1 != LOG)                               //se o tipo for diferente de logico
                  yyerror("Incompatibilidade de tipos!"); //gera erro
              fprintf (yyout,"\tCRCT\t1\n");              //gera codigo para carregar o valor 1
              empilha(LOG,'t');                           //empilha o tipo logico
          }
      | T_F
          { 
              int t1 = desempilha();                      //desempilha o tipo 1 da expressao
              if(t1 != LOG)                               //se o tipo for diferente de logico
                  yyerror("Incompatibilidade de tipos!"); //gera erro
              fprintf (yyout,"\tCRCT\t0\n");              //gera codigo para carregar o valor 0
              empilha(LOG,'t');                           //empilha o tipo logico
          }

      | T_NAO termo
          { 
              int t1 = desempilha();                       //desempilha o tipo 1 da expressao
              if(t1 != LOG)                                //se o tipo for diferente de logico
                  yyerror("Incompatibilidade de tipos!");  //gera erro
              fprintf (yyout,"\tNEGA\n");                  //gera codigo para negacao
              empilha(LOG,'t');                            //empilha o tipo logico
          } 
      ;    

      | T_ABRE expressao T_FECHA
      | T_IDENTIF T_ABRE
          { 
              int pos = busca_simboloID(atomo);       //busca o simbolo na tabela de simbolos
              if(pos == -1)                        
                  yyerror("Variavel nao declarada!"); //se nao encontrar o simbolo, gera erro
              empilha(TabSimb[pos].rotulo, 'r');      //empilha o rotulo da funcao
              fprintf (yyout,"\tAMEM\t%d\n",1);       //gera codigo para alocar espaco para o retorno
          }

argumentos T_FECHA          
    {
        fprintf (yyout,"\tSVCP\n");             //gera codigo para salvar o contexto de execucao
        int t = desempilha();                   //desempilha o rotulo da funcao
        fprintf (yyout,"\tDSVS\tL%d\n",t);      //gera codigo para desvio incondicional para a funcao
    }
  ;

%%

int main (int argc, char *argv[]) {
    char *p, nameIn[100], nameOut[100];
    argv++;
    if (argc < 2) {
        puts("\nCompilador Simples");
        puts("\n\tUso: ./simples <NOME>[.simples]\n\n");
        exit(10);
    }
    p = strstr(argv[0], ".simples");
    if (p) *p = 0;
    strcpy(nameIn, argv[0]);
    strcat(nameIn, ".simples");
    strcpy(nameOut, argv[0]);
    strcat(nameOut, ".mvs");
    yyin = fopen (nameIn, "rt");
    if (!yyin) {
        puts("Programa fonte não encontrado!");
        exit(20);
    }
    yyout = fopen(nameOut, "wt");
    yyparse();
    puts("Programa ok!");
}