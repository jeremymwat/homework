/****************************************************************************
 * dictionary.c
 *
 * Computer Science 50
 * Problem Set 6
 *
 * Implements a dictionary's functionality.
 ***************************************************************************/

#include <stdbool.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "dictionary.h"

int wordCount = 0;

node* hashTable[HASHTABLESIZE] = {NULL};


/**
 * Returns true if word is in dictionary else false.
 */
bool check(const char* word)
{
    // holding variable as cword is a const
    char lcWord[LENGTH + 1];

    // buffer to copy lower case word in to
    char* p = lcWord;
    
    // convert to lower case
    while((*p++ = tolower( *word ++)) != '\0');

    // create node pointer 
    node* checkWord = hashTable[hash(lcWord)];
    

    while (checkWord)// && strcmp(lcWord, checkWord->word) >= 0)
    {
        if (strcmp(lcWord, checkWord->word) == 0)
            return true;
        checkWord = checkWord->next;

    }

    return false;
}

/**
 * Loads dictionary into memory.  Returns true if successful else false.
 */
bool load(const char* dictionary)
{

    // open dictionary file and return false if unopenable
    FILE* dict = fopen(dictionary, "r");
    if (dict == NULL)
        return false;


    // storing hash index, fewer hash computations this way
    int hashInt;

    while (true)
    {

        // try to create new node
        node* new_node = malloc(sizeof(node));

        // malloc error checking
        if (new_node == NULL)
        {    
            return false;
            fclose(dict);
        }
        // initialize new node
        if (fscanf(dict, "%s", new_node->word) <= 0)
        {
            // break out if error or end of file is reached
            free(new_node);
            break;
        }

        // precalculating hash for use down the line
        hashInt = hash(new_node->word);

        new_node->next = hashTable[hashInt];
        hashTable[hashInt] = new_node;

        wordCount++;
    }

    fclose(dict);
  //printf("Highest number of collisions: %d\n", maxCollisionSize);
    return true;
}

/**
 * Returns number of words in dictionary if loaded else 0 if not yet loaded.
 */
unsigned int size(void)
{
    return wordCount;
}

/**
 * Unloads dictionary from memory.  Returns true if successful else false.
 */
bool unload(void)
{
    // iterate over hashtable
    for (int i = 0; i < HASHTABLESIZE ; i++)
    {        
        node* freeNode = hashTable[i]; 
        
        // if pointer in hashtable is not null, there are items to free
        while (freeNode != NULL)
        {
            // free linked list one by one
            node* predPtr = freeNode;
            freeNode = freeNode->next;
            free(predPtr);
        }

    }
    return true; //true for testing, should be false on failure
}
// djb2 hash function
unsigned int hash(const char* word)
{
    unsigned int hash = 5381;
    int c;

    while ((c = *word++))
        hash = ((hash << 5) + hash) + c;
        
    return (hash % HASHTABLESIZE); 
}
