// ignore_for_file: constant_identifier_names

enum ChatStatus {
  waiting,
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

const String USER_URL = 'https://intensivecredentialdev.azurewebsites.net/api';
const String CHAT_URL = 'https://intensiveconversedev.azurewebsites.net/api';
// const String USER_URL = 'https://intensivecredentialprod.azurewebsites.net/api';
// const String CHAT_URL = 'https://intensiveconverseprod.azurewebsites.net/api';

/*
 * Network error code
 */
const String CODE_OK = '200';
const String CODE_SERVICE_UNAVAILABLE = '0';
const String CODE_NETWORK_EXCEPTION = '4444';
const String CODE_INVALI_OPERATION = '400';
const String CODE_NETWORK_TIMEOUT = '504';

/*
 * User settings
 */
const int USER_DEFAULT_TOKEN_DURATION_IN_MIN = 60 * 24 * 10;
const String USER_DEFAULT_ROLE = 'User';
/*
 * Chat settings
 */
const int CHAT_COMPLETE_GAP_IN_MINUTES = 60;
const int MAX_CHAT_DEPTH = 15;
