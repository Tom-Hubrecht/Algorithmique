#include <stdio.h>
#include <stdlib.h>

// Implémentation de piles avec des tableaux d'entiers
typedef struct pile {
    size_t pos;
    size_t t_max;
    int * cont;
} pile;


pile * cree_pile(size_t n)
{
    pile * p = malloc(sizeof(pile));
    p->pos = 0;
    p->t_max = n;
    p->cont = calloc(n, sizeof(int));

    return p;
}


char est_vide(pile *p)
{
    return p->pos == 0;
}


char est_remplie(pile *p)
{
    return p->pos == p->t_max;
}

void empiler(int x, pile *p)
{
    if (est_remplie(p))
    {
        printf("Pile remplie");
    }
    else
    {
        p->pos ++;
        p->cont[p->pos] = x;
    }
}


int depiler(pile *p)
{
    if (est_vide(p))
    {
        printf("Pile vide");
    }
    else
    {
        p->pos --;
        return p->cont[p->pos + 1];
    }
}


void detruit_pile(pile *p)
{
    free(p->cont);
    free(p);
}