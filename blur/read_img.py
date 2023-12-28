from PIL import Image
import numpy
im = Image.open('image.jpg', 'r')
width, height = im.size
pixel_values = list(im.getdata())   
pixel_values = numpy.array(pixel_values).reshape((width, height, 3))
with open('image.txt','w') as f:
    f.write("{} {}\n".format(height, width))
    for i in range(height):
        for j in range(width):
            f.write("{} {} {}\n".format(pixel_values[j][i][0], pixel_values[j][i][1], pixel_values[j][i][2]))


f.close()
