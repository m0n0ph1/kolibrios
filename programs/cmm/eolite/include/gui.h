
void Scroll() {
	dword i;

	dword sc_x = files.x + files.w;
	dword sc_y = files.y;
	dword sc_h = files.h - 16;
	dword sc_slider_y;
	dword sc_center;

	if (files.count<=0)
	{
		sc_slider_y = sc_y;
		sc_slider_h = sc_h - 1;
	}
	else
	{
		sc_slider_y = files.first * sc_h / files.count + sc_y;
		sc_slider_h = sc_h * files.visible - files.visible / files.count;
		if (sc_slider_h < 20) sc_slider_h = 20; //minimal scroll width
		if (sc_slider_h > sc_h-sc_slider_y+56) || (files.first+files.visible>=files.count) sc_slider_y= sc_y + sc_h - sc_slider_h - 1; //��� �������� ������ 
	}
	//slider
	DrawRectangle(sc_x,sc_slider_y,16,sc_slider_h,sc.work_graph);
	DrawRectangle3D(sc_x+1,sc_slider_y+1,14,sc_slider_h-2, sc.work_light , sc.work_dark);
	if (!scroll_used) for (i=0; i<13; i++) DrawBar(sc_x + 2 + i, sc_slider_y+2, 1, sc_slider_h-3, col.work_gradient[13-i]);
	if (scroll_used)  for (i=0; i<13; i++) DrawBar(sc_x + 2 + i, sc_slider_y+2, 1, sc_slider_h-3, col.work_gradient[i]);

	sc_center = sc_slider_h / 2 + sc_slider_y;

	DrawBar(sc_x+4,   sc_center-3, 8,  1, sc.work_graph);
	DrawBar(sc_x+4+1, sc_center-2, 8,  1, sc.work_light);

	DrawBar(sc_x+3,   sc_center,   10, 1, sc.work_graph);
	DrawBar(sc_x+3+1, sc_center+1, 10, 1, sc.work_light);

	DrawBar(sc_x+4,   sc_center+3, 8,  1, sc.work_graph);
	DrawBar(sc_x+4+1, sc_center+4, 8,  1, sc.work_light);

	//area before slider
	if (sc_slider_y > sc_y + 1) 
	{
		DrawBar(sc_x+1, sc_y,   15, 1, col.slider_bg_left);
		DrawBar(sc_x+1, sc_y+1,  1, sc_slider_y-sc_y-1, col.slider_bg_left);
		DrawBar(sc_x+2, sc_y+1, 14, sc_slider_y-sc_y-1, col.slider_bg_big);
	}
	//area after slider
	if (sc_h-sc_slider_h+sc_y-2>sc_slider_y)
	{
		DrawBar(sc_x+1, sc_slider_y + sc_slider_h+1, 15, 1, col.slider_bg_left);
		DrawBar(sc_x+1, sc_slider_y + sc_slider_h+2,  1, sc_h-sc_slider_h-sc_slider_y+sc_y-2, col.slider_bg_left);
		DrawBar(sc_x+2, sc_slider_y + sc_slider_h+2, 14, sc_h-sc_slider_h-sc_slider_y+sc_y-2, col.slider_bg_big);
	}
}

void DrawFlatButtonSmall(dword x,y,width,height,id,text)
{
	DrawRectangle(x,y,width,height,sc.work_graph);
	DrawRectangle3D(x+1,y+1,width-2,height-2, sc.work_light, sc.work_dark);
	PutPixel(x+width-1, y+1, sc.work_dark);
	DrawFilledBar(x+2, y+2, width-3, height-3);
	if (id) DefineHiddenButton(x+1,y+1,width-2,height-2,id);
	WriteText(-strlen(text)*6+width/2+x+1,height/2+y-3,0x80,sc.work_text,text);
}

void DrawFilledBar(dword x, y, w, h)
{ int i; for (i=0; i<h; i++) DrawBar(x, y+h-i-1, w, 1, col.work_gradient[i]); }

int popin_w=260;
void DrawEolitePopup(dword b1_text, b2_text)
{
	int but_x;
	int popin_x = files.w - popin_w / 2 + files.x ;
	DrawPopup(popin_x, 160, popin_w, 95, 1, sc.work, sc.work_graph);
	but_x = DrawStandartCaptButton(popin_x+23, 215, POPUP_BTN1, b1_text);
	DrawStandartCaptButton(popin_x+23 + but_x, 215, POPUP_BTN2, b2_text);
}

void DrawDot(dword x,y) {
	dword col_pxl = MixColors(sc.work_graph, sc.work, 60);
	DrawBar(x+1,y,2,4,sc.work_graph);
	DrawBar(x,y+1,4,2,sc.work_graph);
	PutPixel(x,y,col_pxl);
	PutPixel(x+3,y,col_pxl);
	PutPixel(x,y+3,col_pxl);
	PutPixel(x+3,y+3,col_pxl);
}

void DrawCaptButtonSmallText(dword x,y,w,h,id,color_b, color_t,text)
{
	dword tx = -strlen(text)*6+w/2+x;
	dword ty = h/2-3+y;
	DefineButton(x,y,w,h,id,color_b);
	WriteText(tx,ty,0x80,color_t,text);
}