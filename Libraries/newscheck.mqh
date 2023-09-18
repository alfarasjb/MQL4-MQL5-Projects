
#property copyright "Copyright 2023, Jay Benedict Alfaras"
#property version   "1.00"
#property strict

#include <B63/FFCalendarDownload.mqh>
#include <B63/CObjects.mqh>
SFFEvent mainData [];
CObjects object;



int checkMatch(string source, string data){
   int result = StringFind(source, data);
   return result;
}

void streamAllNews(){
   fetchData();
   int arrSize = ArraySize(mainData);
   for (int i = 0; i < arrSize; i++){
   PrintFormat("Title=%s, Country=%s, Time=%s, Impact=%s",
         mainData[i].title,
         mainData[i].country,
         TimeToString(mainData[i].time),
         mainData[i].impact
      );
   }
}

void fetchData(){
   string todayString = TimeToString(iTime(_Symbol, PERIOD_W1, 0),TIME_DATE);
      string fileName = "news\\" + todayString + ".csv";
      CFFCalendarDownload *downloader  =  new CFFCalendarDownload("news", 50000);
      bool           success     =  downloader.Download(fileName);
      int            error       =  0;
      if (!success){
         PrintFormat("Failed To Download");
      } else {
         ArrayResize(mainData, downloader.Count);
         for (int i = 0; i < downloader.Count; i++){
            mainData[i].title = downloader.Events[i].title;
            mainData[i].country = downloader.Events[i].country;
            mainData[i].time = downloader.Events[i].time;
            mainData[i].impact = downloader.Events[i].impact;
            mainData[i].forecast = downloader.Events[i].forecast;
            mainData[i].previous = downloader.Events[i].previous;  
         }
      }
      delete downloader;
}

void checkNews(){
   checkNews(true, true, true, true, true);
}

SFFEvent newsToday[];

void checkNews(bool plot, bool printOnTerminal, bool todayOnly, bool thisSymOnly, bool highImpactOnly){
   checkNews(newsToday, plot, printOnTerminal, todayOnly, thisSymOnly, highImpactOnly);
}
int checkNews(SFFEvent &arr_target[], bool plot, bool printOnTerminal, bool todayOnly, bool thisSymOnly, bool highImpactOnly){
   fetchData();
   string todayTime = TimeToStr(TimeCurrent());
   int arrSize = ArraySize(mainData);
   int newsCount = 0;
   string printString = "";

   for (int i = 0; i < arrSize; i++){
      //StringFind(What To Find, Where to find)
      int dateMatch = todayOnly ? StringFind(todayTime, TimeToString(mainData[i].time,TIME_DATE)) : 1 ;
      int symMatch = thisSymOnly ? StringFind(Symbol(), mainData[i].country) : 1 ;
      int impactMatch = highImpactOnly ? StringFind("High", mainData[i].impact) : 1 ;
      if (dateMatch > -1 && symMatch > -1 && impactMatch > -1) {
         newsCount++;
         ArrayResize(newsToday, newsCount);
         newsToday[newsCount - 1] = mainData[i];
      }
   }
   int newsArrSize = ArraySize(newsToday);
   if (newsArrSize > 0){
      for (int i = 0; i < newsArrSize; i++){
      //newscount data here
      
      printString = "Title: " + newsToday[i].title + ", Country: " + newsToday[i].country + ", Time: " + TimeToString(newsToday[i].time) + ", Impact: " + newsToday[i].impact;
      //string objname = "NewsToday" + (string)i;
     // draw(objname, newsToday[i].time, newsToday[i].title, clrRed);
      if (printOnTerminal) Print(printString);        
   }
      if (plot) plotOnChart("news_today", plot, newsToday);
   }
   if (newsArrSize == 0) PrintFormat("No News Today");
   return newsArrSize;
}

SFFEvent newsDateMatch[];
SFFEvent newsSymMatch[];
SFFEvent newsImpactMatch[];
SFFEvent newsCustom[];

void checkNewsCustom(bool todayOnly, bool thisSymOnly, bool highImpactOnly){
   fetchData();
   string todayTime = TimeToStr(TimeCurrent());
   int arrSize = ArraySize(mainData);
   int newsCustomCount = 0;
   int newsDateCount = 0;
   int newsSymCount = 0;
   int newsImpactCount = 0;
   for (int i = 0; i < arrSize; i++){
      int dateMatch = todayOnly ? StringFind(todayTime, TimeToString(mainData[i].time,TIME_DATE)) : 1 ;
      int symMatch = thisSymOnly ? StringFind(Symbol(), mainData[i].country) : 1 ;
      int impactMatch = highImpactOnly ? StringFind("High", mainData[i].impact) : 1 ;
      if (dateMatch > -1 && symMatch > -1 && impactMatch > -1) {
         newsCustomCount++;
         ArrayResize(newsCustom, newsCustomCount);
         newsCustom[newsCustomCount - 1] = mainData[i];
    
      }
      if (dateMatch > - 1){
         newsDateCount++;
         ArrayResize(newsDateMatch, newsDateCount);
         newsDateMatch[newsDateCount - 1] = mainData[i];
     
      }
      if (symMatch > - 1){
         newsSymCount++;
         ArrayResize(newsSymMatch, newsSymCount);
         newsSymMatch[newsSymCount - 1] = mainData[i];
       
      }
      if (impactMatch > - 1){
         newsImpactCount++;
         ArrayResize(newsImpactMatch, newsImpactCount);
         newsImpactMatch[newsImpactCount - 1] = mainData[i];
      
      }
   }
}



void plotOnChart(string source, bool plot, SFFEvent &news[]){
   // plot here
   string newsText = "";
   int size = ArraySize(news);
   for (int i = 0; i < size; i++){
      // draw
      string objname = source + (string)i;
      newsText = news[i].title + "\n" + news[i].country + "\n" + TimeToString(news[i].time) +"\n" + news[i].impact;
      datetime time = news[i].time;
      
      draw(objname, time, newsText, eventColor(news[i].impact));
   }
}

color eventColor(string impact){
   if (impact == "High") return clrRed;
   if (impact == "Medium") return clrOrange;
   if (impact == "Low") return clrYellow;
   return 0;
}

void draw(string name, datetime time, string newsText, color eventColor){
   ObjectCreate(0, name, OBJ_EVENT, 0, time, 0);
   ObjectSetString(0, name, OBJPROP_TEXT, newsText);
   ObjectSetInteger(0, name, OBJPROP_COLOR, eventColor);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 5);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 2);
   
   ObjectCreate(0, name+"line", OBJ_VLINE, 0, time, 0);
   ObjectSetInteger(0, name + "line", OBJPROP_COLOR, eventColor);
   ObjectSetInteger(0, name + "line", OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, name + "line", OBJPROP_BACK, true);

}