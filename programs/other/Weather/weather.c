/* Copyright (C) 2019-2021 Logaev Maxim (turbocat2001), GPLv2 */

/*
    Info: App uses api from openweathermap.org. 
    The standard configuration uses my token and the city of Moscow. 
    You can always change it in the weather.json file.
    If you use UTF-8 encoding, then city names can be entered in different languages!
*/

#include <stdio.h>
#include <string.h>
#include "json/json.h"
#include <kos32sys1.h>
#include <kolibrisys.h>
#include <clayer/http.h>
#include <clayer/libimg.h>

#define VERSION  "Weather 1.4"

enum BUTTONS{
    BTN_QUIT = 1,
    BTN_UPDATE = 2
};

#define START_YPOS 34
#define UTF8_W 8
#define CP866_W 6
#define JSON_OBJ(X) value->u.object.values[X]
#define OK 200

unsigned WINDOW_W = 230;

#define API       "api.openweathermap.org/data/2.5/weather?q=%s&appid=%s&units=%s&lang=%s"
#define IMAGE_URL "openweathermap.org/img/w/%s.png"
  
Image *blend;

unsigned char char_size=1;

char *wind_speed_str, *pressure_str, *visibility_str, *humidity_str, *update_str, *wind_deg_str;
        
char lang[3]="en";
char format_temp_str[6];
char full_url[512];
char full_url_image[256];

char temp_char='K';

struct kolibri_system_colors sys_color_table;

pos_t win_pos; 

#pragma pack(push,1)
struct open_weather_data{
    char    City[100];
    int     wind_speed;
    int     wind_deg;
    int     pressure;
    int     humidity;
    char    weath_desc[100];
    int     visibility;
    int     timezone;
    char    image_code[4];
    int     temp;
}myw;
#pragma pack(pop)

void notify_show(char *text)
{
   start_app("/sys/@notify", text);
}

void* safe_malloc(size_t size)
{
    void *p=user_alloc(size);
    if(p==NULL){
       notify_show("'Memory allocation error!' -E");
       exit(0);
    }else{
        return p;
    }
}

char tmp_buff[100];

void draw_format_text_sys(int x, int y, color_t color, const char *format_str, ... )
{
    va_list ap;
    va_start (ap, format_str);
    vsnprintf(tmp_buff, sizeof tmp_buff ,format_str, ap);
    va_end(ap);
    draw_text_sys(tmp_buff, x, y , 0, color);
}

void find_and_set(json_value *value, struct open_weather_data* weather)
{
    for(int i=0; i<value->u.object.length; i++){
        if(!strcmp(JSON_OBJ(i).name, "main")){
            if(JSON_OBJ(i).value->u.object.values[0].value->type==json_double)
            {
                weather->temp = (int)JSON_OBJ(i).value->u.object.values[0].value->u.dbl;
            }else{
                weather->temp = JSON_OBJ(i).value->u.object.values[0].value->u.integer;
            }
            weather->pressure = JSON_OBJ(i).value->u.object.values[4].value->u.integer;
            weather->humidity = JSON_OBJ(i).value->u.object.values[5].value->u.integer;
        }
        if(!strcmp(JSON_OBJ(i).name, "name")){
            strcpy(weather->City,JSON_OBJ(i).value->u.string.ptr);
        }
        if(!strcmp(JSON_OBJ(i).name, "weather")){
           strcpy(weather->weath_desc, JSON_OBJ(i).value->u.array.values[0]->u.object.values[2].value->u.string.ptr);
           strcpy(weather->image_code, JSON_OBJ(i).value->u.array.values[0]->u.object.values[3].value->u.string.ptr);
        }
        if(!strcmp(JSON_OBJ(i).name, "wind")){
            weather->wind_deg = JSON_OBJ(i).value->u.object.values[1].value->u.integer;
            if(JSON_OBJ(i).value->u.object.values[0].value->type==json_double)
            {
                weather->wind_speed = (int)JSON_OBJ(i).value->u.object.values[0].value->u.dbl;
            }else{
                weather->wind_speed = JSON_OBJ(i).value->u.object.values[0].value->u.integer;
            }  
        }
        if(!strcmp(JSON_OBJ(i).name, "visibility")){
            weather->visibility = JSON_OBJ(i).value->u.integer;
        }
        if(!strcmp(JSON_OBJ(i).name, "timezone")){
            weather->timezone = JSON_OBJ(i).value->u.integer/60/60;
        }
        if(!strcmp(JSON_OBJ(i).name, "message")){
            char *errmsg = safe_malloc(weather->timezone = JSON_OBJ(i).value->u.string.length+6);
            sprintf(errmsg,"'%s!' -E", JSON_OBJ(i).value->u.string.ptr);
            notify_show(errmsg);
            user_free(errmsg);
        }
    }
}

http_msg* get_json(char *City, char *Token, char* Units)
{
    sprintf(full_url, API, City, Token, Units, lang);
    http_msg *h = http_get(full_url, 0,  HTTP_FLAG_BLOCK, "");
    http_long_receive(h);
    if (h->status == OK || h->status == 404) {
        return h;
    } else {
        user_free(h->content_ptr);
        user_free(h);
        return NULL;
    }
}

void get_image(){  // Функция загрузки изображения
    sprintf(full_url_image, IMAGE_URL, myw.image_code);
    http_msg *h= http_get(full_url_image, 0,  HTTP_FLAG_BLOCK, "");
    http_long_receive(h);
    
    if (h->status == OK) {
        Image *image = img_decode(h->content_ptr, h->content_length, 0); // Decode RAW data to Image data
        if (image->Type != IMAGE_BPP32) { 
            image = img_convert(image, NULL, IMAGE_BPP32, 0, 0); // Convert image to format BPP32
                if (!image) {
                notify_show("'Convetring image error!' -E");  
                exit(0);
            }
        }
        blend = img_create(64, 64, IMAGE_BPP32);  // Create an empty layer
        img_fill_color(blend, 64, 64, sys_color_table.work_area); // Fill the layer with one color
        Image* image2 = img_scale(image, 0, 0, 50, 50, NULL, LIBIMG_SCALE_STRETCH , LIBIMG_INTER_BILINEAR, 64, 64);
        img_blend(blend, image2, 0, 0, 0, 0, 64, 64);  // Blending images to display the alpha channel. 
        // Уничтожаем ненужные структуры изображений
        img_destroy(image); 
        img_destroy(image2);
    }else{
       notify_show("'Image not loaded!!' -W"); 
    } 
    user_free(h->content_ptr);
    user_free(h);
    h=NULL;
}

void RedrawGUI() // Перересовываем интерфейс
{
    begin_draw();   // Начинам прорисовку
    
    int new_win_w = (strlen(myw.City)/char_size+10)*(UTF8_W+char_size-1); // Если название города не влезает
    if(new_win_w<WINDOW_W){
        new_win_w=WINDOW_W;
    }
    // Рисуем окно
    sys_create_window(win_pos.x, win_pos.y, new_win_w, START_YPOS+220, VERSION, sys_color_table.work_area, 0x14);
    // Выводим жирным шрифтом название локации и временной зоны
    draw_format_text_sys(20, START_YPOS, 0xB0000000 | sys_color_table.work_text, "%s (UTC%+d)", myw.City, myw.timezone);
    draw_format_text_sys(21, START_YPOS, 0xB0000000 | sys_color_table.work_text, "%s (UTC%+d)", myw.City, myw.timezone);
    // Выводим изображение
    img_draw(blend, 10, START_YPOS+30, 64,64,0,0);
    // Выводим жирным шрифтом название локации и временной зоны
    draw_format_text_sys(20, START_YPOS+20, 0xb0000000 | sys_color_table.work_text, myw.weath_desc);
    draw_format_text_sys(21, START_YPOS+20, 0xb0000000 | sys_color_table.work_text, myw.weath_desc);
    // Выводим жирным шрифтом название локации и временной зоны
    draw_format_text_sys(100, START_YPOS+45, 0xb1000000 | sys_color_table.work_text, format_temp_str, myw.temp);  
    draw_format_text_sys(101, START_YPOS+46, 0xb1000000 | sys_color_table.work_text, format_temp_str, myw.temp);
    // Выводим обычным шрифтом
    draw_format_text_sys(20, START_YPOS+80,  0xb0000000 | sys_color_table.work_text, pressure_str,myw.pressure);
    draw_format_text_sys(20, START_YPOS+100, 0xb0000000 | sys_color_table.work_text, humidity_str, myw.humidity, "%");
    draw_format_text_sys(20, START_YPOS+120, 0xb0000000 | sys_color_table.work_text, wind_speed_str, myw.wind_speed);
    draw_format_text_sys(20, START_YPOS+140, 0xb0000000 | sys_color_table.work_text, wind_deg_str, myw.wind_deg);
    draw_format_text_sys(20, START_YPOS+160, 0xb0000000 | sys_color_table.work_text, visibility_str, myw.visibility);
    // Определяем кнопку
    define_button(X_W(new_win_w/2-60,120), Y_H(START_YPOS+180,30), BTN_UPDATE, sys_color_table.work_button);
    draw_text_sys(update_str, (new_win_w/2)-(UTF8_W*strlen(update_str)/2/char_size), START_YPOS+190, 0, 0xb0000000 | sys_color_table.work_button_text);
    end_draw();
}

void get_config(char **City, char **Token, char **Units) // Загружаем конфиг 
{
    FILE *config_j = fopen("weather.json", "rb"); 
    if(config_j==NULL){
        notify_show("'Configuration file not found!' -E");
        exit(0);
    }
    size_t size = _ksys_get_filesize("weather.json"); // Получаем размер файла
    char *config_buff = safe_malloc(size+1);
    if(size != fread(config_buff, sizeof(char), size, config_j)){
        notify_show("'The configuration file was not fully read!' -E");
        exit(0);    
    }
    json_value* value =json_parse (config_buff, size); // Парсим конфиг
    for(int i=0; i<value->u.object.length; i++){
        if(!strcmp(JSON_OBJ(i).name, "Location")){   
            *City = JSON_OBJ(i).value->u.string.ptr;  // Получаем название города
        }
        if(!strcmp(JSON_OBJ(i).name, "Token")){
            *Token = JSON_OBJ(i).value->u.string.ptr; // Получаем токен
        }
        if(!strcmp(JSON_OBJ(i).name, "Celsius")){
            if(JSON_OBJ(i).value->u.boolean){
                *Units = "metric";
                temp_char = 'C';
            }else{
                *Units = "imperial";
                temp_char = 'F';
            }
        }
        if(!strcmp(JSON_OBJ(i).name, "Lang")){
            strncpy(lang, JSON_OBJ(i).value->u.string.ptr,2); // Получам язык
        }
    }
    if(*City==NULL || *Token ==NULL){
         notify_show("'Invalid config!' -E");
         exit(0);
    }
    user_free(config_buff);
    fclose(config_j);
}

void Update(char* city, char* token, char* units) // Обновление данных
{
    if(blend!=NULL){
        img_destroy(blend); // Уничтожение картинки с прозрачностью
        blend = NULL;
    }
    memset(&myw, 0, sizeof myw); // Обнуляем структуру
    strcpy(myw.City,"None"); 
    strcpy(myw.weath_desc,"unknown");
    http_msg *json_file = get_json(city, token, units); // Получаем данные о погоде в формате json 
    if(json_file != NULL){
        json_value* value=json_parse (json_file->content_ptr, json_file->content_length); // Парсим json файл
        find_and_set(value, &myw);  //  Ищем значения в json
        sprintf(format_temp_str, "%s°%c","%d",temp_char); // Формируем строку для вывода температуры
        get_image(); // Получаем изображение
        json_value_free(value); // Очищаем  ненужные данные
        user_free(json_file->content_ptr);
        user_free(json_file);
    }else{
       notify_show("'Connection error!' -E");
    }
}

void set_lang()
{
    if(!strcmp(lang, "ru")){
        wind_speed_str = "Скорость ветра:    %d м/с";
        pressure_str   = "Давление:          %d гПa";
        visibility_str = "Видимость:         %d м";
        humidity_str   = "Влажность:         %d %s";
        update_str     = "Обновить";
        wind_deg_str   = "Направление ветра: %d°";
        WINDOW_W = 250;
        char_size = 2;
    }else if(!strcmp(lang, "de")){
        wind_speed_str = "Windgeschwindigkeit: %d m/s";
        pressure_str   = "Druck:               %d hPa";
        visibility_str = "Sichtbarkeit:        %d m";
        humidity_str   = "Luftfeuchtigkeit:    %d %s";
        wind_deg_str   = "Windrichtung         %d°";
        WINDOW_W = 270;
        update_str     = "Aktualisieren";
    }else{
        pressure_str   = "Pressure:       %d hPa";
        humidity_str   = "Humidity:       %d %s";
        visibility_str = "Visibility:     %d m";
        wind_speed_str = "Wind speed:     %d m/s";
        wind_deg_str   = "Wind direction: %d°";
        update_str     = "Refresh";
    }
}

int main(){
    win_pos = get_mouse_pos(0); // Получаем позицию курсора
    if(!kolibri_libimg_init()){ // Загружаем libimg.obj
        notify_show("Libimg.obj not loaded!' -E");  
        exit(0);
    }
    get_system_colors(&sys_color_table); // Получаем таблица цветов

    char *City, *Token, *Units; // Указатели на токен, название города, систему мер

    get_config(&City, &Token, &Units); // Загружаем конфиг
    set_lang();  // Установить язык приложения
    Update(City,Token, Units);  // Обновить данные

    while(1){
        switch(get_os_event()){ // Получаем системное событие
            case KOLIBRI_EVENT_NONE:    // Нет события
                break;
            case KOLIBRI_EVENT_REDRAW:  // Событие перерисовки
                RedrawGUI();
                break;        
            case KOLIBRI_EVENT_BUTTON:  // Событие кнопок
                switch (get_os_button()){
                    case BTN_UPDATE:    // Кнопка обновить
                        Update(City, Token, Units);
                        RedrawGUI();
                        break;
                    case BTN_QUIT:      // Кнопка выхода
                        exit(0);
                        break;
                }
        }
    }
    return 0;
}
