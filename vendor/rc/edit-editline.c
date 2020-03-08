#include "rc.h"

#include <errno.h>
#include <stdio.h>

#include "editline.h"

bool editing = 1;

struct cookie {
	char *buffer;
};

static char *prompt;

void *edit_begin(int fd) {
	List *hist;
	struct cookie *c;

	hist = varlookup("history");
	if (hist != NULL)
		if (read_history(hist->w) != 0 &&
				errno != ENOENT) /* ignore if missing */
			uerror(hist->w);

	c = ealloc(sizeof *c);
	c->buffer = NULL;
	return c;
}

/*
static void (*oldint)(int), (*oldquit)(int);

static void edit_catcher(int sig) {
	sys_signal(SIGINT, oldint);
	sys_signal(SIGQUIT, oldquit);
	write(2, "\n", 1);
	rc_raise(eError);
}

*/

char *edit_alloc(void *cookie, size_t *count) {
	struct cookie *c = cookie;
/*
	const char *r;
	HistEvent he;
	struct cookie *c = cookie;

	oldint = sys_signal(SIGINT, edit_catcher);
	oldquit = sys_signal(SIGQUIT, edit_catcher);

	r = el_gets(c->el, count);

	sys_signal(SIGINT, oldint);
	sys_signal(SIGQUIT, oldquit);

	if (r)
		history(c->hist, &he, H_ENTER, r);
*/

	c->buffer = readline(prompt);
	if (c->buffer) {
		*count = strlen(c->buffer);
		c->buffer[*count] = '\n';
		++*count;
	}
	return c->buffer;
}

/*
static char *edit_prompter(ne *e) {
	return prompt;
}
*/

void edit_prompt(void *cookie, char *pr) {
	//struct cookie *c = cookie;

	prompt = pr;
	//el_set(c->el, EL_PROMPT, edit_prompter);
}

void edit_free(void *cookie) {
	struct cookie *c = cookie;

	efree(c->buffer);
	c->buffer = NULL; /* allow "overfrees" */
}

void edit_end(void *cookie) {
	//struct cookie *c = cookie;

	//el_end(c->el);
	//history_end(c->hist);
	//efree(c);
}

void edit_reset(void *cookie) {
	//struct cookie *c = cookie;

	//el_set(c->el, EL_TERMINAL, NULL);
}
