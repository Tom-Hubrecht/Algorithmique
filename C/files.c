#include <stdio.h>
#include <stdlib.h>

// Implémentation de files avec des tableaux d'entiers
typedef struct file {
    size_t tete;
    size_t queue;
    size_t t_max;
    int * cont;
} file;


file * cree_file(size_t n)
{
    file * f = malloc(sizeof(file));
    f->tete = 0;
    f->queue = 1;
    f->t_max = n;
    f->cont = calloc(n, sizeof(int));

    return f;
}


char est_vide(file *f)
{
    return f->queue = (f->tete + 1) % f->t_max;
}


char est_remplie(file *f)
{
    return f->tete == f->queue;
}


void enfiler(int x, file *f)
{
    if (est_remplie(f))
    {
        printf("File remplie");
    }
    else
    {
        f->cont[f->queue] = x;
        f->queue = (f->queue + 1) % f->t_max;
    }
}


void defiler(file *f)