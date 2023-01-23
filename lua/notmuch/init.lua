---@diagnostic disable: undefined-field
-- This is a raw ffi layer on top of notmuch
--
-- Any function that can return a notmuch_status_t can error,
-- So you might want to group these into a pcall.
--
-- A object type that ends with an s like threads is a
-- collection of thread. You can then use the normal lua
-- iterator syntax to go over it. The iterators are not stateless,
-- because no iterator in notmuch is stateless.

-- TODO: map notmuch_config_key_t to strings

local M = {}

local ffi = require "ffi"
local nm = ffi.load "notmuch"

--- @class notmuch.Db
--- @class notmuch.Query
--- @class notmuch.Messages
--- @class notmuch.Message
--- @class notmuch.Threads
--- @class notmuch.Thread
--- @class notmuch.Tags
--- @class notmuch.Directory
--- @class notmuch.Indexopts
--- @class notmuch.Filenames
--- @class notmuch.Properties

ffi.cdef [[
	typedef struct _notmuch_database notmuch_database_t;
	typedef struct {} notmuch_query_t;
	typedef struct {} notmuch_messages_t;
	typedef struct {} notmuch_message_t;
	typedef struct {} notmuch_threads_t;
	typedef struct {} notmuch_thread_t;
	typedef struct {} notmuch_tags_t;
	typedef struct {} notmuch_compact_status_cb_t;
	typedef struct {} notmuch_directory_t;
	typedef struct {} notmuch_indexopts_t;
	typedef struct {} notmuch_filenames_t;
	typedef struct {} notmuch_message_properties_t;
	typedef struct {} notmuch_config_list_t;
	typedef struct {} notmuch_config_values_t;
	typedef struct {} notmuch_config_pairs_t;
	typedef int notmuch_bool_t;
	typedef int notmuch_status_t;
	typedef int notmuch_database_mode_t;
	typedef long time_t;
	typedef int notmuch_query_syntax_t;
	typedef int notmuch_exclude_t;
	typedef enum {
		NOTMUCH_SORT_OLDEST_FIRST,
		NOTMUCH_SORT_NEWEST_FIRST,
		NOTMUCH_SORT_MESSAGE_ID,
		NOTMUCH_SORT_UNSORTED
	} notmuch_sort_t;
	typedef int notmuch_message_flag_t;
	typedef int notmuch_config_key_t;
	typedef int notmuch_decryption_policy_t;

	const char *
	notmuch_status_to_string (notmuch_status_t status);

	notmuch_status_t
	notmuch_database_create (const char *path, notmuch_database_t **database);

	notmuch_status_t
	notmuch_database_create_with_config (const char *database_path,
				 const char *config_path,
				 const char *profile,
				 notmuch_database_t **database,
				 char **error_message);

	notmuch_status_t
	notmuch_database_open_with_config (const char *database_path,
				notmuch_database_mode_t mode,
				const char *config_path,
				const char *profile,
				notmuch_database_t **database,
				char **error_message);

	notmuch_status_t
	notmuch_database_load_config (const char *database_path,
				const char *config_path,
				const char *profile,
				notmuch_database_t **database,
				char **error_message);

	notmuch_status_t
	notmuch_database_open (const char *path,
				notmuch_database_mode_t mode,
				notmuch_database_t **database);

	const char *
	notmuch_database_status_string (const notmuch_database_t *notmuch);

	notmuch_status_t
	notmuch_database_close (notmuch_database_t *database);

	notmuch_status_t
	notmuch_database_compact (const char *path,
				const char *backup_path,
				notmuch_compact_status_cb_t status_cb,
				void *closure);

	notmuch_status_t
	notmuch_database_compact_db (notmuch_database_t *database,
			    const char *backup_path,
			    notmuch_compact_status_cb_t status_cb,
			    void *closure);

	notmuch_status_t
	notmuch_database_destroy (notmuch_database_t *database);

	const char *
	notmuch_database_get_path (notmuch_database_t *database);

	unsigned int
	notmuch_database_get_version (notmuch_database_t *database);

	notmuch_bool_t
	notmuch_database_needs_upgrade (notmuch_database_t *database);

	notmuch_status_t
	notmuch_database_upgrade (notmuch_database_t *database,
				  void (*progress_notify)(void *closure,
							  double progress),
				  void *closure);

	notmuch_status_t
	notmuch_database_begin_atomic (notmuch_database_t *notmuch);

	notmuch_status_t
	notmuch_database_end_atomic (notmuch_database_t *notmuch);

	unsigned long
	notmuch_database_get_revision (notmuch_database_t *notmuch,
					   const char **uuid);

	notmuch_status_t
	notmuch_database_get_directory (notmuch_database_t *database,
					const char *path,
					notmuch_directory_t **directory);

	notmuch_status_t
	notmuch_database_index_file (notmuch_database_t *database,
					 const char *filename,
					 notmuch_indexopts_t *indexopts,
					 notmuch_message_t **message);

	notmuch_status_t
	notmuch_database_remove_message (notmuch_database_t *database,
					 const char *filename);

	notmuch_status_t
	notmuch_database_find_message (notmuch_database_t *database,
			       const char *message_id,
			       notmuch_message_t **message);

	notmuch_status_t
	notmuch_database_find_message_by_filename (notmuch_database_t *notmuch,
						   const char *filename,
						   notmuch_message_t **message);

	notmuch_tags_t *
	notmuch_database_get_all_tags (notmuch_database_t *db);

	notmuch_status_t
	notmuch_database_reopen (notmuch_database_t *db, notmuch_database_mode_t mode);

	notmuch_query_t *
	notmuch_query_create (notmuch_database_t *database,
              const char *query_string);

	notmuch_status_t
	notmuch_query_create_with_syntax (notmuch_database_t *database,
				  const char *query_string,
				  notmuch_query_syntax_t syntax,
				  notmuch_query_t **output);

	const char *
	notmuch_query_get_query_string (const notmuch_query_t *query);

	notmuch_database_t *
	notmuch_query_get_database (const notmuch_query_t *query);

	void
	notmuch_query_set_omit_excluded (notmuch_query_t *query,
					 notmuch_exclude_t omit_excluded);

	void
	notmuch_query_set_sort (notmuch_query_t *query, notmuch_sort_t sort);

	notmuch_sort_t
	notmuch_query_get_sort (const notmuch_query_t *query);

	notmuch_status_t
	notmuch_query_add_tag_exclude (notmuch_query_t *query, const char *tag);


	notmuch_status_t
	notmuch_query_search_threads (notmuch_query_t *query,
					  notmuch_threads_t **out);

	notmuch_status_t
	notmuch_query_search_messages (notmuch_query_t *query,
					   notmuch_messages_t **out);

	void
	notmuch_query_destroy (notmuch_query_t *query);

	notmuch_bool_t
	notmuch_threads_valid (notmuch_threads_t *threads);

	notmuch_thread_t *
	notmuch_threads_get (notmuch_threads_t *threads);

	void
	notmuch_threads_move_to_next (notmuch_threads_t *threads);

	void
	notmuch_threads_destroy (notmuch_threads_t *threads);

	notmuch_status_t
	notmuch_query_count_messages (notmuch_query_t *query, unsigned int *count);

	notmuch_status_t
	notmuch_query_count_threads (notmuch_query_t *query, unsigned *count);

	const char *
	notmuch_thread_get_thread_id (notmuch_thread_t *thread);

	int
	notmuch_thread_get_total_messages (notmuch_thread_t *thread);

	int
	notmuch_thread_get_total_files (notmuch_thread_t *thread);

	notmuch_messages_t *
	notmuch_thread_get_toplevel_messages (notmuch_thread_t *thread);

	notmuch_messages_t *
	notmuch_thread_get_messages (notmuch_thread_t *thread);

	int
	notmuch_thread_get_matched_messages (notmuch_thread_t *thread);

	const char *
	notmuch_thread_get_authors (notmuch_thread_t *thread);

	const char *
	notmuch_thread_get_subject (notmuch_thread_t *thread);

	time_t
	notmuch_thread_get_oldest_date (notmuch_thread_t *thread);

	time_t
	notmuch_thread_get_newest_date (notmuch_thread_t *thread);

	notmuch_tags_t *
	notmuch_thread_get_tags (notmuch_thread_t *thread);

	void
	notmuch_thread_destroy (notmuch_thread_t *thread);

	notmuch_bool_t
	notmuch_messages_valid (notmuch_messages_t *messages);

	notmuch_message_t *
	notmuch_messages_get (notmuch_messages_t *messages);

	void
	notmuch_messages_move_to_next (notmuch_messages_t *messages);

	void
	notmuch_messages_destroy (notmuch_messages_t *messages);

	notmuch_tags_t *
	notmuch_messages_collect_tags (notmuch_messages_t *messages);

	notmuch_database_t *
	notmuch_message_get_database (const notmuch_message_t *message);

	const char *
	notmuch_message_get_message_id (notmuch_message_t *message);

	const char *
	notmuch_message_get_thread_id (notmuch_message_t *message);

	notmuch_messages_t *
	notmuch_message_get_replies (notmuch_message_t *message);

	int
	notmuch_message_count_files (notmuch_message_t *message);

	const char *
	notmuch_message_get_filename (notmuch_message_t *message);

	notmuch_filenames_t *
	notmuch_message_get_filenames (notmuch_message_t *message);

	notmuch_status_t
	notmuch_message_reindex (notmuch_message_t *message,
				 notmuch_indexopts_t *indexopts);

	notmuch_status_t
	notmuch_message_get_flag_st (notmuch_message_t *message,
					 notmuch_message_flag_t flag,
					 notmuch_bool_t *is_set);

	void
	notmuch_message_set_flag (notmuch_message_t *message,
				  notmuch_message_flag_t flag, notmuch_bool_t value);

	time_t
	notmuch_message_get_date (notmuch_message_t *message);

	const char *
	notmuch_message_get_header (notmuch_message_t *message, const char *header);

	notmuch_tags_t *
	notmuch_message_get_tags (notmuch_message_t *message);

	notmuch_status_t
	notmuch_message_add_tag (notmuch_message_t *message, const char *tag);

	notmuch_status_t
	notmuch_message_remove_tag (notmuch_message_t *message, const char *tag);

	notmuch_status_t
	notmuch_message_remove_all_tags (notmuch_message_t *message);

	notmuch_status_t
	notmuch_message_maildir_flags_to_tags (notmuch_message_t *message);

	notmuch_status_t
	notmuch_message_has_maildir_flag_st (notmuch_message_t *message,
						 char flag,
						 notmuch_bool_t *is_set);

	notmuch_status_t
	notmuch_message_tags_to_maildir_flags (notmuch_message_t *message);

	notmuch_status_t
	notmuch_message_freeze (notmuch_message_t *message);

	notmuch_status_t
	notmuch_message_thaw (notmuch_message_t *message);

	void
	notmuch_message_destroy (notmuch_message_t *message);

	notmuch_status_t
	notmuch_message_get_property (notmuch_message_t *message, const char *key, const char **value);

	notmuch_status_t
	notmuch_message_add_property (notmuch_message_t *message, const char *key, const char *value);

	notmuch_status_t
	notmuch_message_remove_property (notmuch_message_t *message, const char *key, const char *value);

	notmuch_status_t
	notmuch_message_remove_all_properties (notmuch_message_t *message, const char *key);

	notmuch_status_t
	notmuch_message_remove_all_properties (notmuch_message_t *message, const char *key);

	notmuch_status_t
	notmuch_message_remove_all_properties_with_prefix (notmuch_message_t *message, const char *prefix);

	notmuch_message_properties_t *
	notmuch_message_get_properties (notmuch_message_t *message, const char *key, notmuch_bool_t exact);

	notmuch_status_t
	notmuch_message_count_properties (notmuch_message_t *message, const char *key, unsigned int *count);

	notmuch_bool_t
	notmuch_message_properties_valid (notmuch_message_properties_t *properties);

	void
	notmuch_message_properties_move_to_next (notmuch_message_properties_t *properties);

	const char *
	notmuch_message_properties_key (notmuch_message_properties_t *properties);

	const char *
	notmuch_message_properties_value (notmuch_message_properties_t *properties);

	void
	notmuch_message_properties_destroy (notmuch_message_properties_t *properties);

	notmuch_bool_t
	notmuch_tags_valid (notmuch_tags_t *tags);

	const char *
	notmuch_tags_get (notmuch_tags_t *tags);

	void
	notmuch_tags_move_to_next (notmuch_tags_t *tags);

	void
	notmuch_tags_destroy (notmuch_tags_t *tags);

	notmuch_status_t
	notmuch_directory_set_mtime (notmuch_directory_t *directory,
					 time_t mtime);

	time_t
	notmuch_directory_get_mtime (notmuch_directory_t *directory);

	notmuch_filenames_t *
	notmuch_directory_get_child_files (notmuch_directory_t *directory);

	notmuch_filenames_t *
	notmuch_directory_get_child_directories (notmuch_directory_t *directory);

	notmuch_status_t
	notmuch_directory_delete (notmuch_directory_t *directory);

	void
	notmuch_directory_destroy (notmuch_directory_t *directory);

	notmuch_bool_t
	notmuch_filenames_valid (notmuch_filenames_t *filenames);

	const char *
	notmuch_filenames_get (notmuch_filenames_t *filenames);

	void
	notmuch_filenames_move_to_next (notmuch_filenames_t *filenames);

	void
	notmuch_filenames_destroy (notmuch_filenames_t *filenames);

	notmuch_status_t
	notmuch_database_set_config (notmuch_database_t *db, const char *key, const char *value);

	notmuch_status_t
	notmuch_database_get_config (notmuch_database_t *db, const char *key, char **value);

	notmuch_status_t
	notmuch_database_get_config_list (notmuch_database_t *db, const char *prefix,
					  notmuch_config_list_t **out);

	notmuch_bool_t
	notmuch_config_list_valid (notmuch_config_list_t *config_list);

	const char *
	notmuch_config_list_key (notmuch_config_list_t *config_list);

	const char *
	notmuch_config_list_value (notmuch_config_list_t *config_list);

	void
	notmuch_config_list_move_to_next (notmuch_config_list_t *config_list);

	void
	notmuch_config_list_destroy (notmuch_config_list_t *config_list);

	const char *
	notmuch_config_get (notmuch_database_t *notmuch, notmuch_config_key_t key);

	notmuch_status_t
	notmuch_config_set (notmuch_database_t *notmuch, notmuch_config_key_t key, const char *val);

	notmuch_config_values_t *
	notmuch_config_get_values (notmuch_database_t *notmuch, notmuch_config_key_t key);

	notmuch_config_values_t *
	notmuch_config_get_values_string (notmuch_database_t *notmuch, const char *key);

	notmuch_bool_t
	notmuch_config_values_valid (notmuch_config_values_t *values);

	const char *
	notmuch_config_values_get (notmuch_config_values_t *values);

	void
	notmuch_config_values_move_to_next (notmuch_config_values_t *values);

	void
	notmuch_config_values_start (notmuch_config_values_t *values);

	void
	notmuch_config_values_destroy (notmuch_config_values_t *values);

	notmuch_config_pairs_t *
	notmuch_config_get_pairs (notmuch_database_t *notmuch,
				  const char *prefix);

	notmuch_bool_t
	notmuch_config_pairs_valid (notmuch_config_pairs_t *pairs);

	void
	notmuch_config_pairs_move_to_next (notmuch_config_pairs_t *pairs);

	const char *
	notmuch_config_pairs_key (notmuch_config_pairs_t *pairs);

	const char *
	notmuch_config_pairs_value (notmuch_config_pairs_t *pairs);

	void
	notmuch_config_pairs_destroy (notmuch_config_pairs_t *pairs);

	notmuch_status_t
	notmuch_config_get_bool (notmuch_database_t *notmuch,
				 notmuch_config_key_t key,
				 notmuch_bool_t *val);

	const char *
	notmuch_config_path (notmuch_database_t *notmuch);

	notmuch_indexopts_t *
	notmuch_database_get_default_indexopts (notmuch_database_t *db);

	notmuch_status_t
	notmuch_indexopts_set_decrypt_policy (notmuch_indexopts_t *indexopts,
						  notmuch_decryption_policy_t decrypt_policy);

	notmuch_decryption_policy_t
	notmuch_indexopts_get_decrypt_policy (const notmuch_indexopts_t *indexopts);

	void
	notmuch_indexopts_destroy (notmuch_indexopts_t *options);

	notmuch_bool_t
	notmuch_built_with (const char *name);
]]

local function safestr(str)
  if str ~= nil then
    return ffi.string(str)
  end
end

local function stat(status)
  return safestr(nm.notmuch_status_to_string(status))
end

local function result(res)
  if res ~= 0 then
    local fun = debug.getinfo(2).name
    local err_str = string.format("Notmuch %s return error: %s", fun, stat(res))
    error(err_str)
  end
end

local function result_str(res, err)
  if res ~= 0 then
    local fun = debug.getinfo(2).name
    local err_str = string.format("Notmuch %s return error: %s '%s'", fun, stat(res), safestr(err[0]))
    error(err_str)
  end
end

--- @param path string path to the new database
--- @param destroy? boolean
--- @return notmuch.Db
function M.db_create(path, destroy)
  local db = ffi.new "notmuch_database_t*[1]"
  local res = nm.notmuch_database_create(path, db)
  result(res)
  if destroy then
    return ffi.gc(db[0], nm.notmuch_database_destroy)
  end
  return ffi.gc(db[0], nm.notmuch_database_close)
end

--- @param path string path to the new database
--- @param conf_path string path to the config
--- @param profile string name of the profile in the config
--- @param destroy? boolean
--- @return notmuch.Db
function M.db_create_with_config(path, conf_path, profile, destroy)
  local db = ffi.new "notmuch_database_t*[1]"
  local err = ffi.new "char*[1]"
  local res = nm.notmuch_database_create_with_config(path, conf_path, profile, db, err)
  result_str(res, err)
  if destroy then
    return ffi.gc(db[0], nm.notmuch_database_destroy)
  end
  return ffi.gc(db[0], nm.notmuch_database_close)
end

--- @param path string directory where the Notmuch database is stored.
--- @param mode number Read/write mode. 0 for r and 1 for rw.
--- @param destroy? boolean
--- @return notmuch.Db
function M.db_open(path, mode, destroy)
  mode = mode or 0
  local db = ffi.new "notmuch_database_t*[1]"
  local res = nm.notmuch_database_open(path, mode, db)
  result(res)
  if destroy then
    return ffi.gc(db[0], nm.notmuch_database_destroy)
  end
  return ffi.gc(db[0], nm.notmuch_database_close)
end

--- @param path string path to the database
--- @param mode number Read/write mode. 0 for r and 1 for rw.
--- @param conf_path string path to the config
--- @param profile string name of the profile in the config
--- @param destroy? boolean
--- @return notmuch.Db
function M.db_open_with_config(path, mode, conf_path, profile, destroy)
  local db = ffi.new "notmuch_database_t*[1]"
  local err = ffi.new "char*[1]"
  local res = nm.notmuch_database_open_with_config(path, mode, conf_path, profile, db, err)
  result_str(res, err)
  if destroy then
    return ffi.gc(db[0], nm.notmuch_database_destroy)
  end
  return ffi.gc(db[0], nm.notmuch_database_close)
end

--- If you want to handle closing/destroying the db manually, because using the garbage collector
--- to close the db isn't to your satisfaction.
--- @param path string path to the database
--- @param mode number Read/write mode. 0 for r and 1 for rw.
--- @param conf_path string path to the config
--- @param profile string name of the profile in the config
--- @return notmuch.Db
function M.db_open_with_config_raw(path, mode, conf_path, profile)
  local db = ffi.new "notmuch_database_t*[1]"
  local err = ffi.new "char*[1]"
  local res = nm.notmuch_database_open_with_config(path, mode, conf_path, profile, db, err)
  result_str(res, err)
  return db[0]
end

--- @param path string path to the new database
--- @param conf_path string path to the config
--- @param profile string name of the profile in the config
--- @param destroy? boolean
--- @return notmuch.Db
function M.db_load_config(path, conf_path, profile, destroy)
  local db = ffi.new "notmuch_database_t*[1]"
  local err = ffi.new "char*[1]"
  local res = nm.notmuch_database_load_config(path, conf_path, profile, db, err)
  result_str(res, err)
  if destroy then
    return ffi.gc(db[0], nm.notmuch_database_destroy)
  end
  return ffi.gc(db[0], nm.notmuch_database_close)
end

--- @param db notmuch.Db
--- @return string
function M.db_status_string(db)
  return ffi.string(nm.notmuch_database_status_string(db))
end

--- @param db notmuch.Db
function M.db_close(db)
  local res = nm.notmuch_database_close(db)
  result(res)
end

function M.db_destroy(db)
  local res = nm.notmuch_database_destroy(db)
  result(res)
end

--- @param path string path to db
--- @param backup string where to backup
--- @param fun fun(message: string, arg: any)
--- @param arg any agrement passed to fun
function M.db_compact(path, backup, fun, arg)
  assert(type(arg) == "table" or type(arg) == "nil", "Arg needs to be a table or nil")
  local function cfun(cstr, closure)
    local str = ffi.string(cstr)
    fun(str, closure)
  end
  return nm.notmuch_database_compact(path, backup, cfun, arg)
end

--- @param db notmuch.Db
--- @param backup string where to backup
--- @param fun fun(message: string, arg: any)
--- @param arg any agrement passed to fun
function M.db_compact_db(db, backup, fun, arg)
  local function cfun(cstr, closure)
    local str = ffi.string(cstr)
    fun(str, closure)
  end
  return nm.notmuch_database_compact_db(db, backup, cfun, arg)
end

--- @param db notmuch.Db
--- @return string
function M.db_get_path(db)
  return safestr(nm.notmuch_database_get_path(db))
end

--- @param db notmuch.Db
--- @return number
function M.db_get_version(db)
  return nm.notmuch_database_get_version(db)
end

--- @param db notmuch.Db
--- @return boolean
function M.db_needs_upgrade(db)
  return nm.notmuch_database_needs_upgrade(db) ~= 0
end

--- @param db notmuch.Db
--- @param progress_func fun(closure: any, progress: any)
--- @param arg any
function M.db_upgrade(db, progress_func, arg)
  local function cfun(closure, num)
    progress_func(closure, num)
  end
  result(nm.notmuch_database_upgrade(db, cfun, arg))
end

--- @param db notmuch.Db
function M.db_atomic_begin(db)
  result(nm.notmuch_database_begin_atomic(db))
end

--- @param db notmuch.Db
function M.db_atomic_end(db)
  result(nm.notmuch_database_end_atomic(db))
end

--- @param db notmuch.Db
--- @return string
function M.get_revision(db)
  local uuid = ffi.new "const char*[1]"
  local rev = nm.notmuch_database_get_revision(db, uuid)
  return rev, ffi.string(uuid)
end

--- @param db notmuch.Db
--- @param path string
--- @return notmuch.Directory
function M.db_get_directory(db, path)
  local db_dir = ffi.new "notmuch_directory_t*[1]"
  local res = nm.notmuch_database_get_directory(db, path, db_dir)
  result(res)
  return ffi.gc(db_dir[0], nm.notmuch_directory_destroy)
end

--- @param db notmuch.Db
--- @param filename string
--- @param opts notmuch.Indexopts?
--- @return notmuch.Message
function M.db_index_file(db, filename, opts)
  local message = ffi.new "notmuch_message_t*[1]"
  opts = opts or nm.notmuch_database_get_default_indexopts(db)
  local res = nm.notmuch_database_index_file(db, filename, opts, message)
  result(res)
  return ffi.gc(message[0], nm.notmuch_message_destroy)
end

--- @param db notmuch.Db
--- @param filename string
function M.db_remove_message(db, filename)
  result(nm.notmuch_database_remove_message(db, filename))
end

--- @param db notmuch.Db
--- @param mid string message id
--- @return notmuch.Message
function M.db_find_message(db, mid)
  local message = ffi.new "notmuch_message_t*[1]"
  local res = nm.notmuch_database_find_message(db, mid, message)
  result(res)
  return ffi.gc(message[0], nm.notmuch_message_destroy)
end

--- @param db notmuch.Db
--- @param filename string
--- @return notmuch.Message
function M.db_find_message_by_filename(db, filename)
  local message = ffi.new "notmuch_message_t*[1]"
  local res = nm.notmuch_database_find_message_by_filename(db, filename, message)
  result(res)
  return ffi.gc(message[0], nm.notmuch_message_destroy)
end

local function tag_iterator(tags)
  return function()
    if nm.notmuch_tags_valid(tags) == 1 then
      local tag = safestr(nm.notmuch_tags_get(tags))
      nm.notmuch_tags_move_to_next(tags)
      return tag
    end
  end
end

local function thread_iterator(threads)
  return function()
    if nm.notmuch_threads_valid(threads) == 1 then
      local thread = nm.notmuch_threads_get(threads)
      nm.notmuch_threads_move_to_next(threads)
      return thread
    end
  end
end

local function message_iterator(messages)
  return function()
    if nm.notmuch_messages_valid(messages) == 1 then
      local message = nm.notmuch_messages_get(messages)
      nm.notmuch_messages_move_to_next(messages)
      return message
    end
  end
end

local function filename_iterator(filenames)
  return function()
    if nm.notmuch_filenames_valid(filenames) == 1 then
      local filename = safestr(nm.notmuch_filenames_get(filenames))
      nm.notmuch_filenames_move_to_next(filenames)
      return filename
    end
  end
end

local function pair_iterator(pairs)
  return function()
    if nm.notmuch_config_pairs_valid(pairs) == 1 then
      local key = safestr(nm.notmuch_config_pairs_key(pairs))
      local value = safestr(nm.notmuch_config_pairs_value(pairs))
      nm.notmuch_config_pairs_move_to_next(pairs)
      return key, value
    end
  end
end

local function property_iterator(properties)
  return function()
    if nm.notmuch_message_properties_valid(properties) == 1 then
      local key = safestr(nm.notmuch_message_properties_key(properties))
      local value = safestr(nm.notmuch_message_properties_value(properties))
      nm.notmuch_message_properties_move_to_next(properties)
      return key, value
    end
  end
end

local function config_list_iterator(properties)
  return function()
    if nm.notmuch_config_list_valid(properties) ~= 0 then
      local key = safestr(nm.notmuch_config_list_key(properties))
      local value = safestr(nm.notmuch_config_list_value(properties))
      nm.notmuch_config_list_move_to_next(properties)
      return key, value
    end
  end
end

local function value_iterator(values)
  return function()
    if nm.notmuch_config_values_valid(values) == 1 then
      local value = nm.notmuch_config_values_get(values)
      nm.notmuch_config_values_move_to_next(values)
      return safestr(value)
    end
  end
end

--- @param db notmuch.Db
--- @return fun():string
function M.db_get_all_tags(db)
  local tags = ffi.gc(nm.notmuch_database_get_all_tags(db), nm.notmuch_tags_destroy)
  return tag_iterator(tags)
end

--- @param db notmuch.Db
--- @param mode number Read/write mode. 0 for r and 1 for rw.
function M.db_reopen(db, mode)
  result(nm.notmuch_database_reopen(db, mode))
end

--- @param db notmuch.Db
--- @param query_string string
--- @return notmuch.Query
function M.create_query(db, query_string)
  local q = nm.notmuch_query_create(db, query_string)
  return ffi.gc(q, nm.notmuch_query_destroy)
end

--- @param db notmuch.Db
--- @param query_string string
--- @syntax syntax number 0 for xpian, 1 for sexp
--- @return notmuch.Query
function M.create_query_with_syntax(db, query_string, syntax)
  local query = ffi.new "notmuch_query_t*[1]"
  local res = nm.notmuch_query_create_with_syntax(db, query_string, syntax, query)
  result(res)
  return ffi.gc(query[0], nm.notmuch_query_destroy)
end

--- @param query notmuch.Query
--- @return string
function M.query_get_string(query)
  return ffi.string(nm.notmuch_query_get_query_string(query))
end

--- @param query notmuch.Query
--- @return notmuch.Db
function M.query_get_db(query)
  return nm.notmuch_query_get_database(query)
end

--- @param query notmuch.Query
--- @param exclude string (flag, true, false, all)
function M.query_set_omit(query, exclude)
  local flag
  if exclude == "flag" then
    flag = 0
  elseif exclude == "true" then
    flag = 1
  elseif exclude == "false" then
    flag = 2
  elseif exclude == "all" then
    flag = 3
  else
    error("query_set_omit got a bad flag")
  end

  nm.notmuch_query_set_omit_excluded(query, flag)
end

local sorttbl = {
  oldest = nm.NOTMUCH_SORT_OLDEST_FIRST,
  newest = nm.NOTMUCH_SORT_NEWEST_FIRST,
  ["message-id"] =nm.NOTMUCH_SORT_MESSAGE_ID,
  unsorted = nm.NOTMUCH_SORT_UNSORTED,
}
--- @param query notmuch.Query
--- @param sort string (oldest, newest, message-id, unsort)
function M.query_set_sort(query, sort)
  local sortint
  if sort == "oldest" then
    sortint = nm.NOTMUCH_SORT_OLDEST_FIRST
  elseif sort == "newest" then
    sortint = nm.NOTMUCH_SORT_NEWEST_FIRST
  elseif sort == "message-id" then
    sortint = nm.NOTMUCH_SORT_MESSAGE_ID
  elseif sort == nil or sort == "unsorted" then
    sortint = nm.NOTMUCH_SORT_UNSORTED
  else
    error("Can't find sorting algorithm")
  end
  nm.notmuch_query_set_sort(query, sortint)
end

--- @param query notmuch.Query
--- @return string
function M.query_get_sort(query)
  local sort = nm.notmuch_query_get_sort(query)
  if sort == nm.NOTMUCH_SORT_OLDEST_FIRST then
    return "oldest"
  elseif sort == nm.NOTMUCH_SORT_NEWEST_FIRST then
    return "newest"
  elseif sort == nm.NOTMUCH_SORT_MESSAGE_ID then
    return "message-id"
  elseif sort == nm.NOTMUCH_SORT_UNSORTED then
    return "unsorted"
  end
end

--- @param query notmuch.Query
--- @param tag string tag to exclude
function M.query_add_tag_exclude(query, tag)
  result(nm.notmuch_query_add_tag_exclude(query, tag))
end

--- @param query notmuch.Query
--- @return fun():notmuch.Thread
function M.query_get_threads(query)
  local threads = ffi.new "notmuch_threads_t*[1]"
  local res = nm.notmuch_query_search_threads(query, threads)
  result(res)
  local tthreads = ffi.gc(threads[0], nm.notmuch_threads_destroy)
  return thread_iterator(tthreads)
end

--- @param query notmuch.Query
--- @return fun():notmuch.Message
function M.query_get_messages(query)
  local messages = ffi.new "notmuch_messages_t*[1]"
  local res = nm.notmuch_query_search_messages(query, messages)
  result(res)
  local mmessages = ffi.gc(messages[0], nm.notmuch_messages_destroy)
  return message_iterator(mmessages)
end

--- @param query notmuch.Query
--- @return number
function M.query_count_threads(query)
  local count = ffi.new "unsigned int[1]"
  local res = nm.notmuch_query_count_threads(query, count)
  result(res)
  return count[0]
end

--- @param query notmuch.Query
--- @return number
function M.query_count_messages(query)
  local count = ffi.new "unsigned int[1]"
  local res = nm.notmuch_query_count_messages(query, count)
  result(res)
  return count[0]
end

--- @param thread notmuch.Thread
--- @return string
function M.thread_get_id(thread)
  return ffi.string(nm.notmuch_thread_get_thread_id(thread))
end

--- @param thread notmuch.Thread
--- @return number
function M.thread_get_total_messages(thread)
  return nm.notmuch_thread_get_total_messages(thread)
end

--- @param thread notmuch.Thread
--- @return number
function M.thread_get_total_files(thread)
  return nm.notmuch_thread_get_total_files(thread)
end

--- @param thread notmuch.Thread
--- @return fun():notmuch.Message
function M.thread_get_toplevel_messages(thread)
  local messages = ffi.gc(nm.notmuch_thread_get_toplevel_messages(thread), nm.notmuch_messages_destroy)
  return message_iterator(messages)
end

--- @param thread notmuch.Thread
--- @return fun():notmuch.Message
function M.thread_get_messages(thread)
  local messages = ffi.gc(nm.notmuch_thread_get_messages(thread), nm.notmuch_messages_destroy)
  return message_iterator(messages)
end

--- @param thread notmuch.Thread
--- @return number
function M.thread_get_matched_messages(thread)
  return nm.notmuch_thread_get_matched_messages(thread)
end

--- @param thread notmuch.Thread
--- @return string
function M.thread_get_authors(thread)
  return ffi.string(nm.notmuch_thread_get_authors(thread))
end

--- @param thread notmuch.Thread
--- @return string
function M.thread_get_subject(thread)
  return safestr(nm.notmuch_thread_get_subject(thread))
end

--- @param thread notmuch.Thread
--- @return number
function M.thread_get_oldest_date(thread)
  return tonumber(nm.notmuch_thread_get_oldest_date(thread))
end

--- @param thread notmuch.Thread
--- @return number
function M.thread_get_newest_date(thread)
  return tonumber(nm.notmuch_thread_get_newest_date(thread))
end

--- @param thread notmuch.Thread
--- @return fun():string
function M.thread_get_tags(thread)
  local tags = ffi.gc(nm.notmuch_thread_get_tags(thread), nm.notmuch_tags_destroy)
  return tag_iterator(tags)
end

--- @param query notmuch.Query
--- @return fun():string
function M.messages_collect_tags(query)
  local messages = ffi.new "notmuch_messages_t*[1]"
  local res = nm.notmuch_query_search_messages(query, messages)
  assert(res == 0, "Error retriving messages, err= " .. res)
  local function cleanup(tags)
    nm.notmuch_messages_destroy(messages[0])
    nm.notmuch_tags_destroy(tags)
  end
  local tags = ffi.gc(nm.notmuch_messages_collect_tags(messages[0]), cleanup)
  return tag_iterator(tags)
end

--- @param message notmuch.Message
--- @return object db
function M.message_get_db(message)
  return nm.notmuch_message_get_database(message)
end

--- @param message notmuch.Message
--- @return string id
function M.message_get_id(message)
  return ffi.string(nm.notmuch_message_get_message_id(message))
end

--- @param message notmuch.Message
--- @return string id
function M.message_get_thread_id(message)
  return ffi.string(nm.notmuch_message_get_thread_id(message))
end

--- @param message notmuch.Message
--- @return fun():notmuch.Message
function M.message_get_replies(message)
  local messages = nm.notmuch_message_get_replies(message)
  return message_iterator(messages)
end

--- @param message notmuch.Message
--- @return number
function M.message_count_files(message)
  return nm.notmuch_message_count_files(message)
end

--- @param message notmuch.Message
--- @return string
function M.message_get_filename(message)
  local filename = nm.notmuch_message_get_filename(message)
  return safestr(filename)
end

--- @param message gmime.Message
--- @return fun():string
function M.message_get_filenames(message)
  local filenames = ffi.gc(nm.notmuch_message_get_filenames(message), nm.notmuch_filenames_destroy)
  return filename_iterator(filenames)
end

--- @param message notmuch.Message
--- @param indexopts? notmuch.Indexopts
function M.message_reindex(message, indexopts)
  local db = nm.notmuch_message_get_database(message)
  indexopts = indexopts or nm.notmuch_database_get_default_indexopts(db)
  result(nm.notmuch_message_reindex(message, indexopts))
end

--- @param message notmuch.Message
--- @param flag number
--- @return boolean flag
function M.message_get_flag(message, flag)
  local is_set = ffi.new "notmuch_bool_t[1]"
  local res = nm.notmuch_message_get_flag_st(message, flag, is_set)
  result(res)
  return is_set[0] ~= 0
end

--- @param message notmuch.Message
--- @param flag number
--- @param value boolean
function M.message_set_flag(message, flag, value)
  nm.notmuch_message_set_flag(message, flag, value)
end

--- @param message notmuch.Message
--- @return number
function M.message_get_date(message)
  return tonumber(nm.notmuch_message_get_date(message))
end

--- @param message notmuch.Message
--- @param header string
--- @return string
function M.message_get_header(message, header)
  return safestr(nm.notmuch_message_get_header(message, header))
end

--- @param message notmuch.Message
--- @return fun(): string
function M.message_get_tags(message)
  local tags = ffi.gc(nm.notmuch_message_get_tags(message), nm.notmuch_tags_destroy)
  return tag_iterator(tags)
end

--- @param message notmuch.Message
--- @param tag string
function M.message_add_tag(message, tag)
  result(nm.notmuch_message_add_tag(message, tag))
end

--- @param message notmuch.Message
--- @param tag string
function M.message_remove_tag(message, tag)
  result(nm.notmuch_message_remove_tag(message, tag))
end

--- @param message notmuch.Message
function M.message_remove_all_tags(message)
  result(nm.notmuch_message_remove_all_tags(message))
end

--- @param message notmuch.Message
function M.message_maildir_flags_to_tags(message)
  result(nm.notmuch_message_maildir_flags_to_tags(message))
end

--- @param message notmuch.Message
--- @param flag string
--- @return boolean
function M.message_has_maildir_flag(message, flag)
  local is_set = ffi.new "notmuch_bool_t[1]"
  local res = nm.notmuch_message_has_maildir_flag_st(message, flag, is_set)
  result(res)
  return is_set[0] ~= 0
end

--- @param message notmuch.Message
function M.message_tags_to_maildir_flags(message)
  result(nm.notmuch_message_tags_to_maildir_flags(message))
end

--- @param message notmuch.Message
function M.message_freeze(message)
  result(nm.notmuch_message_freeze(message))
end

--- @param message notmuch.Message
function M.message_thaw(message)
  result(nm.notmuch_message_thaw(message))
end

--- @param message notmuch.Message
--- @param key string
--- @return string
function M.message_get_property(message, key)
  local value = ffi.new "char *[1]"
  local res = nm.notmuch_message_get_property(message, key, value)
  result(res)
  return safestr(value[0])
end

--- @param message notmuch.Message
--- @param key string
--- @param value string
function M.message_add_property(message, key, value)
  result(nm.notmuch_message_add_property(message, key, value))
end

--- @param message notmuch.Message
--- @param key string
--- @param value string
function M.message_remove_properety(message, key, value)
  result(nm.notmuch_message_remove_property(message, key, value))
end

--- @param message notmuch.Message
--- @param key string
function M.message_remove_all_properties(message, key)
  result(nm.notmuch_message_remove_all_properties(message, key))
end

--- @param message notmuch.Message
--- @param prefix string
function M.message_remove_all_properties_with_prefix(message, prefix)
  result(nm.notmuch_message_remove_all_properties_with_prefix(message, prefix))
end

--- @param message notmuch.Message
--- @param key string
--- @param exact boolean
--- @return fun(): string, string
function M.message_get_properties(message, key, exact)
  local it = ffi.gc(nm.notmuch_message_get_properties(message, key, exact), nm.notmuch_message_properties_destroy)
  return property_iterator(it)
end

--- @param message notmuch.Message
--- @param key string
--- @return number
function M.message_count_properties(message, key)
  local count = ffi.new "unsigned int[1]"
  local ret = nm.notmuch_message_count_properties(message, key, count)
  result(ret)
  return tonumber(count[0])
end

--- @param directory notmuch.Directory
--- @param time object
function M.directory_set_mtime(directory, time)
  result(nm.notmuch_directory_set_mtime(directory, time))
end

--- @param directory notmuch.Directory
--- @preturn time object
function M.directory_get_mtime(directory)
  return nm.notmuch_directory_get_mtime(directory)
end

--- @param directory notmuch.Directory
--- @return notmuch.Filenames
function M.directry_get_child_files(directory)
  local filenames = ffi.gc(nm.notmuch_directory_get_child_files(directory), nm.notmuch_filenames_destroy)
  return filename_iterator(filenames)
end

--- @param directory notmuch.Directory
--- @return notmuch.Filenames
function M.directory_get_child_directories(directory)
  local filenames = ffi.gc(nm.notmuch_directory_get_child_directories(directory), nm.notmuch_filenames_destroy)
  return filename_iterator(filenames)
end

--- @param directory notmuch.Directory
function M.directory_delete(directory)
  result(nm.notmuch_directory_delete(directory))
end

--- @param db notmuch.Db
--- @param key string
--- @param value string
function M.db_set_conf(db, key, value)
  result(nm.notmuch_database_set_config(db, key, value))
end

--- @param db notmuch.Db
--- @param key string
--- @return string value
function M.db_get_conf(db, key)
  local value = ffi.new("char*[1]")
  local res = nm.notmuch_database_get_config(db, key, value)
  result(res)
  return safestr(value[0])
end

--- @param db notmuch.Db
--- @param prefix string
--- @return fun():string
function M.db_get_conf_list(db, prefix)
  local list = ffi.new "notmuch_config_list_t*[1]"
  local res = nm.notmuch_database_get_config_list(db, prefix, list)
  result(res)
  local llist = ffi.gc(list[0], nm.notmuch_config_list_destroy)
  return config_list_iterator(llist)
end

--- @param db notmuch.Db
--- @param key object
--- @return string
function M.config_get(db, key)
  return safestr(nm.notmuch_config_get(db, key))
end

--- @param db notmuch.Db
--- @param key object
--- @param value string
function M.config_set(db, key, value)
  result(nm.notmuch_config_set(db, key, value))
end

--- @param db notmuch.Db
--- @param key string
--- @return fun():string
function M.config_get_values(db, key)
  local values = ffi.gc(nm.notmuch_config_get_values(db, key), nm.notmuch_config_values_destroy)
  return value_iterator(values)
end

--- @param db notmuch.Db
--- @param key string
--- @return fun():string
function M.config_get_values_string(db, key)
  local values = ffi.gc(nm.notmuch_config_get_values_string(db, key), nm.notmuch_config_values_destroy)
  return value_iterator(values)
end
--- @param db notmuch.Db
--- @param prefix string
--- @return fun():string, string
function M.config_get_pairs(db, prefix)
  local pairs = ffi.gc(nm.notmuch_config_get_pairs(db, prefix), nm.notmuch_config_pairs_destroy)
  return pair_iterator(pairs)
end

--- @param db notmuch.Db
--- @param key object
--- @return boolean
function M.config_get_bool(db, key)
  local value = ffi.new "notmuch_bool_t*[1]"
  local res = nm.notmuch_config_get_bool(db, key, value)
  result(res)
  return value[0] ~= 0
end

--- @param db notmuch.Db
--- @return string
function M.config_path(db)
  return safestr(nm.notmuch_config_path(db))
end

--- @param db notmuch.Db
--- @return object
function M.db_get_default_indexopts(db)
  return ffi.gc(nm.notmuch_database_get_default_indexopts(db), nm.notmuch_indexopts_destroy)
end

--- @param indexopts object
--- @param decrypt_pol string (false, true, auto, nostash)
function M.indexopts_set_decrypt_policy(indexopts, decrypt_pol)
  local decrypt = 0
  if decrypt_pol == "false" then
    decrypt = 0
  elseif decrypt_pol == "true" then
    decrypt = 1
  elseif decrypt_pol == "auto" then
    decrypt = 2
  elseif decrypt_pol == "nostash" then
    decrypt = 3
  end
  result(nm.notmuch_indexopts_set_decrypt_policy(indexopts, decrypt))
end

--- @param indexopts object
--- @return number decryption_policy
function M.indexopts_get_decrypt_policy(indexopts)
  return nm.notmuch_indexopts_get_decrypt_policy(indexopts)
end

--- @param name string
--- @return boolean
function M.built_with(name)
  return nm.notmuch_built_with(name)
end

return M
