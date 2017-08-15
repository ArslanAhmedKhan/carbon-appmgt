BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS IDN_BASE_TABLE (
            PRODUCT_NAME VARCHAR (20),
            PRIMARY KEY (PRODUCT_NAME)
)
;

INSERT INTO IDN_BASE_TABLE values ('WSO2 Identity Server');

CREATE TABLE IF NOT EXISTS IDN_OAUTH_CONSUMER_APPS (
            CONSUMER_KEY VARCHAR (512),
            CONSUMER_SECRET VARCHAR (512),
            USERNAME VARCHAR (255),
            TENANT_ID INTEGER DEFAULT 0,
            APP_NAME VARCHAR (255),
            OAUTH_VERSION VARCHAR (128),
            CALLBACK_URL VARCHAR (1024),
            GRANT_TYPES VARCHAR (1024),
            PRIMARY KEY (CONSUMER_KEY)
)
;

CREATE TABLE IF NOT EXISTS IDN_OAUTH1A_REQUEST_TOKEN (
            REQUEST_TOKEN VARCHAR (512),
            REQUEST_TOKEN_SECRET VARCHAR (512),
            CONSUMER_KEY VARCHAR (512),
            CALLBACK_URL VARCHAR (1024),
            SCOPE VARCHAR(2048),
            AUTHORIZED VARCHAR (128),
            OAUTH_VERIFIER VARCHAR (512),
            AUTHZ_USER VARCHAR (512),
            PRIMARY KEY (REQUEST_TOKEN),
            FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY)
)
;

CREATE TABLE IF NOT EXISTS IDN_OAUTH1A_ACCESS_TOKEN (
            ACCESS_TOKEN VARCHAR (512),
            ACCESS_TOKEN_SECRET VARCHAR (512),
            CONSUMER_KEY VARCHAR (512),
            SCOPE VARCHAR(2048),
            AUTHZ_USER VARCHAR (512),
            PRIMARY KEY (ACCESS_TOKEN),
            FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY)
)
;

CREATE TABLE IF NOT EXISTS IDN_OAUTH2_AUTHORIZATION_CODE (
            AUTHORIZATION_CODE VARCHAR (512),
            CONSUMER_KEY VARCHAR (512),
            SCOPE VARCHAR(2048),
            AUTHZ_USER VARCHAR (512),
            TIME_CREATED TIMESTAMP,
            VALIDITY_PERIOD BIGINT,
            PRIMARY KEY (AUTHORIZATION_CODE),
            FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY)
)
;

CREATE TABLE IF NOT EXISTS IDN_OAUTH2_ACCESS_TOKEN (
			ACCESS_TOKEN VARCHAR (255),
			REFRESH_TOKEN VARCHAR (255),
			CONSUMER_KEY VARCHAR (255),
			AUTHZ_USER VARCHAR (255),
			USER_TYPE VARCHAR (255),
			TIME_CREATED TIMESTAMP,
			VALIDITY_PERIOD BIGINT,
			TOKEN_SCOPE VARCHAR (25),
			TOKEN_STATE VARCHAR (25) DEFAULT 'ACTIVE',
			TOKEN_STATE_ID VARCHAR (255) DEFAULT 'NONE',
			PRIMARY KEY (ACCESS_TOKEN),
            FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY)
)
;

CREATE TABLE IF NOT EXISTS IDN_OPENID_USER_RPS (
			USER_NAME VARCHAR(255) NOT NULL,
			TENANT_ID INTEGER DEFAULT 0,
			RP_URL VARCHAR(255) NOT NULL,
			TRUSTED_ALWAYS VARCHAR(128) DEFAULT 'FALSE',
			LAST_VISIT DATE NOT NULL,
			VISIT_COUNT INTEGER DEFAULT 0,
			DEFAULT_PROFILE_NAME VARCHAR(255) DEFAULT 'DEFAULT',
			PRIMARY KEY (USER_NAME, TENANT_ID, RP_URL)
)
;

CREATE SEQUENCE AM_SUBSCRIBER_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS AM_SUBSCRIBER (
    SUBSCRIBER_ID INTEGER DEFAULT nextval('am_subscriber_sequence'),
    USER_ID VARCHAR(255) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    EMAIL_ADDRESS VARCHAR(256) NULL,
    DATE_SUBSCRIBED DATE NOT NULL,
    PRIMARY KEY (SUBSCRIBER_ID),
    UNIQUE (TENANT_ID,USER_ID)
)
;

CREATE SEQUENCE AM_APPLICATION_SEQUENCE START WITH 1 INCREMENT BY 1 ;
CREATE TABLE IF NOT EXISTS AM_APPLICATION (
    APPLICATION_ID INTEGER DEFAULT nextval('am_application_sequence'),
    NAME VARCHAR(100),
    SUBSCRIBER_ID INTEGER,
    APPLICATION_TIER VARCHAR(50) DEFAULT 'Unlimited',
    CALLBACK_URL VARCHAR(512),
    DESCRIPTION VARCHAR(512),
	APPLICATION_STATUS VARCHAR(50) DEFAULT 'APPROVED',
    FOREIGN KEY(SUBSCRIBER_ID) REFERENCES AM_SUBSCRIBER(SUBSCRIBER_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY(APPLICATION_ID),
    UNIQUE (NAME,SUBSCRIBER_ID)
)
;

CREATE SEQUENCE APM_BUSINESS_OWNER_SEQUENCE START WITH 1 INCREMENT BY 1 ;
CREATE TABLE IF NOT EXISTS APM_BUSINESS_OWNER(
  OWNER_ID INTEGER DEFAULT nextval('apm_business_owner_sequence'),
  OWNER_NAME VARCHAR(200) NOT NULL,
  OWNER_EMAIL VARCHAR(300) NOT NULL,
  OWNER_DESC VARCHAR(1500),
  OWNER_SITE VARCHAR(200),
  TENANT_ID INTEGER,
  PRIMARY KEY(OWNER_ID),
  UNIQUE (OWNER_NAME,OWNER_EMAIL,TENANT_ID)

);

CREATE SEQUENCE APM_BUSINESS_OWNER_PROPERTY_SEQUENCE START WITH 1 INCREMENT BY 1 ;
CREATE TABLE IF NOT EXISTS APM_BUSINESS_OWNER_PROPERTY(
  OWNER_PROP_ID INTEGER DEFAULT nextval('apm_business_owner_property_sequence'),
  OWNER_ID INTEGER NOT NULL,
  NAME VARCHAR(200) NOT NULL,
  VALUE VARCHAR(300) NOT NULL,
  SHOW_IN_STORE BOOLEAN NOT NULL,
  PRIMARY KEY(OWNER_PROP_ID),
  FOREIGN KEY(OWNER_ID) REFERENCES APM_BUSINESS_OWNER(OWNER_ID)
);

CREATE SEQUENCE APPMGR_APP_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS APPMGR_APP (
    API_ID INTEGER DEFAULT nextval('appmgr_app_sequence'),
    API_PROVIDER VARCHAR(256),
    API_NAME VARCHAR(256),
    API_VERSION VARCHAR(30),
    CONTEXT VARCHAR(256),
    PRIMARY KEY(API_ID),
    UNIQUE (API_PROVIDER,API_NAME,API_VERSION)
)
;

CREATE SEQUENCE APPMGR_APP_URL_MAPPING_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS APPMGR_APP_URL_MAPPING (
    URL_MAPPING_ID INTEGER DEFAULT nextval('appmgr_app_url_mapping_sequence'),
    API_ID INTEGER NOT NULL,
    HTTP_METHOD VARCHAR(20) NULL,
    AUTH_SCHEME VARCHAR(50) NULL,
    URL_PATTERN VARCHAR(512) NULL,
    THROTTLING_TIER varchar(512) DEFAULT NULL,
    USER_ROLES varchar(512) DEFAULT NULL,
    ENTITLEMENT_POLICY_ID  varchar(512) DEFAULT NULL,
    PRIMARY KEY(URL_MAPPING_ID)
)
;

CREATE SEQUENCE AM_SUBSCRIPTION_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS AM_SUBSCRIPTION (
    SUBSCRIPTION_ID INTEGER DEFAULT nextval('am_subscription_sequence'),
    SUBSCRIPTION_TYPE VARCHAR(50),
    TIER_ID VARCHAR(50),
    API_ID INTEGER,
    LAST_ACCESSED DATE NULL,
    APPLICATION_ID INTEGER,
    SUB_STATUS VARCHAR(50),
    FOREIGN KEY(APPLICATION_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY(API_ID) REFERENCES APPMGR_APP(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (SUBSCRIPTION_ID)
)
;

CREATE TABLE IF NOT EXISTS AM_SUBSCRIPTION_KEY_MAPPING (
    SUBSCRIPTION_ID INTEGER,
    ACCESS_TOKEN VARCHAR(512),
    KEY_TYPE VARCHAR(512) NOT NULL,
    FOREIGN KEY(SUBSCRIPTION_ID) REFERENCES AM_SUBSCRIPTION(SUBSCRIPTION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY(SUBSCRIPTION_ID,ACCESS_TOKEN)
)
;

CREATE TABLE IF NOT EXISTS AM_APPLICATION_KEY_MAPPING (
    APPLICATION_ID INTEGER,
    CONSUMER_KEY VARCHAR(512),
    KEY_TYPE VARCHAR(512) NOT NULL,
    FOREIGN KEY(APPLICATION_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY(APPLICATION_ID,CONSUMER_KEY)
)
;

CREATE SEQUENCE APPMGR_APP_LC_EVENT_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS APPMGR_APP_LC_EVENT (
    EVENT_ID INTEGER DEFAULT nextval('appmgr_app_lc_event_sequence'),
    API_ID INTEGER NOT NULL,
    PREVIOUS_STATE VARCHAR(50),
    NEW_STATE VARCHAR(50) NOT NULL,
    USER_ID VARCHAR(255) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    EVENT_DATE DATE NOT NULL,
    FOREIGN KEY(API_ID) REFERENCES APPMGR_APP(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (EVENT_ID)
)
;

CREATE TABLE IF NOT EXISTS AM_APP_KEY_DOMAIN_MAPPING (
   CONSUMER_KEY VARCHAR(255),
   AUTHZ_DOMAIN VARCHAR(255) DEFAULT 'ALL',
   PRIMARY KEY (CONSUMER_KEY,AUTHZ_DOMAIN),
   FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY)
)
;

CREATE SEQUENCE APPMGR_APP_COMMENTS_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS APPMGR_APP_COMMENTS (
    COMMENT_ID INTEGER DEFAULT nextval('appmgr_app_comments_sequence'),
    COMMENT_TEXT VARCHAR(512),
    COMMENTED_USER VARCHAR(255),
    DATE_COMMENTED DATE NOT NULL,
    API_ID INTEGER NOT NULL,
    FOREIGN KEY(API_ID) REFERENCES APPMGR_APP(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (COMMENT_ID)
)
;

CREATE SEQUENCE AM_WORKFLOWS_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS AM_WORKFLOWS(
    WF_ID INTEGER DEFAULT nextval('am_workflows_sequence'),
    WF_REFERENCE VARCHAR(255) NOT NULL,
    WF_TYPE VARCHAR(255) NOT NULL,
    WF_STATUS VARCHAR(255) NOT NULL,
    WF_CREATED_TIME TIMESTAMP,
    WF_UPDATED_TIME TIMESTAMP,
    WF_STATUS_DESC VARCHAR(1000),
    TENANT_ID INTEGER,
    TENANT_DOMAIN VARCHAR(255),
    WF_EXTERNAL_REFERENCE VARCHAR(255) NOT NULL,
    PRIMARY KEY (WF_ID),
    UNIQUE (WF_EXTERNAL_REFERENCE)
)
;

CREATE SEQUENCE APPMGR_APP_RATINGS_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS APPMGR_APP_RATINGS (
    RATING_ID INTEGER DEFAULT nextval('appmgr_app_ratings_sequence'),
    API_ID INTEGER,
    RATING INTEGER,
    SUBSCRIBER_ID INTEGER,
    FOREIGN KEY(API_ID) REFERENCES APPMGR_APP(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY(SUBSCRIBER_ID) REFERENCES AM_SUBSCRIBER(SUBSCRIBER_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (RATING_ID)
)
;

CREATE SEQUENCE AM_TIER_PERMISSIONS_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS AM_TIER_PERMISSIONS (
    TIER_PERMISSIONS_ID INTEGER DEFAULT nextval('am_tier_permissions_sequence'),
    TIER VARCHAR(50) NOT NULL,
    PERMISSIONS_TYPE VARCHAR(50) NOT NULL,
    ROLES VARCHAR(512) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    PRIMARY KEY(TIER_PERMISSIONS_ID)
);

CREATE TABLE IF NOT EXISTS IDN_THRIFT_SESSION (
    SESSION_ID VARCHAR(255) NOT NULL,
    USER_NAME VARCHAR(255) NOT NULL,
    CREATED_TIME VARCHAR(255) NOT NULL,
    LAST_MODIFIED_TIME VARCHAR(255) NOT NULL,
    PRIMARY KEY (SESSION_ID)

)
;

CREATE SEQUENCE AM_EXTERNAL_STORES_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS AM_EXTERNAL_STORES (
    APISTORE_ID INTEGER DEFAULT nextval('am_external_stores_sequence'),
    API_ID INTEGER,
    STORE_ID VARCHAR(255) NOT NULL,
    STORE_DISPLAY_NAME VARCHAR(255) NOT NULL,
    STORE_ENDPOINT VARCHAR(255) NOT NULL,
    STORE_TYPE VARCHAR(255) NOT NULL,
    FOREIGN KEY(API_ID) REFERENCES APPMGR_APP(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (APISTORE_ID)
)
;

CREATE SEQUENCE APM_APP_DEFAULT_VERSION_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS APM_APP_DEFAULT_VERSION (
    DEFAULT_VERSION_ID INTEGER DEFAULT nextval('apm_app_default_version_sequence'),
    APP_NAME VARCHAR(256),
    APP_PROVIDER VARCHAR(256),
    DEFAULT_APP_VERSION VARCHAR(30),
    PUBLISHED_DEFAULT_APP_VERSION VARCHAR(30),
    TENANT_ID INTEGER,
PRIMARY KEY(DEFAULT_VERSION_ID)
)
;

CREATE TABLE IF NOT EXISTS APM_USER_PORTAL_THEME(
  TENANT_ID INTEGER,
  NAME VARCHAR(200) NOT NULL,
  DESCRIPTION VARCHAR(1500),
  PRIMARY KEY(TENANT_ID),
  UNIQUE (TENANT_ID)
);

CREATE INDEX IDX_SUB_APP_ID ON AM_SUBSCRIPTION (APPLICATION_ID, SUBSCRIPTION_ID)
;
CREATE INDEX IDX_AT_CK_AU ON IDN_OAUTH2_ACCESS_TOKEN(CONSUMER_KEY, AUTHZ_USER, TOKEN_STATE, USER_TYPE);
commit;
