#include <cstdio>

int main()
{
    auto json = 
        "{"
          "\"list\": ["
            "{"
              "\"id\": 1,"
              "\"title\": \"response from main.cpp\","
              "\"term\": \"2018-03-20T19:32:00+0900\""
            "},"
            "{"
              "\"id\": 2,"
              "\"title\": \"good luck !!!\","
              "\"term\": \"2018-03-20T19:32:00+0900\""
            "}"
          "]"
        "}";

    puts(json);
    return 0;
}