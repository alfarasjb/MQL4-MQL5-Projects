
#property copyright "Copyright 2023, Jay Benedict Alfaras"
#property strict


struct STGMessage{
   int messageId;
   string message;
   datetime date;
   
   STGMessage(){
      messageId = 0;
      message = "";
      date = 0;
   }
};

class CTelegram{

protected:
string   BotToken;
string   ChatId;
string   ApiUrl;
int      timeout;

private:
string   headers;
int      gmtOffset;


ushort sepChar;
ushort sepChar2;
ushort sepChar3;
   
void parseSentMessage(string result);
int checkErrors(int response, char &resultData []);
bool parseLastMessage(string result);
string parseText(string property, string &data[]);
string parseData(string property, string &data[]); 
   
public: 
   STGMessage lastMessage;
   STGMessage sentMsg;
   
   
//METHODS
string token() { return BotToken; } 
void token(string value) { BotToken = value; } //

string chatId() {return ChatId; }
void chatId(string value) {ChatId = value; }

string apiURL() { return ApiUrl; }
void apiURL(string value) {ApiUrl = value; }

int Timeout() {return timeout; }
void Timeout(int value) {timeout = value; }

bool getLastMsg();
bool sendMsg(string message, bool pin);
CTelegram(void);
CTelegram(string ChatId, string botToken);



};

// 
#ifdef __MQL4__
const int         UrlDefinedError   =  4066; // MT4
const string nl = "%250A";
#endif

#ifdef __MQL5__
const int         UrlDefinedError   = 4014 // MT5
const string nl = "%0A";
#endif


CTelegram::CTelegram(string val_chatId, string val_botToken){
   token(val_botToken);
   chatId(val_chatId);
   apiURL("https://api.telegram.org");
   Timeout(1000);
   headers   = "";
   gmtOffset = 3 * 3600;
   sepChar = StringGetCharacter(",",0);
   sepChar2 = StringGetCharacter(":",0);
   sepChar3 = StringGetCharacter('"',0);
}


//DEFAULT CONSTRUCTOR
CTelegram::CTelegram(void){
   BotToken  =  ""; 
   ApiUrl    =  "https://api.telegram.org"; // add this to allow urls
   ChatId    =  "";
   headers   = "";
   gmtOffset = 3 * 3600;
   timeout = 1000;
   sepChar = StringGetCharacter(",",0);
   sepChar2 = StringGetCharacter(":",0);
   sepChar3 = StringGetCharacter('"',0);
}


//API URLs, HTTP CALLS

bool CTelegram::getLastMsg(){
   char getData[];
   char resultData[];
   string resultHeaders;
   string result = "";
   // replace apiUrl with get function? test this 
   string updateUrl = StringFormat("%s/bot%s/getUpdates?offset=-1", apiURL(), token());
   int response = WebRequest("GET", updateUrl, headers, Timeout(), getData, resultData, resultHeaders);
      
      //Print(result);
      if (checkErrors(response, resultData) == 200){
         result = CharArrayToString(resultData);
         if(!parseLastMessage(result)) {};
      } else Print("ERROR: ", result);
      

   return true;
}

bool CTelegram::sendMsg(string message, bool pin){
   char postData[];
   char getData[];
   char resultData[];
   string resultHeaders;
   string result = "";
   
   //URL QUERY STRING
   string requestUrl = StringFormat("%s/bot%s/sendmessage?chat_id=%s&text=%s", apiURL(), token(), chatId(), message + nl + nl + "ID: " + (string)AccountInfoInteger(ACCOUNT_LOGIN));
   //STRUCTURE
   // api url/ bot token/ operation
   ResetLastError();
   
   int response = WebRequest("POST", requestUrl, headers, Timeout(), postData, resultData, resultHeaders);
   //int getResponse = WebRequest("GET", fetchUrl, headers, timeout, getData, resultData, resultHeaders);
   
   if (checkErrors(response, resultData) == 200){
      result = CharArrayToString(resultData);
      parseSentMessage(result);
   }
   if (pin){
      string pinRequestUrl = StringFormat("%s/bot%s/pinChatMessage?chat_id=%s&message_id=%i", apiURL(), token(), chatId(), sentMsg.messageId);
      response = WebRequest("POST", pinRequestUrl, headers, Timeout(), postData, resultData, resultHeaders);
   }
   return (response == 200);
}


void CTelegram::parseSentMessage(string result){

   string msg [];
   string messageID[];
   string text[];
   
   StringSplit(result, sepChar, msg);
   StringSplit(msg[1], sepChar2, messageID); //Message ID
   StringSplit(msg[9], sepChar2, text); // MessageText
   
   sentMsg.message = parseData("text", msg);
   sentMsg.messageId = (int)messageID[2];
   sentMsg.date = (int)parseData("date", msg) + gmtOffset;

}


bool CTelegram::parseLastMessage(string result){
   string retData [];
   string msg [];
   string msgid [];
   //ushort sepChar4 = StringGetCharacter("%250A",0);
   StringSplit(result, sepChar, retData);
   StringSplit(retData[ArraySize(retData) - 1], sepChar2, msg);
   if (ArraySize(retData) < 3) return false;
   StringSplit(retData[2], sepChar2, msgid);
   int rcvID = (int)msgid[2];
   

   if (rcvID == lastMessage.messageId) return false;
   lastMessage.messageId = rcvID;
   lastMessage.message = parseData("text", retData);
   lastMessage.date = (int)parseData("date", retData) + gmtOffset;
   
   if (StringLen(lastMessage.message) == 0) return false;
   return true;
}

string CTelegram::parseData(string property, string &data[]){
   
   string retVal = "";
   string toRemove [] = {"{", "}", "[", "]", ":", "\""};
   
   for (int i = 0; i < ArraySize(data); i++){
      if (StringFind(data[i], property, 0) != 1) continue;
      StringReplace(data[i], property, "");
      for (int j = 0 ; j < ArraySize(toRemove) ; j++){
         StringReplace(data[i], toRemove[j], "");
      }
      retVal = data[i];
      break;
   }
   return retVal;
}


int CTelegram::checkErrors(int response, char &resultData []){
   switch(response){
      case -1:{
         int errorCode = GetLastError();
         Print("WebRequestError: ", errorCode);
         if(errorCode == UrlDefinedError){
            Print("Add address in list of allowed URLs", ApiUrl);
         }
         break;
      }
      case 200:
         //Print("Operation Successful");
         break;
      default: {
         string result = CharArrayToString(resultData);
         PrintFormat("Unexpected Response %i, %s", response, result);
         break;
      }
   }
   return response;
}