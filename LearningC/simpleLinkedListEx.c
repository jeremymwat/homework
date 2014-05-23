// This is a simple implementation of a linked list with one data value 

#include <stdio.h>

//this is the basic struct for the node in the linked list
struct entry
{
	int	value;
	struct entry *next;
};

//this is the struct for the head of the list
struct head
{
    struct entry *next;
};


//this inserts a node in the list. It is not very smart, you need
//to give it a pointer to the node and not just a location in the list
//Everything is static.
void insertLL (struct entry *toInsert, struct entry *insertAfter)
{
    toInsert->next = insertAfter->next;
    insertAfter->next = toInsert;
}

//This removes a node by setting the next pointer in the node before the node
//to be removed to the next pointer of the succeeding node (thus skipping
//over the node to be removed and effectively eliminating it from the list

void removeLL (struct entry *removeAfter)
{
	removeAfter->next = (removeAfter->next)->next;
}

int main (void)
{
//initialize all variables
	struct entry n1, n2, n3, insertMe;
	struct entry *list_pointer = &n1;
    struct head startList;
//set up nodes
    startList.next = &n1;

	n1.value = 100;
	n1.next = &n2;
	
	n2.value = 200;
	n2.next = &n3;

	n3.value = 300;
	n3.next = (struct entry *) 0; //mark end of list with a null pointer.

    insertMe.value = 250;
    insertMe.next = 0;

//this uses the insert function. just a test
    insertLL (&insertMe,&n2 );

//Iterates through nodes and prints their value
	while (list_pointer != (struct entry *) 0 ) {
		printf ("%i\n", list_pointer->value);
		list_pointer = list_pointer->next;
	}
    list_pointer = &n1;

	removeLL (&n2);
	while (list_pointer != (struct entry *) 0 ) {
		printf ("%i\n", list_pointer->value);
		list_pointer = list_pointer->next;
	}

	return 0;
}
 
