// ignore_for_file: constant_identifier_names

enum ChatStatus {
  sending, // Sending the chat context, binary files already uploaded and returned access url
  waiting, // Waiting for GPT response, normally used to display the waiting UI widget
  uploading, // Uploading the binary file e.g: image, audio
  done, // Finish send and already get the response, mark the context as done
  failure, // Something wrong with send or get response, mark the context as failure and show
}

enum DownlodInstallStatus {
  existed,
  downloading,
  downloaded,
  donwloadStopped,
  downloadFailed,
  installing,
  installed,
  installFailed,
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
const String CODE_SERVICE_NOT_FOUND = '404';
const String CODE_FILE_NOT_FOUND = '5404';
const String CODE_NETWORK_EXCEPTION = '4444';
const String CODE_INVALID_OPERATION = '400';
const String CODE_NETWORK_TIMEOUT = '504';

/*
 * User settings
 */
const int USER_DEFAULT_TOKEN_DURATION_IN_MIN = 60 * 24 * 10;
const String USER_DEFAULT_ROLE = 'User';
const int RESEND_VERI_CODE_COUNTDOWN_IN_SEC = 60;
/*
 * Chat settings
 */
const int CHAT_COMPLETE_GAP_IN_MINUTES = 15;
const int MAX_CHAT_DEPTH = 7;
const int MAX_AUDIO_LENGTH = 60;
