#include "terminal.h"

int _hx_terminal_grow( hx_terminal* t );

hx_terminal* hx_new_terminal( void ) {
	hx_terminal* terminal	= (hx_terminal*) calloc( 1, sizeof( hx_terminal ) );
	rdf_node* p	= (rdf_node*) calloc( TERMINAL_LIST_ALLOC_SIZE, sizeof( rdf_node ) );
	terminal->ptr		= p;
	terminal->allocated	= TERMINAL_LIST_ALLOC_SIZE;
	terminal->used		= 0;
	terminal->refcount	= 0;
	return terminal;
}

int hx_free_terminal ( hx_terminal* list ) {
//	fprintf( stderr, "freeing terminal %p\n", list );
	list->refcount--;
//	fprintf( stderr, "refcount is now %d\n", list->refcount );
	if (list->refcount == 0) {
		if (list->ptr != NULL) {
//			fprintf( stderr, "free(list->ptr) called\n" );
			free( list->ptr );
		}
//		fprintf( stderr, "free(list) called\n" );
		free( list );
		return 0;
	} else {
		return 1;
	}
}

int hx_terminal_debug ( const char* header, hx_terminal* t, int newline ) {
	fprintf( stderr, "%s[", header );
	for(int i = 0; i < t->used; i++) {
		if (i > 0)
			fprintf( stderr, ", " );
		fprintf( stderr, "%d", (int) t->ptr[ i ] );
	}
	fprintf( stderr, "]" );
	if (newline > 0)
		fprintf( stderr, "\n" );
}

int hx_terminal_add_node ( hx_terminal* t, rdf_node n ) {
	int i;
	int r	= hx_terminal_binary_search( t, n, &i );
	if (r == 0) {
		// already in list. do nothing.
	} else {
		// not found. need to add at index i
//		fprintf( stderr, "list add [used: %d, allocated: %d]\n", (int) t->used, (int) t->allocated );
		if (t->used >= t->allocated) {
			_hx_terminal_grow( t );
		}
		
		for (int k = t->used - 1; k >= i; k--) {
			t->ptr[k + 1]	= t->ptr[k];
		}
		t->ptr[i]	= n;
		t->used++;
	}
	return 0;
}

int hx_terminal_contains_node ( hx_terminal* t, rdf_node n ) {
	int i;
	int r	= hx_terminal_binary_search( t, n, &i );
	if (r == 0) {
		return 1;
	} else {
		return 0;
	}
}

int hx_terminal_remove_node ( hx_terminal* t, rdf_node n ) {
	int i;
	int r	= hx_terminal_binary_search( t, n, &i );
	if (r == -1) {
		// not in list. do nothing.
	} else {
		// found. need to remove at index i
		for (int k = i; k < t->used; k++) {
			t->ptr[ k ]	= t->ptr[ k + 1 ];
		}
		t->used--;
	}
	return 0;
}

int _hx_terminal_grow( hx_terminal* t ) {
	size_t size		= t->allocated * 2;
//	fprintf( stderr, "growing terminal from %d to %d entries\n", (int) t->allocated, (int) size );
	rdf_node* newp	= (rdf_node*) calloc( size, sizeof( rdf_node ) );
	for (int i = 0; i < t->used; i++) {
		newp[ i ]	= t->ptr[ i ];
	}
//	fprintf( stderr, "free(t->ptr) called\n" );
	free( t->ptr );
	t->ptr		= newp;
	t->allocated	= (list_size_t) size;
	return 0;
}

list_size_t hx_terminal_size ( hx_terminal* t ) {
	return t->used;
}

size_t hx_terminal_memory_size ( hx_terminal* t ) {
	list_size_t size	= sizeof( hx_terminal ) + (t->used * sizeof( rdf_node ));
	return size;
}

int hx_terminal_binary_search ( const hx_terminal* t, const rdf_node n, int* index ) {
	int low		= 0;
	int high	= t->used - 1;
	while (low <= high) {
		int mid	= low + (high - low) / 2;
		if (t->ptr[mid] > n) {
			high	= mid - 1;
		} else if (t->ptr[mid] < n) {
			low	= mid + 1;
		} else {
			*index	= mid;
			return 0;
		}
	}
	*index	= low;
	return -1;
}
