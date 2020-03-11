<?php
/*
| For additional options see
| https://github.com/octobercms/october/blob/master/config/cms.php
*/

return [
    'activeTheme' => env('CMS_ACTIVE_THEME', 'demo'),
    'edgeUpdates' => env('CMS_EDGE_UPDATES', false),
    'backendUri' => env('CMS_BACKEND_URI', 'backend'),
    'backendForceSecure' => env('CMS_BACKEND_FORCE_SECURE', false),
    'backendTimezone' => env('TZ', 'UTC'),
    'backendSkin' => env('CMS_BACKEND_SKIN', 'Backend\Skins\Standard'),
    'disableCoreUpdates' => env('CMS_DISABLE_CORE_UPDATES', true),
    'linkPolicy' => env('CMS_LINK_POLICY', 'detect'),
    'databaseTemplates' => env('CMS_DATABASE_TEMPLATES', false),
    'defaultMask' => [
        'file' => env('CMS_DEFAULT_MASK_FILE', '664'),
        'folder' =>  env('CMS_DEFAULT_MASK_FOLDER', '775'),
    ],
];
