<?php
$config['database']['type'] = 'postgres';
$config['database']['table_prefix'] = 'mybb_';
$config['database']['database'] = 'mybb';

$config['database']['hostname'] = 'DB_HOST';
$config['database']['username'] = 'DB_USER';
$config['database']['password'] = 'DB_PASS';

$config['admin_dir'] = 'admin';
$config['hide_admin_links'] = 0;
$config['cache_store'] = 'db';
$config['memcache']['host'] = 'localhost';
$config['memcache']['port'] = 11211;
$config['super_admins'] = '1';
$config['database']['encoding'] = 'utf8';
$config['log_pruning'] = array(
  'admin_logs' => 365,
  'mod_logs' => 365,
  'task_logs' => 30,
  'mail_logs' => 180,
  'user_mail_logs' => 180,
  'promotion_logs' => 180
);
$config['secret_pin'] = '';
