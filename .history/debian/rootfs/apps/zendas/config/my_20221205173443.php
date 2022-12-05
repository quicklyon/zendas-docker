<?php
$config->installed       = true;
$config->debug           = false;
$config->requestType     = 'PATH_INFO';
$config->timezone        = 'Asia/Shanghai';
$config->db->host        = getenv('MYSQL_HOST');
$config->db->port        = getenv('MYSQL_PORT');
$config->db->name        = getenv('MYSQL_DB');
$config->db->user        = getenv('MYSQL_USER');
$config->db->encoding    = 'UTF8';
$config->db->password    = getenv('MYSQL_PASSWORD');
$config->db->prefix      = 'zd_';
$config->webRoot         = getWebRoot();
$config->default->lang   = 'zh-cn';
