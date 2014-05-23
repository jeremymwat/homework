// This is a simple implementation of a double linked list

#include <stdio.h>

struct entry
{
	struct entry *prev;
	int value;
	struct entry *next;
};

struct head
{
	struct entry *next;
};

void insertNode (struct entry *toInsert, struct entry *insertAfter)
{
	toInsert->next = insertAfter->next;
	toInsert->prev = insertAfter;
	(insertAfter->next)->prev = toInsert;
	insertAfter->next = toInsert;

};

int main (void)
{
	struct entry n1, n2, n3, insertMe;
	struct entry *list_pointer = &n1;

	void insertNode (struct entry *toInsert, struct entry *insertAfter);

	n1.prev = (struct entry *) 0;
	n1.value = 100;
	n1.next = &n2;

	n2.prev = &n1;	
	n2.value = 200;
	n2.next = &n3;

	n3.prev = &n2;
	n3.value = 300;
	n3.next = (struct entry *) 0; //mark end of list with a null pointer.

	insertMe.value = 250;
	insertMe.next = 0;

	insertNode (&insertMe, &n2 );

	while (list_pointer != (struct entry *) 0) {
		printf ("%i\n", list_pointer->value);
		list_pointer = list_pointer->next;
	}

	list_pointer = &n3;


	while (list_pointer != (struct entry *) 0) {
		printf ("%i\n", list_pointer->value);
		list_pointer = list_pointer->prev;
	}
	return 0;
}

