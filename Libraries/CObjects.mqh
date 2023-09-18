
class CObjects{
   protected:
      string mName;

   private: 
      
      int               DefScaleFactor;
      ENUM_BASE_CORNER  DefCorner;
      int               DefFontSize;
      string            DefFontStyle;
      string            DefFontBold;
      bool              DefBold;
      //Rectangle Properties
      int               DefXDist;
      int               DefYDist;
      
      ENUM_BORDER_TYPE  DefBorder;
      
      //Line
      ENUM_LINE_STYLE   DefLineStyle;
      int               DefWidth;
      bool              DefRay;
      
      //Misc
      bool              DefHidden;
      bool              DefBack;
      bool              DefSelectable;
      ENUM_ANCHOR_POINT DefAnchor;
      long              DefZOrder;
      ENUM_ALIGN_MODE   DefAlign;
      bool              DefState;
      
      //Button
      color             DefButtonTextColor;
      color             DefButtonBordColor;
      
      //COLORS
      color             DefLineCol;
      color             DefFontCol;
      color             DefBGColor;
      color             DefButtonBGCol;
      color             DefBordColor;
      
      void FName(string inpName) { mName = inpName; }
      string FName() { return mName; }
      
      bool Col(color col); // LINE COLOR
      bool LineStyle(ENUM_LINE_STYLE style); // LINE STYLE
      bool Ray(bool ray); // RAY
      bool Hidden(bool hidden); // HIDDEN
      bool Selectable(bool selectable); //SELECTABLE 
      bool Width(int width); //WIDTH
      
      bool BorderType(ENUM_BORDER_TYPE border); // BORDER TYPE
      bool Back(bool back); // BACK
      
      bool XDist(int xDist); // X DISTANCE
      bool YDist(int yDist); // Y DISTANCE
      bool XSize(int xSize); // X SIZE
      bool YSize(int ySize); // Y SIZE
      bool Corner(ENUM_BASE_CORNER corner); // CORNER
      bool BGCol(color col); // BG COLOR
      
      bool BordColor(color col); // BORDER COLOR 
      
      bool FontSize(int fontSize); // FONTSIZE
      bool Text (string text); // TEXT
      
      
      bool Anchor(ENUM_ANCHOR_POINT anchor);
      bool Font(string fontStyle);
      
      
      bool ZOrder(long zOrder);
      
      bool Align(ENUM_ALIGN_MODE align);
      
      bool State(bool state);
      
      bool ReadOnly(bool readOnly);
      
      
      
      
   public: 
   
   CObjects(void);
   CObjects(int x, int y, int fontSize, int scaleFactor);
   CObjects::CObjects(int x, int y, color lineCol, color fontCol, color bgCol, color buttonCol, color bordCol, string fontStyle, int fontSize);
   
   int scale(int size)                 { return (size * DefScaleFactor) / 100;}
   void CAdjRow(string prefix, int bgX, int bgY, int bgWidth, int bgHeight, int editWidth, int editHeight, int btSize, string editText, int fontSize, color btBGCol, color btBordCol, color fontCol, color editCol){
      //bg 
      //field
      //button
      //button
      const int spaceX     = 3;
      const int spaceY     = 3;
      
      const int editX      = (bgWidth / 2) + bgX - (editWidth / 2);
      const int bgX2       = bgX + bgWidth;
      const int btXPlus    = bgX2 - btSize - spaceX;
      const int btXMinus   = bgX + spaceX;
      
      const int yGap = bgY - spaceY;
      CEdit(prefix + "BG", bgX, bgY, bgWidth, bgHeight, fontSize, "", fontCol, editCol, editCol, true);
      CEdit(prefix, editX, yGap, editWidth, editHeight, fontSize, editText, fontCol, editCol, editCol, false);
      CButton("BT" + prefix + "+", btXPlus, yGap, btSize, btSize, fontSize, "+", fontCol, btBGCol, btBordCol, 50);
      CButton("BT" + prefix + "-", btXMinus, yGap, btSize, btSize, fontSize, "-", fontCol, btBGCol, btBordCol, 50);
   }
   
   void CSwitch(string name1, string name2, int x, int y, int width, int height, color onColor, color offColor, bool state){
      // name1, name2, x, y, width, height, col1, col2, state
      // x + width - 2
      CSwitch(name1, name2, x, y, width, height, onColor, offColor, " ", " ", state);
   }
   
   void CSwitch(string name1, string name2, int x, int y, int width, int height, color onColor, color offColor, string onText, string offText, bool state){
      // name1, name2, x, y, width, height, col1, col2, state
      // x + width - 2
      
      CButton(name1, x + width - 2, y, width, height, DefFontSize, onText, DefFontCol, onColor, DefBordColor, state);
      CButton(name2, x, y, width, height, DefFontSize, offText, DefFontCol, offColor, DefBordColor, !state);
   }
   void CMultiSwitch(int count, string name, int x, int y, int width, int height, color selectedColor, color notSelectedCol, string &text[], bool state, int idx){
      for (int i = 0; i < count ; i++){
         int xDis = (width * i);
         color btCol = (i + 1) == idx ? selectedColor : notSelectedCol;
         CButton(name + (string)(i + 1), x + xDis, y, width, height, DefFontSize, text[i], DefFontCol, btCol, DefBordColor, state);
      }
   }
   
   void CTrend(string name, double price, datetime start, datetime end, ENUM_LINE_STYLE lineStyle, color lineColor){
      CTrend(name, price, start, end, lineStyle, lineColor, DefWidth);
   }
   
   void CTrend(string name, double price, datetime start, datetime end, ENUM_LINE_STYLE lineStyle, color lineColor, int width){
      CTrend(name, price, start,end, lineStyle, lineColor, width, DefHidden, DefRay, DefSelectable);
   }
   
   void CTrend(string name, double price, datetime start, datetime end, ENUM_LINE_STYLE lineStyle, color lineColor, int width, bool hidden, bool ray, bool selectable){
      FName(name);
      if (ObjectFind(0, name) < 0) {
         bool retVal = ObjectCreate(0, name, OBJ_TREND, 0, start, price, end, price);
         if (!retVal) Print("Error | Can't create trend: ", name, " Code: ", GetLastError());
         }
         
      Col(lineColor);
      LineStyle(lineStyle);
      Ray(ray);
      Hidden(hidden);
      Selectable(selectable);
      Width(width);
      
   }
   
   void CRect(string name, double high, double low, datetime start, datetime end, color BGColor){
      // kill box main box
      CRect(name, high, low, start, end, BGColor, DefBorder, DefHidden, DefSelectable, DefBack);
   }
   
   void CRect(string name, double high, double how, datetime start, datetime end, color Color, ENUM_BORDER_TYPE border, bool hidden, bool selectable, bool back){
      FName(name);
      if (ObjectFind(0, name) < 0) {
         bool retVal = ObjectCreate(0, name, OBJ_RECTANGLE, 0, start, high, end, how);
         if (!retVal) Print("Error | Can't create rect: ", name, " Code: ", GetLastError());
         }
      Col(Color);
      BorderType(border);
      Back(back);
      Hidden(hidden);
      Selectable(selectable);
   }
   
   
   void CRect(string name, int XDist, int YDist, int XSize, int YSize){
      //kill box bg
      CRect(name, XDist, YDist, XSize, YSize, DefCorner, DefBGColor, DefBorder, DefHidden, DefSelectable, DefBack);
   }
   
   void CRect(string name, int XDist, int YDist, int XSize, int YSize, color BGColor){
      //kill box bg
      CRect(name, XDist, YDist, XSize, YSize, DefCorner, BGColor, DefBorder, DefHidden, DefSelectable, DefBack);
   }
   
   void CRect(string name, int xDist, int yDist, int xSize, int ySize, ENUM_BASE_CORNER corner, color Col, ENUM_BORDER_TYPE border, bool hidden, bool selectable, bool back){
      FName(name);
      if (ObjectFind(0, name) < 0) {
         bool retVal = ObjectCreate(0, name, OBJ_RECTANGLE_LABEL,0,0,0);
         if (!retVal) Print("Error | Can't create rect: ", name, " Code: ", GetLastError());
         }
         
      XDist(xDist);
      YDist(yDist);
      XSize(xSize);
      YSize(ySize);
      Corner(corner);
      BGCol(Col);
      BorderType(border);
      Back(back);
      Hidden(hidden);
      Selectable(selectable);
      
   }
   
   void CRectLabel(string name, int width, int height){
      CRectLabel(name, DefXDist, DefYDist, width, height);
   }
   
   void CRectLabel(string name, int x, int y, int width, int height) {
      CRectLabel(name, x, y, width, height, DefCorner, DefBGColor, DefBorder, DefBordColor, DefLineStyle, DefWidth);
   }
   
   void CRectLabel(string name, int x, int y, int width, int height,  color BGColor, color BordColor){
      CRectLabel(name, x, y, width, height, DefCorner, BGColor, DefBorder, BordColor, DefLineStyle, DefWidth, DefBack, DefSelectable, DefHidden);
   }
   
   void CRectLabel(string name, int x, int y, int width, int height, ENUM_BORDER_TYPE border, color BordColor, ENUM_LINE_STYLE lineStyle, int lineWidth){
      CRectLabel(name, x, y, width, height, DefCorner, DefBGColor, border, BordColor, lineStyle, lineWidth, DefBack, DefSelectable, DefHidden);
   }
   
   void CRectLabel(string name, int x, int y, int width, int height, ENUM_BASE_CORNER corner, color BGColor, ENUM_BORDER_TYPE borderType, color BordColor, ENUM_LINE_STYLE lineStyle, int lineWidth){
      CRectLabel(name, x, y, width, height, corner, BGColor, borderType, BordColor, lineStyle, lineWidth, DefBack, DefSelectable, DefHidden);
   }
   
   void CRectLabel(string name, int x, int y, int width, int height, ENUM_BASE_CORNER corner, color BGColor, ENUM_BORDER_TYPE borderType, color BordCol, ENUM_LINE_STYLE lineStyle, int lineWidth, bool back, bool selectable, bool hidden){
      FName(name);
      if (ObjectFind(0, name) < 0) {
         bool retVal = ObjectCreate(0, name, OBJ_RECTANGLE_LABEL,0,0,0);
         if (!retVal) Print("Error | Can't create rect: ", name, " Code: ", GetLastError());
         }
         
      XDist(x);
      XSize(width);
      YDist(y);
      YSize(height);
      Corner(corner);
      BGCol(BGColor);
      BorderType(borderType);
      BordColor(BordCol);
      LineStyle(lineStyle);
      Width(lineWidth);
      Back(back);
      Hidden(hidden);
      Selectable(selectable);
      
   }
   
   void CText(string name, string labelString, datetime date, double price){
      CText(name, labelString, date, price, DefFontSize, DefFontCol);
   }
   
   void CText(string name, string labelString, datetime date, double price, int fontSize, color fontColor){
      CText(name, labelString, date, price, fontSize, fontColor, DefAnchor, DefSelectable, DefHidden, DefBack);
   }
   
   void CText(string name, string labelString, datetime date, double price, int fontSize, color fontColor, ENUM_ANCHOR_POINT anchor){
      CText(name, labelString, date, price, fontSize, fontColor, anchor, DefSelectable, DefHidden, DefBack);
   }
   
   void CText(string name, string labelString, datetime date, double price, int fontSize, color fontColor, ENUM_ANCHOR_POINT anchor, bool selectable, bool hidden, bool back){
      FName(name);
      if (ObjectFind(0, name) < 0) {
         bool retVal = ObjectCreate(0 ,name ,OBJ_TEXT ,0 ,date ,price);
         if (!retVal) Print("Error | Can't create text: ", name, " Code: ", GetLastError());
         }
         
      Text(labelString);
      FontSize(fontSize);
      Col(fontColor);
      Selectable(selectable);
      Anchor(anchor);
      Hidden(hidden);
      Back(back);
      
   }
   
   void CButton(string name, int x, int y, int width, int height, int fontSize, string text){
      CButton(name, x, y, width, height, fontSize, text, DefFontCol, DefButtonBGCol, DefBordColor, DefZOrder);
   }
   
   void CButton(string name, int x, int y, int width, int height, color Color, color BGColor, color BordColor, bool state){
      CButton(name, x, y, width, height, DefFontSize, "", DefCorner, Color, BGColor, BordColor, DefHidden, 0, state);
   }
   
   void CButton(string name, int x, int y, int width, int height, int fontSize, string text, color Color, color BGColor, color BordColor){
      CButton(name, x, y, width, height, fontSize, text, DefCorner, Color, BGColor, BordColor, DefHidden, 0, DefState);
   }
   
   void CButton(string name, int x, int y, int width, int height, int fontSize, string text, color Color, color BGColor, color BordColor, long zOrd){
      CButton(name, x, y, width, height, fontSize, text, DefCorner, Color, BGColor, BordColor, DefHidden, zOrd, DefState);
   }
    
   
   void CButton(string name, int x, int y, int width, int height, int fontSize, string text, ENUM_BASE_CORNER corner, color Color, color BGColor, color BordCol, bool hidden, long zOrd, bool state){
      FName(name);
      if (ObjectFind(0, name) < 0) {
         bool retVal = ObjectCreate(0, name, OBJ_BUTTON,0,0,0);
         if (!retVal) Print("Error | Can't create button: ", name, " Code: ", GetLastError());
      }
      
      
      XDist(x);
      XSize(width);
      YDist(y);
      YSize(height);
      Corner(corner);
      FontSize(fontSize);
      Text(text);
      Col(Color);
      BGCol(BGColor);
      BordColor(BordCol);
      Hidden(hidden);
      ZOrder(zOrd);
      State(state);

   }
   
   
   
   void CTextLabel(string name, int x, int y, string labelText){
      CTextLabel(name, x, y, labelText, DefFontStyle, DefFontSize, DefFontCol);
   }
   
   void CTextLabel(string name, int x, int y, string labelText, int fontSize){
      CTextLabel(name, x, y, labelText, DefFontStyle, fontSize, DefFontCol);
   }
   
   void CTextLabel(string name, int x, int y, string labelText, string fontStyle, int fontSize, color fontColor){
      CTextLabel(name, x, y, DefCorner, labelText, fontStyle, fontSize, fontColor, DefAnchor, DefBack, DefSelectable, DefHidden);
   }
   
   void CTextLabel(string name, int x, int y, ENUM_BASE_CORNER corner, string labelText, string fontStyle, int fontSize, color fontColor, ENUM_ANCHOR_POINT anchor, bool back, bool selectable, bool hidden){
      FName(name);
      if (ObjectFind(0, name) < 0) {
         bool retVal = ObjectCreate(0, name, OBJ_LABEL,0,0,0);
         if (!retVal) Print("Error | Can't create label: ", name, " Code: ", GetLastError());
      }
      
      
      XDist(x);
      YDist(y);
      Corner(corner);
      FontSize(fontSize);
      Text(labelText);
      Font(fontStyle);
      Col(fontColor);
      Anchor(anchor);
      Back(back);
      Selectable(selectable);
      Hidden(hidden);

   }
   
   void CEdit(string name, int x, int y, int width, int height, int fontSize, string labelText, color textCol, color bgCol, color bordCol, bool readOnly){
      CEdit(name, x, y, width, height, DefCorner, fontSize, DefFontStyle, labelText, DefAlign, textCol, bgCol, bordCol, DefBack, DefHidden, readOnly);
   }
   
   void CEdit(string name, int x, int y, int width, int height, ENUM_BASE_CORNER corner, int fontSize, string fontStyle, string labelText, ENUM_ALIGN_MODE align, color textCol, color bgCol, color bordCol, bool back, bool hidden, bool readOnly){
      FName(name);
      if (ObjectFind(0, name) < 0){
         bool retVal = ObjectCreate(0, name, OBJ_EDIT, 0, 0, 0);
         if (!retVal) Print("Error | Can't create object: ", name, " Code: ", GetLastError());
      }
      XDist(x);
      YDist(y);
      XSize(width);
      YSize(height);
      Corner(corner);
      FontSize(fontSize);
      Font(fontStyle);
      Text(labelText);
      Align(align);
      Col(textCol);
      BGCol(bgCol);
      BordColor(bordCol);
      Back(back);
      Hidden(hidden);
      ReadOnly(readOnly);
      
      
      
   }
   


};


//Default Constructor
//Runs when the class is called
CObjects::CObjects(void){
   DefLineCol     = clrRed;
   DefFontCol     = clrWhite;
   DefCorner      = CORNER_LEFT_LOWER;
   DefFontSize    = 8;
   DefXDist       = 10;
   DefYDist       = 150;
   DefBGColor     = clrDimGray;
   DefBorder      = BORDER_RAISED;
   DefLineStyle   = STYLE_SOLID;
   DefWidth       = 1;
   DefRay         = false;
   DefHidden      = true;
   DefBack        = false;
   DefSelectable  = false;
   DefAnchor      = ANCHOR_LEFT;
   DefBordColor   = clrGray;
   DefFontStyle   = "Calibri";
   DefBold        = false;
   DefZOrder      = 0;
   DefAlign       = ALIGN_CENTER;
   DefState       = false;
}

//Parametric Constructor
CObjects::CObjects(int x, int y, color lineCol, color fontCol, color bgCol, color buttonCol, color bordCol, string fontStyle, int fontSize){
   DefCorner      = CORNER_LEFT_LOWER;
   DefFontSize    = fontSize;
   DefXDist       = x;
   DefYDist       = y;
   DefBorder      = BORDER_RAISED;
   DefLineStyle   = STYLE_SOLID;
   DefWidth       = 1;
   DefRay         = false;
   DefHidden      = true;
   DefBack        = false;
   DefSelectable  = false;
   DefAnchor      = ANCHOR_LEFT;
   DefLineCol     = lineCol;
   DefFontCol     = fontCol;
   DefBGColor     = bgCol;
   DefButtonBGCol = buttonCol;
   DefBordColor   = bordCol;
   DefFontStyle   = fontStyle;
   DefBold        = false;
   DefZOrder      = 0;
   DefAlign       = ALIGN_CENTER;
   DefState       = false;
}

//Parametric Constructor
CObjects::CObjects(int x, int y, int fontSize, int scaleFactor){
   DefCorner      = CORNER_LEFT_LOWER;
   DefFontSize    = fontSize;
   DefXDist       = x;
   DefYDist       = y;
   DefBorder      = BORDER_RAISED;
   DefLineStyle   = STYLE_SOLID;
   DefWidth       = 1;
   DefRay         = false;
   DefHidden      = true;
   DefBack        = false;
   DefSelectable  = false;
   DefAnchor      = ANCHOR_LEFT;
   DefLineCol     = clrRed;
   DefFontCol     = clrWhite;
   DefBGColor     = clrBlack;
   DefButtonBGCol = clrGray;
   DefBordColor   = clrGray;
   DefFontStyle   = "Calibri";
   DefBold        = false;
   DefZOrder      = 0;
   DefAlign       = ALIGN_CENTER;
   DefState       = false;
   DefScaleFactor = scaleFactor;
}









   

bool CObjects::Col(color col){ return ObjectSetInteger(0, FName(), OBJPROP_COLOR, col); }
bool CObjects::LineStyle(ENUM_LINE_STYLE style) { return ObjectSetInteger(0, FName(), OBJPROP_STYLE, style); }
bool CObjects::Ray(bool ray) { return ObjectSetInteger(0, FName(), OBJPROP_RAY, ray); }
bool CObjects::Hidden(bool hidden) { return ObjectSetInteger(0, FName(), OBJPROP_HIDDEN, hidden); }
bool CObjects::Selectable(bool selectable) { return ObjectSetInteger(0, FName(), OBJPROP_SELECTABLE, selectable);}
bool CObjects::Width(int width) { return ObjectSetInteger(0, FName(), OBJPROP_WIDTH, width); }

bool CObjects::BorderType(ENUM_BORDER_TYPE border) { return ObjectSetInteger(0, FName(), OBJPROP_BORDER_TYPE, border); }
bool CObjects::Back(bool back){ return ObjectSetInteger(0, FName(), OBJPROP_BACK, back);}

bool CObjects::XDist(int xDist) { return  ObjectSetInteger(0, FName(), OBJPROP_XDISTANCE, scale(xDist));}
bool CObjects::YDist(int yDist) { return ObjectSetInteger(0, FName(), OBJPROP_YDISTANCE,scale(yDist)); }
bool CObjects::XSize(int xSize) { return ObjectSetInteger(0, FName(), OBJPROP_XSIZE,scale(xSize)); }
bool CObjects::YSize(int ySize) { return ObjectSetInteger(0, FName(), OBJPROP_YSIZE,scale(ySize)); }
bool CObjects::Corner(ENUM_BASE_CORNER corner) { return ObjectSetInteger(0, FName(), OBJPROP_CORNER,corner);}
bool CObjects::BGCol(color col) { return ObjectSetInteger(0, FName(), OBJPROP_BGCOLOR,col);}

bool CObjects::BordColor(color col){ return ObjectSetInteger(0, FName(), OBJPROP_BORDER_COLOR, col); }

bool CObjects::FontSize(int fontSize) { return ObjectSetInteger(0, FName(), OBJPROP_FONTSIZE, fontSize); } 
bool CObjects::Text (string text) { return ObjectSetString(0, FName(), OBJPROP_TEXT, text); } 

bool CObjects::Anchor(ENUM_ANCHOR_POINT anchor) { return ObjectSetInteger(0, FName(), OBJPROP_ANCHOR, anchor); }
bool CObjects::Font(string fontStyle) { return ObjectSetString(0, FName(), OBJPROP_FONT, fontStyle); }

bool CObjects::ZOrder(long zOrder) { return ObjectSetInteger(0, FName(), OBJPROP_ZORDER, zOrder); }


bool CObjects::Align(ENUM_ALIGN_MODE align){ return ObjectSetInteger(0, FName(), OBJPROP_ALIGN, ALIGN_CENTER); }

bool CObjects::State(bool state) { return ObjectSetInteger(0, FName(), OBJPROP_STATE, state);}

bool CObjects::ReadOnly(bool readOnly) { return ObjectSetInteger(0, FName(), OBJPROP_READONLY, readOnly); }