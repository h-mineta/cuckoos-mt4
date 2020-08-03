// MIT License
// 
// Copyright (c) 2020 MINETA Hiroki
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#property copyright "h-mineta@0nyx.net"
#property link      "https://github.com/h-mineta/cuckoos-mt4"
#property version   "0.0.1"
#property strict
#property script_show_inputs
//--- input parameters
input string webhook_url="https://discordapp.com/api/webhooks/ID/TOKEN";

bool order_init = false;
int order_prev = 0; // Number of orders at the time of previous OnTrade() call

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   if (SendDiscord(webhook_url, NULL) == false) {
      return(INIT_FAILED);
   }

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if (order_init == false || order_prev != OrdersTotal()) {
      string message;
      message = StringFormat("```日時(Local) : %s\n残高　　　　 : %+10.1f%s\n有効証拠金　 : %+10.1f%s\n損益　　　　 : %+10.1f%s```", 
         TimeToString(TimeLocal(), TIME_DATE | TIME_SECONDS),
         AccountBalance(),
         AccountCurrency(),
         AccountEquity(),
         AccountCurrency(),
         AccountProfit(),
         AccountCurrency());
 
      SendDiscord(webhook_url, message);
      
      order_init = true;
      order_prev = OrdersTotal();
   }
}

//+------------------------------------------------------------------+
//| Expert SendDiscord function                                      |
//+------------------------------------------------------------------+
bool SendDiscord(const string url, const string message)
{
   string method = "GET";
   int status_code;
   string result_headers;
   char data[];
   char result[];
   
   if (message != NULL ) {
      StringToCharArray("content=" + message, data, 0, WHOLE_ARRAY, CP_UTF8);
      method = "POST";
   }
   status_code = WebRequest(method, webhook_url, NULL, NULL, 3000, data, 0, result, result_headers);
   
   printf("Webhook Status Code : %d(%s)", status_code, method);
   if (status_code == -1) {
      Print(GetLastError());
      return(false);
   } else if (status_code != 200 && status_code != 204) {
      return(false);
   }
   
   return(true);
}
//+------------------------------------------------------------------+
