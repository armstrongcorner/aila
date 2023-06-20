// ignore_for_file: constant_identifier_names

enum ChatStatus {
  sending,
  done,
  failure,
}

/*
 * Hive related
 */
const String BOX_NAME_CHAT = 'chat_box';
// Box Type ID
const int BOX_TYPE_ID_CHAT = 1;

/*
 * Network related
 */
const int NETWORK_TIMEOUT = 120;

const String DEV_URL = 'https://intensivechatdev.azurewebsites.net/api';
const String PROD_URL = 'https://intensivechatdev.azurewebsites.net/api';

const String USER_URL = 'https://intensiveidentitydev.azurewebsites.net/api';
const String CHAT_URL = 'https://intensivechatdev.azurewebsites.net/api';

/*
 * Network error code
 */
const String CODE_OK = '200';
const String CODE_SERVICE_UNAVAILABLE = '0';
const String CODE_NETWORK_EXCEPTION = '4444';
const String CODE_INVALI_OPERATION = '400';
const String CODE_NETWORK_TIMEOUT = '504';
