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

#include "sintatico.h"
char atomo[100];
int cont = 1;
void yyerror (char *s);
%}

identificador  [a-zA-Z]([a-zA-Z0-9])*
numero         [0-9]+
espaco         [ \t\r]+
novalinha      [\n]

%x coment

%%

programa    return T_PROGRAMA;
inicio      return T_INICIO;
fimprograma return T_FIM;
leia        return T_LEIA;
escreva     return T_ESCREVA;
se          return T_SE;
entao       return T_ENTAO;
senao       return T_SENAO;
fimse       return T_FIMSE;
enquanto    return T_ENQTO;
faca        return T_FACA;
fimenquanto return T_FIMENQTO;
inteiro     return T_INTEIRO;
logico      return T_LOGICO;

func        return T_FUNC;
fimfunc     return T_FIMFUNC;
retorne     return T_RETORNE;

"+"         return T_MAIS;
"-"         return T_MENOS;
"*"         return T_VEZES;
div         return T_DIV;
">"         return T_MAIOR;
"<"         return T_MENOR;
"="         return T_IGUAL;
e           return T_E;
ou          return T_OU;
nao         return T_NAO;
"<-"        return T_ATRIB;

"("         return T_ABRE;
")"         return T_FECHA;

V           return T_V;
F           return T_F;

"//".*           ;
"/*"             BEGIN(coment);
<coment>"*/"     BEGIN(INITIAL);
<coment>.        ;
<coment>\n       cont++;

{identificador} { strcpy (atomo, yytext); return T_IDENTIF; };
{numero}        { strcpy (atomo, yytext); return T_NUMERO; };
{espaco}        ;
{novalinha}     cont++;
.                yyerror("Erro lexico");

%%

void yyerror (char *s) {
   printf ("ERRO na linha %d: %s\n", cont, s);
   exit (10);
}

int yywrap(void) {
   return 1; 
}