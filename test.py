from PIL import Image 

img = Image.open("test_picture.png") 

# get right, left, top, bottom bounds
x = 0
y = 200
w = 100
h = 100

img_res = img.crop((x, y,x+ w,y+ h)) 
img_res = img_res.save("text_out1.png")