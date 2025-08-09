<?php
/* phpMyAdmin configuration for large file uploads */

$i = 0;

/* Server: MySQL */
$i++;
$cfg['Servers'][$i]['verbose'] = 'MySQL';
$cfg['Servers'][$i]['host'] = 'mysql';
$cfg['Servers'][$i]['port'] = 3306;
$cfg['Servers'][$i]['socket'] = '';
$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['Servers'][$i]['user'] = '';
$cfg['Servers'][$i]['password'] = '';

/* Global settings */
$cfg['blowfish_secret'] = 'H2OxcGXxflSd8JwrwVlh6KW6s2rER63j';

/* Upload settings for large files */
$cfg['UploadDir'] = '';
$cfg['SaveDir'] = '';
$cfg['MaxFileSize'] = '20G';

/* Import settings */
$cfg['Import']['memory_limit'] = '512M';
$cfg['Import']['upload_time_limit'] = 3600;

/* Export settings */
$cfg['Export']['memory_limit'] = '512M';
$cfg['Export']['time_limit'] = 3600;

/* Other settings */
$cfg['DefaultLang'] = 'ja';
$cfg['ServerDefault'] = 1;
$cfg['CharEditing'] = 'textarea';
$cfg['NavigationTreeEnableGrouping'] = false;