/*
 * Licensed Materials - Property of Dasudian
 * Copyright Dasudian Technology Co., Ltd. 2017
 */

#ifndef DataHubCommon_h
#define DataHubCommon_h

#define DATAHUB_TRUE 1
#define DATAHUB_FALSE 0

#define DEFAULT_SERVER_URL      "tcp://try.iotdatahub.net:1883"
#define DEFAULT_DEBUG_OPT       DATAHUB_FALSE
#define DEFAULT_CLEANSESSION    DATAHUB_FALSE
#define DEFAULT_CONTEXT         NULL

/** 选项的初始化宏 */
#define DATAHUB_OPTIONS_INITIALIZER {\
DEFAULT_SERVER_URL,\
DEFAULT_DEBUG_OPT,\
DEFAULT_CLEANSESSION,\
DEFAULT_CONTEXT,\
}

/** 消息的初始化宏,只包含字符串结尾符'\0' */
#define DATAHUB_MESSAGE_INITIALIZER {\
1,\
""\
}

#define DATAHUB_DT_INITIALIZER {0}

/**
 * @brief客户端的类型
 */
typedef void* datahub_client;

/** @brief 消息的结构体类型
 */
typedef struct datahub_message_s {
    /** 消息长度，必须大于0 */
    unsigned int payload_len;
    /** 发送消息的起始地址 */
    void *payload;
} datahub_message;

/** @brief 错误码 */
enum datahub_error_code_s {
    /** 成功 */
    ERROR_NONE = 0,
    /** 某些参数不合法 */
    ERROR_ILLEGAL_PARAMETERS = -1,
    /** 客户端未连接服务器 */
    ERROR_DISCONNECTED = -2,
    /** MQTT服务器不支持当前使用的协议版本号,请联系开发人员 */
    ERROR_UNACCEPT_PROTOCOL_VERSION = -3,
    /** client_id不可用,可能使用了不支持的字符 */
    ERROR_IDENTIFIER_REJECTED = -4,
    /** 服务器不可用 */
    ERROR_SERVER_UNAVAILABLE = -5,
    /** instance_id 或者instance_key不正确,请检查或者联系客服人员 */
    ERROR_BAD_USERNAME_OR_PASSWD = -6,
    /** 未被授权 */
    ERROR_UNAUTHORIZED = -7,
    /** 验证服务器不可用 */
    ERROR_AUTHORIZED_SERVER_UNAVAILABLE = -8,
    /** 操作失败 */
    ERROR_OPERATION_FAILURE = -9,
    /** 消息过长 */
    ERROR_MESSAGE_TOO_BIG = -10,
    /** 网络不可用 */
    ERROR_NETWORK_UNREACHABLE = -11,
    /** 同步超时 */
    ERROR_TIMEOUT = -12,
    /** 内存申请失败 */
    ERROR_MEMORY_ALLOCATE = -500,
    /** 不合法的JSON字符串 */
    ERROR_MESSAGE_INVALID_JSON = -501,
    /** 不合法的设备类型字符;设备类型不能包含竖线"|", 也不能以下划线"_"开头 */
    ERROR_INVALID_CLIENT_TYPE = -502
};

/**
 * 数据类型
 */
typedef enum datahub_data_type_s {
    /** 数据为JSON格式 */
    JSON = 0,
    /** 数据为文本/字符串 */
    TEXT = 1,
    /** 数据为二进制 */
    BINARY = 2,
    DATA_TYPE_END
}datahub_data_type;

#endif
