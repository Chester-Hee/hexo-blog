---
title: 使用 Laravel-Swagger 编写接口文档
author: Chester-He
tags:
  - PHP
  - swagger
  - Laravel
categories:
  - PHP
translate_title: use-laravel-swagger-writing-document
date: 2019-05-25 17:00:00
---

## Swagger 文档管理

官方网站：https://swagger.io/

快速编写你的 `RESTFUL API` 接口文档工具，通过注释定义接口和模型，可以和代码文件放置一起，也可以单独文件存放。

### Laravel Swagger 扩展

扩展源代码地址：https://github.com/DarkaOnLine/L5-Swagger

```shell
composer require darkaonline/l5-swagger
php artisan vendor:publish --provider "L5Swagger\L5SwaggerServiceProvider"
```

将会生成配置文件 `l5-swagger.php`，其中需要注意的配置项

- `routes.api` 默认值为 `api/documentation` Swagger 文档系统访问路由
- `routes.docs` Swagger 解析注释生成文档 JSON 文件的存储路径
- `paths.annotations` 有效注释的路径配置，默认 `base_path('app')` 应用路径
- `generate_always` 测试环境应该开启这个配置，每次访问都会自动解析注释生成最新的文档
- `swagger_version` 这个默认为 2.0 , 建议修改为 3.0

**下文所有的注释内容，需要存在于 `paths.annotations` 路径下。**

### 接口版本

`@OA\Info` 定义接口版本，标题，描述，已经作者信息。

```php
/**
 * @OA\Info(
 *      version="1.0",
 *      title="用户管理",
 *      description="用户模块接口",
 *      @OA\Contact(
 *          name="PHP 开发支持",
 *          email="dreamhelingfeng@gmail.com"
 *      )
 * )
 */
```
### 接口请求方式与请求路径

`@OA\Get`,`@OA\Post` 定义接口请求方式

示例：根据`USER_ID`请求用户详情信息 `/api/users/{user_id}` 
接口分组配置：`tags`，将会对接口归类

```php
/**
  * @OA\Get(
  *   path="/api/users/{user_id}",
  *   summary="根据 ID 获取用户信息",
  *   tags={"用户管理"},
  *   @OA\Parameter(
  *     name="user_id",
  *     in="path",
  *     required=true,
  *     description="用户 ID",
  *     @OA\Schema(
  *        type="string"
  *     )
  *   ),
  *   @OA\Response(
  *     response=200,
  *     description="用户对象",
  *     @OA\JsonContent(ref="#/components/schemas/UserModel")
  *   )
  * )
  */
```

### 接口请求参数

通过 Swagger 可以定义三类参数，`path`,`header`,`query`

- path, 参数存在 endponit 中，如，/users/{user_id}
- header, 参数存在请求头部，如，token 用户校验令牌
- query, 请求参数带在请求URL上，如，/users?nickname={nickname}

```php
/**
  * @OA\Get(
  *   @OA\Parameter(
  *     name="user_id",
  *     in="path",
  *     required=true,
  *     description="用户 ID",
  *     @OA\Schema(
  *        type="string"
  *     )
  * )
  */
```

POST 提交表单，通常使用 `application/json` 方式，如，创建用户

`@OA\Post`
path=`/users`

```php
/**
  *   @OA\RequestBody(
  *       @OA\MediaType(
  *           mediaType="application/json",
  *           @OA\Schema(ref="#/components/schemas/UserModel"),
  *           example={
  *              "username": "helingfeng", "age": "25"
  *           }
  *       )
  *   )
  */
```

### Schema 模型定义

上面的注释中，多次引用 `@OA\Schema(ref="#/components/schemas/UserModel")` 

```php
/**
 * @OA\Schema(
 *      schema="UserModel",
 *      required={"username", "age"},
 *      @OA\Property(
 *          property="username",
 *          type="string",
 *          description="用户名称"
 *      ),
 *      @OA\Property(
 *          property="age",
 *          type="int",
 *          description="年龄"
 *      )
 * )
 */
```

Laravel-Swagger 会自动根据您的注释进行匹配


### 上传文件接口示例

定义一个接口，接收上传文件，并返回结果远程文件地址

**接口定义：**
```php
/**
  * @OA\Post(
  *   path="/api/files/upload",
  *   summary="文件上传",
  *   tags={"文件上传"},
  *   @OA\RequestBody(
  *       @OA\MediaType(
  *           mediaType="multipart/form-data",
  *           @OA\Schema(
  *              required={"upload_file"},
  *              @OA\Property(
  *                  property="upload_file",
  *                  type="file",
  *                  description="上传文件"
  *              ),
  *           ),
  *       )
  *   ),
  *   @OA\Response(
  *     response=200,
  *     description="上传成功",
  *     @OA\JsonContent(ref="#/components/schemas/UploadFileModel")
  *   ),
  *   @OA\Response(
  *     response="default",
  *     description="error",
  *     @OA\JsonContent(ref="#/components/schemas/ErrorModel")
  *   )
  * )
  */
```

**模型定义：**

```php
/**
 * @OA\Schema(
 *      schema="UploadFileModel",
 *      @OA\Property(
 *          property="file_name",
 *          type="string",
 *          description="文件名，不包含路径"
 *      ),
 *      @OA\Property(
 *          property="file_path",
 *          type="string",
 *          description="文件路径"
 *      ),
 *      @OA\Property(
 *          property="file_url",
 *          type="string",
 *          description="URL链接，用于展示"
 *      ),
 *      @OA\Property(
 *          property="file_size",
 *          type="string",
 *          description="文件大小，单位B"
 *      ),
 *      @OA\Property(
 *          property="extension",
 *          type="string",
 *          description="文件扩展名"
 *      )
 * )
 */
```

访问 `api/documentation` 效果如图

![demo1](/images/swagger-demo1.png)

`try it out` 上传文件操作结果

![demo2](/images/swagger-demo2.png)

### 需要权限认证的接口

一般对外网开放的接口，需要添加权限控制，Swagger 提供很好的支持

在 `l5-swagger.php` 配置文件中添加， `crypt-token` 定义请求头部必须添加 `token` 作为权限校验令牌。

```php
'security' => [
    /*
    |--------------------------------------------------------------------------
    | Examples of Security definitions
    |--------------------------------------------------------------------------
    */
    'crypt-token' => [ // Unique name of security
        'type' => 'apiKey', // The type of the security scheme. Valid values are "basic", "apiKey" or "oauth2".
        'description' => 'A short description for security scheme',
        'name' => 'token', // The name of the header or query parameter to be used.
        'in' => 'header', // The location of the API key. Valid values are "query" or "header".
    ],
]
```

接口注释中，添加对应的验证方式：

```php
/**
  * security={
  *    {"crypt-token": {}}
  * },
  */
```
![demo3](/images/swagger-demo3.png)

更多 Swagger3 定义字段描述，可以查看官方文档：https://swagger.io/specification/#parameterObject