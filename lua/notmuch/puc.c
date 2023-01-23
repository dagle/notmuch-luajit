#include <notmuch.h>
#include <string.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#if LUA_VERSION_NUM >= 502
#ifndef luaL_register
#define luaL_register(L, null, regs) luaL_setfuncs (L, regs, 0)
#endif
#endif

#define luaL_nm_db(L, n) *(notmuch_database_t **)luaL_checkudata(L, n, "nm_database")
#define luaL_nm_query(L, n) *(notmuch_query_t **)luaL_checkudata(L, n, "nm_query")
#define luaL_nm_thread(L, n) *(notmuch_thread_t **)luaL_checkudata(L, n, "nm_thread")
#define luaL_nm_message(L, n) *(notmuch_message_t **)luaL_checkudata(L, n, "nm_message")
#define luaL_nm_opts(L, n) *(notmuch_indexopts_t **)luaL_checkudata(L, n, "nm_opts")

#define luaL_nm_newuserdata(type, var) 	notmuch_ ## type ## _t ** type ## ptr = (notmuch_ ## type ## _t **)lua_newuserdata(L, sizeof(notmuch_ ## type ## _t *)); \
	* type ## ptr = var; \
	luaL_getmetatable(L, "nm_" #type); \
	lua_setmetatable(L, -2)

#define result(res) \
	if (res) { \
		luaL_error(L, "%s", notmuch_status_to_string(res));\
	}

static int tag_iterator(lua_State *L);
static int thread_iterator(lua_State *L);
static int message_iterator(lua_State *L);
static int filename_iterator(lua_State *L);
static int pair_iterator(lua_State *L);
static int property_iterator(lua_State *L);
static int config_list_iterator(lua_State *L);
static int value_iterator(lua_State *L);

const char* luaL_maybestring(lua_State *L, int index) {
	if lua_isnoneornil(L, index) {
		return NULL;
	}
	return luaL_checkstring(L,index);
}

static int db_create(lua_State *L) {
	notmuch_database_t *db;
	const char *path;

	int res = notmuch_database_create(path, &db);
	result(res);

	luaL_nm_newuserdata(database, db);

	return 1;
}

static int db_create_with_config(lua_State *L) {
	notmuch_database_t *db;
	const char *path, *conf, *profile;
	char *error;

	int res = notmuch_database_create_with_config(path, conf, profile, &db, &error);
	result(res);
	
	luaL_nm_newuserdata(database, db);

	return 1;
}

static int db_open(lua_State *L) {
	notmuch_database_t *db;
	const char *path;
	char mode = 0;

	path = luaL_maybestring(L,1);
    mode = luaL_checknumber (L, 2);
	int res = notmuch_database_open(path, mode, &db);
	result(res);

	luaL_nm_newuserdata(database, db);

	return 1;
}

static int db_open_with_config(lua_State *L) {
	notmuch_database_t *db;
	const char *path, *conf, *profile;
	int mode = 0;
	char *error;

	path = luaL_maybestring(L,1);
    mode = luaL_checknumber (L, 2);
	conf = luaL_maybestring(L,3);

	profile = luaL_maybestring(L,4);
	int res = notmuch_database_open_with_config(path, mode, conf, profile, &db, &error);
	result(res);

	luaL_nm_newuserdata(database, db);

	return 1;
}

static int db_load_config(lua_State *L) {
	notmuch_database_t *db;
	const char *path, *conf, *profile;
	char *error;

	path = luaL_maybestring(L,1);
	conf = luaL_maybestring(L,2);
	profile = luaL_maybestring(L,3);
	int res = notmuch_database_load_config(path, conf, profile, &db, &error);
	result(res);

	luaL_nm_newuserdata(database, db);

	return 1;
}

static int db_status_string(lua_State *L) {
	notmuch_database_t *db;
	const char *str;

	db = luaL_nm_db(L, 1);
	str = notmuch_database_status_string(db);
	lua_pushstring(L, str);
	return 1;
}


static int db_close(lua_State *L) {
	notmuch_database_t *db;

	db = luaL_nm_db(L, 1);
	notmuch_database_close(db);
	return 0;
}

static int db_destroy(lua_State *L) {
	notmuch_database_t *db;

	db = luaL_nm_db(L, 1);
	notmuch_database_destroy(db);
	return 0;
}

static int db_compact_db(lua_State *L) {
	return 0;
}

static int db_get_path(lua_State *L) {
	notmuch_database_t *db;
	const char *path;

	db = luaL_nm_db(L, 1);
	path = notmuch_database_get_path(db);
	lua_pushstring(L, path);
	return 1;
}

static int db_get_version(lua_State *L) {
	notmuch_database_t *db;
	double version;

	db = luaL_nm_db(L, 1);
	version = notmuch_database_get_version(db);
	lua_pushnumber(L, version);
	return 1;
}

static int db_needs_upgrade(lua_State *L) {
	notmuch_database_t *db;
	double b;

	db = luaL_nm_db(L, 1);
	b = notmuch_database_needs_upgrade(db);
	lua_pushboolean(L, b != 0);
	return 1;
}

static int db_upgrade(lua_State *L) {
	return 0;
}

static int db_atomic_begin(lua_State *L) {
	notmuch_database_t *db;

	db = luaL_nm_db(L, 1);
	int res = notmuch_database_begin_atomic(db);
	return 0;
}

static int db_atomic_end(lua_State *L) {
	notmuch_database_t *db;

	db = luaL_nm_db(L, 1);
	int res = notmuch_database_end_atomic(db);
	return 0;
}

static int get_revision(lua_State *L) {
	notmuch_database_t *db;
	const char *uuid;

	db = luaL_nm_db(L, 1);
	unsigned long rev = notmuch_database_get_revision(db, &uuid);
	lua_pushnumber(L, rev);
	lua_pushstring(L, uuid);
	return 2;
}

static int db_get_directory(lua_State *L) {
	notmuch_database_t *db;
	notmuch_directory_t *db_dir;
	const char *path;

	db = luaL_nm_db(L, 1);
	path = luaL_checkstring(L, 2);

	int res = notmuch_database_get_directory(db, path, &db_dir);
	result(res);

	lua_pushlightuserdata(L, db_dir);
	return 1;
}


static int db_index_file(lua_State *L) {
	notmuch_database_t *db;
	const char *filename;
	notmuch_indexopts_t *indexopts;
	notmuch_message_t *message;

	db = luaL_nm_db(L, 1);
	filename = luaL_checkstring(L, 2);
	indexopts = luaL_nm_opts(L, 3);

	int res = notmuch_database_index_file (db, filename,
					 indexopts, &message);
	result(res);

	luaL_nm_newuserdata(message, message);

	return 1;
}

static int db_remove_message(lua_State *L) {
	notmuch_database_t *db;
	const char *filename;

	db = luaL_nm_db(L, 1);
	filename = luaL_checkstring(L, 2);

	int res = notmuch_database_remove_message(db, filename);
	result(res);

	return 0;
}

static int db_find_message(lua_State *L) {
	notmuch_database_t *db;
	const char *message_id;
	notmuch_message_t *message;

	db = luaL_nm_db(L, 1);
	message_id = luaL_checkstring(L, 2);

	int res = notmuch_database_find_message (db, message_id, &message);
	result(res);

	luaL_nm_newuserdata(message, message);

	return 1;
}

static int db_find_message_by_filename(lua_State *L) {
	notmuch_database_t *db;
	const char *filename;
	notmuch_message_t *message;

	db = luaL_nm_db(L, 1);
	filename = luaL_checkstring(L, 2);

	int res = notmuch_database_find_message (db, filename, &message);
	result(res);
	lua_pushlightuserdata(L, message);

	return 1;
}

static int db_get_all_tags(lua_State *L) {
	notmuch_database_t *db;
	notmuch_tags_t *tags;

	db = luaL_nm_db(L, 1);
	tags = notmuch_database_get_all_tags(db);
	lua_pushlightuserdata(L, tags);

	lua_pushlightuserdata(L, tags);
	lua_pushcclosure(L, &tag_iterator, 1);

	return 1;
}

static int db_reopen(lua_State *L) {
	notmuch_database_t *db;
	int mode;

	db = luaL_nm_db(L, 1);
	mode = luaL_checknumber(L,2);
	int res = notmuch_database_reopen(db, mode);
	result(res);
	return 0;
}

static int create_query(lua_State *L) {
	notmuch_database_t *db;
	notmuch_query_t *q;
	const char *str;

	db = luaL_nm_db(L, 1);
	str = luaL_checkstring(L,2);

	q = notmuch_query_create(db, str);

	luaL_nm_newuserdata(query, q);

	return 1;
}

static int create_query_with_syntax(lua_State *L) {
	notmuch_database_t *db;
	notmuch_query_t *q;
	const char *str;
	int syntax;

	db = luaL_nm_db(L, 1);
	str = luaL_checkstring(L, 2);
	syntax = luaL_checknumber(L, 3);

	int res = notmuch_query_create_with_syntax(db, str, syntax, &q);
	result(res);

	luaL_nm_newuserdata(query, q);

	lua_pushlightuserdata(L, q);
	return 1;

}

static int query_destroy(lua_State *L) {
	notmuch_query_t *q;

	q = luaL_nm_query(L, 1);
	notmuch_query_destroy(q);

	return 0;
}

static int query_get_string(lua_State *L) {
	notmuch_query_t *q;
	const char *str;

	q = luaL_nm_query(L, 1);
	str = notmuch_query_get_query_string(q);

	lua_pushstring(L, str);
	return 1;
}

static int query_get_db(lua_State *L) {
	notmuch_database_t *db;
	notmuch_query_t *q;

	q = luaL_nm_query(L, 1);
	db = notmuch_query_get_database(q);

	lua_pushlightuserdata(L, db);
	return 1;
}

static int query_set_omit(lua_State *L) {
	notmuch_query_t *q;
	const char *exclude;
	int flag;

	q = luaL_nm_query(L, 1);
	exclude = luaL_checkstring(L, 2);

	if (strcmp("flag", exclude)) {
		flag = 0;
	} else if (strcmp("true", exclude)) {
		flag = 1;
	} else if (strcmp("false", exclude)) {
		flag = 2;
	} else if (strcmp("all", exclude)) {
		flag = 3;
	} else {
		luaL_error(L, "query_set_omit got a bad flag");
		return 1;
	}
	notmuch_query_set_omit_excluded(q, flag);
	return 0;
}

static int query_set_sort(lua_State *L) {
	notmuch_query_t *q;
	const char *sort;
	int flag;

	q = luaL_nm_query(L, 1);
	sort = luaL_checkstring(L, 2);

	if (strcmp("oldest", sort)) {
		flag = NOTMUCH_SORT_OLDEST_FIRST;
	} else if (strcmp("newest", sort)) {
		flag = NOTMUCH_SORT_NEWEST_FIRST;
	} else if (strcmp("message-id", sort)) {
		flag = NOTMUCH_SORT_MESSAGE_ID;
	} else if (strcmp("unsorted", sort)) {
		flag = NOTMUCH_SORT_UNSORTED;
	} else {
		luaL_error(L, "Can't find sorting algorithm");
		return 1;
	}
	notmuch_query_set_sort(q, flag);
	return 0;
}

static int query_get_sort(lua_State *L) {
	notmuch_query_t *q;
	const char *sort;
	int flag;

	q = luaL_nm_query(L, 1);
	flag = notmuch_query_get_sort(q);

	switch (flag) {
		case NOTMUCH_SORT_OLDEST_FIRST:
			lua_pushstring(L, "oldest");
			break;
		case NOTMUCH_SORT_NEWEST_FIRST:
			lua_pushstring(L, "newest");
			break;
		case NOTMUCH_SORT_MESSAGE_ID:
			lua_pushstring(L, "message-id");
			break;
		case NOTMUCH_SORT_UNSORTED:
			lua_pushstring(L, "unsorted");
			break;
	}
	return 1;
}

static int query_add_tag_exclude(lua_State *L) {
	notmuch_query_t *q;
	const char *tag;

	q = luaL_nm_query(L, 1);
	tag = luaL_checkstring(L, 2);

	int res = notmuch_query_add_tag_exclude(q, tag);
	result(res);

	return 0;
}

static int query_get_threads(lua_State *L) {
	notmuch_query_t *q;
	notmuch_threads_t *threads;

	q = luaL_nm_query(L, 1);
	int res = notmuch_query_search_threads(q, &threads);
	result(res);

	lua_pushlightuserdata(L, threads);
	lua_pushcclosure(L, &thread_iterator, 1);

	return 1;
}

static int tag_iterator(lua_State *L) {
	notmuch_tags_t *tags;
	const char *tag;

	tags = lua_touserdata(L, lua_upvalueindex(1));

	if (notmuch_tags_valid(tags)) {
		tag = notmuch_tags_get(tags);
		notmuch_tags_move_to_next(tags);
		lua_pushstring(L, tag);

		return 1;
	}
	return 0;
}

static int thread_iterator(lua_State *L) {
	notmuch_threads_t *threads;
	notmuch_thread_t *thread;

	threads = lua_touserdata(L, lua_upvalueindex(1));

	if (notmuch_threads_valid(threads)) {
		thread = notmuch_threads_get(threads);
		notmuch_threads_move_to_next(threads);
		luaL_nm_newuserdata(thread, thread);
		return 1;
	}
	return 0;
}

static int message_iterator(lua_State *L) {
	notmuch_messages_t *messages;
	notmuch_message_t *message;

	messages = lua_touserdata(L, lua_upvalueindex(1));

	if (notmuch_messages_valid(messages)) {
		message = notmuch_messages_get(messages);
		notmuch_messages_move_to_next(messages);
		luaL_nm_newuserdata(message, message);
		return 1;
	}
	return 0;
}

static int filename_iterator(lua_State *L) {
	notmuch_filenames_t *filenames;
	const char *filename;

	filenames = lua_touserdata(L, lua_upvalueindex(1));

	if (notmuch_filenames_valid(filenames)) {
		filename = notmuch_filenames_get(filenames);
		notmuch_filenames_move_to_next(filenames);
		lua_pushstring(L, filename);

		return 1;
	}
	return 0;
}

static int pair_iterator(lua_State *L) {
	notmuch_config_pairs_t *pairs;
	const char *key;
	const char *value;

	pairs = lua_touserdata(L, lua_upvalueindex(1));

	if (notmuch_config_pairs_valid(pairs)) {
		key = notmuch_config_pairs_key(pairs);
		value = notmuch_config_pairs_value(pairs);
		notmuch_config_pairs_move_to_next(pairs);
		lua_pushstring(L, key);
		lua_pushstring(L, value);

		return 2;
	}
	return 0;
}

static int property_iterator(lua_State *L) {
	notmuch_message_properties_t *props;
	const char *key;
	const char *value;

	props = lua_touserdata(L, lua_upvalueindex(1));

	if (notmuch_message_properties_valid(props)) {
		key = notmuch_message_properties_key(props);
		value = notmuch_message_properties_value(props);
		notmuch_message_properties_move_to_next(props);
		lua_pushstring(L, key);
		lua_pushstring(L, value);

		return 2;
	}
	return 0;
}


static int config_list_iterator(lua_State *L) {
	notmuch_config_list_t *props;
	const char *key;
	const char *value;

	props = lua_touserdata(L, lua_upvalueindex(1));

	if (notmuch_config_list_valid(props)) {
		key = notmuch_config_list_key(props);
		value = notmuch_config_list_value(props);
		notmuch_config_list_move_to_next(props);
		lua_pushstring(L, key);
		lua_pushstring(L, value);

		return 2;
	}
	return 0;
}

static int value_iterator(lua_State *L) {
	notmuch_config_values_t *values;
	const char *value;

	values = lua_touserdata(L, lua_upvalueindex(1));

	if (notmuch_config_values_valid(values)) {
		value = notmuch_config_values_get(values);
		notmuch_config_values_move_to_next(values);
		lua_pushstring(L, value);

		return 2;
	}
	return 0;
}

static int query_get_messages(lua_State *L) {
	notmuch_query_t *q;
	notmuch_messages_t *messages;

	q = luaL_nm_query(L, 1);
	int res = notmuch_query_search_messages(q, &messages);
	result(res);

	lua_pushlightuserdata(L, messages);
	lua_pushcclosure(L, &message_iterator, 1);

	return 1;
}

static int query_count_threads(lua_State *L) {
	notmuch_query_t *q;
	unsigned int count;

	q = luaL_nm_query(L, 1);
	int res = notmuch_query_count_threads(q, &count);
	result(res);

	lua_pushnumber(L, count);

	return 1;
}

static int query_count_messages(lua_State *L) {
	notmuch_query_t *q;
	unsigned int count;

	q = luaL_nm_query(L, 1);
	int res = notmuch_query_count_messages(q, &count);
	result(res);

	lua_pushnumber(L, count);

	return 1;
}

static int thread_destroy(lua_State *L) {
	notmuch_thread_t *thread;

	thread = luaL_nm_thread(L, 1);
	notmuch_thread_destroy (thread);

	return 0;
}

static int thread_get_id(lua_State *L) {
	notmuch_thread_t *thread;
	const char *id;

	thread = luaL_nm_thread(L, 1);
	id = notmuch_thread_get_thread_id(thread);
	
	lua_pushstring(L, id);
	return 1;
}

static int thread_get_total_messages(lua_State *L) {
	notmuch_thread_t *thread;
	int num;

	thread = luaL_nm_thread(L, 1);
	num = notmuch_thread_get_total_messages(thread);

	lua_pushnumber(L, num);
	return 1;
}

static int thread_get_total_files(lua_State *L) {
	notmuch_thread_t *thread;
	int num;

	thread = luaL_nm_thread(L, 1);
	num = notmuch_thread_get_total_files(thread);

	lua_pushnumber(L, num);
	return 1;
}

static int thread_get_toplevel_messages(lua_State *L) {
	notmuch_thread_t *thread;
	notmuch_messages_t *messages;

	thread = luaL_nm_thread(L, 1);
	messages = notmuch_thread_get_toplevel_messages(thread);

	lua_pushlightuserdata(L, messages);
	lua_pushcclosure(L, &message_iterator, 1);

	return 1;
}

static int thread_get_messages(lua_State *L) {
	notmuch_thread_t *thread;
	notmuch_messages_t *messages;

	thread = luaL_nm_thread(L, 1);
	messages = notmuch_thread_get_messages(thread);

	lua_pushlightuserdata(L, messages);
	lua_pushcclosure(L, &message_iterator, 1);

	return 1;
}

static int thread_get_matched_messages(lua_State *L) {
	notmuch_thread_t *thread;
	int num;

	thread = luaL_nm_thread(L, 1);
	num = notmuch_thread_get_matched_messages(thread);

	lua_pushnumber(L, num);

	return 1;
}

static int thread_get_authors(lua_State *L) {
	notmuch_thread_t *thread;
	const char *authors;

	thread = luaL_nm_thread(L, 1);
	authors = notmuch_thread_get_authors(thread);

	lua_pushstring(L, authors);

	return 1;
}

static int thread_get_subject(lua_State *L) {
	notmuch_thread_t *thread;
	const char *subject;

	thread = luaL_nm_thread(L, 1);
	subject = notmuch_thread_get_subject(thread);

	lua_pushstring(L, subject);

	return 1;
}

static int thread_get_oldest_date(lua_State *L) {
	notmuch_thread_t *thread;
	const char *date;

	thread = luaL_nm_thread(L, 1);
	// date = notmuch_thread_get_oldest_date(thread);

	// lua_pushstring(L, date);

	return 1;
}
static int thread_get_newest_date(lua_State *L) {
	notmuch_thread_t *thread;
	const char *date;

	thread = luaL_nm_thread(L, 1);
	// date = notmuch_thread_get_newest_date(thread);

	return 1;
}

static int thread_get_tags(lua_State *L) {
	notmuch_thread_t *thread;
	notmuch_tags_t *tags;

	thread = luaL_nm_thread(L, 1);

	tags = notmuch_thread_get_tags(thread);

	lua_pushlightuserdata(L, tags);
	lua_pushcclosure(L, &tag_iterator, 1);

	return 1;
}

static int messages_collect_tags(lua_State *L) {
	notmuch_messages_t *messages;
	notmuch_tags_t *tags;

	messages = lua_touserdata(L, lua_upvalueindex(1));

	tags = notmuch_messages_collect_tags(messages);

	lua_pushlightuserdata(L, tags);
	lua_pushcclosure(L, &tag_iterator, 1);

	return 1;
}

static int messages_destroy(lua_State *L) {
	notmuch_messages_t *messages;

	messages = lua_touserdata(L, 1);
	notmuch_messages_destroy (messages);

	return 0;
}

static int message_destroy(lua_State *L) {
	notmuch_message_t *message;

	message = luaL_nm_message(L, 1);
	notmuch_message_destroy (message);

	return 0;
}

static int message_get_db(lua_State *L) {
	notmuch_database_t *db;
	notmuch_message_t *message;

	message = luaL_nm_message(L, 1);
	db = notmuch_message_get_database(message);

	lua_pushlightuserdata(L, db);

	return 1;
}

static int message_get_id(lua_State *L) {
	notmuch_message_t *message;
	const char *id;

	message = luaL_nm_message(L, 1);
	id = notmuch_message_get_message_id(message);

	lua_pushstring(L, id);

	return 1;
}

static int message_get_message_id(lua_State *L) {
	notmuch_message_t *message;
	const char *id;

	message = luaL_nm_message(L, 1);
	id = notmuch_message_get_message_id(message);

	lua_pushstring(L, id);

	return 1;
}

static int message_get_replies(lua_State *L) {
	notmuch_message_t *message;
	notmuch_messages_t *messages;

	message = luaL_nm_message(L, 1);
	messages = notmuch_message_get_replies(message);

	lua_pushlightuserdata(L, messages);
	lua_pushcclosure(L, &message_iterator, 1);

	return 1;
}

static int message_count_files(lua_State *L) {
	notmuch_message_t *message;
	int num;

	message = luaL_nm_message(L, 1);
	num = notmuch_message_count_files(message);
	lua_pushnumber(L, num);

	return 1;
}

static int message_get_filename(lua_State *L) {
	notmuch_message_t *message;
	const char *filename;

	message = luaL_nm_message(L, 1);
	filename = notmuch_message_get_filename(message);

	lua_pushstring(L, filename);

	return 1;
}

static int message_get_filenames(lua_State *L) {
	notmuch_message_t *message;
	notmuch_filenames_t *filenames;

	message = luaL_nm_message(L, 1);
	filenames = notmuch_message_get_filenames(message);
	
	lua_pushlightuserdata(L, filenames);
	lua_pushcclosure(L, &filename_iterator, 1);

	return 1;
}

static int message_reindex(lua_State *L) {
	notmuch_message_t *message;
	notmuch_indexopts_t *opts;

	message = luaL_nm_message(L, 1);
	opts = luaL_nm_opts(L,2);

	int res = notmuch_message_reindex(message, opts);
	result(res);

	return 0;
}

static notmuch_bool_t luaL_checkbool(lua_State *L, int index) {
	if (lua_isboolean( L, index )) {
		return lua_toboolean(L, index);
	}
	luaL_error(L, "Function expected a bool as argument #%d", index);
	return 0;
}

static int message_get_flag(lua_State *L) {
	notmuch_message_t *message;
	notmuch_message_flag_t flag;
	notmuch_bool_t b;

	message = luaL_nm_message(L, 1);
	flag = luaL_checknumber(L, 2);

	int res = notmuch_message_get_flag_st(message, flag, &b);
	result(res);
	
	lua_pushboolean(L, b);

	return 1;
}

static int message_set_flag(lua_State *L) {
	notmuch_message_t *message;
	notmuch_message_flag_t flag;
	notmuch_bool_t b;

	message = luaL_nm_message(L, 1);
	flag = luaL_checknumber(L, 2);
	b = luaL_checkbool(L, 3);

	notmuch_message_set_flag(message, flag, b);

	return 0;
}

static int message_get_date(lua_State *L) {
	notmuch_message_t *message;
	int date;

	message = luaL_nm_message(L, 1);
	date = notmuch_message_get_date(message);
	// lua_pushnumber(L, num);

	return 1;
}

static int message_get_header(lua_State *L) {
	notmuch_message_t *message;
	const char *header;

	message = luaL_nm_message(L, 1);
	header = notmuch_message_get_filename(message);

	lua_pushstring(L, header);

	return 1;
}

static int message_get_tags(lua_State *L) {
	notmuch_message_t *message;
	notmuch_tags_t *tags;

	message = luaL_nm_message(L, 1);

	tags = notmuch_message_get_tags(message);

	lua_pushlightuserdata(L, tags);
	lua_pushcclosure(L, &tag_iterator, 1);

	return 1;
}

static int message_add_tag(lua_State *L) {
	notmuch_message_t *message;
	const char *tag;

	message = luaL_nm_message(L, 1);
	tag = luaL_checkstring(L, 2);

	int res = notmuch_message_add_tag(message, tag);
	result(res);

	return 0;
}

static int message_remove_tag(lua_State *L) {
	notmuch_message_t *message;
	const char *tag;

	message = luaL_nm_message(L, 1);
	tag = luaL_checkstring(L, 2);

	int res = notmuch_message_remove_tag(message, tag);
	result(res);

	return 0;
}

static int message_remove_all_tags(lua_State *L) {
	notmuch_message_t *message;

	message = luaL_nm_message(L, 1);
	notmuch_message_remove_all_tags(message);

	return 0;
}

static int message_maildir_flags_to_tags(lua_State *L) {
	notmuch_message_t *message;

	message = luaL_nm_message(L, 1);

	int res = notmuch_message_maildir_flags_to_tags(message);
	result(res);

	return 0;
}

static int message_has_maildir_flag(lua_State *L) {
	notmuch_message_t *message;
	const char *flag;
	notmuch_bool_t b;

	message = luaL_nm_message(L, 1);
	flag = luaL_checkstring(L, 2);
	int res = notmuch_message_has_maildir_flag_st(message, *flag, &b);
	result(res);

	lua_pushboolean(L, b);

	return 1;
}

static int message_tags_to_maildir_flags(lua_State *L) {
	notmuch_message_t *message;

	message = luaL_nm_message(L, 1);

	int res = notmuch_message_maildir_flags_to_tags(message);
	result(res);

	return 0;
}

static int message_freeze(lua_State *L) {
	notmuch_message_t *message;

	message = luaL_nm_message(L, 1);
	notmuch_message_freeze(message);

	return 0;
}

static int message_thaw(lua_State *L) {
	notmuch_message_t *message;

	message = luaL_nm_message(L, 1);
	notmuch_message_thaw(message);

	return 0;
}

static int message_get_property(lua_State *L) {
	notmuch_message_t *message;
	const char *key;
	const char *val;

	message = luaL_nm_message(L, 1);
	key = luaL_checkstring(L, 2);
	int res = notmuch_message_get_property(message, key, &val);
	result(res);

	lua_pushstring(L, val);

	return 1;
}

static int message_add_property(lua_State *L) {
	notmuch_message_t *message;
	const char *key;
	const char *val;

	message = luaL_nm_message(L, 1);
	key = luaL_checkstring(L, 2);
	val = luaL_checkstring(L, 3);
	int res = notmuch_message_add_property(message, key, val);
	result(res);

	return 0;
}

static int message_remove_properety(lua_State *L) {
	notmuch_message_t *message;
	const char *key;
	const char *value;

	message = luaL_nm_message(L, 1);
	key = luaL_checkstring(L, 2);
	value = luaL_checkstring(L, 2);
	int res = notmuch_message_remove_property(message, key, value);
	result(res);

	return 0;
}

static int message_remove_all_properties(lua_State *L) {
	notmuch_message_t *message;
	const char *key;

	message = luaL_nm_message(L, 1);
	key = luaL_checkstring(L, 2);
	int res = notmuch_message_remove_all_properties(message, key);
	result(res);

	return 0;
}

static int message_remove_all_properties_with_prefix(lua_State *L) {
	notmuch_message_t *message;
	const char *prefix;

	message = luaL_nm_message(L, 1);
	prefix = luaL_checkstring(L, 2);
	int res = notmuch_message_remove_all_properties_with_prefix(message, prefix);
	result(res);

	return 0;
}

static int message_get_properties(lua_State *L) {
	notmuch_message_t *message;
	notmuch_message_properties_t *props;
	const char *key;
	notmuch_bool_t exact;

	message = luaL_nm_message(L, 1);
	key = luaL_checkstring(L, 2);
	exact = luaL_checkbool(L, 3);

	props = notmuch_message_get_properties(message, key, exact);

	lua_pushlightuserdata(L, props);
	lua_pushcclosure(L, &property_iterator, 1);
	
	return 1;
}

static int message_count_properties(lua_State *L) {
	notmuch_message_t *message;
	const char *key;
	unsigned int count;

	message = luaL_nm_message(L, 1);
	key = luaL_checkstring(L, 2);

	notmuch_message_count_properties(message, key, &count);
	lua_pushnumber(L, count);

	return 1;
}

static int directory_set_mtime(lua_State *L) {
	notmuch_directory_t *dir;
	time_t mtime;

	dir = lua_touserdata(L, 1);
	mtime = luaL_checknumber(L, 2);

	int res = notmuch_directory_set_mtime(dir, mtime);
	result(res);

	return 0;
}

static int directory_get_mtime(lua_State *L) {
	notmuch_directory_t *dir;
	time_t mtime;

	dir = lua_touserdata(L, 1);

	mtime = notmuch_directory_get_mtime(dir);
	lua_pushnumber(L, mtime);

	return 1;
}

static int directry_get_child_files(lua_State *L) {
	notmuch_directory_t *dir;
	notmuch_filenames_t *files;

	dir = lua_touserdata(L, 1);
	files = notmuch_directory_get_child_files(dir);

	lua_pushlightuserdata(L, files);
	lua_pushcclosure(L, &filename_iterator, 1);

	return 1;
}

static int directory_get_child_directories(lua_State *L) {
	notmuch_directory_t *dir;
	notmuch_filenames_t *files;

	dir = lua_touserdata(L, 1);
	files = notmuch_directory_get_child_directories(dir);

	lua_pushlightuserdata(L, files);
	lua_pushcclosure(L, &filename_iterator, 1);

	return 1;
}

static int directory_delete(lua_State *L) {
	notmuch_directory_t *dir;

	dir = lua_touserdata(L, 1);
	int res = notmuch_directory_delete(dir);
	result(res);

	return 0;
}

static int db_set_conf(lua_State *L) {
	notmuch_database_t *db;
	const char *key;
	const char *value;

	db = lua_touserdata(L, 1);
	key = luaL_checkstring(L, 2);
	value = luaL_checkstring(L, 3);

	int res = notmuch_database_set_config(db, key, value);
	result(res);

	return 0;
}

static int db_get_conf(lua_State *L) {
	notmuch_database_t *db;
	const char *key;
	char *value;

	db = lua_touserdata(L, 1);
	key = luaL_checkstring(L, 2);

	int res = notmuch_database_get_config(db, key, &value);
	result(res);

	lua_pushstring(L, value);

	return 1;

}

static int db_get_conf_list(lua_State *L) {
	notmuch_database_t *db;
	notmuch_config_list_t *out;
	const char *prefix;

	db = lua_touserdata(L, 1);
	prefix = luaL_checkstring(L, 2);
	
	int res = notmuch_database_get_config_list(db, prefix, &out);
	result(res);

	lua_pushlightuserdata(L, out);
	lua_pushcclosure(L, &config_list_iterator, 1);
	
	return 1;
}

static int config_get(lua_State *L) {
	notmuch_database_t *db;
	notmuch_config_key_t key;
	const char *value;

	db = lua_touserdata(L, 1);
	key = luaL_checknumber(L, 2);

	value = notmuch_config_get(db, key);
	lua_pushstring(L, value);
	
	return 1;
}

static int config_set(lua_State *L) {
	notmuch_database_t *db;
	notmuch_config_key_t key;
	const char *value;

	db = lua_touserdata(L, 1);
	key = luaL_checknumber(L, 2);
	value = luaL_checkstring(L, 3);

	int res = notmuch_config_set(db, key, value);
	result(res);
	
	return 0;
}

static int config_get_values(lua_State *L) {
	notmuch_database_t *db;
	notmuch_config_key_t key;
	notmuch_config_values_t *values;

	db = lua_touserdata(L, 1);
	key = (notmuch_config_key_t) luaL_checknumber(L, 2);
	values = notmuch_config_get_values(db, key);

	lua_pushlightuserdata(L, values);
	lua_pushcclosure(L, &value_iterator, 1);

	return 1;
}

static int config_get_values_string(lua_State *L) {
	notmuch_database_t *db;
	const char *key;
	notmuch_config_values_t *values;

	db = lua_touserdata(L, 1);
	key =  luaL_checkstring(L, 2);
	values = notmuch_config_get_values_string(db, key);

	lua_pushlightuserdata(L, values);
	lua_pushcclosure(L, &value_iterator, 1);

	return 1;
}

static int config_get_pairs(lua_State *L) {
	notmuch_database_t *db;
	const char *prefix;
	notmuch_config_pairs_t *pairs;

	db = luaL_nm_db(L, 1);
	prefix = luaL_checkstring(L, 2);
	pairs = notmuch_config_get_pairs(db, prefix);

	lua_pushlightuserdata(L, pairs);
	lua_pushcclosure(L, &pair_iterator, 1);

	return 1;
}

static int config_get_bool(lua_State *L) {
	notmuch_database_t *db;
	notmuch_config_key_t key;
	notmuch_bool_t value;

	db = lua_touserdata(L, 1);
	key = (notmuch_config_key_t) luaL_checknumber(L, 2);
	notmuch_config_get_bool(db, key, &value);

	lua_pushboolean(L, value);

	return 1;
}

static int config_path(lua_State *L) {
	notmuch_database_t *db;
	const char *path;

	db = lua_touserdata(L, 1);
	path = notmuch_config_path(db);

	lua_pushstring(L, path);

	return 1;
}

static int db_get_default_indexopts(lua_State *L) {
	notmuch_database_t *db;
	notmuch_indexopts_t *opts;

	db = lua_touserdata(L, 1);
	opts = notmuch_database_get_default_indexopts(db);

	luaL_nm_newuserdata(indexopts, opts);
	
	return 1;
}

static int indexopts_set_decrypt_policy(lua_State *L) {
	notmuch_indexopts_t *opts;
	notmuch_decryption_policy_t policy;

	opts = luaL_nm_opts(L, 1);
	policy = (notmuch_decryption_policy_t) luaL_checknumber(L, 2);
	int res = notmuch_indexopts_set_decrypt_policy(opts, policy);
	result(res);

	return 0;
}

static int indexopts_get_decrypt_policy(lua_State *L) {
	notmuch_indexopts_t *opts;
	notmuch_decryption_policy_t policy;

	opts = lua_touserdata(L, 1);
	policy = notmuch_indexopts_get_decrypt_policy(opts);

	lua_pushnumber(L, policy);

	return 1;
}

static int indexopts_destroy(lua_State *L) {
	notmuch_indexopts_t *opts;

	opts = luaL_nm_opts(L, 1);
	notmuch_indexopts_destroy(opts);

	return 0;
}

static int built_with(lua_State *L) {
	const char *name;
	notmuch_bool_t b;

	name = luaL_checkstring(L, 1);

	b = notmuch_built_with(name);

	lua_pushboolean(L, b);

	return 1;
}

// static int make_indexopts(lua_State *L) {
// 	notmuch_indexopts_t *opts;
// 	notmuch_decryption_policy_t policy;
//
// 	opts = lua_newuserdata(L, sizeof(notmuch_indexopts_t));
// 	policy = (notmuch_decryption_policy_t) luaL_checknumber(L, 2);
// 	notmuch_indexopts_set_decrypt_policy(opts, policy);
//
// 	return 1;
// }

static const struct luaL_Reg notmuch2 [] = {
	{"db_create", db_create},
	{"db_create_with_config", db_create_with_config}, /* names can be different */
	{"db_open", db_create},
	{"db_open_with_config", db_open_with_config},
	{"db_load_config", db_load_config},
	{"db_status_string", db_status_string},
	{NULL, NULL}
};

struct luaL_Reg nm_db[] =
{
	{"__gc", db_close },
	{"status_string", db_status_string},
	{"get_path", db_get_path },
	{"get_version", db_get_version},
	{"needs_upgrade", db_needs_upgrade},
	{"atomic_begin", db_atomic_begin},
	{"atomic_end", db_atomic_end},
	{"get_directory", db_get_directory},
	{"index_file", db_index_file},
	{"remove_message", db_remove_message},
	{"find_message", db_find_message},
	{"find_message_by_filename", db_find_message_by_filename},
	{"get_all_tags", db_get_all_tags},
	{"reopen", db_reopen},
	{"create_query", create_query},
	{"create_query_with_syntax", create_query_with_syntax},
	{""},
	{"get_default_indexopts", db_get_default_indexopts},
	{ NULL, NULL }
};

struct luaL_Reg nm_query[] =
{
	{"__gc", query_destroy },
	{"get_string", query_get_string},
	{"get_db", query_get_db},
	{"set_omit", query_set_omit},
	{"set_sort", query_set_sort},
	{"get_sort", query_get_sort},
	{"add_tag_exclude", query_add_tag_exclude},
	{"get_threads", query_get_threads},
	{"get_messages", query_get_messages},
	{"count_threads", query_count_threads},
	{"count_messages", query_count_messages},
	{ NULL, NULL }
};

struct luaL_Reg nm_thread[] =
{
	{"__gc", thread_destroy },
	{"get_id", thread_get_id },
	{"get_total_messages", thread_get_total_messages },
	{"get_total_files", thread_get_total_files },
	{"get_toplevel_messages", thread_get_toplevel_messages },
	{"get_messages", thread_get_messages },
	{"get_matched_messages", thread_get_matched_messages },
	{"get_authors", thread_get_authors },
	{"get_subject", thread_get_subject },
	{"get_oldest_date", thread_get_oldest_date },
	{"get_newest_date", thread_get_newest_date },
	{"get_tags", thread_get_tags },
	{ NULL, NULL }
};

struct luaL_Reg nm_message[] =
{
	{"__gc", message_destroy },
	{"get_db", message_get_db },
	{"get_id", message_get_id },
	{"get_message_id", message_get_message_id },
	{"get_replies", message_get_replies },
	{"count_files", message_count_files },
	{"get_filename", message_get_filename },
	{"get_filenames", message_get_filenames },
	{"reindex", message_reindex },
	{"get_flag", message_get_flag },
	{"set_flag", message_set_flag },
	{"get_date", message_get_date },
	{"get_header", message_get_header },
	{"get_tags", message_get_tags },
	{"add_tag", message_add_tag },
	{"remove_tag", message_remove_tag },
	{"remove_all_tags", message_remove_all_tags },
	{"maildir_flags_to_tags", message_maildir_flags_to_tags },
	{"has_maildir_flag", message_has_maildir_flag },
	{"tags_to_maildir_flags", message_tags_to_maildir_flags },
	{"freeze", message_freeze },
	{"thaw", message_thaw },
	{"get_property", message_get_property },
	{"add_property", message_add_property },
	{"remove_properety", message_remove_properety },
	{"remove_all_properties", message_remove_all_properties },
	{"remove_all_properties_with_prefix", message_remove_all_properties_with_prefix },
	{"remove_all_properties_with_prefix", message_remove_all_properties_with_prefix },
	{"get_properties", message_get_properties },
	{"count_properties", message_count_properties },
	{ NULL, NULL }
};


struct luaL_Reg nm_messages[] =
{
	{"__gc", messages_destroy },
};

struct luaL_Reg nm_indexopts[] = 
{
	{"__gc", indexopts_destroy },
	{"set_decrypt_policy", indexopts_set_decrypt_policy },
	{"get_decrypt_policy", indexopts_get_decrypt_policy },
};

void register_metatable(lua_State *L, luaL_Reg *reg, const char *s) {
	luaL_newmetatable(L, s);
	luaL_setfuncs (L, reg, 0);
	lua_pushvalue(L, -1);
	lua_setfield(L, -1, "__index");
}

int luaopen_notmuch2(lua_State *L){
	register_metatable(L, nm_db, "nm_database");
	register_metatable(L, nm_query, "nm_query");
	register_metatable(L, nm_thread, "nm_thread");
	register_metatable(L, nm_message, "nm_message");
	register_metatable(L, nm_indexopts, "nm_opts");
	register_metatable(L, nm_messages, "nm_messages");

	lua_newtable (L);
	luaL_register (L, NULL, notmuch2);
    return 1;
}
