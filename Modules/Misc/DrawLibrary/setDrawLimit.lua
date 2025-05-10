local args = {...}
SCREEN_X,SCREEN_Y,SCREEN_WIDTH,SCREEN_HEIGHT = math.max(1,args[1]), math.max(1, args[2]), math.min(layer.w,args[3]), math.min(layer.h,args[4])