/*+−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
|          UNIFAL − Universidade Federal de Alfenas.
|            BACHARELADO EM CIENCIA DA COMPUTACAO.
| Trabalho..: Funcao com retorno
| Disciplina: Teoria de Linguagens e Compiladores
| Professor.: Luiz Eduardo da Silva
| Aluno.....: Denis Mendes Coutinho
| Data......: 17/02/2023
+−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−*/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#define TAM_TAB 100
#define TAM_PIL 100

enum
{
    INT = 1,  // INT
    LOG,      // LOG
    VAL = 10, // VAL
};

typedef struct no *lista; // lista de parametros
struct no                 // lista de parametros
{
    int tipo;   // INT ou LOG
    int mec;    // VAL
    lista prox; // proximo elemento da lista
};

struct
{
    int valor;    // valor da pilha
    char tipo;    // tipo da pilha
} Pilha[TAM_PIL]; // pilha de tipos

struct elem_tab_simbolos // elemento da tabela de simbolos
{
    char id[30];              // posicao na tabela
    int desloca;              // endereco
    int tipo;                 // INT ou LOG
    int mec;                  // apenar por valor
    int rotulo;               // rotulo
    char escopo;              // G ou L
    char cat;                 // Parametro Variavel ou Funcao
    int npar;                 // quantidade de parametros
    lista listapar;           // lista dos parametros
} TabSimb[TAM_TAB], elem_tab; // tabela de simbolos

int pos_tab = 0; // posicao da tabela de simbolos

void maiuscula(char *s) // transforma a string em maiuscula
{
    int i;                    // contador
    for (i = 0; s[i]; i++)    // enquanto nao for o fim da string
        s[i] = toupper(s[i]); // transforma o caracter em maiusculo
}

int busca_simbolo(char *id, char escopo) // retorna a posicao de id na tabela ou -1 se nao encontrar
{
    int i = pos_tab - 1; // posicao da tabela
    for (; i >= 0; i--)  // enquanto nao encontrar o id e a posicao for maior que 0
    {
        if (strcmp(TabSimb[i].id, id) == 0 && TabSimb[i].escopo == escopo) // se o id e o escopo forem iguais
            return i;                                                      // retorna a posicao do id
    }
    return -1; // retorna a posicao do id
}

int busca_simboloID(char *id) // retorna a posicao de id na tabela ou -1 se nao encontrar
{
    int i = pos_tab - 1;                             // posicao da tabela
    for (; strcmp(TabSimb[i].id, id) && i >= 0; i--) // enquanto nao encontrar o id e a posicao for maior que 0
        ;
    return i; // retorna a posicao do id
}

int busca_simboloDesRt(int desloca, int rotulo) // busca o simbolo pelo deslocamento e rotulo
{
    int i = pos_tab - 1; // posicao da tabela
    for (; i >= 0; i--)  // enquanto nao encontrar o id e a posicao for maior que 0
    {
        if (TabSimb[i].desloca == desloca && TabSimb[i].rotulo == rotulo) // enquanto nao encontrar o id e a posicao for maior que 0
            return i;                                                     // retorna a posicao do id
    }
    return -1; // retorna a posicao do id
}

void insere_simbolo(struct elem_tab_simbolos elem) // insere um elemento na tabela de simbolos
{
    int i = 0;                               // posicao da tabela
    if (pos_tab == TAM_TAB)                  // se a tabela estiver cheia
        yyerror("Tabela de simbolos cheia"); // erro
    i = busca_simbolo(elem.id, elem.escopo); // busca o simbolo na tabela
    if (i != -1)
        yyerror("Identificador duplicado"); // se encontrar o simbolo na tabela
    TabSimb[pos_tab] = elem;                // insere o elemento na tabela
    pos_tab++;                              // incrementa a posicao da tabela
}

void mostra_lista(lista L) // mostra a lista
{
    printf("[ "); // abre a lista
    while (L)     // enquanto nao for o ultimo elemento
    {
        char tipo[4] = "";                                        // tipo do parametro
        L->tipo == 1 ? strcpy(tipo, "INT") : strcpy(tipo, "LOG"); // se o tipo for 1, entao eh INT, se nao eh LOG
        char mec[4] = "";                                         // mecanismo de passagem
        L->mec == 10 ? strcpy(mec, "VAL") : strcpy(mec, "REF");   // se o mecanismo for 10, entao eh VAL
        printf("{%s | %s}", tipo, mec);                           // mostra o tipo e o mecanismo
        L = L->prox;                                              // proximo elemento da lista
        if (L)                                                    // se nao for o ultimo elemento
        {
            printf(" -> "); // mostra a seta
        }
    }
    printf(" ]"); // fecha a lista
}

void mostra_tabela() // mostra a tabela de simbolos
{
    int i;                                              // contador
    lista aux;                                          // auxiliar para percorrer a lista
    for (i = 0; i < 51; i++)                            // mostra a linha de cima
        printf("- ");                                   // mostra o traço
    printf("\n");                                       // quebra de linha
    printf("|%40s Tabela de Simbolos %33s|\n", "", ""); // mostra o titulo da tabela
    for (i = 0; i < 51; i++)                            // mostra a linha de baixo
        printf("- ");                                   // mostra o traço
    printf("\n| %3s | %15s | %s | %s | %s | %s | %s | %s | %3s |\n", "#", "ID", "ESC", "DSL", "ROT", "CAT", "TIP", "NPAR", "LPAR");
    for (i = 0; i < 51; i++)
        printf("- ");             // mostra a linha de baixo
    for (i = 0; i < pos_tab; i++) // percorre a tabela
    {
        printf("\n| %3d | %15s | %3c | %3d | %3d | %3c | %3s | %4d | ", i, TabSimb[i].id, TabSimb[i].escopo, TabSimb[i].desloca, TabSimb[i].rotulo, TabSimb[i].cat, TabSimb[i].tipo == INT ? "INT" : "LOG", TabSimb[i].npar);
        if (TabSimb[i].listapar != NULL) // se a lista de parametros nao for vazia
        {
            mostra_lista(TabSimb[i].listapar); // mostra a lista
        }
        else
        {
            printf("%30s |", ""); // mostra espacos em branco
        }
    }
    printf("\n");            // quebra de linha
    for (i = 0; i < 51; i++) // mostra a linha de baixo
        printf("- ");        // mostra o traço
    printf("\n\n");          // quebra de linha
}

int remove_tabela(int nvarl, int npar) // remove os elementos da tabela de simbolos
{
    pos_tab = pos_tab - npar - nvarl; // decrementa a posicao da tabela
    return pos_tab;                   // retorna a posicao da tabela
}

lista inicia() // inicia a lista
{
    return NULL; // retorna NULL
}

lista insere_lista(lista lno, int tipo, int mec) // insere um elemento na lista
{
    lista aux, ant, p;                    // auxiliar para percorrer a lista
    p = (lista)malloc(sizeof(struct no)); // aloca memoria para o novo elemento
    if (!p)                               // se nao conseguir alocar memoria
        printf("\n Lista Cheia");         // mostra a mensagem
    else
    {
        ant = NULL;         // inicializa o anterior
        aux = lno;          // inicializa o auxiliar
        while (aux != NULL) // enquanto o auxiliar nao for NULL
        {
            ant = aux;       // o anterior recebe o auxiliar
            aux = aux->prox; // o auxiliar recebe o proximo elemento da lista
        }
        p->tipo = tipo;  // insere o tipo
        p->mec = mec;    // insere o mecanismo de passagem
        if (ant == NULL) // se o anterior for NULL
        {
            p->prox = lno; // o proximo elemento da lista recebe o primeiro elemento da lista
            lno = p;       // o primeiro elemento da lista recebe o novo elemento
        }
        else
        {
            p->prox = ant->prox; // o proximo elemento da lista recebe o proximo elemento do anterior
            ant->prox = p;       // o proximo elemento do anterior recebe o novo elemento
        }
    }
    return lno; // retorna a lista
}

int topo = -1; // topo da pilha semantica

void empilha(int valor, char tipo) // empilha um elemento na pilha
{
    if (topo == TAM_PIL)                  // se a pilha estiver cheia
        yyerror("Pilha semântica cheia"); // erro
    Pilha[++topo].valor = valor;          // insere o valor na pilha
    Pilha[topo].tipo = tipo;              // insere o tipo na pilha
}

int desempilha() // desempilha um elemento da pilha
{
    if (topo == -1)             // se a pilha estiver vazia
        yyerror("Pilha vazia"); // erro
    return Pilha[topo--].valor; // retorna o valor do topo da pilha
}

void mostrapilha() // mostra a pilha
{
    int i = topo;        // inicializa o contador
    printf("Pilha = ["); // mostra o titulo da pilha
    while (i >= 0)       // enquanto o contador for maior ou igual a zero
    {
        printf("%d,%c ", Pilha[i].valor, Pilha[i].tipo); // mostra o valor e o tipo
        i--;                                             // decrementa o contador
    }
    printf("]\n"); // quebra de linha
}