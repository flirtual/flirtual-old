#include "rc.h"

#include <errno.h>
#include <stdio.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <readline/rltypedefs.h>

#include "edit.h"

bool editing = 1;

static const char *quote_chars = "\t\n !#$&'()*;<=>?@[\\]^`{|}~";

struct cookie {
	char *buffer;
};

/* Join two strings with a "/" between them, into a malloc string */
static char *dir_join(const char *a, const char *b) {
	size_t l;
	if (!a) a = "";
	if (!b) b = "";
	l = strlen(a);
	return mprint("%s%s%s", a, l && a[l-1] != '/' ? "/" : "", b);
}

char *quote(char *p, int open) {
	if (strpbrk(p, quote_chars)) {
		char *r = mprint("%#S", p);
		if (open)
			r[strlen(r)-1] = '\0';
		efree(p);
		return r;
	}
	return p;
}

static char *unquote(const char *text) {
	int quoted = 0;
	char *p, *r;
	p = r = ealloc(strlen(text) + 1);
	while ((*p = *text++)) {
		if (*p == '\'' && (!quoted || *text != '\''))
			quoted = !quoted;
		else
			p++;
	}
	return r;
}

/* Decide if this directory entry is a completion candidate, either executable
 * or a directory. "dname" is the absolute path of the directory, "name" is the
 * current entry. "subdirs" is the name being completed up to and including the
 * last slash (or NULL if there is no slash), "prefix" is the remainder of the
 * name being completed, "len" is the length of "prefix".
 */
static char *entry(char *dname, char *name, char *subdirs,
			char *prefix, size_t len) {
	char *full;
	struct stat st;

	if (strncmp(name, prefix, len) != 0)
		return NULL;
	if (streq(name, ".") || streq(name, ".."))
		return NULL;
	full = dir_join(dname, name);
	int exe = rc_access(full, FALSE, &st);
	efree(full);
	if (S_ISDIR(st.st_mode))
		rl_completion_append_character = '/';
	if (exe || S_ISDIR(st.st_mode))
		return dir_join(subdirs, name);
	return NULL;
}

/* Split a string "text" after the last "/" into "pre" and "post". If there is
 * no "/", "pre" will be NULL. */
void split_last_slash(const char *text, char **pre, char **post) {
	char *last_slash = strrchr(text, '/');
	if (last_slash) {
		size_t l = last_slash + 1 - text;
		*pre = ealloc(l + 1);
		memcpy(*pre, text, l);
		(*pre)[l] = '\0';
		*post = last_slash + 1;
	} else {
		*pre = NULL;
		*post = (char *)text;
	}
}

static char *compl_extcmd(const char *text, int state) {
	static char *dname, *prefix, *subdirs;
	static DIR *d;
	static List nil, *path;
	static size_t len;

	if (!state) {
		split_last_slash(text, &subdirs, &prefix);
		d = NULL;
		if (subdirs && isabsolute(subdirs))
			path = &nil;
		else
			path = varlookup("path");
		len = strlen(prefix);
	}
	while (d || path) {
		if (!d) {
			dname = dir_join(path->w, subdirs);
			d = opendir(dname);
			path = path->n;
			if (!d) efree(dname);
		} else {
			struct dirent *e;
			while ((e = readdir(d))) {
				char *x;
				x = entry(dname, e->d_name, subdirs,
						prefix, len);
				if (x) return x;
			}
			closedir(d);
			efree(dname);
			d = NULL;
		}
	}
	efree(subdirs);
	return NULL;
}

static rl_compentry_func_t *const compl_cmd_funcs[] = {
	compl_builtin,
	compl_fn,
	compl_extcmd
};

static char *compl_command(const char *text, int state) {
	static size_t i;
	static int s;
	char *name = NULL;

	if (!state) {
		i = 0;
		s = 0;
	}
	while (name == NULL && i < arraysize(compl_cmd_funcs)) {
		name = compl_cmd_funcs[i](text, s);
		if (name != NULL) {
			s = 1;
		} else {
			i++;
			s = 0;
		}
	}
	return name;
}

static char *compl_filename(const char *text, int state) {
	char *name = rl_filename_completion_function(text, state);
	struct stat st;
	if (name != NULL && stat(name, &st) == 0 && S_ISDIR(st.st_mode))
		rl_completion_append_character = '/';
	return name;
}

static rl_compentry_func_t *compl_func(char prefix) {
	switch (prefix) {
		case '`': case '@': case '|': case '&':
		case '(': case ')': case '{': case ';':
			return compl_command;
		case '$':
			return compl_var;
	}
	return compl_filename;
}

static char compl_prefix(int index) {
	while (index-- > 0) {
		char c = rl_line_buffer[index];
		if (c != ' ' && c != '\t')
			return c;
	}
	return ';';
}

/* Find the start of the word to complete. This function is the only way to
 * make readline's code fully support rc's quoting rules. It is called in
 * *_rl_find_completion_word* as the *rl_completion_word_break_hook* and
 * exploits the fact that readline stores the start of the word in *rl_point*.
 * We put the correct postion there first and prevent readline from overwriting
 * it by keeping *rl_completer_quote_characters* empty!
 */
static char *compl_start() {
	int i, quoted = 0, start = 0;
	for (i = 0; i < rl_point; i++) {
		char c = rl_line_buffer[i];
		if (c == '\'')
			quoted = !quoted;
		if (!quoted && strchr(rl_basic_word_break_characters, c))
			start = i;
	}
	rl_point = start;
	return NULL;
}

static int matchcmp(const void *a, const void *b) {
	return strcoll(*(const char **)a, *(const char **)b);
}

static rl_compentry_func_t *compentry_func;

static char **rc_completion(const char *text, int start, int end) {
	size_t i, n;
	char *t = unquote(text);
	char **matches = NULL;
	rl_compentry_func_t *func;

	if (compentry_func != NULL) {
		func = compentry_func;
		compentry_func = NULL;
	} else
		func = compl_func(compl_prefix(start));
	matches = rl_completion_matches(t, func);
	if (matches) {
		for (n = 1; matches[n]; n++);
		qsort(&matches[1], n - 1, sizeof(matches[0]), matchcmp);
		if (rl_completion_type != '?')
			matches[0] = quote(matches[0], n > 1);
		if (rl_completion_type == '*')
			for (i = 1; i < n; i++)
				matches[i] = quote(matches[i], 0);
	}
	efree(t);
	rl_attempted_completion_over = 1;
	rl_sort_completion_matches = 0;
	return matches;
}

static int expl_complete(rl_compentry_func_t *func, int count, int key) {
	if (rl_last_func == rl_complete)
		rl_last_func = NULL;
	compentry_func = func;
	return rl_complete(count, key);
}

static int rc_complete_command(int count, int key) {
	return expl_complete(compl_extcmd, count, key);
}

static int rc_complete_filename(int count, int key) {
	return expl_complete(compl_filename, count, key);
}

static int rc_complete_variable(int count, int key) {
	return expl_complete(compl_var, count, key);
}

void *edit_begin(int fd) {
	List *hist;
	struct cookie *c;

	rl_attempted_completion_function = rc_completion;
	rl_basic_quote_characters = "";
	rl_basic_word_break_characters = " \t\n`@$><=;|&{(";
	rl_catch_signals = 0;
	rl_completion_word_break_hook = compl_start;
	rl_readline_name = "rc";

	rl_initialize();

	rl_add_funmap_entry("rc-complete-command", rc_complete_command);
	rl_add_funmap_entry("rc-complete-filename", rc_complete_filename);
	rl_add_funmap_entry("rc-complete-variable", rc_complete_variable);
	rl_bind_keyseq("\e!", rc_complete_command);
	rl_bind_keyseq("\e/", rc_complete_filename);
	rl_bind_keyseq("\e$", rc_complete_variable);

	hist = varlookup("history");
	if (hist != NULL)
		if (read_history(hist->w) != 0 &&
				errno != ENOENT) /* ignore if missing */
			uerror(hist->w);

	c = ealloc(sizeof *c);
	c->buffer = NULL;
	return c;
}

static void (*oldint)(int), (*oldquit)(int);

static void edit_catcher(int sig) {
	sys_signal(SIGINT, oldint);
	sys_signal(SIGQUIT, oldquit);
	write(2, "\n", 1);
	rc_raise(eError);
}

static char *prompt;

char *edit_alloc(void *cookie, size_t *count) {
	struct cookie *c = cookie;

	oldint = sys_signal(SIGINT, edit_catcher);
	oldquit = sys_signal(SIGQUIT, edit_catcher);

	rl_reset_screen_size();
	c->buffer = readline(prompt);

	sys_signal(SIGINT, oldint);
	sys_signal(SIGQUIT, oldquit);

	if (c->buffer) {
		*count = strlen(c->buffer);
		if (*count) {
			history_set_pos(history_length);
			while (history_search_prefix(c->buffer, -1) == 0) {
				HIST_ENTRY *e = current_history();
				if (e != NULL && e->line[*count] == '\0') {
					if ((e = remove_history(where_history())))
						free_history_entry(e);
				}
				if (!previous_history())
					break;
			}
			add_history(c->buffer);
		}
		c->buffer[*count] = '\n';
		++*count; /* include the \n */
	}
	return c->buffer;
}

void edit_prompt(void *cookie, char *pr) {
	prompt = pr;
}

void edit_free(void *cookie) {
	struct cookie *c = cookie;

	efree(c->buffer);
	/* Set c->buffer to NULL, allowing us to "overfree" it. This is a bit
	 * of a kludge, but it's otherwise hard to deal with the case where a
	 * signal causes an early return from readline. */
	c->buffer = NULL;
}

void edit_end(void *cookie) {
	struct cookie *c = cookie;

	efree(c);
}

void edit_reset(void *cookie) {
	rl_reset_terminal(NULL);
}
