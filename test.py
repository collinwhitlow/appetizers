from PIL import Image 
boxes = [[[427, 79], [515, 79], [515, 181], [427, 181]], [[845, 51], [942, 51], [942, 163], [845, 163]], [[620, 38], [716, 38], [716, 149], [620, 149]], [[196, 90], [287, 90], [287, 196], [196, 196]], [[62, 12], [173, 12], [173, 141], [62, 141]], [[1040, 47], [1148, 47], [1148, 173], [1040, 173]]]
counter = 0
# get right, left, top, bottom bounds
for box in boxes:
    x_cords = []
    y_cords = []
    for bound in box:
        x_cords.append(bound[0])
        y_cords.append(bound[1])

    img = Image.open("friends.jpeg") 

    # get right, left, top, bottom bounds
    x = min(x_cords)
    y = min(y_cords)
    w = max(x_cords) - min(x_cords)	
    h = max(y_cords) - min(y_cords)
    tmp_file = "outFolder/friends_out"
    img_res = img.crop((x, y, x+w, y+h)) 
    img_res = img_res.save(tmp_file + str(counter) + ".png")
    counter += 1