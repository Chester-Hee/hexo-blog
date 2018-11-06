---
title: PHP源码阅读-SAPI
author: helingfeng
tags: []
categories:
  - PHP源码分析
translate_title: php-source-code-reading-sapi
date: 2018-04-02 15:42:00
---
开始之前，先克隆一份源代码：

GitHub下载->https://github.com/helingfeng/php-src

#### 源码的目录结构


![upload successful](/images/pasted-8.png)

- root根目录下，包含项目的说明文件以及设计方案，大部分文件是必读的。

- build顾名思义，放置一些和源码编译相关的文件，比如编译前脚本配置、环境监测等。

- ext官方扩展，包含了绝大数PHP函数的定义和实现，包括date、pdo、ftp、curl等。


![upload successful](/images/pasted-9.png)

- main 放置PHP核心文件，主要实现PHP的基础设施，这里和Zend engine不一样，Zend engine主要完成最核心的语言运行环境。

- Zend 放置Zend engine实现文件，包含脚本语法解析，扩展机制的实现等。

- pear PHP的扩展与应用仓库

- sapi 包含多种服务器的抽象层代码，例如apache的mod_php、cgi、fcgi以及fpm等接口。

- TSRM（Thread Safe Resource Manager） php的线程安全是构建在TSRM库之上的。

- tests php的测试脚本集合，包含各个模块功能的测试文件。

- win32 包含windows平台下的相关实现，比如socket的实现在windows与*Nix平台就不太相同，同时包含了在windows下编译php的相关脚本。

#### php架构图


![upload successful](/images/pasted-10.png)

从架构图中，很清楚看出SAPI（Server Application Programming Interface）应用编程接口，是非常重要的东东。

今天，拿最简单的CGI接口来学习SAPI。

> 先百度百科一下什么是CGI：Common Gateway Interface 是WWW技术中最重要的技术之一，有着不可替代的重要地位。CGI是外部应用程序（CGI程序）与Web服务器之间的接口标准，是在CGI程序和Web服务器之间传递信息的规程。CGI规范允许Web服务器执行外部程序，并将它们的输出发送给Web浏览器，CGI将Web的一组简单的静态超媒体文档变成一个完整的新的交互式媒体。

**脚本执行的开始都是以SAPI接口实现开始的。只是不同的SAPI接口实现会完成他们特定的工作， 例如Apache的mod_php SAPI实现需要初始化从Apache获取的一些信息，在输出内容是将内容返回给Apache， 其他的SAPI实现也类似。**

以CGI为例了解一下源码结构：


![upload successful](/images/pasted-12.png)

cgi_main.c

定义SAPI：

```
/* {{{ sapi_module_struct cgi_sapi_module
 */
static sapi_module_struct cgi_sapi_module = {
    "cgi-fcgi",                        /* name */
    "CGI/FastCGI",                    /* pretty name */

    php_cgi_startup,                /* startup */
    php_module_shutdown_wrapper,    /* shutdown */

    sapi_cgi_activate,                /* activate */
    sapi_cgi_deactivate,            /* deactivate */

    sapi_cgi_ub_write,                /* unbuffered write */
    sapi_cgi_flush,                    /* flush */
    NULL,                            /* get uid */
    sapi_cgi_getenv,                /* getenv */

    php_error,                        /* error handler */

    NULL,                            /* header handler */
    sapi_cgi_send_headers,            /* send headers handler */
    NULL,                            /* send header handler */

    sapi_cgi_read_post,                /* read POST data */
    sapi_cgi_read_cookies,            /* read Cookies */

    sapi_cgi_register_variables,    /* register server variables */
    sapi_cgi_log_message,            /* Log message */
    NULL,                            /* Get request time */
    NULL,                            /* Child terminate */

    STANDARD_SAPI_MODULE_PROPERTIES
};
```

定义了一些常量字符串，以及定义初始化函数、销毁函数、以及一些函数指针，告诉Zend如何获取与输出数据。

**例如：php_cgi_startup 调用php初始化。**

```
static int php_cgi_startup(sapi_module_struct *sapi_module)
{
    if (php_module_startup(sapi_module, &cgi_module_entry, 1) == FAILURE) {
        return FAILURE;
    }
    return SUCCESS;
}
```

**例如：php_module_shutdown_wrapper php关闭函数。**

```
1 int php_module_shutdown_wrapper(sapi_module_struct *sapi_globals)
2 {
3     php_module_shutdown();
4     return SUCCESS;
5 }
```

**例如：sapi_cgi_activate 处理request进行初始化。**

```
static int sapi_cgi_activate(void)
{
    char *path, *doc_root, *server_name;
    size_t path_len, doc_root_len, server_name_len;

    /* PATH_TRANSLATED should be defined at this stage but better safe than sorry :) */
    if (!SG(request_info).path_translated) {
        return FAILURE;
    }

    if (php_ini_has_per_host_config()) {
        /* Activate per-host-system-configuration defined in php.ini and stored into configuration_hash during startup */
        if (fcgi_is_fastcgi()) {
            fcgi_request *request = (fcgi_request*) SG(server_context);

            server_name = FCGI_GETENV(request, "SERVER_NAME");
        } else {
            server_name = getenv("SERVER_NAME");
        }
        /* SERVER_NAME should also be defined at this stage..but better check it anyway */
        if (server_name) {
            server_name_len = strlen(server_name);
            server_name = estrndup(server_name, server_name_len);
            zend_str_tolower(server_name, server_name_len);
            php_ini_activate_per_host_config(server_name, server_name_len);
            efree(server_name);
        }
    }

    if (php_ini_has_per_dir_config() ||
        (PG(user_ini_filename) && *PG(user_ini_filename))
    ) {
        /* Prepare search path */
        path_len = strlen(SG(request_info).path_translated);

        /* Make sure we have trailing slash! */
        if (!IS_SLASH(SG(request_info).path_translated[path_len])) {
            path = emalloc(path_len + 2);
            memcpy(path, SG(request_info).path_translated, path_len + 1);
            path_len = zend_dirname(path, path_len);
            path[path_len++] = DEFAULT_SLASH;
        } else {
            path = estrndup(SG(request_info).path_translated, path_len);
            path_len = zend_dirname(path, path_len);
        }
        path[path_len] = 0;

        /* Activate per-dir-system-configuration defined in php.ini and stored into configuration_hash during startup */
        php_ini_activate_per_dir_config(path, path_len); /* Note: for global settings sake we check from root to path */

        /* Load and activate user ini files in path starting from DOCUMENT_ROOT */
        if (PG(user_ini_filename) && *PG(user_ini_filename)) {
            if (fcgi_is_fastcgi()) {
                fcgi_request *request = (fcgi_request*) SG(server_context);

                doc_root = FCGI_GETENV(request, "DOCUMENT_ROOT");
            } else {
                doc_root = getenv("DOCUMENT_ROOT");
            }
            /* DOCUMENT_ROOT should also be defined at this stage..but better check it anyway */
            if (doc_root) {
                doc_root_len = strlen(doc_root);
                if (doc_root_len > 0 && IS_SLASH(doc_root[doc_root_len - 1])) {
                    --doc_root_len;
                }
#ifdef PHP_WIN32
                /* paths on windows should be case-insensitive */
                doc_root = estrndup(doc_root, doc_root_len);
                zend_str_tolower(doc_root, doc_root_len);
#endif
                php_cgi_ini_activate_user_config(path, path_len, doc_root, doc_root_len, (doc_root_len > 0 && (doc_root_len - 1)));

#ifdef PHP_WIN32
                efree(doc_root);
#endif
            }
        }

        efree(path);
    }

    return SUCCESS;
}
```

**例如：sapi_cgi_deactivate 处理完request关闭函数，与activate对应。**

```
static int sapi_cgi_deactivate(void)
{
    /* flush only when SAPI was started. The reasons are:
        1. SAPI Deactivate is called from two places: module init and request shutdown
        2. When the first call occurs and the request is not set up, flush fails on FastCGI.
    */
    if (SG(sapi_started)) {
        if (fcgi_is_fastcgi()) {
            if (
                !parent &&
                !fcgi_finish_request((fcgi_request*)SG(server_context), 0)) {
                php_handle_aborted_connection();
            }
        } else {
            sapi_cgi_flush(SG(server_context));
        }
    }
    return SUCCESS;
}
```
